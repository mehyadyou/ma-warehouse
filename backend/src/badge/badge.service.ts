import { prisma } from '../utils/prisma';

export const badgeService = {
    list: async (orderId?: string, limit = 200) => {
        return prisma.badge.findMany({
            where: orderId ? { orderId } : undefined,
            include: {
                order: {
                    select: {
                        id: true,
                        status: true,
                        createdAt: true,
                        shippingMethod: true,
                        carrier: true,
                        city: true,
                        postalCode: true,
                        address: true,
                        warehouse: { select: { name: true } },
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
            take: Math.min(limit, 500),
        });
    },

    listByOrder: async (orderId: string) => {
        const badges = await prisma.badge.findMany({
            where: { orderId },
            include: {
                order: {
                    select: {
                        id: true,
                        status: true,
                        createdAt: true,
                        shippingMethod: true,
                        carrier: true,
                        city: true,
                        postalCode: true,
                        address: true,
                        warehouse: { select: { name: true } },
                    },
                },
            },
            orderBy: { sequence: 'asc' },
        });
        if (badges.length === 0) return null;
        return badges;
    },
};
