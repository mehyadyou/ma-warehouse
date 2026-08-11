import { Request, Response, NextFunction } from 'express';
import { AppError } from '../common/exceptions/AppError';
import { logger } from '../utils/logger';

// نقطه‌ی مرکزی پاسخ‌دهی به همه‌ی خطاها — شکل پاسخ همیشه یکدست است: { error: string }
export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // خطاهای کسب‌وکار با کد وضعیت مشخص
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: err.message,
    });
  }

  // خطاهای Prisma
  if (err?.name === 'PrismaClientKnownRequestError') {
    return res.status(400).json({
      error: 'خطا در عملیات دیتابیس',
    });
  }

  // خطاهای JWT
  if (err?.name === 'JsonWebTokenError' || err?.name === 'TokenExpiredError') {
    return res.status(401).json({
      error: 'توکن نامعتبر است',
    });
  }

  // خطاهای multer (آپلود فایل)
  if (err?.name === 'MulterError') {
    return res.status(400).json({
      error: 'خطا در آپلود فایل',
    });
  }

  logger.error({ err, reqId: req.id, method: req.method, url: req.url }, 'unhandled error');
  return res.status(500).json({
    error: 'خطای داخلی سرور؛ لطفاً دوباره تلاش کنید',
  });
};