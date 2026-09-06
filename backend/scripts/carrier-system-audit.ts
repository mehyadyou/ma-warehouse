import { prisma } from '../src/utils/prisma';

/// ممیزی عمیق سیستم باربری — فقط‌خواندنی
const normalize = (s: string) =>
  s
    .trim()
    .replace(/[\u200B-\u200F\u202A-\u202E\u2066-\u2069]/g, '')
    .replace(/\s+/g, ' ')
    .toLowerCase();

(async () => {
  try {
    console.log('════ ۱) جدول باربری‌ها (صف انباردار) ════');
    const carriers = await prisma.carrier.findMany({
      orderBy: [{ priority: 'asc' }, { name: 'asc' }],
    });
    for (const c of carriers) {
      const hasInvisible = /[\u200B-\u200F\u202A-\u202E\u2066-\u2069]/.test(c.name);
      const hasEdgeSpace = c.name !== c.name.trim();
      console.log(
        `  p=${String(c.priority).padStart(2)}  "${c.name}"  norm="${normalize(c.name)}"${hasInvisible ? '  ⚠ کاراکتر نامرئی' : ''}${hasEdgeSpace ? '  ⚠ فاصلهٔ ابتدا/انتها' : ''}`,
      );
    }

    // نام‌های نرمال‌شدهٔ تکراری → تطبیق مبهم
    console.log('\n════ ۲) نام‌های نرمال‌شدهٔ تکراری (ریسک تطبیق مبهم) ════');
    const byNorm = new Map<string, string[]>();
    for (const c of carriers) {
      const k = normalize(c.name);
      byNorm.set(k, [...(byNorm.get(k) ?? []), c.name]);
    }
    const dups = [...byNorm.entries()].filter(([, v]) => v.length > 1);
    if (dups.length === 0) console.log('  ✅ هیچ تکراری نیست');
    for (const [k, names] of dups) {
      console.log(`  ⚠ «${k}» ← [${names.join(' | ')}] — اولویت مبهم!`);
    }

    console.log('\n════ ۳) سفارش‌ها در برابر صف (کیفیت تطبیق نام) ════');
    const candidates = carriers
      .map((c) => ({ name: normalize(c.name), priority: c.priority }))
      .filter((c) => c.name.length > 0)
      .sort((a, b) => b.name.length - a.name.length);
    const exact = new Map(candidates.map((c) => [c.name, c.priority]));

    const orders = await prisma.order.findMany({
      select: { orderNumber: true, status: true, carrier: true, shippingMethod: true, warehouseId: true },
      orderBy: { orderNumber: 'asc' },
    });
    let unmatched = 0;
    let ambiguous = 0;
    for (const o of orders) {
      if (o.shippingMethod !== 'باربری') continue; // تیپاکس صف باربری ندارد
      const raw = o.carrier ?? '';
      if (!raw.trim()) {
        unmatched++;
        console.log(`  ⚠ #${o.orderNumber} [${o.status}] باربری=NULL → ته صف`);
        continue;
      }
      const key = normalize(raw);
      let p = exact.get(key);
      let how = 'exact';
      if (p === undefined) {
        const hits = candidates.filter((c) => key.includes(c.name) || c.name.includes(key));
        if (hits.length > 1) {
          ambiguous++;
          console.log(
            `  ⚠ #${o.orderNumber} [${o.status}] "${raw}" → ${hits.length} تطبیق: [${hits.map((h) => `p${h.priority}`).join(', ')}] — طولانی‌ترین برنده می‌شود`,
          );
          p = hits[0].priority;
          how = 'fuzzy(ambiguous)';
        } else if (hits.length === 1) {
          p = hits[0].priority;
          how = 'fuzzy';
        }
      }
      if (p === undefined) {
        unmatched++;
        console.log(`  ✗ #${o.orderNumber} [${o.status}] "${raw}" → بدون تطبیق (ته صف، p=99)`);
      } else if (how !== 'exact') {
        console.log(`  ~ #${o.orderNumber} [${o.status}] "${raw}" → تطبیق ${how} p=${p}`);
      }
    }
    if (unmatched === 0 && ambiguous === 0) console.log('  ✅ همهٔ سفارش‌های باربری تطبیق تمیز دارند');

    console.log('\n════ ۴) توزیع راننده در Deliveryها ════');
    const noDriver = await prisma.order.count({
      where: { status: { in: ['PENDING', 'SHIPPED'] }, delivery: null },
    });
    console.log(`  سفارش‌های PENDING/SHIPPED بدون راننده: ${noDriver}`);

    console.log('\n════ ۵) کنترل‌های نرم (بدون دیتا) ════');
    console.log('  - POST /manager/carriers (مسیر قدیمی مدیر) هنوز فعال است و اولویت دلخواه می‌پذیرد');
    console.log('  - جدول Carrier سراسری است (بدون warehouseId) — صف برای همهٔ انبارها مشترک است');
  } catch (e: any) {
    console.error('AUDIT-FAIL', e?.message ?? e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
