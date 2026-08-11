import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import fs from 'fs';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        $queryRaw: vi.fn(),
        order: { findUnique: vi.fn(), findUniqueOrThrow: vi.fn() },
        carton: { findMany: vi.fn() },
        delivery: { findUnique: vi.fn() },
        activityLog: { create: vi.fn() },
        warehouse: { findUnique: vi.fn() },
        product: { findMany: vi.fn() },
        productModel: { findMany: vi.fn() },
    },
}));

import { ordersService } from './orders.service';
import { prisma } from '../../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

function makeTx(overrides: Record<string, any> = {}) {
    return {
        order: { create: vi.fn().mockResolvedValue({}), delete: vi.fn().mockResolvedValue({}) },
        orderItem: {
            deleteMany: vi.fn().mockResolvedValue({}),
            createMany: vi.fn().mockResolvedValue({}),
            findMany: vi.fn().mockResolvedValue([]),
        },
        badge: { deleteMany: vi.fn().mockResolvedValue({}), create: vi.fn().mockResolvedValue({}) },
        carton: { updateMany: vi.fn().mockResolvedValue({}), count: vi.fn().mockResolvedValue(0) },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
        auditLog: { create: vi.fn().mockResolvedValue({}) },
        ...overrides,
    };
}

const mockMappedOrder = (overrides: Record<string, any> = {}) => ({
    id: 'order1',
    status: 'PENDING',
    shippingMethod: 'باربری',
    carrier: null,
    city: null,
    postalCode: null,
    address: null,
    customerPhone: null,
    senderName: 'فرستنده',
    receiverName: 'گیرنده',
    createdAt: new Date(),
    updatedAt: new Date(),
    warehouse: { name: 'انبار تست' },
    delivery: null,
    _count: { badges: 5 },
    items: [],
    ...overrides,
});

describe('ordersService.getCarriers', () => {
    it('آرایه‌ای از باربری‌ها برمیگرداند', async () => {
        const carriers = await ordersService.getCarriers();
        expect(Array.isArray(carriers)).toBe(true);
        expect(carriers.length).toBeGreaterThan(0);
        expect(carriers[0]).toHaveProperty('name');
        expect(carriers[0]).toHaveProperty('priority');
    });

    it('ساختار هر باربری درست است', async () => {
        const carriers = await ordersService.getCarriers();
        for (const c of carriers) {
            expect(typeof c.name).toBe('string');
            expect(typeof c.priority).toBe('number');
        }
    });
});

describe('ordersService.createCarrier', () => {
    const originalReadFileSync = fs.readFileSync;
    const originalWriteFileSync = fs.writeFileSync;
    let writtenData: string | null = null;

    beforeEach(() => {
        writtenData = null;
        vi.spyOn(fs, 'readFileSync').mockImplementation((path: any, encoding: any) => {
            if (String(path).includes('carriers.json')) {
                return JSON.stringify([
                    { name: 'باربری موجود', priority: 1, phone: '021-11111111', address: 'تهران' },
                ]);
            }
            return originalReadFileSync(path, encoding);
        });
        vi.spyOn(fs, 'writeFileSync').mockImplementation((path: any, data: any) => {
            if (String(path).includes('carriers.json')) {
                writtenData = data as string;
            }
        });
    });

    afterEach(() => {
        vi.restoreAllMocks();
    });

    it('باربری جدید با موفقیت اضافه میشود', async () => {
        const result = await ordersService.createCarrier('باربری جدید', 5, '021-99999999', 'اصفهان');
        expect(result.name).toBe('باربری جدید');
        expect(result.priority).toBe(5);

        const written = JSON.parse(writtenData!);
        expect(written).toHaveLength(2);
        expect(written[1].name).toBe('باربری جدید');
    });

    it('نام تکراری AppError 409 برمیگرداند', async () => {
        await expect(
            ordersService.createCarrier('باربری موجود', 1)
        ).rejects.toThrow('این باربری قبلاً ثبت شده است');
    });
});

describe('ordersService.createOrder', () => {
    const runCreate = async (tx: any, args: any[]) => {
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.order.findUniqueOrThrow as any).mockResolvedValue(mockMappedOrder());
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'wh1', name: 'انبار تست' });
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1' }, { id: 'p2' }]);
        (prisma.productModel.findMany as any).mockResolvedValue([]);
        (prisma.$queryRaw as any).mockResolvedValue([
            { productId: 'p1', available: 100 },
            { productId: 'p2', available: 100 },
        ]);
        await ordersService.createOrder(...args);
        return tx;
    };

    it('تعداد badgeها برابر totalUnits اقلام است', async () => {
        const tx = await runCreate(makeTx(), [
            'wh1', 'user1',
            [
                { productId: 'p1', quantity: 3, model: 'M1', price: 100, exchangeRate: 50000 },
                { productId: 'p2', quantity: 2, model: 'M2', price: 200, exchangeRate: 50000 },
            ],
            'باربری', undefined, undefined, undefined, undefined, undefined,
            'فرستنده', 'گیرنده',
        ]);

        const createData = tx.order.create.mock.calls[0][0].data;
        // 3 + 2 = 5 badge (count-based)
        expect(createData.badges.create.count).toBe(5);
        expect(createData.items.create).toHaveLength(2);
        expect(createData.status).toBe('PENDING');
    });

    it('وقتی فرستنده/گیرنده نباشد badge ساخته نمیشود', async () => {
        const tx = await runCreate(makeTx(), [
            'wh1', 'user1', [{ productId: 'p1', quantity: 2 }], 'باربری',
            undefined, undefined, undefined, undefined, undefined,
            undefined, undefined,
        ]);

        const createData = tx.order.create.mock.calls[0][0].data;
        expect(createData.badges).toBeUndefined();
        expect(createData.items.create).toHaveLength(1);
    });

    it('رویداد outbox و فعالیت‌ها پس از ثبت سفارش نوشته میشوند', async () => {
        const tx = await runCreate(makeTx(), [
            'wh1', 'user1', [{ productId: 'p1', quantity: 1 }], 'باربری',
            undefined, undefined, undefined, undefined, undefined,
            'فرستنده', 'گیرنده',
        ]);

        expect(tx.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order_created', orderId: expect.any(String) }) })
        );
        expect(tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order:created', aggregate: 'order' }) })
        );
        const payload = tx.outboxEvent.create.mock.calls[0][0].data.payload;
        expect(payload.orderId).toBeTruthy();
        expect(payload.warehouseId).toBe('wh1');
    });
});

