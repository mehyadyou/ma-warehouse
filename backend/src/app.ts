import express from 'express';
import cors, { CorsOptions } from 'cors';
import helmet from 'helmet';
import path from 'path';
import { prisma } from './utils/prisma';
import { redisIsReady } from './utils/redis';
import { getAllowedOrigins, isCorsAllowAll } from './config/cors';
import { authenticate } from './middleware/auth';
import { authRoutes } from './auth/auth.routes';
import { managerRoutes } from './manager/manager.routes';
import { warehouseRoutes } from './warehouse_keeper/warehouse.routes';
import { notificationRoutes } from './notification/notification.routes';
import { badgeRoutes } from './badge/badge.routes';
import { appUpdatesRoutes } from './app_updates/app-updates.routes';
import driverRoutes from './driver/driver.routes';
import { errorHandler } from './middleware/errorHandler';
import { requestId, logger } from './utils/logger';

export function createApp() {
  const app = express();

  // شناسهٔ یکتای درخواست — قبل از همهٔ middleware ها
  app.use(requestId);

  // پشت پروکسی (nginx/ترمیم): آدرس IP واقعی کاربر برای rate limit
  app.set('trust proxy', process.env.TRUST_PROXY === 'true' ? 1 : false);

  // هدرهای امنیتی (X-Content-Type-Options, HSTS, ...)
  app.use(helmet());

  // CORS با لیست مبدأ مجاز (ALLOWED_ORIGINS)؛ اگر خالی یا شامل `*` باشد، همه مجازند (فقط غیر-production)
  const corsOrigins = getAllowedOrigins();

  // هشدار بوت: در production لیست خالی یعنی CORS بسته (fail-closed) — نه همه‌مجاز
  if (process.env.NODE_ENV === 'production' && corsOrigins.length === 0) {
    logger.warn('ALLOWED_ORIGINS در production خالی است — CORS بسته است؛ همهٔ مبدأها رد می‌شوند');
  }

  const corsOptions: CorsOptions = !isCorsAllowAll()
    ? {
        origin: (origin, callback) => {
          // درخواست‌های بدون Origin (اپ موبایل / سرور) مجازند
          if (!origin || corsOrigins.includes(origin)) return callback(null, true);
          callback(null, false);
        },
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
        allowedHeaders: ['Content-Type', 'Authorization'],
      }
    : {
        origin: '*',
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
        allowedHeaders: ['Content-Type', 'Authorization'],
      };
  app.use(cors(corsOptions));

  app.use(express.json({ limit: '1mb' }));

  // سرو کردن فایل‌های آپلودشده — فقط با توکن معتبر (عکس تحویل شامل اطلاعات مشتری است)
  app.use(
    '/uploads',
    authenticate,
    express.static(path.join(process.cwd(), 'uploads')),
  );

  app.get('/', (_req, res) => res.send('ma-warehouse API is running'));

  // لاگ درخواست‌ها — ساختاریافته با requestId
  app.use((req, res, next) => {
    logger.info({ reqId: req.id, method: req.method, url: req.originalUrl });
    next();
  });

  // وضعیت سلامت سرویس — برای مانیتورینگ/دکور
  app.get('/healthz', async (_req, res) => {
    let database = false;
    try {
      await prisma.$queryRaw`SELECT 1`;
      database = true;
    } catch {
      // غیرفعال
    }
    const redis = await redisIsReady();
    res.status(database ? 200 : 503).json({
      status: database ? 'ok' : 'degraded',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      checks: { database, redis },
    });
  });

  app.use('/api/auth',             authRoutes);
  app.use('/api/manager',          managerRoutes);
  app.use('/api/warehouse-keeper', warehouseRoutes);
  app.use('/api/notifications',    notificationRoutes);
  app.use('/api/badges',           badgeRoutes);
  app.use('/api/app/updates',      appUpdatesRoutes);
  app.use('/api/driver',           driverRoutes);

  // مسیرهای پیدا نشده
  app.use((req, res) => {
    res.status(404).json({ error: 'مسیر مورد نظر یافت نشد' });
  });

  // نقطه‌ی مرکزی همه‌ی خطاها — باید آخرین middleware باشد
  app.use(errorHandler);

  return app;
}
