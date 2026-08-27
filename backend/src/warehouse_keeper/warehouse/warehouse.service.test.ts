import { describe, it, expect, vi, beforeEach } from 'vitest';
import { warehouseService } from './warehouse.service';

const mocks = vi.hoisted(() => {
    const queryRaw = vi.fn();
    return { queryRaw };
});

vi.mock('../../utils/prisma', () => ({
    prisma: { $queryRaw: mocks.queryRaw },
}));

import { prisma } from '../../utils/prisma';

/// تبدیل آرگومان‌های فراخوانیِ mock شدهٔ `$queryRaw` به متن کامل SQL.
/// `strings` فقط تکه‌های ثابتِ قالب را دارد؛ هر مقدارِ درج‌شده (شامل قطعاتِ
/// `Prisma.raw`) به‌صورت آرگومانِ مستقل در `call[1..]` می‌آید و وسط تکه‌ها قرار می‌گیرد.
function renderCall(call: unknown[]): string {
    const strings = call[0] as string[];
    let out = strings[0];
    for (let i = 1; i < call.length; i++) {
        const v = call[i] as { strings?: string[] } | string | number | null;
        const frag =
            v && typeof v === 'object' && Array.isArray(v.strings)
                ? v.strings.join('')
                : String(v);
        out += frag + (strings[i] ?? '');
    }
    return out;
}

function makeOrder(id: string) {
    return {
        id,
        warehouseId: 'wh1',
        status: 'PENDING',
        createdById: 'u1',
        shippingMethod: 'باربری',
        carrier: null,
        city: 'تهران',
        postalCode: '12345',
        address: 'خیابان ۱',
        customerPhone: '0912',
        senderName: 'فرستنده',
        receiverName: 'گیرنده',
        createdAt: new Date(),
        updatedAt: new Date(),
        createdByName: 'مدیر',
    };
}

beforeEach(() => {
    vi.clearAllMocks();
});

describe('warehouseService.getOrders', () => {
    it('اقلام سفارش‌ها را در یک کوئری واحد می‌خواند و به هر سفارش متصل می‌کند', async () => {
        const orders = [makeOrder('o1'), makeOrder('o2')];
        const items = [
            { orderId: 'o1', id: 'i1', productId: 'p1', quantity: 2, productName: 'کالای A' },
            { orderId: 'o1', id: 'i2', productId: 'p2', quantity: 1, productName: 'کالای B' },
            { orderId: 'o2', id: 'i3', productId: 'p3', quantity: 5, productName: 'کالای C' },
        ];

        mocks.queryRaw.mockResolvedValueOnce(orders);
        mocks.queryRaw.mockResolvedValueOnce(items);

        const result = await warehouseService.getOrders('wh1');

        expect(result).toHaveLength(2);
        expect(result[0].items).toHaveLength(2);
        expect(result[1].items).toHaveLength(1);
        expect(result[0].items[0].productName).toBe('کالای A');
        expect(result[1].items[0].productName).toBe('کالای C');

        const secondCall = mocks.queryRaw.mock.calls[1];
        const templateParts = secondCall[0] as unknown as string[];
        const queryText = templateParts.join('');
        expect(queryText).toContain('SELECT oi."orderId"');
        expect(queryText).toContain('p.name as "productName"');
        expect(queryText).toContain('WHERE oi."orderId" IN (');
        expect(prisma.$queryRaw).toHaveBeenCalledTimes(2);
    });

    it('وقتی سفارشی وجود ندارد کوئری اقلام زده نمی‌شود', async () => {
        mocks.queryRaw.mockResolvedValueOnce([]);

        const result = await warehouseService.getOrders('wh1');

        expect(result).toHaveLength(0);
        expect(mocks.queryRaw).toHaveBeenCalledTimes(1);
    });

    it('سفارش بدون قلم آیتم خالی دارد', async () => {
        const orders = [makeOrder('o1')];
        mocks.queryRaw.mockResolvedValueOnce(orders);
        mocks.queryRaw.mockResolvedValueOnce([]);

        const result = await warehouseService.getOrders('wh1');

        expect(result[0].items).toEqual([]);
    });
});

