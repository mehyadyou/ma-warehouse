import { Server } from 'socket.io';
import http from 'http';
import jwt from 'jsonwebtoken';
import { realtime } from './realtime';
import { env } from '../config/env';
import { getAllowedOrigins } from '../config/cors';

const JWT_SECRET = env.JWT_SECRET;

export async function initSocketServer(httpServer: http.Server) {
  const origins = getAllowedOrigins();
  const io = new Server(httpServer, {
    cors: origins.length > 0
      ? { origin: origins, methods: ['GET', 'POST'] }
      : { origin: '*', methods: ['GET', 'POST'] },
  });

  realtime.init(io);

  io.use((socket, next) => {
    const token = socket.handshake.auth?.token as string | undefined;
    if (!token) return next(new Error('احراز هویت نامعتبر'));
    try {
      const payload = jwt.verify(token, JWT_SECRET) as { id: string; role: string; warehouseId?: string };
      socket.data.userId      = payload.id;
      socket.data.role        = payload.role;
      socket.data.warehouseId = payload.warehouseId;
      next();
    } catch (err) {
      console.log('خطا در verify کردن JWT:', err);
      next(new Error('توکن نامعتبر'));
    }
  });

  io.on('connection', (socket) => {
    const { userId, role, warehouseId } = socket.data as {
      userId: string; role: string; warehouseId?: string;
    };

    console.log(`Socket متصل شد: User ${userId}, Role: ${role}, Warehouse: ${warehouseId || 'N/A'}`);

    socket.join(`user:${userId}`);
    socket.join(`role:${role}`);
    if (warehouseId) socket.join(`warehouse:${warehouseId}`);

    socket.on('disconnect', () => {
      console.log(`Socket قطع شد: User ${userId}`);
    });
  });

  return io;
}
