import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import { prisma } from '../utils/prisma';
import { jalaliDayKey } from '../utils/jalali';

declare global {
    namespace Express {
        interface Request {
            apiKey?: { id: string; scopes: string[] };
        }
    }
}

const hashKey = (key: string) => crypto.createHash('sha256').update(key).digest('hex');

/// ثبت مصرف روزانهٔ کلید برای داشبورد CRM — fire-and-forget، هرگز مسیر را کند/خراب نمی‌کند
async function bumpUsage(apiKeyId: string, field: 'hits' | 'errors'): Promise<void> {
    const dayKey = jalaliDayKey(new Date());
    try {
        await prisma.apiKeyDailyUsage.upsert({
            where: { apiKeyId_dayKey: { apiKeyId, dayKey } },
            update: field === 'hits' ? { hits: { increment: 1 } } : { errors: { increment: 1 } },
            create: { apiKeyId, dayKey, hits: field === 'hits' ? 1 : 0, errors: field === 'errors' ? 1 : 0 },
        });
    } catch (e: any) {
        // مسابقهٔ هم‌زمان روی ساخت ردیف روز: برنده ساخته، بازنده فقط increment می‌کند
        if (e?.code === 'P2002') {
            await prisma.apiKeyDailyUsage.updateMany({
                where: { apiKeyId, dayKey },
                data: field === 'hits' ? { hits: { increment: 1 } } : { errors: { increment: 1 } },
            }).catch(() => {});
        }
    }
}

/// احراز هویت کلید API — هدر Authorization: Bearer ma_live_xxx
export const authenticateApiKey = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const header = req.headers.authorization;
        if (!header || !header.startsWith('Bearer ')) {
            res.status(401).json({
                error: 'کلید API ارسال نشده است',
                hint: 'هدر Authorization: Bearer ma_live_...',
            });
            return;
        }
        const rawKey = header.slice(7).trim();
        if (!rawKey.startsWith('ma_live_') || rawKey.length < 20) {
            res.status(401).json({ error: 'قالب کلید API نامعتبر است' });
            return;
        }

        const key = await prisma.apiKey.findUnique({ where: { keyHash: hashKey(rawKey) } });
        if (!key) {
            res.status(401).json({ error: 'کلید API نامعتبر است' });
            return;
        }
        if (key.revokedAt || !key.isActive) {
            res.status(401).json({ error: 'این کلید API باطل شده است' });
            return;
        }
        if (key.expiresAt && key.expiresAt.getTime() < Date.now()) {
            res.status(401).json({ error: 'کلید API منقضی شده است' });
            return;
        }

        req.apiKey = { id: key.id, scopes: key.scopes };

        // آمار استفاده — بدون کند کردن مسیر (fire-and-forget)
        void prisma.apiKey.update({
            where: { id: key.id },
            data: { lastUsedAt: new Date(), useCount: { increment: 1 } },
        }).catch(() => {});
        void bumpUsage(key.id, 'hits');
        // خطاهای 4xx/5xx این درخواست هم برای همان روز/کلید شمرده می‌شود
        res.on('finish', () => {
            if (res.statusCode >= 400) void bumpUsage(key.id, 'errors');
        });

        next();
    } catch {
        res.status(401).json({ error: 'کلید API نامعتبر است' });
    }
};

/// سنجش اسکوپ — کلید باید محدودهٔ خواسته‌شده را داشته باشد
export const requireScope = (scope: string) => {
    return (req: Request, res: Response, next: NextFunction) => {
        if (!req.apiKey?.scopes.includes(scope)) {
            res.status(403).json({
                error: `این کلید به محدودهٔ '${scope}' دسترسی ندارد`,
                requiredScope: scope,
            });
            return;
        }
        next();
    };
};
