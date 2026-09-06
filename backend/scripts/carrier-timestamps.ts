import { prisma } from '../src/utils/prisma';

/// بررسی داده‌ای صف: تاریخ‌ها و پیوستگی اولویت‌ها — فقط‌خواندنی
(async () => {
  try {
    const carriers = await prisma.carrier.findMany({ orderBy: { priority: 'asc' } });
    for (const c of carriers) {
      console.log(
        `p=${String(c.priority).padStart(2)}  "${c.name}"  createdAt=${c.createdAt.toISOString()}  updatedAt=${c.updatedAt.toISOString()}`,
      );
    }
    const prios = carriers.map((c) => c.priority).sort((a, b) => a - b);
    const contiguous = prios.every((p, i) => p === i);
    console.log('پیوستگی اولویت‌ها ۰..n-1:', contiguous ? '✅' : `❌ [${prios.join(',')}]`);
  } catch (e: any) {
    console.error('TS-FAIL', e?.message ?? e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
