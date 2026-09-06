import { prisma } from '../../utils/prisma';

/// نرمال‌سازی نام باربری برای مقایسه — حذف نیم‌فاصله/کاراکترهای نامرئی (ZWNJ و
/// علائم bidi)، یکسان‌سازی فاصله‌ها و حروف — تا اختلاف نامرئی صف را نشکند
const normalizeCarrierName = (s: string) =>
  s
    .trim()
    .replace(/[\u200B-\u200F\u202A-\u202E\u2066-\u2069]/g, '')
    .replace(/\s+/g, ' ')
    .toLowerCase();

export const loadingPlanService = {
  /// فقط سفارش‌هایی که انباردار هنگام خروج محصول به همین راننده تخصیص داده
  /// (رکورد Delivery با driverId این راننده) — نه همهٔ سفارش‌های انبار.
  getLoadingPlan: async (driverId: string, warehouseId: string) => {
    const carriers = await prisma.carrier.findMany({
      select: { name: true, priority: true },
    });

    // تطبیق دقیق روی نام نرمال‌شده + تطبیق تقریبی برای نام‌های تغییرکرده:
    // سفارش‌های قبلی نام باربری را در لحظهٔ ثبت نگه داشته‌اند — اگر انباردار بعداً
    // باربری را تغییرنام دهد (مثلاً «باربری فارس» → «فارس»)، سفارش‌های قدیمی دیگر
    // با تطبیق دقیق پیدا نمی‌شوند و همیشه ته صف می‌مانند. تطبیق تقریبی (یکی شامل
    // دیگری) همین را حل می‌کند؛ در چندتایی‌بودن، طولانی‌ترین نام (مشخص‌ترین) برنده است.
    const exactPriority = new Map(
      carriers.map((c) => [normalizeCarrierName(c.name), c.priority]),
    );
    const candidates = carriers
      .map((c) => ({ name: normalizeCarrierName(c.name), priority: c.priority }))
      .filter((c) => c.name.length > 0)
      .sort((a, b) => b.name.length - a.name.length);

    const priorityCache = new Map<string, number>();
    const getPriority = (carrierName: string): number => {
      if (!carrierName) return 99;
      const key = normalizeCarrierName(carrierName);
      const cached = priorityCache.get(key);
      if (cached !== undefined) return cached;

      let priority = exactPriority.get(key);
      if (priority === undefined) {
        const hit = candidates.find(
          (c) => key.includes(c.name) || c.name.includes(key),
        );
        priority = hit?.priority;
      }
      const resolved = priority ?? 99;
      priorityCache.set(key, resolved);
      return resolved;
    };

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
      // ترتیب قطعی درونِ هر باربری (کهنه‌ترین اول) — برای چیدمان کل صف فقط اولویتِ
      // باربری مهم است (sort پایدار است)، این فقط برای تست‌پذیری/پیش‌بینی‌پذیری است
      orderBy: { createdAt: 'asc' },
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

    // صف‌بندیِ سفارش‌های در انتظار هم طبق صف باربری انباردار — وقتی انباردار صف
    // باربری‌ها را جابه‌جا می‌کند، کل پنل راننده (چه بارِ خارج‌شده و چه در انتظار)
    // همان ترتیب را نشان دهد. داخلِ هر باربری، جدیدترین اول می‌ماند (خروجی پرزیما
    // createdAt نزولی است و مرتب‌سازی پایدار آن را برای هم‌اولویت‌ها حفظ می‌کند).

    // ترتیب صف بارگیری از منوی «باربری» انباردار می‌آید: اولویت ۰ = بالای صف =
    // دورترین = اولین بار (ته وانت) و پایین صف = نزدیک‌ترین = آخرین بار.
    // راننده دقیقاً به همین ترتیب بار می‌زند.
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

    const sortedPending = pendingOrders.sort(
      (a, b) => getPriority(a.carrier || '') - getPriority(b.carrier || ''),
    );

    const pending = sortedPending.map((o) => ({
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