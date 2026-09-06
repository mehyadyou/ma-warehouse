import { prisma } from '../src/utils/prisma';

/// شمارش سفارش‌های ثبت‌شدهٔ هر انبار به تفکیک وضعیت — فقط‌خواندنی
(async () => {
  try {
    const warehouses = await prisma.warehouse.findMany({
      select: { id: true, name: true },
      orderBy: { name: 'asc' },
    });

    console.log('=== سفارش‌های ثبت‌شده به تفکیک انبار و وضعیت ===');
    let grandTotal = 0;
    for (const wh of warehouses) {
      const grouped = await prisma.order.groupBy({
        by: ['status'],
        _count: { _all: true },
        where: { warehouseId: wh.id },
      });
      const total = grouped.reduce((s, g) => s + g._count._all, 0);
      grandTotal += total;
      const parts = grouped
        .map((g) => `${g.status}=${g._count._all}`)
        .join('  ');
      console.log(`  ${wh.name} — مجموع ${total}${parts ? `  (${parts})` : ''}`);
    }
    console.log(`\nمجموع کل: ${grandTotal}`);
  } catch (e: any) {
    console.error('COUNT-FAIL', e?.message ?? e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
