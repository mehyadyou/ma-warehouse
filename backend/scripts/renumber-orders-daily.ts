import { prisma } from '../src/utils/prisma';
import { jalaliDayKey } from '../src/utils/jalali';

/// بازشماره‌گذاری سفارش‌های موجود بر اساس «روزِ شمسیِ ساخت» — هر روز از ۱.
/// بعد از اعمال مهاجرت order_daily_number یک‌بار اجرا شود (دستور پیشنهادی):
///   npx ts-node scripts/renumber-orders-daily.ts
/// اسکریپت قابل تکرار است (idempotent): در اجرای مجدد همان شماره‌ها دوباره محاسبه می‌شوند.
(async () => {
  try {
    const all = await prisma.order.findMany({
      select: { id: true, createdAt: true },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
    });
    console.log(`=== بازشماره‌گذاری ${all.length} سفارش بر اساس روز شمسی ===`);

    // گروه‌بندی به ترتیب ساخت (ترتیب پایدار برای شماره‌گذاری داخل هر روز)
    const days: { key: number; rows: { id: string }[] }[] = [];
    const byKey = new Map<number, { key: number; rows: { id: string }[] }>();
    for (const o of all) {
      const key = jalaliDayKey(o.createdAt);
      let g = byKey.get(key);
      if (!g) {
        g = { key, rows: [] };
        byKey.set(key, g);
        days.push(g);
      }
      g.rows.push({ id: o.id });
    }

    let updated = 0;
    for (const day of days) {
      let seq = 0;
      await prisma.$transaction(async (tx) => {
        for (const row of day.rows) {
          seq += 1;
          await tx.order.updateMany({
            where: { id: row.id },
            data: { orderNumber: seq, orderDay: day.key },
          });
          updated += 1;
        }
      });
      console.log(`  روز ${day.key}: ${day.rows.length} سفارش → شمارهٔ ۱..${day.rows.length}`);
    }
    console.log(`\nتمام شد: ${updated} سفارش روزشمار شدند.`);
  } catch (e: any) {
    console.error('RENUMBER-FAIL', e?.message ?? e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
