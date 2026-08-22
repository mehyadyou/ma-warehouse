import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import fs from 'fs';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        $queryRaw: vi.fn(),
        order: { findMany: vi.fn(), findUnique: vi.fn(), findUniqueOrThrow: vi.fn(), count: vi.fn() },
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
        $queryRaw: vi.fn(),
        order: { create: vi.fn().mockResolvedValue({}), delete: vi.fn().mockResolvedValue({}) },
        orderItem: {
            deleteMany: vi.fn().mockResolvedValue({}),
            createMany: vi.fn().mockResolvedValue({}),
            findMany: vi.fn().mockResolvedValue([]),
        },
        badge: { deleteMany: vi.fn().mockResolvedValue({}), create: vi.fn().mockResolvedValue({}) },
        carton: {
            updateMany: vi.fn().mockResolvedValue({}),
            count: vi.fn().mockResolvedValue(0),
            findMany: vi.fn().mockResolvedValue([]),
        },
        delivery: { findUnique: vi.fn().mockResolvedValue(null) },
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
        // getProductStock داخل تراکنش با tx.$queryRaw اجرا می‌شود:
        // ۱) محصولات دارای کارتن ۲) کارتن‌های IN_STOCK ۳) تراکنش‌های لِگاسی
        (tx.$queryRaw as any)
            .mockResolvedValueOnce([{ productId: 'p1' }, { productId: 'p2' }])
            .mockResolvedValueOnce([
                { productId: 'p1', available: 100 },
                { productId: 'p2', available: 100 },
            ])
            .mockResolvedValueOnce([]);
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
        // چک موجودی + ثبت داخل تراکنش Serializable است (ضد oversell هم‌زمان)
        expect(prisma.$transaction).toHaveBeenCalledWith(
            expect.any(Function),
            expect.objectContaining({ isolationLevel: 'Serializable' }),
        );
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

    it('کالای لِگاسی (بدون کارتن) با موجودی تراکنش‌ها رد نمی‌شود', async () => {
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.order.findUniqueOrThrow as any).mockResolvedValue(mockMappedOrder());
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'wh1' });
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p3' }]);
        (prisma.productModel.findMany as any).mockResolvedValue([]);
        (tx.$queryRaw as any)
            .mockResolvedValueOnce([]) // بدون کارتن → لِگاسی
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([{ productId: 'p3', legacyCount: 50 }]); // IN−OUT = 50

        await ordersService.createOrder(
            'wh1', 'user1', [{ productId: 'p3', quantity: 30 }],
            'باربری', undefined, undefined, undefined, undefined, undefined,
            'فرستنده', 'گیرنده',
        );

        expect(tx.order.create).toHaveBeenCalled();
    });

    it('کالای لِگاسی با موجودی ناکافی → AppError با مقدار موجودی', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'wh1' });
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p3' }]);
        (prisma.productModel.findMany as any).mockResolvedValue([]);
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (tx.$queryRaw as any)
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([{ productId: 'p3', legacyCount: 10 }]);

        await expect(
            ordersService.createOrder(
                'wh1', 'user1', [{ productId: 'p3', quantity: 30 }],
                'باربری', undefined, undefined, undefined, undefined, undefined,
                'فرستنده', 'گیرنده',
            )
        ).rejects.toThrow('موجودی کافی نیست (موجودی: 10)');
        expect(tx.order.create).not.toHaveBeenCalled();
    });

    it('کارتنی با موجودی ناکافی → AppError (پیام شامل موجودی)', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'wh1' });
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1' }]);
        (prisma.productModel.findMany as any).mockResolvedValue([]);
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (tx.$queryRaw as any)
            .mockResolvedValueOnce([{ productId: 'p1' }])
            .mockResolvedValueOnce([{ productId: 'p1', available: 5 }])
            .mockResolvedValueOnce([]);

        await expect(
            ordersService.createOrder(
                'wh1', 'user1', [{ productId: 'p1', quantity: 10 }],
                'باربری',
            )
        ).rejects.toThrow('موجودی کافی نیست (موجودی: 5)');
        expect(tx.order.create).not.toHaveBeenCalled();
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
        // اعتبارسنجی اقلام: محصول وجود دارد + مدل متعلق است + موجودی کافی
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1' }]);
        (prisma.productModel.findMany as any).mockResolvedValue([{ id: 'm1', productId: 'p1' }]);
        (tx.$queryRaw as any)
            .mockResolvedValueOnce([{ productId: 'p1' }])
            .mockResolvedValueOnce([{ productId: 'p1', available: 10 }])
            .mockResolvedValueOnce([]);

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

    it('محصول ناموجود در اقلام ویرایش → AppError', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(existingOrder());
        const tx = makeTx();
        tx.order.updateMany = vi.fn().mockResolvedValue({ count: 1 });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1' }]);

        await expect(
            ordersService.updateOrder('o1', {
                items: [{ productId: 'p99', quantity: 1 }],
                version: 2,
            })
        ).rejects.toThrow('محصول یافت نشد');
        expect(tx.orderItem.deleteMany).not.toHaveBeenCalled();
    });

    it('مدلی که متعلق به محصول نیست در ویرایش → AppError', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(existingOrder());
        const tx = makeTx();
        tx.order.updateMany = vi.fn().mockResolvedValue({ count: 1 });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1' }]);
        (prisma.productModel.findMany as any).mockResolvedValue([{ id: 'm9', productId: 'p2' }]);

        await expect(
            ordersService.updateOrder('o1', {
                items: [{ productId: 'p1', quantity: 1, modelId: 'm9' }],
                version: 2,
            })
        ).rejects.toThrow('مدل انتخاب‌شده متعلق به این محصول نیست');
    });

    it('موجودی ناکافی در ویرایش اقلام → AppError', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(existingOrder());
        const tx = makeTx();
        tx.order.updateMany = vi.fn().mockResolvedValue({ count: 1 });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1' }]);
        (prisma.productModel.findMany as any).mockResolvedValue([]);
        (tx.$queryRaw as any)
            .mockResolvedValueOnce([{ productId: 'p1' }])
            .mockResolvedValueOnce([{ productId: 'p1', available: 3 }])
            .mockResolvedValueOnce([]);

        await expect(
            ordersService.updateOrder('o1', {
                items: [{ productId: 'p1', quantity: 5 }],
                version: 2,
            })
        ).rejects.toThrow('موجودی کافی نیست (موجودی: 3)');
    });
});

