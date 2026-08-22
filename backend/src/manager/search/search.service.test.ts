import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Prisma } from '@prisma/client';

const mocks = vi.hoisted(() => {
    const queryRaw = vi.fn();
    const orderItemFindMany = vi.fn();
    const orderFindMany = vi.fn();
    const orderCount = vi.fn();
    const transaction = vi.fn(async (arr: any[]) => Promise.all(arr));
    return { queryRaw, orderItemFindMany, orderFindMany, orderCount, transaction };
});

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $queryRaw: mocks.queryRaw,
        $transaction: mocks.transaction,
        orderItem: { findMany: mocks.orderItemFindMany },
        order: { findMany: mocks.orderFindMany, count: mocks.orderCount },
    },
}));

import { searchService } from './search.service';

function makeCarton(overrides: Record<string, any> = {}) {
    return {
        id: 'c1',
        productId: 'p1',
        serialNumber: 'S-123',
        status: 'IN_STOCK',
        entryType: 'MANUAL',
        isIndividual: false,
        createdAt: new Date(),
        scannedOutAt: null,
        productName: 'کالای A',
        unit: 'عدد',
        modelName: null,
        unitsPerBox: null,
        warehouseName: 'انبار ۱',
        orderId: null,
        senderName: null,
        receiverName: null,
        orderStatus: null,
        city: null,
        address: null,
        customerPhone: null,
        deliveryStatus: null,
        deliveredAt: null,
        driverName: null,
        ...overrides,
    };
}

function makeOrderRow(overrides: Record<string, any> = {}) {
    return {
        id: 'o1',
        status: 'PENDING',
        shippingMethod: null,
        carrier: null,
        city: null,
        postalCode: null,
        address: null,
        customerPhone: null,
        senderName: 'فرستنده',
        receiverName: 'گیرنده',
        createdAt: new Date(),
        updatedAt: new Date(),
        warehouse: { name: 'انبار ۱' },
        delivery: null,
        items: [{ id: 'i1', quantity: 2, model: null, price: null, product: { name: 'کالای A' } }],
        ...overrides,
    };
}

beforeEach(() => {
    vi.clearAllMocks();
});

describe('searchService.searchBySerial', () => {
    it('با warehouseId — فیلتر انبار به SQL اضافه می‌شود و سفارش‌های مرتبط هم محدود به همان انبار است', async () => {
        mocks.queryRaw.mockResolvedValueOnce([makeCarton()]);
        mocks.orderItemFindMany.mockResolvedValueOnce([
            { quantity: 2, order: { id: 'o9', status: 'PENDING', createdAt: new Date() } },
        ]);

        const result = await searchService.searchBySerial('S-123', 'wh1');

        expect(result).not.toBeNull();
        expect(result!.serialNumber).toBe('S-123');
        expect(mocks.orderItemFindMany).toHaveBeenCalledTimes(1);
        const findArgs = mocks.orderItemFindMany.mock.calls[0][0] as { where: { order?: object; productId: string } };
        expect(findArgs.where.order).toEqual({ warehouseId: 'wh1' });
    });

    it('بدون warehouseId — سفارش‌های مرتبط بدون محدودیت انبار خوانده می‌شوند (حالت مدیر)', async () => {
        mocks.queryRaw.mockResolvedValueOnce([makeCarton()]);
        mocks.orderItemFindMany.mockResolvedValueOnce([]);

        const result = await searchService.searchBySerial('S-123');

        expect(result).not.toBeNull();
        const findArgs = mocks.orderItemFindMany.mock.calls[0][0] as { where: { order?: object } };
        expect(findArgs.where.order).toBeUndefined();
        expect(result!.relatedOrders).toHaveLength(0);
    });

    it('وقتی کارتن به سفارش وصله شده، سفارش‌های مرتبط خوانده نمی‌شود', async () => {
        mocks.queryRaw.mockResolvedValueOnce([makeCarton({ orderId: 'o1' })]);

        const result = await searchService.searchBySerial('S-123', 'wh1');

        expect(result).not.toBeNull();
        expect(mocks.orderItemFindMany).not.toHaveBeenCalled();
    });

    it('وقتی کارتنی پیدا نشود null برمی‌گرداند و سفارش مرتبطی خوانده نمی‌شود', async () => {
        mocks.queryRaw.mockResolvedValueOnce([]);

        const result = await searchService.searchBySerial('ناموجود', 'wh1');

        expect(result).toBeNull();
        expect(mocks.orderItemFindMany).not.toHaveBeenCalled();
    });
});

