import { prisma } from '../../utils/prisma';

export const loadingPlanService = {
  /// فقط سفارش‌هایی که انباردار هنگام خروج محصول به همین راننده تخصیص داده
  /// (رکورد Delivery با driverId این راننده) — نه همهٔ سفارش‌های انبار.
  getLoadingPlan: async (driverId: string, warehouseId: string) => {
    const carriers = await prisma.carrier.findMany({
      select: { name: true, priority: true },
    });
    const carrierPriority = new Map(carriers.map((c) => [c.name, c.priority]));

    // سفارش‌های خارج‌شده از انبار — برنامهٔ بارگیری واقعی (کارتن‌ها اسکن شده‌اند)
    const orders = await prisma.order.findMany({
      where: { warehouseId, status: 'SHIPPED', delivery: { is: { driverId } } },
      include: {
        items: {
          include: { product: { select: { name: true } } },
        },
        cartons: {
          where: { status: 'SHIPPED' },
          include: {
            product: { select: { name: true, unit: true } },
            model: { select: { name: true, unitsPerBox: true, packageType: true } },
          },
        },
      },
    });

    // سفارش‌های تازه‌ثبت‌شده (هنوز از انبار خارج نشده) — در پنل راننده با برچسب
    // «در انتظار خروج از انبار» دیده می‌شوند تا راننده بداند سفارش برایش هست
    const pendingOrders = await prisma.order.findMany({
      where: { warehouseId, status: 'PENDING', delivery: { is: { driverId } } },
      include: {
        items: {
          include: { product: { select: { name: true } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const getPriority = (carrierName: string) =>
      carrierPriority.get(carrierName) ?? 99;

    // ترتیب صف بارگیری از منوی «باربری» انباردار می‌آید: اولویت ۰ = بالای صف =
    // نزدیک‌ترین = اولین بار. راننده دقیقاً به همین ترتیب بار می‌زند.
    const sorted = orders.sort(
      (a, b) => getPriority(a.carrier || '') - getPriority(b.carrier || ''),
    );

    let sequence = 0;
    const plan = sorted.map(order => ({
      sequence: ++sequence,
      orderId: order.id,
      carrier: order.carrier || 'نامشخص',
      priority: getPriority(order.carrier || ''),
      city: order.city,
      postalCode: order.postalCode,
      address: order.address,
      customerPhone: order.customerPhone,
      senderName: order.senderName,
      receiverName: order.receiverName,
      totalCartons: order.cartons.length,
      cartons: order.cartons.map(c => ({
        id: c.id,
        qrUuid: c.qrUuid,
        productName: c.product.name,
        modelName: c.model?.name || '',
        unit: c.product.unit || 'عدد',
        packageType: c.model?.packageType || 'کارتن',
        capacityPerBox: c.model?.unitsPerBox || 1,
        isIndividual: c.isIndividual,
      })),
      items: order.items.map(i => ({
        productName: i.product.name,
        quantity: i.quantity,
        model: i.model,
      })),
    }));

    const pending = pendingOrders.map((o) => ({
      orderId: o.id,
      orderNumber: o.orderNumber,
      carrier: o.carrier || 'نامشخص',
      city: o.city,
      address: o.address,
      customerPhone: o.customerPhone,
      senderName: o.senderName,
      receiverName: o.receiverName,
      totalUnits: o.items.reduce((sum, i) => sum + Math.max(1, i.quantity || 1), 0),
      items: o.items.map((i) => ({
        productName: i.product.name,
        quantity: i.quantity,
        model: i.model,
      })),
      createdAt: o.createdAt,
    }));

    return { totalOrders: plan.length, plan, pendingOrders: pending };
  },
};