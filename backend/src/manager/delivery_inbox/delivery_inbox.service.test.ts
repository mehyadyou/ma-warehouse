import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        delivery: { findMany: vi.fn() },
        user: { findMany: vi.fn() },
    },
}));

import { deliveryInboxService } from './delivery_inbox.service';
import { prisma } from '../../utils/prisma';
import { jalaliToGregorian } from '../../utils/jalali';

beforeEach(() => {
    vi.clearAllMocks();
    (prisma.delivery.findMany as any).mockResolvedValue([]);
});

describe('deliveryInboxService.list', () => {
    it('بدون فیلتر: فقط تحویل‌شده‌های دارای عکس بیجک', async () => {
        await deliveryInboxService.list({});

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        expect(callArgs.where).toEqual({
            status: 'DELIVERED',
            receiptUrl: { not: null },
        });
        expect(callArgs.orderBy).toEqual({ deliveredAt: 'desc' });
    });

    it('فیلتر راننده: driverId به where اضافه می‌شود', async () => {
        await deliveryInboxService.list({ driverId: 'd1' });

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        expect(callArgs.where.driverId).toBe('d1');
    });

    it('فیلتر سال شمسی: کل سال به بازهٔ میلادی تبدیل می‌شود', async () => {
        await deliveryInboxService.list({ year: 1405 });

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        expect(callArgs.where.deliveredAt).toEqual({
            gte: jalaliToGregorian(1405, 1, 1),
            lt: jalaliToGregorian(1406, 1, 1),
        });
    });

    it('فیلتر سال+ماه: بازهٔ همان ماه شمسی', async () => {
        await deliveryInboxService.list({ year: 1405, month: 6 });

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        expect(callArgs.where.deliveredAt).toEqual({
            gte: jalaliToGregorian(1405, 6, 1),
            lt: jalaliToGregorian(1405, 7, 1),
        });
    });

    it('فیلتر سال+ماه+روز: بازهٔ همان روز + یک روز', async () => {
        await deliveryInboxService.list({ year: 1405, month: 6, day: 15 });

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        const gte = jalaliToGregorian(1405, 6, 15);
        expect(callArgs.where.deliveredAt).toEqual({
            gte,
            lt: new Date(gte.getTime() + 24 * 60 * 60 * 1000),
        });
    });

    it('ماه اسفند: ماه بعد به سال بعد می‌رود', async () => {
        await deliveryInboxService.list({ year: 1405, month: 12 });

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        expect(callArgs.where.deliveredAt).toEqual({
            gte: jalaliToGregorian(1405, 12, 1),
            lt: jalaliToGregorian(1406, 1, 1),
        });
    });

    it('فیلتر روز بدون سال: بدون شرط تاریخ (کنترلر این حالت را ۴۰۰ می‌کند)', async () => {
        await deliveryInboxService.list({ day: 15 });

        const callArgs = (prisma.delivery.findMany as any).mock.calls[0][0];
        expect(callArgs.where.deliveredAt).toBeUndefined();
    });
});

describe('deliveryInboxService.listDrivers', () => {
    it('همهٔ راننده‌های فعال + راننده‌های دارای بیجک را از کاربران می‌خواند', async () => {
        (prisma.user.findMany as any).mockResolvedValue([
            { id: 'd1', name: 'علی', phone: '0912' },
            { id: 'd2', name: 'رضا', phone: '0935' },
        ]);

        await deliveryInboxService.listDrivers();

        const callArgs = (prisma.user.findMany as any).mock.calls[0][0];
        expect(callArgs.where.OR).toEqual([
            { role: 'DRIVER', isActive: true },
            {
                deliveries: {
                    some: { status: 'DELIVERED', receiptUrl: { not: null } },
                },
            },
        ]);
        expect((prisma.delivery.findMany as any)).not.toHaveBeenCalled();
    });

    it('نتیجه به‌ترتیب نام فارسی مرتب می‌شود', async () => {
        (prisma.user.findMany as any).mockResolvedValue([
            { id: 'd1', name: 'علی', phone: '0912' },
            { id: 'd2', name: 'رضا', phone: '0935' },
        ]);

        const drivers = await deliveryInboxService.listDrivers();

        expect(drivers.map((d: any) => d.name)).toEqual(['رضا', 'علی']);
    });

    it('بدون هیچ راننده‌ای: لیست خالی برمی‌گردد', async () => {
        (prisma.user.findMany as any).mockResolvedValue([]);

        const drivers = await deliveryInboxService.listDrivers();

        expect(drivers).toEqual([]);
    });
});