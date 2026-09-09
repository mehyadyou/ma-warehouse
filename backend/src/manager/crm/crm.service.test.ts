import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        user: { count: vi.fn() },
        warehouse: { count: vi.fn() },
        order: { count: vi.fn(), groupBy: vi.fn(), findMany: vi.fn() },
        carton: { count: vi.fn() },
        product: { count: vi.fn() },
        transfer: { count: vi.fn() },
        outboxEvent: { count: vi.fn(), findFirst: vi.fn() },
        auditLog: { findMany: vi.fn(), count: vi.fn() },
        activityLog: { findMany: vi.fn() },
        transaction: { findMany: vi.fn() },
        apiKeyDailyUsage: { findMany: vi.fn() },
        $queryRaw: vi.fn(),
        $transaction: vi.fn(),
    },
}));

vi.mock('../../utils/cache', () => ({
    cached: vi.fn(async (_key: string, _ttl: number, fn: () => Promise<unknown>) => fn()),
}));

vi.mock('../../utils/redis', () => ({
    getRedis: vi.fn().mockResolvedValue(null),
}));

import { crmService } from './crm.service';
import { prisma } from '../../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

const D = (s: string) => new Date(s);

describe('crmService.getOverview', () => {
    it('شمارنده‌ها + سفارش امروز در یک پاسخ', async () => {
        (prisma.user.count as any).mockResolvedValue(7);
        (prisma.warehouse.count as any).mockResolvedValue(2);
        (prisma.order.count as any).mockResolvedValueOnce(3).mockResolvedValueOnce(5);
        (prisma.transfer.count as any).mockResolvedValue(1);
        (prisma.outboxEvent.count as any).mockResolvedValueOnce(0).mockResolvedValueOnce(0);

        const r = await crmService.getOverview();
        expect(r.usersCount).toBe(7);
        expect(r.ordersPending).toBe(3);
        expect(r.todayOrders).toBe(5);
        expect(r.outboxFailed).toBe(0);
        expect(typeof r.todayDayKey).toBe('number');
    });
});

describe('crmService.getCustomers', () => {
    it('صفحه‌بندی + جمع خرید با Decimal', async () => {
        (prisma.$queryRaw as any).mockResolvedValue([{ n: 2 }]);
        (prisma.order.groupBy as any).mockResolvedValue([
            { customerPhone: '09120000001', _count: { _all: 2 }, _max: { createdAt: D('2026-09-01T10:00:00Z') } },
            { customerPhone: '09120000002', _count: { _all: 1 }, _max: { createdAt: D('2026-09-02T10:00:00Z') } },
        ]);
        (prisma.order.findMany as any).mockResolvedValue([
            { customerPhone: '09120000001', city: 'تهران', receiverName: 'گیرنده', items: [{ quantity: 2, price: '100000' }, { quantity: 1, price: null }] },
            { customerPhone: '09120000002', city: null, receiverName: null, items: [{ quantity: 3, price: '50000' }] },
        ]);

        const r = await crmService.getCustomers({ page: 1, pageSize: 20 });
        expect(r.total).toBe(2);
        expect(r.customers[0]).toMatchObject({ phone: '09120000001', orders: 2, spent: 200000, items: 3 });
        expect(r.customers[1]).toMatchObject({ phone: '09120000002', spent: 150000 });
    });

    it('پیش‌فرض صفحه‌بندی امن (سقف ۱۰۰)', async () => {
        (prisma.$queryRaw as any).mockResolvedValue([{ n: 0 }]);
        (prisma.order.groupBy as any).mockResolvedValue([]);
        (prisma.order.findMany as any).mockResolvedValue([]);
        const r = await crmService.getCustomers({ pageSize: 9999 });
        expect(r.pageSize).toBe(100);
        expect(r.customers).toEqual([]);
    });
});

describe('crmService.getCustomerDetail', () => {
    it('مشتری ناموجود → تجمیع صفر بدون خطا', async () => {
        (prisma.order.findMany as any).mockResolvedValue([]);
        const r = await crmService.getCustomerDetail('09000000000');
        expect(r.totals).toEqual({ orders: 0, spent: 0, items: 0 });
        expect(r.orders).toEqual([]);
    });

    it('قیمت Decimal به Number تبدیل می‌شود', async () => {
        (prisma.order.findMany as any).mockResolvedValue([
            {
                id: 'o1', createdAt: D('2026-09-01T10:00:00Z'),
                items: [{ quantity: 2, price: '150000.50', exchangeRate: null }],
                delivery: null, warehouse: { id: 'w1', name: 'انبار' },
            },
        ]);
        (prisma.activityLog.findMany as any).mockResolvedValue([]);
        const r = await crmService.getCustomerDetail('09120000001');
        expect(r.totals.spent).toBeCloseTo(300001, 0);
        expect(r.orders[0].items[0].price).toBeCloseTo(150000.5, 1);
    });
});

