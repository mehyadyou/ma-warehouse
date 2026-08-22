import { Server } from 'socket.io';
import http from 'http';
import jwt from 'jsonwebtoken';
import { realtime } from './realtime';
import { env } from '../config/env';
import { getAllowedOrigins, isCorsAllowAll } from '../config/cors';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { assistantService } from '../manager/assistant/assistant.service';
import { assistantChatSchema } from '../manager/assistant/assistant.schema';

const JWT_SECRET = env.JWT_SECRET;

export async function initSocketServer(httpServer: http.Server) {
  const origins = getAllowedOrigins();
  const io = new Server(httpServer, {
    cors: !isCorsAllowAll()
      ? { origin: origins, methods: ['GET', 'POST'] }
      : { origin: '*', methods: ['GET', 'POST'] },
  });

  realtime.init(io);

  io.use(async (socket, next) => {
    const token = socket.handshake.auth?.token as string | undefined;
    if (!token) return next(new Error('احراز هویت نامعتبر'));
    try {
      const payload = jwt.verify(token, JWT_SECRET) as { id: string; ver?: number };
      const user = await prisma.user.findUnique({
        where: { id: payload.id },
        select: { isActive: true, deletedAt: true, role: true, warehouseId: true, tokenVersion: true },
      });
      if (!user || !user.isActive || user.deletedAt) return next(new Error('حساب غیرفعال است'));
      if (payload.ver !== undefined && payload.ver !== user.tokenVersion)
        return next(new Error('نشست منقضی شده'));

      socket.data.userId      = payload.id;
      socket.data.role        = user.role;
      socket.data.warehouseId = user.warehouseId ?? undefined;
      next();
    } catch {
      next(new Error('توکن نامعتبر'));
    }
  });

  io.on('connection', (socket) => {
    const { userId, role, warehouseId } = socket.data as {
      userId: string; role: string; warehouseId?: string;
    };

    logger.debug({ userId, role, warehouseId: warehouseId || null }, 'socket connected');

    socket.join(`user:${userId}`);
    socket.join(`role:${role}`);
    if (warehouseId) socket.join(`warehouse:${warehouseId}`);

    socket.on('disconnect', () => {
      logger.debug({ userId }, 'socket disconnected');
    });

    // ── دستیار هوش مصنوعی (فقط مدیر) — استریم کامل (reasoning + پاسخ) ──
    let assistantBusy = false;
    const assistantAbort = new AbortController();
    // محدودیت نرخ سبک: ۱۰ درخواست در دقیقه به ازای هر سوکت
    let assistantAskTimes: number[] = [];
    socket.on('assistant:ask', async (payload: unknown) => {
      if (role !== 'MANAGER') {
        socket.emit('assistant:error', { error: 'فقط مدیر به دستیار دسترسی دارد' });
        return;
      }
      if (assistantBusy) {
        socket.emit('assistant:error', { error: 'در حال پاسخ‌دهی به درخواست قبلی هستید' });
        return;
      }
      const now = Date.now();
      assistantAskTimes = assistantAskTimes.filter((t) => now - t < 60_000);
      if (assistantAskTimes.length >= 10) {
        socket.emit('assistant:error', { error: 'تعداد درخواست‌ها زیاد است؛ کمی صبر کنید' });
        return;
      }
      assistantAskTimes.push(now);
      const parsed = assistantChatSchema.safeParse(payload);
      if (!parsed.success) {
        socket.emit('assistant:error', { error: 'پیام نامعتبر است' });
        return;
      }
      assistantBusy = true;
      try {
        const { answer } = await assistantService.chatStream(parsed.data, {
          onToken: (text) => socket.emit('assistant:token', { text }),
          onStatus: (text) => socket.emit('assistant:status', { text }),
          signal: assistantAbort.signal,
        });
        socket.emit('assistant:done', { fullText: answer });
      } catch (e) {
        socket.emit('assistant:error', { error: (e as Error)?.message ?? 'خطای داخلی دستیار' });
      } finally {
        assistantBusy = false;
      }
    });

    socket.on('disconnect', () => {
      // اگر مدیر وسط پاسخ صفحه را ترک کرد، تولید توکن متوقف شود
      assistantAbort.abort();
    });
  });

  return io;
}