describe('ordersService.listOrders', () => {
    const mappedRow = (id: string) => ({
        id,
        version: 3,
        status: 'PENDING',
        shippingMethod: 'باربری',
        carrier: null,
        city: null,
        postalCode: null,
        address: null,
        customerPhone: null,
        senderName: 'الف',
        receiverName: 'ب',
        createdAt: new Date(),
        updatedAt: new Date(),
        warehouse: { name: 'انبار ۱' },
        delivery: null,
        badges: [],
        items: [],
    });

    it('نسخهٔ سفارش و شمارندهٔ وضعیت‌ها در پاسخ می‌آید', async () => {
        (prisma.order.findMany as any).mockResolvedValue([mappedRow('o1'), mappedRow('o2')]);
        (prisma.order.count as any).mockResolvedValue(10);
        (prisma.$queryRaw as any).mockResolvedValue([
            { key: 'pending', count: 4 },
            { key: 'in_transit', count: 3 },
            { key: 'delivered', count: 2 },
            { key: 'other', count: 1 },
        ]);
        (prisma.$transaction as any).mockImplementation(async (arr: any[]) => Promise.all(arr));

        const res = await ordersService.listOrders(1, 10);

        expect(res.orders[0].version).toBe(3);
        expect(res.pagination.total).toBe(10);
        expect(res.counts).toEqual({ total: 10, pending: 4, inTransit: 3, delivered: 2, other: 1 });
    });

    it('فیلتر وضعیت pending به لیست و شمارندهٔ total اعمال می‌شود', async () => {
        (prisma.order.findMany as any).mockResolvedValue([mappedRow('o1')]);
        (prisma.order.count as any).mockResolvedValue(1);
        (prisma.$queryRaw as any).mockResolvedValue([
            { key: 'pending', count: 1 },
            { key: 'in_transit', count: 0 },
            { key: 'delivered', count: 0 },
            { key: 'other', count: 0 },
        ]);
        (prisma.$transaction as any).mockImplementation(async (arr: any[]) => Promise.all(arr));

        const res = await ordersService.listOrders(1, 10, 'pending');

        expect(prisma.order.findMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: { status: 'PENDING' } })
        );
        expect(prisma.order.count).toHaveBeenCalledWith({ where: { status: 'PENDING' } });
        expect(res.pagination.total).toBe(1);
    });
});

describe('ordersService.getOrderStock', () => {
    it('انبار ناموجود → null', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue(null);
        const res = await ordersService.getOrderStock('nope', ['p1']);
        expect(res).toBeNull();
    });

    it('موجودی هر محصول بر اساس منطق کارتن/لِگاسی', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'wh1' });
        (prisma.$queryRaw as any)
            .mockResolvedValueOnce([{ productId: 'p1' }])
            .mockResolvedValueOnce([{ productId: 'p1', available: 7 }])
            .mockResolvedValueOnce([{ productId: 'p2', legacyCount: 12 }]);

        const res = await ordersService.getOrderStock('wh1', ['p1', 'p2']);

        expect(res).toEqual([
            { productId: 'p1', available: 7 },
            { productId: 'p2', available: 12 },
        ]);
    });
});

describe('ordersService.deleteOrder', () => {
    it('سفارش یافت نشد AppError 404', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(null);
        await expect(ordersService.deleteOrder('nonexistent')).rejects.toThrow('سفارش یافت نشد');
    });

    it('وقتی کارتنی خروج خورده باشد قابل حذف نیست', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1' });
        const tx = makeTx();
        tx.carton.findMany = vi.fn().mockResolvedValue([{ scannedOutAt: new Date() }]);
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        await expect(ordersService.deleteOrder('o1')).rejects.toThrow('قابل حذف نیست');
        expect(tx.order.delete).not.toHaveBeenCalled();
    });

    it('وقتی سفارش وارد مرحله ارسال شده باشد قابل حذف نیست', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1' });
        const tx = makeTx();
        tx.carton.findMany = vi.fn().mockResolvedValue([{ scannedOutAt: null }]);
        tx.delivery.findUnique = vi.fn().mockResolvedValue({ id: 'd1' });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        await expect(ordersService.deleteOrder('o1')).rejects.toThrow('قابل حذف نیست');
    });

    it('حذف موفق: جدا کردن کارتنها + حذف سفارش + لاگ + outbox', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({
            id: 'o1', warehouseId: 'wh1', senderName: 'الف', receiverName: 'ب', createdById: 'u1',
        });

        const tx = makeTx();
        tx.carton.findMany = vi.fn().mockResolvedValue([{ scannedOutAt: null }]);
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