describe('crmService.getAudit', () => {
    it('فیلترها + صفحه‌بندی به کوئری می‌رسند', async () => {
        (prisma.$transaction as any).mockImplementation(async (arr: any[]) => [await arr[0], await arr[1]]);
        (prisma.auditLog.findMany as any).mockResolvedValue([{ id: 'a1' }]);
        (prisma.auditLog.count as any).mockResolvedValue(1);
        const r = await crmService.getAudit({ actorId: 'u1', entity: 'Order', page: 2, pageSize: 10 });
        expect(r.total).toBe(1);
        expect(prisma.auditLog.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: expect.objectContaining({ actorId: 'u1', entity: 'Order' }),
                skip: 10,
                take: 10,
            }),
        );
    });

    it('بازه نامعتبر تاریخ نادیده گرفته می‌شود', async () => {
        (prisma.$transaction as any).mockImplementation(async (arr: any[]) => [await arr[0], await arr[1]]);
        (prisma.auditLog.findMany as any).mockResolvedValue([]);
        (prisma.auditLog.count as any).mockResolvedValue(0);
        const r = await crmService.getAudit({ from: 'not-a-date' });
        expect(r.total).toBe(0);
        expect(prisma.auditLog.findMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: {} }),
        );
    });
});

describe('crmService.getUserActivity', () => {
    it('ادغام سه منبع به ترتیب نزولی با سقف', async () => {
        (prisma.activityLog.findMany as any).mockResolvedValue([
            { id: 'a1', createdAt: D('2026-09-03T10:00:00Z'), type: 'order_created' },
        ]);
        (prisma.auditLog.findMany as any).mockResolvedValue([
            { id: 'u1', createdAt: D('2026-09-04T10:00:00Z'), action: 'user.update' },
        ]);
        (prisma.transaction.findMany as any).mockResolvedValue([
            { id: 't1', createdAt: D('2026-09-02T10:00:00Z') },
        ]);
        const r = await crmService.getUserActivity({ userId: 'x', limit: 10 });
        expect(r.entries.map((e) => e.kind)).toEqual(['audit', 'activity', 'transaction']);
        expect(r.counts).toEqual({ activities: 1, audits: 1, transactions: 1 });
    });
});

describe('crmService.getFinance', () => {
    it('جمع درآمد/واحد + تفکیک‌ها', async () => {
        (prisma.order.findMany as any).mockResolvedValue([
            {
                id: 'o1', createdAt: D('2026-09-05T10:00:00Z'), status: 'PENDING',
                city: 'تهران', carrier: 'باربری X', shippingMethod: 'باربری',
                warehouseId: 'w1', warehouse: { name: 'انبار ۱' },
                items: [{ quantity: 2, price: '100000' }, { quantity: 1, price: null }],
            },
            {
                id: 'o2', createdAt: D('2026-09-05T12:00:00Z'), status: 'SHIPPED',
                city: null, carrier: null, shippingMethod: 'شهری',
                warehouseId: 'w1', warehouse: { name: 'انبار ۱' },
                items: [{ quantity: 1, price: '50000' }],
            },
        ]);
        const r = await crmService.getFinance({});
        expect(r.totals).toMatchObject({ revenue: 250000, units: 4, orders: 2, capped: false });
        expect(r.byWarehouse[0]).toMatchObject({ name: 'انبار ۱', orders: 2 });
        expect(r.byCity.find((c) => c.key === 'نامشخص')).toBeTruthy();
    });
});

describe('crmService.getApiUsage', () => {
    it('پیش‌فرض ۱۴ روز اخیر + تجمیع هر کلید', async () => {
        (prisma.apiKeyDailyUsage.findMany as any).mockResolvedValue([
            { apiKeyId: 'k1', dayKey: 14050615, hits: 10, errors: 1, apiKey: { id: 'k1', name: 'حسابداری', prefix: 'ma_live_x', isActive: true } },
            { apiKeyId: 'k1', dayKey: 14050614, hits: 5, errors: 0, apiKey: { id: 'k1', name: 'حسابداری', prefix: 'ma_live_x', isActive: true } },
        ]);
        const r = await crmService.getApiUsage({});
        expect(r.keys).toHaveLength(1);
        expect(r.keys[0]).toMatchObject({ totalHits: 15, totalErrors: 1 });
        expect(r.keys[0].days).toHaveLength(2);
        expect(r.to - r.from).toBe(13);
    });
});

describe('crmService.getHealth', () => {
    it('شمارنده‌ها + صف outbox + آپتایم', async () => {
        (prisma.user.count as any).mockResolvedValue(7);
        (prisma.order.count as any).mockResolvedValue(13);
        (prisma.carton.count as any).mockResolvedValue(35);
        (prisma.product.count as any).mockResolvedValue(5);
        (prisma.transfer.count as any).mockResolvedValue(0);
        (prisma.outboxEvent.count as any).mockResolvedValueOnce(2).mockResolvedValueOnce(0);
        (prisma.outboxEvent.findFirst as any).mockResolvedValue({ createdAt: D('2026-09-05T10:00:00Z'), type: 'order:created' });
        const r = await crmService.getHealth();
        expect(r.counts).toMatchObject({ users: 7, orders: 13 });
        expect(r.outbox).toMatchObject({ pending: 2, failed: 0 });
        expect(typeof r.uptimeSec).toBe('number');
    });
});
