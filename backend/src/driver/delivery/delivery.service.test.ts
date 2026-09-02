import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        order: { findUnique: vi.fn(), findMany: vi.fn() },
        delivery: { findMany: vi.fn(), upsert: vi.fn() },
        user: { findUnique: vi.fn() },
    },
}));

import { deliveryService } from './delivery.service';
import { prisma } from '../../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

function makeTx(overrides: Record<string, any> = {}) {
    return {
        order: { updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
        delivery: { upsert: vi.fn().mockResolvedValue({}) },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
        ...overrides,
    };
}

describe('deliveryService.deliverOrder', () => {
    it('تحویل موفق: قفل شرطی + ساخت رکورد تحویل با بیجک + لاگ + outbox', async () => {
        (prisma.order.findUnique as any)
            .mockResolvedValueOnce({
                id: 'o1', status: 'SHIPPED', receiverName: 'رضا', city: 'تهران',
                orderNumber: 12, carrier: 'باربری آفتاب', warehouseId: 'w1',
                warehouse: { name: 'انبار مرکزی' },
            })
            .mockResolvedValueOnce({ id: 'o1', status: 'DELIVERED' });
        (prisma.user.findUnique as any).mockResolvedValue({ name: 'علی' });
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        const result = await deliveryService.deliverOrder('o1', 'd1', 'تحویل شد', '/uploads/receipts/bijak.jpg');

        expect(tx.order.updateMany).toHaveBeenCalledWith({
            where: { id: 'o1', status: 'SHIPPED' },
            data: expect.objectContaining({ status: 'DELIVERED' }),
        });
        expect(tx.delivery.upsert).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { orderId: 'o1' },
                create: expect.objectContaining({
                    orderId: 'o1', driverId: 'd1', status: 'DELIVERED', notes: 'تحویل شد',
                    receiptUrl: '/uploads/receipts/bijak.jpg',
                }),
            })
        );
        expect(tx.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order_completed', userId: 'd1' }) })
        );
        expect(tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({
                    type: 'delivery:completed',
                    aggregate: 'delivery',
                    payload: expect.objectContaining({
                        orderId: 'o1',
                        orderNumber: 12,
                        driverId: 'd1',
                        driverName: 'علی',
                        receiverName: 'رضا',
                        city: 'تهران',
                        carrier: 'باربری آفتاب',
                        warehouseId: 'w1',
                        warehouseName: 'انبار مرکزی',
                        receiptUrl: '/uploads/receipts/bijak.jpg',
                    }),
                }),
            })
        );
        expect(result.order?.status).toBe('DELIVERED');
    });

    it('بدون عکس بیجک → AppError 400 و هیچ رکوردی ساخته نمیشود', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1', status: 'SHIPPED', warehouse: null });
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(deliveryService.deliverOrder('o1', 'd1')).rejects.toThrow('عکس بیجک باربری الزامی است');
        expect(tx.delivery.upsert).not.toHaveBeenCalled();
        expect(tx.outboxEvent.create).not.toHaveBeenCalled();
    });

    it('سفارش در وضعیت ارسال نیست → AppError 400', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1', status: 'PENDING', warehouse: null });
        (prisma.user.findUnique as any).mockResolvedValue({ name: 'علی' });
        const tx = makeTx();
        tx.order.updateMany = vi.fn().mockResolvedValue({ count: 0 });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(deliveryService.deliverOrder('o1', 'd1', undefined, '/uploads/receipts/bijak.jpg')).rejects.toThrow('در وضعیت ارسال نیست');
        expect(tx.delivery.upsert).not.toHaveBeenCalled();
        expect(tx.outboxEvent.create).not.toHaveBeenCalled();
    });

    it('سفارش یافت نشد → AppError 404', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(null);
        await expect(deliveryService.deliverOrder('nonexistent', 'd1', undefined, '/uploads/receipts/bijak.jpg')).rejects.toThrow('سفارش یافت نشد');
    });
});

describe('deliveryService.getMyDeliveries', () => {
    it('فقط تحویلهای همین راننده را از جدول Delivery میخواند', async () => {
        (prisma.delivery.findMany as any).mockResolvedValue([
            { order: { id: 'o1', status: 'DELIVERED', city: 'تهران' } },
            { order: { id: 'o2', status: 'DELIVERED', city: 'شیراز' } },
        ]);

        const result = await deliveryService.getMyDeliveries('d1');

        expect(prisma.delivery.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: expect.objectContaining({ driverId: 'd1' }),
                include: expect.objectContaining({ order: expect.any(Object) }),
            })
        );
        expect(result).toEqual([
            expect.objectContaining({ id: 'o1' }),
            expect.objectContaining({ id: 'o2' }),
        ]);
    });

    it('فیلتر تاریخ روی deliveredAt اعمال میشود', async () => {
        (prisma.delivery.findMany as any).mockResolvedValue([]);

        await deliveryService.getMyDeliveries('d1', '2026-08-09');

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        expect(callArgs.where.driverId).toBe('d1');
        expect(callArgs.where.deliveredAt).toEqual({
            gte: new Date('2026-08-09'),
            lt: new Date('2026-08-10'),
        });
    });
});