import http from 'http';
import { createApp } from './app';
import { initSocketServer } from './realtime/socket.server';
import { startOutboxDispatcher } from './realtime/outbox';
import { prisma } from './utils/prisma';
import { getRedis } from './utils/redis';
import { startCleanup } from './utils/cleanup';
import { logger } from './utils/logger';

const app = createApp();
const PORT = process.env.PORT || 3000;

const stopOutbox = startOutboxDispatcher(1000);

// پاک‌سازی روزانهٔ رکوردهای منقضی (RefreshToken / IdempotencyKey / OutboxEvent)
startCleanup();

const httpServer = http.createServer(app);

let io: Awaited<ReturnType<typeof initSocketServer>> | null = null;

initSocketServer(httpServer)
  .then((server) => {
    io = server;
    httpServer.listen(PORT, () =>
      logger.info({ port: PORT }, 'server started (HTTP + WebSocket)'),
    );
  })
  .catch((err) => {
    logger.error({ err }, 'realtime init failed, falling back to HTTP-only');
    httpServer.listen(PORT, () =>
      logger.info({ port: PORT }, 'server started (HTTP only)'),
    );
  });

async function shutdown(signal: string) {
  logger.info({ signal }, 'shutdown: closing cleanly');
  stopOutbox();
  if (io) io.close();
  httpServer.close(async () => {
    await prisma.$disconnect();
    const redis = await getRedis();
    await redis?.quit();
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10_000).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
