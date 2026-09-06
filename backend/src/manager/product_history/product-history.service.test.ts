import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $queryRaw: vi.fn(),
        $transaction: vi.fn(),
        product: {
            findUnique: vi.fn(),
        },
        carton: { findMany: vi.fn() },
        transaction: { findMany: vi.fn() },
        transfer: { findMany: vi.fn() },
    },
}));

import { productHistoryService, parseJalaliDateStr } from './product-history.service';
import { prisma } from '../../utils/prisma';
import { tehranDayRange } from '../../utils/jalali';

const queryRaw = vi.mocked(prisma.$queryRaw);
const productFindUnique = vi.mocked(prisma.product.findUnique);

beforeEach(() => {
    vi.clearAllMocks();
});

describe('productHistoryService.list', () => {
    it('صفحه‌بندی و total درست از window function خوانده می‌شود', async () => {
        queryRaw.mockResolvedValueOnce([
            {
                productId: 'p1',
                productName: 'کالای یک',
                archived: false,
                cartonTotal: 10n,
                inStock: 4n,
                shipped: 6n,
                returned: 0n,
                exited: 0n,
                individualTotal: 3n,
                individualInStock: 2n,
                txIn: 100n,
                txOut: 60n,
                txReturn: 5n,
                firstEntryAt: new Date('2026-01-01'),
                lastActivityAt: new Date('2026-02-01'),
                total: 42n,
            },
        ] as any);

        const res = await productHistoryService.list({ page: 2, pageSize: 20 });

        expect(res.pagination.total).toBe(42);
        expect(res.pagination.page).toBe(2);
        expect(res.pagination.hasMore).toBe(true); // 2*20 < 42
        expect(res.rows[0].cartonTotal).toBe(10);
        expect(res.rows[0].individualTotal).toBe(3);
        expect(res.rows[0].txOut).toBe(60);
        expect(typeof res.rows[0].cartonTotal).toBe('number');
    });

    it('بدون داده → total صفر و rows خالی', async () => {
        queryRaw.mockResolvedValueOnce([] as any);
        const res = await productHistoryService.list({});
        expect(res.pagination.total).toBe(0);
        expect(res.rows).toEqual([]);
        expect(res.pagination.hasMore).toBe(false);
    });

    it('فیلترِ روزِ دقیق → EXISTS زیرِ درخواست با مرزِ تهران ساخته می‌شود', async () => {
        queryRaw.mockResolvedValueOnce([] as any);
        await productHistoryService.list({ activityDate: '1405-06-15' });

        expect(queryRaw).toHaveBeenCalledTimes(1);

        // template tagged call: آرگومان‌ها = strings + مقادیرِ درونیابی‌شده (که خودشان Prisma.Sql اند)
        let text = '';
        const dates: Date[] = [];
        const walk = (v: unknown): void => {
            if (typeof v === 'string') {
                text += v + '\n';
                return;
            }
            if (v instanceof Date) {
                dates.push(v);
                return;
            }
            if (Array.isArray(v)) {
                v.forEach(walk);
                return;
            }
            if (v && typeof v === 'object') {
                const o = v as { sql?: unknown; values?: unknown };
                if (typeof o.sql === 'string') text += o.sql + '\n';
                if (Array.isArray(o.values)) o.values.forEach(walk);
            }
        };
        walk(queryRaw.mock.calls[0] as unknown[]);

        // زیرِ درخواستِ روزِ دقیق
        expect(text).toContain('"Transaction" td');
        expect(text).toContain('"Carton" cd');
        expect(text).toContain('"scannedOutAt"');

        // مرزِ روز = ۰۰:۰۰ تهرانِ همان روز تا ۰۰:۰۰ فردا
        const { start, end } = tehranDayRange(1405, 6, 15);
        expect(dates.some((d) => d.getTime() === start.getTime())).toBe(true);
        expect(dates.some((d) => d.getTime() === end.getTime())).toBe(true);
    });

    it('تاریخِ نامعتبر نادیده گرفته می‌شود (بدون فیلترِ روز)', async () => {
        queryRaw.mockResolvedValueOnce([] as any);
        await productHistoryService.list({ activityDate: 'garbage' });
        let text = '';
        const walk = (v: unknown): void => {
            if (typeof v === 'string') {
                text += v + '\n';
                return;
            }
            if (Array.isArray(v)) {
                v.forEach(walk);
                return;
            }
            if (v && typeof v === 'object') {
                const o = v as { sql?: unknown; values?: unknown };
                if (typeof o.sql === 'string') text += o.sql + '\n';
                if (Array.isArray(o.values)) o.values.forEach(walk);
            }
        };
        walk(queryRaw.mock.calls[0] as unknown[]);
        expect(text).not.toContain('"Transaction" td');
    });

    it('parseJalaliDateStr فرمت‌های مجاز را می‌پذیرد', () => {
        expect(parseJalaliDateStr('1405-06-15')).toEqual({ jy: 1405, jm: 6, jd: 15 });
        expect(parseJalaliDateStr(' 1405-6-5 ')).toEqual({ jy: 1405, jm: 6, jd: 5 });
        expect(parseJalaliDateStr(undefined)).toBeUndefined();
        expect(parseJalaliDateStr('2026-01-01')).toBeUndefined();
        expect(parseJalaliDateStr('')).toBeUndefined();
    });
});