describe('searchService.searchShipments', () => {
    it('با warehouseId — فیلتر انبار به where اضافه می‌شود', async () => {
        mocks.orderFindMany.mockResolvedValueOnce([makeOrderRow()]);
        mocks.orderCount.mockResolvedValueOnce(1);

        const result = await searchService.searchShipments({ sender: 'فرستنده', warehouseId: 'wh1' });

        expect(result.orders).toHaveLength(1);
        expect(result.orders[0].warehouseName).toBe('انبار ۱');
        expect(result.orders[0].items[0].productName).toBe('کالای A');
        const where = mocks.orderFindMany.mock.calls[0][0] as { where: { AND: Array<object | null> } };
        expect(where.where.AND[0]).toEqual({ warehouseId: 'wh1' });
    });

    it('بدون warehouseId — فیلتر انبار در where وجود ندارد (حالت مدیر)', async () => {
        mocks.orderFindMany.mockResolvedValueOnce([]);
        mocks.orderCount.mockResolvedValueOnce(0);

        const result = await searchService.searchShipments({ sender: 'فرستنده' });

        expect(result.orders).toHaveLength(0);
        expect(result.pagination.total).toBe(0);
        const where = mocks.orderFindMany.mock.calls[0][0] as { where: { AND: Array<object | null> } };
        expect(where.where.AND.some((c) => c !== null && 'warehouseId' in c)).toBe(false);
    });

    it('فیلتر محصول و مدل داخل items -> some قرار می‌گیرد', async () => {
        mocks.orderFindMany.mockResolvedValueOnce([]);
        mocks.orderCount.mockResolvedValueOnce(0);

        await searchService.searchShipments({ product: 'کالا', model: 'مدل X', warehouseId: 'wh1' });

        const where = mocks.orderFindMany.mock.calls[0][0] as { where: { AND: Array<object | null> } };
        const itemsFilter = where.where.AND[1] as { items: { some: object } };
        expect(itemsFilter.items.some).toBeDefined();
    });

    it('q متن آزاد → OR روی همهٔ فیلدها', async () => {
        mocks.orderFindMany.mockResolvedValueOnce([]);
        mocks.orderCount.mockResolvedValueOnce(0);

        await searchService.searchShipments({ q: 'شیراز' });

        const where = mocks.orderFindMany.mock.calls[0][0] as { where: { AND: Array<object | null> } };
        const orFilter = where.where.AND[0] as { OR: Array<object> };
        expect(orFilter.OR).toBeDefined();
        expect(orFilter.OR.length).toBeGreaterThan(1);
    });

    it('نقشه‌ی خروجی شامل راننده، تحویل و اقلام است', async () => {
        mocks.orderFindMany.mockResolvedValueOnce([
            makeOrderRow({
                delivery: {
                    status: 'DELIVERED',
                    deliveredAt: new Date(),
                    notes: null,
                    driver: { name: 'راننده ۱' },
                },
                items: [
                    { id: 'i1', quantity: 3, model: 'مدل A', price: 1000, product: { name: 'کالای B' } },
                ],
            }),
        ]);
        mocks.orderCount.mockResolvedValueOnce(1);

        const result = await searchService.searchShipments({ receiver: 'گیرنده', warehouseId: 'wh1' });

        expect(result.orders[0].deliveryStatus).toBe('DELIVERED');
        expect(result.orders[0].driverName).toBe('راننده ۱');
        expect(result.orders[0].items[0].productName).toBe('کالای B');
        expect(result.orders[0].items[0].price).toBe(1000);
    });
});