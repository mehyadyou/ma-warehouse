import { Request, Response, NextFunction } from 'express';
import { getRedis } from '../utils/redis';

interface RateLimitEntry {
    count: number;
    resetAt: number;
}

// fallback محلی (درون‌حافظه) وقتی Redis در دسترس نیست
const windows = new Map<string, RateLimitEntry>();

const cleanup = setInterval(() => {
    const now = Date.now();
    for (const [key, entry] of windows) {
        if (entry.resetAt <= now) windows.delete(key);
    }
}, 60 * 1000);
cleanup.unref?.();

export const rateLimit = (options: { windowMs: number; max: number; keyPrefix?: string }) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        const ip = req.ip || req.socket.remoteAddress || 'unknown';
        const key = `${options.keyPrefix ?? 'rl'}:${ip}`;
        const now = Date.now();

        // شمارش اتمی در Redis؛ اگر خطا داد به‌صورت خودکار روی حافظه‌ی محلی عمل می‌کند
        try {
            const redis = await getRedis();
            if (redis) {
                const count = await redis.incr(key);
                if (count === 1) await redis.pexpire(key, options.windowMs);
                if (count > options.max) {
                    return res.status(429).json({
                        error: 'تعداد تلاش‌ها بیش از حد مجاز است. کمی بعد دوباره تلاش کنید',
                    });
                }
                return next();
            }
        } catch {
            // ادامه با fallback محلی
        }

        const entry = windows.get(key);
        if (!entry || entry.resetAt <= now) {
            windows.set(key, { count: 1, resetAt: now + options.windowMs });
            return next();
        }

        entry.count += 1;
        if (entry.count > options.max) {
            return res.status(429).json({
                error: 'تعداد تلاش‌ها بیش از حد مجاز است. کمی بعد دوباره تلاش کنید',
            });
        }

        next();
    };
};

// نسخهٔ مبتنی بر کاربر — کلید `${req.user?.id ?? req.ip}` برای کاربران پشت NAT
export const userRateLimit = (options: { windowMs: number; max: number; keyPrefix?: string }) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        const id = req.user?.id ?? req.ip ?? req.socket.remoteAddress ?? 'unknown';
        const key = `${options.keyPrefix ?? 'url'}:${id}`;
        const now = Date.now();

        try {
            const redis = await getRedis();
            if (redis) {
                const count = await redis.incr(key);
                if (count === 1) await redis.pexpire(key, options.windowMs);
                if (count > options.max) {
                    return res.status(429).json({
                        error: 'تعداد درخواست‌ها بیش از حد مجاز است. کمی بعد دوباره تلاش کنید',
                    });
                }
                return next();
            }
        } catch {
            // ادامه با fallback محلی
        }

        const entry = windows.get(key);
        if (!entry || entry.resetAt <= now) {
            windows.set(key, { count: 1, resetAt: now + options.windowMs });
            return next();
        }

        entry.count += 1;
        if (entry.count > options.max) {
            return res.status(429).json({
                error: 'تعداد درخواست‌ها بیش از حد مجاز است. کمی بعد دوباره تلاش کنید',
            });
        }

        next();
    };
};
