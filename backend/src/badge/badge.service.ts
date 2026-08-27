import { prisma } from '../utils/prisma';

const orderSelect = {
    select: {
        id: true,
        warehouseId: true,
        status: true,
        createdAt: true,
        shippingMethod: true,
        carrier: true,
        city: true,
        postalCode: true,
        address: true,
        customerPhone: true,
        senderName: true,
        senderNationalId: true,
        senderPhone: true,
        receiverName: true,
        warehouse: { select: { name: true } },
    },
} as const;

export const badgeService = {
    /// لیست بیجک‌های یک انبار مشخص — انباردار فقط بیجکِ انبارِ خودش را می‌بیند
    listForWarehouse: async (warehouseId: string, orderId?: string, limit = 200) => {
        return prisma.badge.findMany({
            where: {
                ...(orderId ? { orderId } : {}),
                order: { is: { warehouseId } },
            },
            include: { order: orderSelect },
            orderBy: { createdAt: 'desc' },
            take: Math.min(limit, 500),
        });
    },

    /// بیجک یک سفارش ولی فقط اگر به انبارِ داده‌شده تعلق داشته باشد
    listByOrderForWarehouse: async (orderId: string, warehouseId: string) => {
        const badges = await prisma.badge.findMany({
            where: {
                orderId,
                order: { is: { warehouseId } },
            },
            include: { order: orderSelect },
            orderBy: { createdAt: 'asc' },
        });
        if (badges.length === 0) return null;
        return badges;
    },
};
