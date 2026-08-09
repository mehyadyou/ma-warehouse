import { prisma } from '../../utils/prisma';

export const ordersService = {
  getReadyOrders: async (warehouseId: string) => {
    return prisma.order.findMany({
      where: { warehouseId, status: 'SHIPPED' },
      include: {
        items: {
          include: { product: { select: { name: true } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  },
};