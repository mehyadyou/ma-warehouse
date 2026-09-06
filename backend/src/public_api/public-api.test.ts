import { describe, it, expect, vi, beforeEach } from 'vitest';
import request from 'supertest';

vi.mock('../utils/prisma', () => ({
    prisma: {
        apiKey: {
            findUnique: vi.fn(),
            update: vi.fn().mockResolvedValue({}),
        },
        product: { findMany: vi.fn().mockResolvedValue([]), count: vi.fn().mockResolvedValue(0) },
        order: { findMany: vi.fn().mockResolvedValue([]), count: vi.fn().mockResolvedValue(0) },
        transaction: { findMany: vi.fn().mockResolvedValue([]), count: vi.fn().mockResolvedValue(0) },
        carton: { findMany: vi.fn().mockResolvedValue([]), count: vi.fn().mockResolvedValue(0), groupBy: vi.fn().mockResolvedValue([]) },
        warehouse: { findMany: vi.fn().mockResolvedValue([]) },
        carrier: { findMany: vi.fn().mockResolvedValue([]) },
        delivery: { findMany: vi.fn().mockResolvedValue([]), count: vi.fn().mockResolvedValue(0) },
        user: { findMany: vi.fn().mockResolvedValue([]) },
        productModel: { findMany: vi.fn().mockResolvedValue([]) },
        $queryRaw: vi.fn().mockResolvedValue([{ 1: 1 }]),
    },
}));

vi.mock('../utils/redis', () => ({ redisIsReady: vi.fn().mockResolvedValue(false) }));

import { createApp } from '../app';
import { prisma } from '../utils/prisma';

const app = createApp();

const keyRow = (overrides: Record<string, any> = {}) => ({
    id: 'k1',
    name: 'حسابداری',
    keyHash: 'hash',
    scopes: ['products', 'orders'],
    isActive: true,
    revokedAt: null,
    expiresAt: null,
    ...overrides,
});

beforeEach(() => {
    vi.clearAllMocks();
    (prisma.apiKey.update as any).mockResolvedValue({});
});

describe('API عمومی v1 — احراز کلید', () => {
    it('بدون هدر Authorization → 401', async () => {
        const res = await request(app).get('/api/v1/products');
        expect(res.status).toBe(401);
    });

    it('کلید با قالب غلط → 401', async () => {
        const res = await request(app).get('/api/v1/products').set('Authorization', 'Bearer wrong-format');
        expect(res.status).toBe(401);
    });

    it('کلید ناموجود → 401', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(null);
        const res = await request(app).get('/api/v1/products').set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');
        expect(res.status).toBe(401);
    });

    it('کلید باطل‌شده → 401 «باطل شده»', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow({ revokedAt: new Date(), isActive: false }));
        const res = await request(app).get('/api/v1/products').set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');
        expect(res.status).toBe(401);
        expect(res.body.error).toContain('باطل');
    });

    it('کلید منقضی → 401 «منقضی»', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow({ expiresAt: new Date(Date.now() - 1000) }));
        const res = await request(app).get('/api/v1/products').set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');
        expect(res.status).toBe(401);
        expect(res.body.error).toContain('منقضی');
    });

    it('کلید معتبر → 200 + ثبت آمار استفاده', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow());
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1', name: 'محصول', models: [] }]);
        (prisma.product.count as any).mockResolvedValue(1);

        const res = await request(app).get('/api/v1/products').set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');
        expect(res.status).toBe(200);
        expect(res.body.data).toHaveLength(1);
        expect(res.body.meta.total).toBe(1);
        // آمار fire-and-forget ثبت شده
        expect(prisma.apiKey.update).toHaveBeenCalled();
    });
});

describe('API عمومی v1 — اسکوپ‌ها', () => {
    beforeEach(() => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow());
    });

    it('کلید بدون اسکوپ transactions → 403 روی /transactions', async () => {
        const res = await request(app).get('/api/v1/transactions').set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');
        expect(res.status).toBe(403);
        expect(res.body.requiredScope).toBe('transactions');
    });

    it('کلید دارای اسکوپ orders → 200 روی /orders', async () => {
        (prisma.order.findMany as any).mockResolvedValue([]);
        (prisma.order.count as any).mockResolvedValue(0);
        const res = await request(app).get('/api/v1/orders').set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');
        expect(res.status).toBe(200);
    });
});

describe('API عمومی v1 — صفحه‌بندی', () => {
    beforeEach(() => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow());
    });

    it('پارامترهای page/pageSize به DB پاس داده می‌شوند', async () => {
        (prisma.product.findMany as any).mockResolvedValue([]);
        (prisma.product.count as any).mockResolvedValue(95);

        const res = await request(app)
            .get('/api/v1/products?page=3&pageSize=50')
            .set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');

        expect(res.status).toBe(200);
        expect(prisma.product.findMany).toHaveBeenCalledWith(
            expect.objectContaining({ skip: 100, take: 50 }),
        );
        expect(res.body.meta).toMatchObject({ total: 95, page: 3, pageSize: 50, totalPages: 2 });
    });

    it('pageSize بیشتر از سقف ۱۰۰ → محدود می‌شود', async () => {
        (prisma.product.findMany as any).mockResolvedValue([]);
        (prisma.product.count as any).mockResolvedValue(0);

        await request(app)
            .get('/api/v1/products?pageSize=5000')
            .set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');

        expect(prisma.product.findMany).toHaveBeenCalledWith(
            expect.objectContaining({ take: 100 }),
        );
    });

    it('فیلتر status نامعتبر سفارش → نادیده گرفته می‌شود (بدون خطا)', async () => {
        (prisma.order.findMany as any).mockResolvedValue([]);
        (prisma.order.count as any).mockResolvedValue(0);

        const res = await request(app)
            .get('/api/v1/orders?status=HACKED')
            .set('Authorization', 'Bearer ma_live_abcdef1234567890abcdef1234567890');
        expect(res.status).toBe(200);
        // where بدون status ساخته شده
        expect(prisma.order.findMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: {} }),
        );
    });
});

describe('openapi.json', () => {
    it('بدون کلید قابل دریافت است — مستندات عمومی', async () => {
        const res = await request(app).get('/api/v1/openapi.json');
        expect(res.status).toBe(200);
        expect(res.body.info.title).toContain('Public API');
        expect(Object.keys(res.body.paths).length).toBeGreaterThanOrEqual(9);
    });
});
