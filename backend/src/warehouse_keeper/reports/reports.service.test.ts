import { describe, it, expect, vi, beforeEach } from 'vitest';
import { getKeeperReports } from './reports.service';

const mocks = vi.hoisted(() => ({
  transactions: vi.fn(),
  orders: vi.fn(),
  activityLogGroupBy: vi.fn(),
  activityLogFindMany: vi.fn(),
}));

vi.mock('../../utils/prisma', () => ({
  prisma: {
    transaction: { findMany: mocks.transactions },
    order: { findMany: mocks.orders },
    activityLog: {
      groupBy: mocks.activityLogGroupBy,
      findMany: mocks.activityLogFindMany,
    },
  },
}));

const filter = {
  warehouseId: 'wh1',
  userId: 'keeper1',
  from: new Date('2026-08-01T00:00:00.000Z'),
  toExclusive: new Date('2026-08-21T00:00:00.000Z'),
  scope: 'mine' as const,
};

const log = (type: string, label = 'عملیات') => ({
  type,
  label,
  createdAt: new Date('2026-08-10T10:00:00.000Z'),
});

beforeEach(() => {
  vi.clearAllMocks();
});

describe('getKeeperReports', () => {
  it('خلاصه، سری روزانه و رتبه‌بندی محصولات را از تراکنش‌ها می‌سازد', async () => {
    mocks.transactions.mockResolvedValue([
      // ورود ۲۰ واحد از A در روز ۱
      { type: 'IN', quantity: 20, productName: 'A', createdAt: new Date('2026-08-01T08:00:00.000Z') },
      // خروج ۵ واحد از A + ۳ واحد از B در روز ۲
      { type: 'OUT', quantity: 5, productName: 'A', createdAt: new Date('2026-08-02T09:00:00.000Z') },
      { type: 'OUT', quantity: 3, productName: 'B', createdAt: new Date('2026-08-02T10:00:00.000Z') },
      // مرجوعی ۲ واحد
      { type: 'RETURN', quantity: 2, productName: 'C', createdAt: new Date('2026-08-02T11:00:00.000Z') },
    ]);
    mocks.orders.mockResolvedValue([
      { status: 'SHIPPED', createdAt: new Date('2026-08-01T09:00:00.000Z') },
      { status: 'PENDING', createdAt: new Date('2026-08-02T09:00:00.000Z') },
    ]);
    mocks.activityLogGroupBy.mockResolvedValue([
      { type: 'product_checkin', _count: { _all: 3 } },
      { type: 'order_shipped', _count: { _all: 1 } },
    ]);
    mocks.activityLogFindMany.mockResolvedValue([log('product_checkin', 'ورود کالا')]);

    const r = await getKeeperReports(filter);

    expect(r.summary).toEqual({
      inUnits: 20,
      outUnits: 8,
      returnUnits: 2,
      outCount: 2,
      checkinCount: 3,
      returnReceivedCount: 0,
      ordersShipped: 1,
      transfersExecuted: 0,
      driverAssignments: 0,
      myActions: 4,
    });

    expect(r.daily).toEqual([
      { date: '2026-08-01', inUnits: 20, outUnits: 0 },
      { date: '2026-08-02', inUnits: 0, outUnits: 8 },
    ]);

    expect(r.topIn).toEqual([{ name: 'A', units: 20 }]);
    expect(r.topOut).toEqual([
      { name: 'A', units: 5 },
      { name: 'B', units: 3 },
    ]);

    expect(r.ordersByStatus).toEqual([
      { status: 'SHIPPED', count: 1 },
      { status: 'PENDING', count: 1 },
    ]);

    expect(r.recent).toHaveLength(1);
    expect(r.recent[0]).toMatchObject({ type: 'product_checkin', label: 'ورود کالا' });
  });

  it('scope=mine تراکنش‌ها و لاگ‌ها را با userId خود انباردار فیلتر می‌کند', async () => {
    mocks.transactions.mockResolvedValue([]);
    mocks.orders.mockResolvedValue([]);
    mocks.activityLogGroupBy.mockResolvedValue([]);
    mocks.activityLogFindMany.mockResolvedValue([]);

    await getKeeperReports(filter);

    expect(mocks.transactions).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ userId: 'keeper1', warehouseId: 'wh1' }),
      }),
    );
    expect(mocks.activityLogFindMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ userId: 'keeper1' }),
      }),
    );
  });

  it('scope=all تراکنش‌ها را کل انبار و لاگ‌ها را همهٔ انباردارها می‌گیرد', async () => {
    mocks.transactions.mockResolvedValue([]);
    mocks.orders.mockResolvedValue([]);
    mocks.activityLogGroupBy.mockResolvedValue([]);
    mocks.activityLogFindMany.mockResolvedValue([]);

    await getKeeperReports({ ...filter, scope: 'all' });

    const txWhere = mocks.transactions.mock.calls[0][0].where;
    expect(txWhere).not.toHaveProperty('userId');
    expect(txWhere.warehouseId).toBe('wh1');

    const logWhere = mocks.activityLogFindMany.mock.calls[0][0].where;
    expect(logWhere.user).toEqual({ warehouseId: 'wh1', role: 'WAREHOUSE_KEEPER' });
    expect(logWhere).not.toHaveProperty('userId');
  });

  it('رتبه‌بندی محصولات را به ۶ مورد برتر محدود می‌کند', async () => {
    const tx = (name: string, q: number, date: Date) => ({ type: 'OUT', quantity: q, productName: name, createdAt: date });
    mocks.transactions.mockResolvedValue(
      Array.from({ length: 8 }, (_, i) => tx(`P${i}`, i + 1, new Date('2026-08-05T10:00:00.000Z'))),
    );
    mocks.orders.mockResolvedValue([]);
    mocks.activityLogGroupBy.mockResolvedValue([]);
    mocks.activityLogFindMany.mockResolvedValue([]);

    const r = await getKeeperReports(filter);

    expect(r.topOut).toHaveLength(6);
    expect(r.topOut[0].name).toBe('P7');
  });
});