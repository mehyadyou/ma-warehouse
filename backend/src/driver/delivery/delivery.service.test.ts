import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        order: { findUnique: vi.fn(), findMany: vi.fn() },
        delivery: { findMany: vi.fn(), upsert: vi.fn() },
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
    it('تحویل موفق: قفل شرطی + ساخت رکورد تحویل با راننده + لاگ + outbox', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({
            id: 'o1', status: 'SHIPPED', receiverName: 'رضا', city: 'تهران',
        });
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1', status: 'DELIVERED' });

        const result = await deliveryService.deliverOrder('o1', 'd1', 'تحویل شد');

        expect(tx.order.updateMany).toHaveBeenCalledWith({
            where: { id: 'o1', status: 'SHIPPED' },
            data: expect.objectContaining({ status: 'DELIVERED' }),
        });
        expect(tx.delivery.upsert).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { orderId: 'o1' },
                create: expect.objectContaining({ orderId: 'o1', driverId: 'd1', status: 'DELIVERED', notes: 'تحویل شد' }),
            })
        );
        expect(tx.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order_completed', userId: 'd1' }) })
        );
        expect(tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'delivery:completed', aggregate: 'delivery' }) })
        );
        expect(result.order?.status).toBe('DELIVERED');
    });

    it('سفارش در وضعیت ارسال نیست → AppError 400', async () => {
        (prisma.order.findUnique as any).mockResolvedValue({ id: 'o1', status: 'PENDING' });
        const tx = makeTx();
        tx.order.updateMany = vi.fn().mockResolvedValue({ count: 0 });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(deliveryService.deliverOrder('o1', 'd1')).rejects.toThrow('در وضعیت ارسال نیست');
        expect(tx.delivery.upsert).not.toHaveBeenCalled();
        expect(tx.outboxEvent.create).not.toHaveBeenCalled();
    });

    it('سفارش یافت نشد → AppError 404', async () => {
        (prisma.order.findUnique as any).mockResolvedValue(null);
        await expect(deliveryService.deliverOrder('nonexistent', 'd1')).rejects.toThrow('سفارش یافت نشد');
    });
});

describe('deliveryService.getMyDeliveries', () => {
    it('فقط تحویل‌های همین راننده را از جدول Delivery می‌خواند', async () => {
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

    it('فیلتر تاریخ روی deliveredAt اعمال می‌شود', async () => {
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
