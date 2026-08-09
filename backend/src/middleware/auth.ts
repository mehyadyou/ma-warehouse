import { Request, Response, NextFunction } from 'express';
import { verifyToken, JwtPayload } from '../config/jwt';
import { prisma } from '../utils/prisma';

// اضافه کردن user به Request
declare global {
    namespace Express {
        interface Request {
            user?: JwtPayload;
        }
    }
}

// چک کردن توکن JWT + وضعیت کاربر
export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            res.status(401).json({ error: 'توکن ارسال نشده است' });
            return;
        }

        const token = authHeader.split(' ')[1];
        const decoded = verifyToken(token);

        // بررسی فعال بودن کاربر + نقش/انبار/نسخه‌ی توکن از دیتابیس (داده‌ی همیشه تازه)
        const user = await prisma.user.findUnique({
            where: { id: decoded.id },
            select: { isActive: true, deletedAt: true, role: true, warehouseId: true, tokenVersion: true },
        });
        if (!user || !user.isActive || user.deletedAt) {
            res.status(401).json({ error: 'حساب کاربری غیرفعال شده است' });
            return;
        }

        // توکنِ صادرشده قبل از تغییر رمز/نقش/انبار → باطل
        if (decoded.ver !== undefined && decoded.ver !== user.tokenVersion) {
            res.status(401).json({ error: 'نشست شما منقضی شده است؛ لطفاً دوباره وارد شوید' });
            return;
        }

        // نقش و انبار را از دیتابیس بازنویسی کن — توکنِ کهنه دیگر امنیتی نیست
        req.user = {
            id: decoded.id,
            role: user.role,
            warehouseId: user.warehouseId ?? undefined,
            ver: user.tokenVersion,
        };
        next();
    } catch (error) {
        res.status(401).json({ error: 'توکن نامعتبر یا منقضی شده است' });
        return;
    }
};

// چک کردن نقش کاربر
export const authorize = (...roles: string[]) => {
    return (req: Request, res: Response, next: NextFunction) => {
        if (!req.user) {
            res.status(401).json({ error: 'ابتدا وارد شوید' });
            return;
        }

        if (!roles.includes(req.user.role)) {
            res.status(403).json({ error: 'دسترسی غیرمجاز' });
            return;
        }

        next();
    };
};