describe('warehouseService.getInventorySummary', () => {
    it('خلاصه: totalProducts/totalModels کامل + فقط ۶۰ محصول برتر بدون مدل در پاسخ', async () => {
        // ۷۰ محصول، هر کدام ۲ مدل → ۱۴۰ ردیف کارتن
        const cartonStats = [];
        for (let i = 0; i < 70; i++) {
            cartonStats.push(
                { productId: `p${i}`, productName: `کالای ${i}`, unit: 'عدد', modelId: `m${i}a`, modelName: 'مدل A', totalCount: 10, cartonCount: 1, individualCount: 0 },
                { productId: `p${i}`, productName: `کالای ${i}`, unit: 'عدد', modelId: `m${i}b`, modelName: 'مدل B', totalCount: 5, cartonCount: 1, individualCount: 0 },
            );
        }
        mocks.queryRaw.mockResolvedValueOnce(cartonStats);
        mocks.queryRaw.mockResolvedValueOnce([
            { shippedUnits: 0, shippedCartons: 0, returnedUnits: 0, returnedCartons: 0, totalUnits: 1050, totalCartons: 140 },
        ]);
        mocks.queryRaw.mockResolvedValueOnce([]);

        const result = await warehouseService.getInventorySummary('wh1');

        expect(result.totalProducts).toBe(70);
        expect(result.totalModels).toBe(140);
        expect(result.totalUnits).toBe(1050);
        expect(result.products).toHaveLength(60);
        // فقط محصولات برتر (همه موجودی ۱۵ دارند — مرتب‌سازی پایدار، p0 اول)
        expect(result.products[0].productId).toBe('p0');
        // مدل‌ها در پاسخ خلاصه نیستند
        expect('models' in result.products[0]).toBe(false);
        expect(result.products[0].totalCount).toBe(15);
        expect(result.products[0].modelCount).toBe(2);
    });

    it('getTransactions با فیلتر type=OUT شرط نوع امن را به کوئری اضافه می‌کند', async () => {
        mocks.queryRaw.mockResolvedValue([{ id: 't1', type: 'OUT' }]);

        await warehouseService.getTransactions('wh1', undefined, 'OUT');

        const call = mocks.queryRaw.mock.calls[0];
        const queryText = renderCall(call);
        expect(queryText).toContain('WHERE t."warehouseId"');
        expect(queryText).toContain('t."type" = \'OUT\'');
        // با فیلتر OUT، تاریخ نباید در کوئری بیاید
        expect(queryText).not.toContain('"createdAt"::date');
        expect(prisma.$queryRaw).toHaveBeenCalledTimes(1);
    });

    it('getTransactions با فیلتر نامعتبر، شرط نوع اضافه نمی‌شود', async () => {
        mocks.queryRaw.mockResolvedValue([]);

        await warehouseService.getTransactions('wh1', '2026-08-20', 'INJECT');

        const call = mocks.queryRaw.mock.calls[0];
        const queryText = renderCall(call);
        // فیلتر نامعتبر نادیده گرفته می‌شود ولی تاریخ اعمال می‌شود
        expect(queryText).not.toContain('INJECT');
        expect(queryText).toContain('"createdAt"::date');
    });

    it('محصولات لِگاسی (بدون کارتن) هم شمارش می‌شوند و در سقف می‌مانند', async () => {
        mocks.queryRaw.mockResolvedValueOnce([]);
        mocks.queryRaw.mockResolvedValueOnce([
            { shippedUnits: 0, shippedCartons: 0, returnedUnits: 0, returnedCartons: 0, totalUnits: 0, totalCartons: 0 },
        ]);
        mocks.queryRaw.mockResolvedValueOnce([
            { productId: 'l1', name: 'کالای لگاسی', unit: 'عدد', legacyCount: 7 },
        ]);

        const result = await warehouseService.getInventorySummary('wh2');

        expect(result.totalProducts).toBe(1);
        expect(result.products).toHaveLength(1);
        expect(result.products[0].productId).toBe('l1');
        expect(result.products[0].totalCount).toBe(7);
    });
});
