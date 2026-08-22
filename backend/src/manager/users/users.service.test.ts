import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        user: { findUnique: vi.fn() },
        transaction: { findMany: vi.fn(), count: vi.fn(), aggregate: vi.fn() },
        order: { findMany: vi.fn(), count: vi.fn() },
        delivery: { findMany: vi.fn(), count: vi.fn() },
    },
}));

import { usersService } from './users.service';
import { prisma } from '../../utils/prisma';

const userRow = { id: 'u1', name: 'علی', phone: '09120000000', role: 'KEEPER', avatarUrl: null, isActive: true, createdAt: new Date(), warehouse: { id: 'w1', name: 'انبار مرکزی' } };

beforeEach(() => {
    vi.clearAllMocks();
    (prisma.user.findUnique as any).mockResolvedValue(userRow);
    (prisma.transaction.findMany as any).mockResolvedValue([]);
    (prisma.order.findMany as any).mockResolvedValue([]);
    (prisma.delivery.findMany as any).mockResolvedValue([]);
    (prisma.transaction.count as any).mockResolvedValue(0);
    (prisma.transaction.aggregate as any).mockResolvedValue({ _sum: { quantity: 0 } });
    (prisma.order.count as any).mockResolvedValue(0);
    (prisma.delivery.count as any).mockResolvedValue(0);
});

describe('usersService.getUserReport', () => {
    it('کاربر یافت نشد → AppError 404', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(null);
        await expect(usersService.getUserReport('nope')).rejects.toThrow('کاربر یافت نشد');
    });

    it('totalCheckins فقط تراکنش‌های IN و totalReturns فقط RETURN را می‌شمارد', async () => {
        (prisma.transaction.count as any)
            .mockResolvedValueOnce(7) // IN
            .mockResolvedValueOnce(3); // RETURN

        const report = await usersService.getUserReport('u1');

        expect(report.stats.totalCheckins).toBe(7);
        expect(report.stats.totalReturns).toBe(3);
        expect(prisma.transaction.count).toHaveBeenNthCalledWith(1, { where: { userId: 'u1', type: 'IN' } });
        expect(prisma.transaction.count).toHaveBeenNthCalledWith(2, { where: { userId: 'u1', type: 'RETURN' } });
    });

    it('totalUnits مجموع واحدهای ورودی و مرجوعی است و OUT را شامل نمی‌شود', async () => {
        (prisma.transaction.aggregate as any).mockResolvedValue({ _sum: { quantity: 25 } });

        const report = await usersService.getUserReport('u1');

        expect(report.stats.totalUnits).toBe(25);
        expect(prisma.transaction.aggregate).toHaveBeenCalledWith({
            where: { userId: 'u1', type: { in: ['IN', 'RETURN'] } },
            _sum: { quantity: true },
        });
    });

    it('آخرین فعالیت بر اساس زمان مرتب می‌شود و اخیرترین رویداد را برمی‌گرداند', async () => {
        const t1 = new Date('2026-08-10T10:00:00Z');
        const t2 = new Date('2026-08-11T10:00:00Z');
        (prisma.transaction.findMany as any).mockResolvedValue([
            { id: 'tx1', type: 'IN', productName: 'اسپیکر', quantity: 4, createdAt: t1 },
            { id: 'tx2', type: 'RETURN', productName: 'اسپیکر', quantity: 1, createdAt: t2 },
        ]);

        const report = await usersService.getUserReport('u1');

        expect(report.lastActivity).toMatchObject({ type: 'RETURN', label: 'اسپیکر — تعداد 1' });
        expect(report.recentActivities[0].type).toBe('RETURN');
    });

    it('بدون هیچ رویدادی → lastActivity صفر و آمار صفر', async () => {
        const report = await usersService.getUserReport('u1');
        expect(report.lastActivity).toBeNull();
        expect(report.stats).toMatchObject({ totalCheckins: 0, totalUnits: 0, totalReturns: 0, totalOrders: 0, totalDeliveries: 0 });
    });
});