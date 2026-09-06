import { prisma } from '../src/utils/prisma';

/// فهرست سفارش‌های «خزایی» با باربریِ ثبت‌شده — فقط‌خواندنی
(async () => {
  try {
    const wh = await prisma.warehouse.findFirst({
      where: { name: 'خزایی' },
      select: { id: true, name: true },
    });
    if (!wh) {
      console.log('انبار خزایی پیدا نشد');
      return;
    }

    const orders = await prisma.order.findMany({
      where: { warehouseId: wh.id },
      select: {
        orderNumber: true,
        status: true,
        carrier: true,
        shippingMethod: true,
        city: true,
        receiverName: true,
        createdAt: true,
        delivery: { select: { driver: { select: { name: true } } } },
      },
      orderBy: { orderNumber: 'asc' },
    });

    console.log(`=== سفارش‌های انبار ${wh.name} (${orders.length} عدد) ===`);
    for (const o of orders) {
      console.log(
        `  #${o.orderNumber}  [${o.status}]  روش=${o.shippingMethod ?? '—'}  باربری="${o.carrier ?? 'ثبت نشده (NULL)'}"  شهر=${o.city ?? '—'}  گیرنده=${o.receiverName ?? '—'}  راننده=${o.delivery?.driver?.name ?? '—'}`,
      );
    }
  } catch (e: any) {
    console.error('LIST-FAIL', e?.message ?? e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
