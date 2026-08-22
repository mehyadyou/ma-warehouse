import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/cache', () => ({
    cached: (_key: string, _ttl: number, fn: () => Promise<unknown>) => fn(),
}));

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $queryRaw: vi.fn(),
    },
}));

import { dashboardService } from './dashboard.service';
import { prisma } from '../../utils/prisma';

const queryRaw = vi.mocked(prisma.$queryRaw);

function sqlText(callIndex: number): string {
    const args = queryRaw.mock.calls[callIndex];
    const parts = [...(args[0] as string[])];
    const inner = args[1] as { strings: string[] } | undefined;
    if (inner) parts.push(...inner.strings);
    return parts.join('');
}

function sqlValues(callIndex: number): unknown[] {
    const inner = queryRaw.mock.calls[callIndex][1] as { values: unknown[] } | undefined;
    return inner?.values ?? [];
}

beforeEach(() => {
    vi.clearAllMocks();
});

describe('dashboardService.getHistory', () => {
    it('بدون پارامتر — رفتار قبلی: ۵۰۰ ردیف اول و total کامل', async () => {
        queryRaw
            .mockResolvedValueOnce([{ count: 12 }])
            .mockResolvedValueOnce([{ id: 'a' }, { id: 'b' }]);

        const res = await dashboardService.getHistory();

        expect(queryRaw).toHaveBeenCalledTimes(2);
        expect(res).toMatchObject({
            entries: [{ id: 'a' }, { id: 'b' }],
            total: 12,
            page: 1,
            pageSize: 500,
        });
        expect(queryRaw.mock.calls[1][2]).toBe(500);
        expect(queryRaw.mock.calls[1][3]).toBe(0);
    });

    it('صفحه‌بندی + فیلتر دسته + جستجو → شرط‌های SQL و OFFSET درست', async () => {
        queryRaw
            .mockResolvedValueOnce([{ count: 42 }])
            .mockResolvedValueOnce([]);

        const res = await dashboardService.getHistory({ page: 3, pageSize: 20, category: 'users', q: 'علی' });

        const countSql = sqlText(0);
        expect(countSql).toContain('COUNT(*)::int');
        expect(countSql).toContain('"type" IN');
        expect(countSql).toContain('ILIKE');
        expect(sqlValues(0)).toContain('user_created');
        expect(sqlValues(0)).toContain('%علی%');

        const rowsSql = sqlText(1);
        expect(rowsSql).toContain('ORDER BY al."createdAt" DESC');
        expect(rowsSql).toContain('LIMIT');
        expect(queryRaw.mock.calls[1][2]).toBe(20);
        expect(queryRaw.mock.calls[1][3]).toBe(40);

        expect(res).toMatchObject({ total: 42, page: 3, pageSize: 20 });
    });

    it('دستهٔ نامعتبر → بدون فیلتر نوع (همهٔ وقایع)', async () => {
        queryRaw
            .mockResolvedValueOnce([{ count: 5 }])
            .mockResolvedValueOnce([]);

        await dashboardService.getHistory({ category: 'bogus' });

        expect(sqlText(0)).not.toContain('"type" IN');
    });

    it('pageSize بیشتر از سقف → به ۵۰۰ محدود می‌شود', async () => {
        queryRaw
            .mockResolvedValueOnce([{ count: 1 }])
            .mockResolvedValueOnce([]);

        await dashboardService.getHistory({ pageSize: 9999 });

        expect(queryRaw.mock.calls[1][2]).toBe(500);
    });

    it('صفحهٔ منفی/صفر → صفحهٔ ۱', async () => {
        queryRaw
            .mockResolvedValueOnce([{ count: 1 }])
            .mockResolvedValueOnce([]);

        await dashboardService.getHistory({ page: -2 });

        expect(queryRaw.mock.calls[1][3]).toBe(0);
    });
});

describe('dashboardService.getRecentActivities', () => {
    it('تراکنش تکراری ورود/مرجوعی در برابر لاگ همان ثانیه حذف می‌شود (لاگ می‌ماند)', async () => {
        queryRaw
            .mockResolvedValueOnce([
                { id: 'tx1', type: 'IN', title: 'اسپیکر', quantity: 3, createdAt: new Date('2026-08-18T10:00:00.500Z'), userName: 'علی', activityType: 'transaction' },
                { id: 'tx2', type: 'RETURN', title: 'ماوس', quantity: 1, createdAt: new Date('2026-08-18T11:00:00.200Z'), userName: 'علی', activityType: 'transaction' },
                { id: 'tx3', type: 'OUT', title: 'هدفون', quantity: 2, createdAt: new Date('2026-08-18T12:00:00.000Z'), userName: 'رضا', activityType: 'transaction' },
            ])
            .mockResolvedValueOnce([
                { id: 'log1', type: 'product_checkin', label: 'اسپیکر — 1 کارتن — ورود به انبار', createdAt: new Date('2026-08-18T10:00:00.100Z'), userName: 'علی', activityType: 'activityLog' },
                { id: 'log2', type: 'return_received', label: 'ماوس — بازگشت به انبار', createdAt: new Date('2026-08-18T11:00:00.100Z'), userName: 'علی', activityType: 'activityLog' },
            ]);

        const res = await dashboardService.getRecentActivities();

        // IN و RETURN حذف شدند، OUT می‌ماند
        expect(res.activities).toHaveLength(3);
        expect(res.activities.filter(a => a.activityType === 'transaction').map(a => a.id)).toEqual(['tx3']);
        expect(res.activities.filter(a => a.activityType === 'activityLog')).toHaveLength(2);
    });

    it('تراکنش بدون لاگ معادل (ثانیه متفاوت) حفظ می‌شود', async () => {
        queryRaw
            .mockResolvedValueOnce([
                { id: 'tx1', type: 'IN', title: 'اسپیکر', quantity: 3, createdAt: new Date('2026-08-18T10:00:59.500Z'), userName: 'علی', activityType: 'transaction' },
            ])
            .mockResolvedValueOnce([
                { id: 'log1', type: 'product_checkin', label: 'اسپیکر — ورود', createdAt: new Date('2026-08-18T10:01:00.100Z'), userName: 'علی', activityType: 'activityLog' },
            ]);

        const res = await dashboardService.getRecentActivities();

        expect(res.activities).toHaveLength(2);
    });

    it('مرتب‌سازی نزولی بر اساس زمان + برش به ۱۵', async () => {
        const logs = Array.from({ length: 15 }, (_, i) => ({
            id: `log${i}`,
            type: 'product_created',
            label: 'محصول',
            createdAt: new Date(2026, 7, 18, 10, 0, i),
            userName: 'علی',
            activityType: 'activityLog',
        }));
        const txs = [
            { id: 'tx1', type: 'OUT', title: 'کالا', quantity: 1, createdAt: new Date(2026, 7, 18, 12, 0, 0), userName: 'رضا', activityType: 'transaction' },
            { id: 'tx2', type: 'IN', title: 'کالا', quantity: 1, createdAt: new Date(2026, 7, 18, 9, 0, 0), userName: 'رضا', activityType: 'transaction' },
        ];
        queryRaw.mockResolvedValueOnce(txs).mockResolvedValueOnce(logs);

        const res = await dashboardService.getRecentActivities();

        expect(res.activities).toHaveLength(15);
        // جدیدترین (۱۲:۰۰) اول است
        expect(res.activities[0].id).toBe('tx1');
        const times = res.activities.map(a => new Date(a.createdAt as Date).getTime());
        expect(times).toEqual([...times].sort((a, b) => b - a));
    });
});
