import { prisma } from '../src/utils/prisma';

/// نرمال‌سازی نام برای مقایسه — حذف فاصله/نیم‌فاصله و کاراکترهای نامرئی
const normalize = (s: string) =>
  s
    .trim()
    .replace(/[\u200B-\u200F\u202A-\u202E\u2066-\u2069]/g, '') // ZWNJ/ bidi marks
    .replace(/\s+/g, ' ')
    .toLowerCase();

(async () => {
  try {
    const carriers = await prisma.carrier.findMany({
      orderBy: [{ priority: 'asc' }, { name: 'asc' }],
    });
    console.log('=== CARRIERS (صف انباردار: بالا = اولویت ۰ = اولین بار) ===');
    for (const c of carriers) {
      console.log(
        `  priority=${String(c.priority).padStart(3)}  id=${c.id}  name="${c.name}"  norm="${normalize(c.name)}"`,
      );
    }
    if (carriers.length === 0) console.log('  (هیچ باربری‌ای ثبت نشده!)');

    const byName = new Map(carriers.map((c) => [normalize(c.name), c]));

    const grouped = await prisma.order.groupBy({
      by: ['carrier', 'status', 'warehouseId'],
      _count: { _all: true },
      where: { status: { in: ['PENDING', 'SHIPPED'] } },
    });

    console.log('\n=== ORDERS grouped by carrier/status/warehouse ===');
    for (const g of grouped) {
      const raw = g.carrier ?? 'NULL';
      const match = g.carrier ? byName.get(normalize(g.carrier)) : undefined;
      const flag = !g.carrier
        ? '❌ carrier=NULL → همیشه آخر صف'
        : match
          ? `✅ matched priority=${match.priority}`
          : '❌ NO MATCH → priority=99 (آخر صف، بی‌تأثیر از چیدمان)';
      console.log(
        `  wh=${g.warehouseId ?? 'NULL'}  status=${g.status}  count=${g._count._all}  carrier="${raw}"  → ${flag}`,
      );
    }

    // سفارش‌های بدون Delivery (راننده‌ای تعریف نشده) — در پنل هیچ راننده‌ای نمی‌آیند
    const noDelivery = await prisma.order.count({
      where: { status: { in: ['PENDING', 'SHIPPED'] }, delivery: null },
    });
    console.log(`\n=== سفارش‌های PENDING/SHIPPED بدون Delivery (راننده) ===`);
    console.log(`  count=${noDelivery}`);
  } catch (e: any) {
    console.error('DEBUG-FAIL', e?.message ?? e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
