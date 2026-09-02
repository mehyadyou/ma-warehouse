import { prisma } from '../../utils/prisma';

export const ordersService = {
  /// فقط سفارش‌هایی که انباردار هنگام خروج محصول به همین راننده تخصیص داده
  /// (رکورد Delivery با driverId این راننده) — نه همهٔ سفارش‌های انبار.
  /// تحویل فقط روی SHIPPED مجاز است (کنترلر/سرویس تحویل).
  getReadyOrders: async (driverId: string, warehouseId: string) => {
    return prisma.order.findMany({
      where: {
        warehouseId,
        status: { in: ['PENDING', 'SHIPPED'] },
        delivery: { is: { driverId } },
      },
      include: {
        items: {
          include: { product: { select: { name: true } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  },
};