describe('ordersService.updateOrder', () => {
    const existingOrder = (overrides: Record<string, any> = {}) => ({
        id: 'o1',
        warehouseId: 'wh1',
        createdById: 'u1',
        version: 2,
        status: 'PENDING',
        shippingMethod: 'باربری',
        carrier: null,
        city: null,
        postalCode: null,
        address: null,
        customerPhone: null,
        senderName: 'فرستنده',
        receiverName: 'گیرنده',
        ...overrides,
    });

    it('تغییر همزمان با version قدیمی → AppError 409', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(existingOrder());
        await expect(
            ordersService.updateOrder('o1', { version: 1 })
        ).rejects.toThrow('تازه کنید');
    });

    it('ویرایش موفق با version درست: اقلام بازنویسی + badge بازتولید + outbox', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(existingOrder());
        const tx = makeTx();
        tx.order.updateMany = vi.fn().mockResolvedValue({ count: 1 });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.order.findUniqueOrThrow as any).mockResolvedValue(mockMappedOrder());

        await ordersService.updateOrder('o1', {
            items: [{ productId: 'p1', quantity: 2, modelId: 'm1', model: 'مدل ۱' }],
            version: 2,
        });

        expect(tx.order.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 'o1', version: 2 } })
        );
        expect(tx.carton.count).toHaveBeenCalledWith(
            expect.objectContaining({ where: { orderId: 'o1', scannedOutAt: { not: null } } })
        );
        expect(tx.orderItem.deleteMany).toHaveBeenCalledWith({ where: { orderId: 'o1' } });
        expect(tx.orderItem.createMany).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.arrayContaining([expect.objectContaining({ productId: 'p1', quantity: 2, modelId: 'm1', model: 'مدل ۱' })]) })
        );
        expect(tx.badge.deleteMany).toHaveBeenCalledWith({ where: { orderId: 'o1' } });
        // senderName/receiverName ثابت مانده → badge بازتولید میشود (count-based, count=2)
        expect(tx.badge.create).toHaveBeenCalled();
        const badgeData = tx.badge.create.mock.calls[0][0].data;
        expect(badgeData.count).toBe(2);
        expect(tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order:updated' }) })
        );
    });

    it('N5: وجود کارتن خروجخورده → ویرایش اقلام ممنوع است (AppError 400)', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(existingOrder());
        const tx = makeTx();
        tx.order.updateMany = vi.fn().mockResolvedValue({ count: 1 });
        tx.carton.count = vi.fn().mockResolvedValue(1);
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(
            ordersService.updateOrder('o1', {
                items: [{ productId: 'p1', quantity: 5 }],
                version: 2,
            })
        ).rejects.toThrow('وارد مرحلهٔ خروج شده');
        expect(tx.orderItem.deleteMany).not.toHaveBeenCalled();
    });

    it('سفارش یافت نشد → AppError 404', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(null);
        await expect(ordersService.updateOrder('nonexistent', {})).rejects.toThrow('سفارش یافت نشد');
    });
});

describe('ordersService.deleteOrder', () => {
    it('سفارش یافت نشد AppError 404', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(null);
        await expect(ordersService.deleteOrder('nonexistent')).rejects.toThrow('سفارش یافت نشد');
    });

    it('وقتی کارتنی خروج خورده باشد قابل حذف نیست', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1' });
        (prisma.carton.findMany as any).mockResolvedValue([{ scannedOutAt: new Date() }]);
        await expect(ordersService.deleteOrder('o1')).rejects.toThrow('قابل حذف نیست');
    });

    it('وقتی سفارش وارد مرحله ارسال شده باشد قابل حذف نیست', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1' });
        (prisma.carton.findMany as any).mockResolvedValue([{ scannedOutAt: null }]);
        (prisma.delivery.findUnique as any).mockResolvedValue({ id: 'd1' });
        await expect(ordersService.deleteOrder('o1')).rejects.toThrow('قابل حذف نیست');
    });

    it('حذف موفق: جدا کردن کارتنها + حذف سفارش + لاگ + outbox', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({
            id: 'o1', warehouseId: 'wh1', senderName: 'الف', receiverName: 'ب', createdById: 'u1',
        });
        (prisma.carton.findMany as any).mockResolvedValue([{ scannedOutAt: null }]);
        (prisma.delivery.findUnique as any).mockResolvedValue(null);

        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await ordersService.deleteOrder('o1');

        expect(tx.carton.updateMany).toHaveBeenCalledWith({ where: { orderId: 'o1' }, data: { orderId: null } });
        expect(tx.order.delete).toHaveBeenCalledWith({ where: { id: 'o1' } });
        expect(tx.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order_deleted' }) })
        );
        expect(tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order:deleted' }) })
        );
    });
});
