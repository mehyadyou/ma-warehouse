import { prisma } from '../../utils/prisma';
import { AppError } from '../../common/exceptions/AppError';
import type { Prisma } from '@prisma/client';

export const deliveryService = {
  deliverOrder: async (orderId: string, driverId: string, notes?: string, receiptUrl?: string) => {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: { warehouse: { select: { name: true } } },
    });
    if (!order) throw new AppError('سفارش یافت نشد', 404);
    // بیجک باربری پیش‌شرط تحویل است — بدون عکس، سفارش تحویل نمی‌شود
    if (!receiptUrl) throw new AppError('عکس بیجک باربری الزامی است', 400);

    const driver = await prisma.user.findUnique({
      where: { id: driverId },
      select: { name: true },
    });

    const now = new Date();
    await prisma.$transaction(async (tx) => {
      // قفل شرطی: فقط سفارشِ در حال ارسال قابل تحویل شدن است (ضد مسابقه)
      const updated = await tx.order.updateMany({
        where: { id: orderId, status: 'SHIPPED' },
        data: { status: 'DELIVERED', updatedAt: now },
      });
      if (updated.count !== 1) {
        throw new AppError('این سفارش در وضعیت ارسال نیست', 400);
      }

      // ساخت/به‌روزرسانی رکورد تحویل — تاریخچه‌ی راننده (#7) به این رکورد با driverId وابسته است
      await tx.delivery.upsert({
        where: { orderId },
        create: {
          orderId,
          driverId,
          status: 'DELIVERED',
          deliveredAt: now,
          notes: notes ?? null,
          receiptUrl,
        },
        update: {
          driverId,
          status: 'DELIVERED',
          deliveredAt: now,
          notes: notes ?? null,
          receiptUrl,
        },
      });

      await tx.activityLog.create({
        data: {
          type: 'order_completed',
          label: `سفارش ${order.receiverName ?? ''} ${order.city ?? ''} تحویل داده شد`,
          orderId,
          userId: driverId,
        },
      });

      await tx.outboxEvent.create({
        data: {
          aggregate: 'delivery',
          type: 'delivery:completed',
          payload: {
            orderId,
            orderNumber: order.orderNumber,
            driverId,
            driverName: driver?.name ?? null,
            receiverName: order.receiverName,
            city: order.city,
            carrier: order.carrier,
            warehouseId: order.warehouseId,
            warehouseName: order.warehouse?.name ?? null,
            receiptUrl,
            notes: notes ?? null,
            deliveredAt: now.toISOString(),
          },
        },
      });
    });

    const updatedOrder = await prisma.order.findUnique({ where: { id: orderId } });
    return { order: updatedOrder };
  },

  // فقط تحویل‌هایی که همین راننده ثبت کرده — نه همه‌ی سفارش‌های DELIVERED سیستم
  getMyDeliveries: async (driverId: string, date?: string) => {
    const where: Prisma.DeliveryWhereInput = { driverId };
    if (date) {
      const start = new Date(date);
      const end = new Date(date);
      end.setDate(end.getDate() + 1);
      where.deliveredAt = { gte: start, lt: end };
    }
    const deliveries = await prisma.delivery.findMany({
      where,
      include: {
        order: {
          include: {
            items: {
              include: { product: { select: { name: true } } },
            },
          },
        },
      },
      orderBy: { deliveredAt: 'desc' },
    });
    // شکل پاسخ قدیمی حفظ می‌شود: لیست سفارش‌ها (موبایل history_tab به همین شکل وابسته است)
    return deliveries.map((d) => d.order);
  },
};
