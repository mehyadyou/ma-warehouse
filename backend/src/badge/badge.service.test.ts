import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../utils/prisma', () => ({
    prisma: {
        badge: { findMany: vi.fn(), updateMany: vi.fn() },
    },
}));

import { badgeService } from './badge.service';
import { prisma } from '../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

describe('badgeService - فیلتر انبار (امنیت)', () => {
    it('listForWarehouse بیجک‌های فقط همان انبار را برمی‌گرداند', async () => {
        (prisma.badge.findMany as any).mockResolvedValue([{ id: 'b1' }]);
        const res = await badgeService.listForWarehouse('wh1');
        expect(res).toHaveLength(1);
        expect(prisma.badge.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { order: { is: { warehouseId: 'wh1' } } },
            })
        );
    });

    it('listForWarehouse با orderId، هر دو شرط را اعمال می‌کند', async () => {
        (prisma.badge.findMany as any).mockResolvedValue([]);
        await badgeService.listForWarehouse('wh1', 'o1');
        expect(prisma.badge.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { orderId: 'o1', order: { is: { warehouseId: 'wh1' } } },
            })
        );
    });

    it('listForWarehouse با printed=true فقط چاپ‌شده‌ها را برمی‌گرداند', async () => {
        (prisma.badge.findMany as any).mockResolvedValue([]);
        await badgeService.listForWarehouse('wh1', undefined, 200, true);
        expect(prisma.badge.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: {
                    printedAt: { not: null },
                    order: { is: { warehouseId: 'wh1' } },
                },
            })
        );
    });

    it('listForWarehouse با printed=false فقط چاپ‌نشده‌ها را برمی‌گرداند', async () => {
        (prisma.badge.findMany as any).mockResolvedValue([]);
        await badgeService.listForWarehouse('wh1', undefined, 200, false);
        expect(prisma.badge.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: {
                    printedAt: null,
                    order: { is: { warehouseId: 'wh1' } },
                },
            })
        );
    });

    it('markPrinted فقط بیجک‌های انبارِ خودش را چاپ‌شده علامت می‌زند', async () => {
        (prisma.badge.updateMany as any).mockResolvedValue({ count: 2 });
        const res = await badgeService.markPrinted(['b1', 'b2'], 'wh1');
        expect(res).toEqual({ updated: 2 });
        expect(prisma.badge.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: {
                    id: { in: ['b1', 'b2'] },
                    order: { is: { warehouseId: 'wh1' } },
                },
                data: { printedAt: expect.any(Date) },
            })
        );
    });

    it('listByOrderForWarehouse فقط بیجکِ انبارِ داده‌شده را برمی‌گرداند', async () => {
        (prisma.badge.findMany as any).mockResolvedValue([{ id: 'b1' }]);
        const res = await badgeService.listByOrderForWarehouse('o1', 'wh1');
        expect(res).not.toBeNull();
        expect(prisma.badge.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { orderId: 'o1', order: { is: { warehouseId: 'wh1' } } },
            })
        );
    });

    it('listByOrderForWarehouse اگر انبارِ سفارش دیگری باشد null برمی‌گرداند', async () => {
        (prisma.badge.findMany as any).mockResolvedValue([]);
        const res = await badgeService.listByOrderForWarehouse('o1', 'wh2');
        expect(res).toBeNull();
    });
});