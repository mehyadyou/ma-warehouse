import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ordersService } from './orders.service';

const mocks = vi.hoisted(() => {
    const findMany = vi.fn();
    return { findMany };
});

vi.mock('../../utils/prisma', () => ({
    prisma: { order: { findMany: mocks.findMany } },
}));

beforeEach(() => {
    vi.clearAllMocks();
});

describe('ordersService.getReadyOrders', () => {
    it('فقط سفارش‌های تخصیص‌داده‌شده به همین راننده برمی‌گردد — نه همهٔ سفارش‌های انبار', async () => {
        mocks.findMany.mockResolvedValue([
            { id: 'o1', status: 'PENDING' },
            { id: 'o2', status: 'SHIPPED' },
        ]);

        const orders = await ordersService.getReadyOrders('d1', 'w1');

        const where = mocks.findMany.mock.calls[0][0].where;
        expect(where.warehouseId).toBe('w1');
        expect(where.status).toEqual({ in: ['PENDING', 'SHIPPED'] });
        // شرط کلیدی: رکورد Delivery با driverId رانندهٔ جاری
        expect(where.delivery).toEqual({ is: { driverId: 'd1' } });
        expect(orders).toHaveLength(2);
    });

    it('سفارش‌های تحویل‌شده و لغوشده در پنل راننده نیایند', async () => {
        mocks.findMany.mockResolvedValue([]);

        await ordersService.getReadyOrders('d1', 'w1');

        const where = mocks.findMany.mock.calls[0][0].where;
        expect(where.status).toEqual({ in: ['PENDING', 'SHIPPED'] });
        expect(where.status.in).not.toContain('DELIVERED');
        expect(where.status.in).not.toContain('CANCELED');
    });
});