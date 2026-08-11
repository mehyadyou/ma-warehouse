import { describe, it, expect, vi, beforeEach } from 'vitest';
import { warehouseService } from './warehouse.service';

const mocks = vi.hoisted(() => {
    const queryRaw = vi.fn();
    return { queryRaw };
});

vi.mock('../../utils/prisma', () => ({
    prisma: { $queryRaw: mocks.queryRaw },
}));

import { prisma } from '../../utils/prisma';

function makeOrder(id: string) {
    return {
        id,
        warehouseId: 'wh1',
        status: 'PENDING',
        createdById: 'u1',
        shippingMethod: 'باربری',
        carrier: null,
        city: 'تهران',
        postalCode: '12345',
        address: 'خیابان ۱',
        customerPhone: '0912',
        senderName: 'فرستنده',
        receiverName: 'گیرنده',
        createdAt: new Date(),
        updatedAt: new Date(),
        createdByName: 'مدیر',
    };
}

beforeEach(() => {
    vi.clearAllMocks();
});

describe('warehouseService.getOrders', () => {
    it('اقلام سفارش‌ها را در یک کوئری واحد می‌خواند و به هر سفارش متصل می‌کند', async () => {
        const orders = [makeOrder('o1'), makeOrder('o2')];
        const items = [
            { orderId: 'o1', id: 'i1', productId: 'p1', quantity: 2, productName: 'کالای A' },
            { orderId: 'o1', id: 'i2', productId: 'p2', quantity: 1, productName: 'کالای B' },
            { orderId: 'o2', id: 'i3', productId: 'p3', quantity: 5, productName: 'کالای C' },
        ];

        mocks.queryRaw.mockResolvedValueOnce(orders);
        mocks.queryRaw.mockResolvedValueOnce(items);

        const result = await warehouseService.getOrders('wh1');

        expect(result).toHaveLength(2);
        expect(result[0].items).toHaveLength(2);
        expect(result[1].items).toHaveLength(1);
        expect(result[0].items[0].productName).toBe('کالای A');
        expect(result[1].items[0].productName).toBe('کالای C');

        const secondCall = mocks.queryRaw.mock.calls[1];
        const templateParts = secondCall[0] as unknown as string[];
        const queryText = templateParts.join('');
        expect(queryText).toContain('SELECT oi."orderId"');
        expect(queryText).toContain('p.name as "productName"');
        expect(queryText).toContain('WHERE oi."orderId" IN (');
        expect(prisma.$queryRaw).toHaveBeenCalledTimes(2);
    });

    it('وقتی سفارشی وجود ندارد کوئری اقلام زده نمی‌شود', async () => {
        mocks.queryRaw.mockResolvedValueOnce([]);

        const result = await warehouseService.getOrders('wh1');

        expect(result).toHaveLength(0);
        expect(mocks.queryRaw).toHaveBeenCalledTimes(1);
    });

    it('سفارش بدون قلم آیتم خالی دارد', async () => {
        const orders = [makeOrder('o1')];
        mocks.queryRaw.mockResolvedValueOnce(orders);
        mocks.queryRaw.mockResolvedValueOnce([]);

        const result = await warehouseService.getOrders('wh1');

        expect(result[0].items).toEqual([]);
    });
});