describe('productHistoryService.detail', () => {
    const product = {
        id: 'p1',
        name: 'کالای یک',
        unit: 'عدد',
        deletedAt: null,
        createdAt: new Date('2026-01-01'),
        models: [
            { id: 'm1', name: 'مدل الف', unitsPerBox: 12, packageType: 'کارتن', deletedAt: null },
        ],
    };

    const carton = (over: Record<string, any> = {}) => ({
        id: 'c1',
        serialNumber: 'SN-100',
        qrUuid: 'qr1',
        isIndividual: false,
        status: 'SHIPPED',
        entryType: 'NEW',
        createdAt: new Date('2026-01-02'),
        printedAt: null,
        scannedOutAt: new Date('2026-01-05'),
        warehouse: { name: 'انبار مرکزی' },
        model: { name: 'مدل الف' },
        order: {
            id: 'o1',
            orderNumber: 7,
            status: 'DELIVERED',
            senderName: 'فرستنده',
            receiverName: 'مشتری اول',
            customerPhone: '09120000000',
            city: 'تهران',
            carrier: 'تیپاکس',
            createdAt: new Date('2026-01-03'),
            delivery: { status: 'DELIVERED', deliveredAt: new Date('2026-01-06'), driver: { name: 'رضا' } },
        },
        ...over,
    });

    it('تاریخِ روزِ دقیق → همهٔ findMany ها با مرزِ همان روز فیلتر می‌شوند', async () => {
        productFindUnique.mockResolvedValueOnce(product as any);
        vi.mocked(prisma.carton.findMany).mockResolvedValueOnce([] as any);
        vi.mocked(prisma.transaction.findMany).mockResolvedValueOnce([] as any);
        vi.mocked(prisma.transfer.findMany).mockResolvedValueOnce([] as any);
        vi.mocked(prisma.$transaction).mockImplementationOnce(
            (async (ops: unknown[]) => Promise.all(ops)) as any,
        );

        const { start, end } = tehranDayRange(1405, 6, 15);
        await productHistoryService.detail('p1', { activityDate: '1405-06-15' });

        const cartonWhere = vi.mocked(prisma.carton.findMany).mock.calls[0]![0]!.where as any;
        expect(cartonWhere.OR).toHaveLength(2);
        expect(cartonWhere.OR[0].createdAt.gte.getTime()).toBe(start.getTime());
        expect(cartonWhere.OR[0].createdAt.lt.getTime()).toBe(end.getTime());
        expect(cartonWhere.OR[1].scannedOutAt.gte.getTime()).toBe(start.getTime());

        const txWhere = vi.mocked(prisma.transaction.findMany).mock.calls[0]![0]!.where as any;
        expect(txWhere.createdAt.gte.getTime()).toBe(start.getTime());
        expect(txWhere.createdAt.lt.getTime()).toBe(end.getTime());

        const trWhere = vi.mocked(prisma.transfer.findMany).mock.calls[0]![0]!.where as any;
        expect(trWhere.createdAt.gte.getTime()).toBe(start.getTime());
        expect(trWhere.createdAt.lt.getTime()).toBe(end.getTime());
    });

    it('محصول نیست → null (کنترلر 404 می‌دهد)', async () => {
        productFindUnique.mockResolvedValueOnce(null as any);
        const res = await productHistoryService.detail('missing');
        expect(res).toBeNull();
    });

    it('ساخت جزئیات کامل: سریال، سفارش مشتری، وضعیت‌ها و counts', async () => {
        productFindUnique.mockResolvedValueOnce(product as any);

        // findMany ها Promise برمی‌گردانند تا $transaction با Promise.all جمع کند
        vi.mocked(prisma.carton.findMany).mockResolvedValueOnce([
            carton(),
            carton({ id: 'c2', serialNumber: null, isIndividual: true, status: 'IN_STOCK', scannedOutAt: null, model: null, order: null }),
        ] as any);
        vi.mocked(prisma.transaction.findMany).mockResolvedValueOnce([
            { id: 't1', type: 'IN', quantity: 120, productName: 'کالای یک', warehouse: { name: 'انبار مرکزی' }, user: { name: 'انباردار' }, createdAt: new Date('2026-01-01') },
            { id: 't2', type: 'OUT', quantity: 20, productName: 'کالای یک', warehouse: { name: 'انبار مرکزی' }, user: { name: 'انباردار' }, createdAt: new Date('2026-01-05') },
        ] as any);
        vi.mocked(prisma.transfer.findMany).mockResolvedValueOnce([
            { id: 'tr1', quantity: 10, status: 'DONE', description: 'خروج برای فروشگاه', toWarehouseId: null, fromWarehouse: { name: 'انبار مرکزی' }, toWarehouse: null, createdBy: { name: 'مدیر' }, createdAt: new Date('2026-01-04'), completedAt: new Date('2026-01-04') },
            { id: 'tr2', quantity: 5, status: 'DONE', description: '', toWarehouseId: 'w2', fromWarehouse: { name: 'انبار مرکزی' }, toWarehouse: { name: 'انبار دو' }, createdBy: { name: 'مدیر' }, createdAt: new Date('2026-01-06'), completedAt: new Date('2026-01-06') },
        ] as any);
        vi.mocked(prisma.$transaction).mockImplementationOnce(
            (async (ops: unknown[]) => Promise.all(ops)) as any,
        );

        const res = await productHistoryService.detail('p1');

        expect(res).not.toBeNull();
        expect(res!.product.name).toBe('کالای یک');
        expect(res!.counts.inStock).toBe(1);
        expect(res!.counts.shipped).toBe(1);
        expect(res!.counts.individuals).toBe(1);
        expect(res!.counts.txIn).toBe(120);
        expect(res!.counts.txOut).toBe(20);

        // کارتن اول: سریال + سفارش مشتری + تحویل
        const c1 = res!.cartons[0];
        expect(c1.serialNumber).toBe('SN-100');
        expect(c1.order).not.toBeNull();
        expect(c1.order!.receiverName).toBe('مشتری اول');
        expect(c1.order!.deliveryStatus).toBe('DELIVERED');
        expect(c1.order!.driverName).toBe('رضا');

        // کارتن تکی بدون سفارش
        const c2 = res!.cartons[1];
        expect(c2.isIndividual).toBe(true);
        expect(c2.order).toBeNull();

        // انتقال/خروج: isExit درست
        expect(res!.transfers[0].isExit).toBe(true);
        expect(res!.transfers[1].isExit).toBe(false);
        expect(res!.transfers[1].toWarehouseName).toBe('انبار دو');
    });
});
