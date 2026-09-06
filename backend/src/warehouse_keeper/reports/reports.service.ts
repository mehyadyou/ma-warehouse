import { prisma } from '../../utils/prisma';

export type ReportsScope = 'mine' | 'all';

export interface KeeperReportsFilter {
  warehouseId: string;
  userId: string;
  /** شروع بازه (شامل) — نیمه‌شب */
  from: Date;
  /** پایان بازه (غیرشامل) — نیمه‌شبِ روزِ بعد */
  toExclusive: Date;
  scope: ReportsScope;
}

const dayKey = (d: Date): string => {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
};

/**
 * گزارش عملکرد انباردار — همه‌چیز در یک درخواست:
 * - خلاصهٔ ورود/خروج/مرجوعی (واحد و دفعات)
 * - سری روزانهٔ ورود در برابر خروج (نمودار میله‌ای)
 * - وضعیت سفارش‌های ثبت‌شده در بازه (نمودار دونات)
 * - پرمصرف‌ترین محصولات ورودی/خروجی (رتبه‌بندی)
 * - فعالیت‌های اخیر انباردارها (فید) + شمارش هر نوع عملکرد
 *
 * scope=mine → فقط اقدامات خودِ انباردار (تراکنش‌ها و لاگ‌های userId خودش)
 * scope=all  → همهٔ انباردارهای همان انبار (تراکنش‌ها و لاگ‌های کل انبار)
 * وضعیت سفارش‌ها همیشه کل انبار است (وضعیت سفارش به فرد خاصی وابسته نیست).
 */
export async function getKeeperReports(filter: KeeperReportsFilter) {
  const { warehouseId, userId, from, toExclusive, scope } = filter;
  const timeRange = { gte: from, lt: toExclusive };

  const [transactions, orders, typeCounts, logs] = await Promise.all([
    // تراکنش‌های ورود/خروج/مرجوعی — مبنای نمودارها و رتبه‌بندی محصولات
    prisma.transaction.findMany({
      where: {
        warehouseId,
        ...(scope === 'mine' ? { userId } : {}),
        createdAt: timeRange,
      },
      select: { type: true, quantity: true, productName: true, createdAt: true },
    }),
    // سفارش‌های ثبت‌شده در بازه — وضعیت فعلی آن‌ها + شمارش روزانه
    prisma.order.findMany({
      where: { warehouseId, createdAt: timeRange },
      select: { status: true, createdAt: true },
    }),
    // شمارش عملکردها به تفکیک نوع — خلاصهٔ رفتار انباردار(ها)
    prisma.activityLog.groupBy({
      by: ['type'],
      where: {
        ...(scope === 'mine'
          ? { userId }
          : { user: { warehouseId, role: 'WAREHOUSE_KEEPER' } }),
        createdAt: timeRange,
      },
      _count: { _all: true },
    }),
    // فید فعالیت‌های اخیر (۵۰ مورد آخر)
    prisma.activityLog.findMany({
      where: {
        ...(scope === 'mine'
          ? { userId }
          : { user: { warehouseId, role: 'WAREHOUSE_KEEPER' } }),
        createdAt: timeRange,
      },
      select: { type: true, label: true, createdAt: true },
      orderBy: { createdAt: 'desc' },
      take: 50,
    }),
  ]);

  // ── خلاصه و سری روزانه از تراکنش‌ها ──
  const dailyMap = new Map<string, { inUnits: number; outUnits: number }>();
  const topInMap = new Map<string, number>();
  const topOutMap = new Map<string, number>();
  let inUnits = 0;
  let outUnits = 0;
  let returnUnits = 0;
  let outCount = 0;

  for (const t of transactions) {
    const q = t.quantity ?? 0;
    const key = dayKey(t.createdAt);
    const bucket = dailyMap.get(key) ?? { inUnits: 0, outUnits: 0 };
    if (t.type === 'IN') {
      inUnits += q;
      bucket.inUnits += q;
      topInMap.set(t.productName, (topInMap.get(t.productName) ?? 0) + q);
    } else if (t.type === 'OUT') {
      outUnits += q;
      outCount += 1;
      bucket.outUnits += q;
      topOutMap.set(t.productName, (topOutMap.get(t.productName) ?? 0) + q);
    } else {
      returnUnits += q;
    }
    dailyMap.set(key, bucket);
  }

  const daily = [...dailyMap.entries()]
    .map(([date, v]) => ({ date, inUnits: v.inUnits, outUnits: v.outUnits }))
    .sort((a, b) => (a.date < b.date ? -1 : 1));

  const top = (map: Map<string, number>, n = 6) =>
    [...map.entries()]
      .map(([name, units]) => ({ name, units }))
      .sort((a, b) => b.units - a.units)
      .slice(0, n);

  // ── وضعیت سفارش‌ها (کل انبار) ──
  const statusMap = new Map<string, number>();
  for (const o of orders) {
    statusMap.set(o.status, (statusMap.get(o.status) ?? 0) + 1);
  }
  const ordersByStatus = [...statusMap.entries()].map(([status, count]) => ({
    status,
    count,
  }));

  // ── شمارش عملکردها به تفکیک نوع ──
  const typeCount = (type: string) =>
    typeCounts.find((g) => g.type === type)?._count._all ?? 0;

  const summary = {
    inUnits,
    outUnits,
    returnUnits,
    outCount,
    checkinCount: typeCount('product_checkin'),
    returnReceivedCount: typeCount('return_received'),
    ordersShipped: typeCount('order_shipped'),
    transfersExecuted:
      typeCount('product_transfer') + typeCount('product_exit'),
    driverAssignments: typeCount('order_updated'),
    myActions: typeCounts.reduce((s, g) => s + (g._count._all ?? 0), 0),
  };

  return {
    summary,
    daily,
    ordersByStatus,
    topIn: top(topInMap),
    topOut: top(topOutMap),
    recent: logs.map((l) => ({
      type: l.type,
      label: l.label,
      createdAt: l.createdAt.toISOString(),
    })),
  };
}