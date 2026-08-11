import pino from 'pino';
import crypto from 'crypto';
import { Request, Response, NextFunction } from 'express';

export const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
});

declare global {
    namespace Express {
        interface Request {
            id?: string;
        }
    }
}

// شناسهٔ یکتای درخواست — برای ردیابی خطا در لاگ‌های ساخت‌یافته
export const requestId = (req: Request, _res: Response, next: NextFunction) => {
    req.id = crypto.randomUUID();
    next();
};
