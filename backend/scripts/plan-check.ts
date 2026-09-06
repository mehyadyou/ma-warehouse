import { prisma } from '../src/utils/prisma';
import { loadingPlanService } from '../src/driver/loadingplan/loadingplan.service';

(async () => {
  try {
    const drivers = await prisma.user.findMany({
      where: { role: 'DRIVER', deletedAt: null },
      select: { id: true, name: true, warehouseId: true },
    });
    console.log(`drivers=${drivers.length}`);
    for (const d of drivers) {
      if (!d.warehouseId) {
        console.log(`  [${d.name}] به انباری متصل نیست`);
        continue;
      }
      const plan = await loadingPlanService.getLoadingPlan(d.id, d.warehouseId);
      console.log(`\n  راننده: ${d.name} — ${plan.totalOrders} سفارش آماده، ${plan.pendingOrders.length} در انتظار`);
      for (const p of plan.plan) {
        console.log(`    بار ${p.sequence}: carrier="${p.carrier}" priority=${p.priority}`);
      }
      for (const p of plan.pendingOrders) {
        console.log(`    در انتظار: سفارش ${p.orderNumber} carrier="${p.carrier}"`);
      }
    }
  } catch (e: any) {
    console.error('CHECK-FAIL', e?.message ?? e);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
})();
