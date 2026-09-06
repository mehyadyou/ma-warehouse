import { describe, it, expect, vi, beforeEach } from 'vitest';
import request from 'supertest';

vi.mock('./utils/prisma', () => ({
    prisma: {
        $queryRaw: vi.fn().mockResolvedValue([{ 1: 1 }]),
        user: {
            findUnique: vi.fn(),
        },
    },
}));
vi.mock('./utils/redis', () => ({
    redisIsReady: vi.fn().mockResolvedValue(false),
}));

import { createApp } from './app';
import { prisma } from './utils/prisma';
import { signToken, verifyToken } from './config/jwt';

const app = createApp();

beforeEach(() => {
    vi.clearAllMocks();
});

describe('app hardening — /uploads محافظت‌شده', () => {
    it('بدون توکن → 401 (فایل‌های آپلود عمومی نیستند)', async () => {
        const res = await request(app).get('/uploads/avatars/whatever.jpg');
        expect(res.status).toBe(401);
    });

    it('با توکن نامعتبر → 401', async () => {
        const res = await request(app)
            .get('/uploads/avatars/whatever.jpg')
            .set('Authorization', 'Bearer not-a-real-jwt');
        expect(res.status).toBe(401);
    });

    it('با توکن معتبر و کاربر فعال → مسیر static سرو می‌شود (404 فایل = عبور از گارد)', async () => {
        (prisma.user.findUnique as any).mockResolvedValue({
            isActive: true,
            deletedAt: null,
            role: 'MANAGER',
            warehouseId: null,
            tokenVersion: 0,
        });
        const token = signToken({ id: 'u1', role: 'MANAGER' }, 0);

        // فایل فیزیکی وجود ندارد ولی مهم نیست — 404 از express.static یعنی
        // گارد احراز هویت رد شده و به لایهٔ فایل رسیده‌ایم (نه 401)
        const res = await request(app)
            .get('/uploads/avatars/nonexistent.jpg')
            .set('Authorization', `Bearer ${token}`);
        expect(res.status).toBe(404);
        expect(res.body.error).toBe('مسیر مورد نظر یافت نشد');
    });

    it('کاربر غیرفعال با توکن معتبر → 401 (بررسی DB هر درخواست)', async () => {
        (prisma.user.findUnique as any).mockResolvedValue({
            isActive: false,
            deletedAt: null,
            role: 'MANAGER',
            warehouseId: null,
            tokenVersion: 0,
        });
        const token = signToken({ id: 'u1', role: 'MANAGER' }, 0);

        const res = await request(app)
            .get('/uploads/avatars/x.jpg')
            .set('Authorization', `Bearer ${token}`);
        expect(res.status).toBe(401);
    });
});

describe('app hardening — مسیرهای پایه', () => {
    it('GET / پیام وضعیت API را برمی‌گرداند', async () => {
        const res = await request(app).get('/');
        expect(res.status).toBe(200);
        expect(res.text).toContain('ma-warehouse API');
    });

    it('GET /healthz با دیتابیس سالم → 200', async () => {
        const res = await request(app).get('/healthz');
        expect(res.status).toBe(200);
        expect(res.body.checks.database).toBe(true);
    });

    it('مسیر ناشناخته → 404 فارسی', async () => {
        const res = await request(app).get('/api/nonexistent');
        expect(res.status).toBe(404);
        expect(res.body.error).toContain('یافت نشد');
    });
});

describe('jwt roundtrip', () => {
    it('sign + verify با ver — payload دست‌نخورده', () => {
        const token = signToken({ id: 'u9', role: 'DRIVER', warehouseId: 'w1' }, 3);
        const payload = verifyToken(token);
        expect(payload.id).toBe('u9');
        expect(payload.role).toBe('DRIVER');
        expect(payload.warehouseId).toBe('w1');
        expect(payload.ver).toBe(3);
    });
});
