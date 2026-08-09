import express from 'express';
import cors, { CorsOptions } from 'cors';
import helmet from 'helmet';
import path from 'path';
import { prisma } from './utils/prisma';
import { redisIsReady } from './utils/redis';
import { getAllowedOrigins } from './config/cors';
import { authRoutes } from './auth/auth.routes';
import { managerRoutes } from './manager/manager.routes';
import { warehouseRoutes } from './warehouse_keeper/warehouse.routes';
import { notificationRoutes } from './notification/notification.routes';
import { badgeRoutes } from './badge/badge.routes';
import driverRoutes from './driver/driver.routes';
import { errorHandler } from './middleware/errorHandler';

export function createApp() {
  const app = express();

  // پشت پروکسی (nginx/ترمیم): آدرس IP واقعی کاربر برای rate limit
  app.set('trust proxy', process.env.TRUST_PROXY === 'true' ? 1 : false);

  // هدرهای امنیتی (X-Content-Type-Options, HSTS, ...)
  app.use(helmet());

  // CORS با لیست مبدأ مجاز (ALLOWED_ORIGINS)؛ اگر خالی باشد، همه مجازند (MVP)
  const corsOrigins = getAllowedOrigins();
  const corsOptions: CorsOptions = corsOrigins.length > 0
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

  //سرو کردن فایل‌های آپلود شده
  app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

  app.get('/', async (req, res) => {
    try {
      await prisma.$connect();
      res.send('اتصال به دیتابیس با موفقیت انجام شد!');
    } catch {
      res.status(500).send('خطا در اتصال به دیتابیس');
    }
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
  app.use('/api/driver',           driverRoutes);

  // مسیرهای پیدا نشده
  app.use((req, res) => {
    res.status(404).json({ error: 'مسیر مورد نظر یافت نشد' });
  });

  // نقطه‌ی مرکزی همه‌ی خطاها — باید آخرین middleware باشد
  app.use(errorHandler);

  return app;
}
