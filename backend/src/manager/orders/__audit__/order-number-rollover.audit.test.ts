/**
 * ═══ تست حساسِ پیش از انتشار — سناریو ۱ ═══
 * «Midnight Rollback شمارهٔ سفارش» — مرزِ روزِ تهران:
 *  - ۲۳:۵۹:۵۸ تهران  → سفارش با orderDay روزِ فعلی ثبت می‌شود
 *  - ۰۰:۰۰:۰۱ تهران   → orderDay باید کلیدِ روزِ «جدید» باشد و orderNumber از ۱ شروع شود
 *
 * ساعتِ سیستم با fake timers روی لحظات واقعیِ اطرافِ نیمه‌شبِ تهران (۲۰:۳۰ UTC) تنظیم
 * می‌شود تا رفتار `jalaliDayKey` + شمارشِ `orderNumber` عیناً مثل production بررسی شود.
 * منطقِ موردِ تست: orders.service.createOrder — شمارش داخل تراکنش Serializable و
 * retry روی تعارض unique(orderDay, orderNumber).
 */
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';

vi.mock('../../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        $queryRaw: vi.fn(),
        order: { findUnique: vi.fn(), findUniqueOrThrow: vi.fn(), count: vi.fn() },
        warehouse: { findUnique: vi.fn() },
        product: { findMany: vi.fn() },
        productModel: { findMany: vi.fn() },
    },
}));

// runSerializable واقعی به DB وصل می‌شود؛ در تست، همان callback را با tx قلابی اجرا می‌کنیم
vi.mock('../../../utils/serializableTx', () => ({
    runSerializable: vi.fn(async (fn: (tx: unknown) => Promise<unknown>) => {
        const { prisma } = await import('../../../utils/prisma');
        return prisma.$transaction(fn);
    }),
}));

import { ordersService } from '../orders.service';
import { prisma } from '../../../utils/prisma';
import { jalaliDayKey, tehranDayRange } from '../../../utils/jalali';

beforeEach(() => {
    vi.clearAllMocks();
});

afterEach(() => {
    vi.useRealTimers();
});

/** tx قلابی منطبق با هر آنچه createOrder داخل تراکنش صدا می‌زند */
function makeTx(orderCount: number) {
    return {
        $queryRaw: vi
            .fn()
            // ۱) کارتن‌های موجود در انبار (مبنای موجودی کارتنی)
            .mockResolvedValueOnce([{ productId: 'p1' }])
            // ۲) جمع کارتن‌های IN_STOCK — موجودیِ کافی
            .mockResolvedValueOnce([{ productId: 'p1', available: 100 }])
            // ۳) تراکنش‌های لِگاسی — خالی
            .mockResolvedValueOnce([]),
        order: {
            count: vi.fn().mockResolvedValue(orderCount),
            create: vi.fn().mockResolvedValue({}),
        },
        productModel: { findUnique: vi.fn().mockResolvedValue(null) },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
    };
}

/** رکورد سفارشی که findUniqueOrThrow برمی‌گرداند — سازگار با mapOrder */
const mappedOrder = {
    id: 'o1',
    orderNumber: 1,
    version: 0,
    status: 'PENDING',
    shippingMethod: 'شهری',
    carrier: null,
    city: null,
    postalCode: null,
    address: null,
    customerPhone: '09120000000',
    senderName: null,
    senderNationalId: null,
    senderPhone: null,
    receiverName: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    warehouse: { name: 'انبار مرکزی' },
    delivery: null,
    badges: [],
    items: [{ id: 'i1', productId: 'p1', quantity: 5, model: null, price: null, exchangeRate: null, product: { name: 'کالا' } }],
};

async function createAtFakeTime(orderCount: number) {
    const tx = makeTx(orderCount);
    (prisma.$transaction as any).mockImplementation(async (fn: any) => fn(tx));
    (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'wh1' });
    (prisma.product.findMany as any).mockResolvedValue([{ id: 'p1' }]);
    (prisma.order.findUniqueOrThrow as any).mockResolvedValue(mappedOrder);

    await ordersService.createOrder('wh1', 'u1', [{ productId: 'p1', quantity: 5 }], 'شهری');
    expect(tx.order.create).toHaveBeenCalledTimes(1);
    const data = tx.order.create.mock.calls[0][0].data;
    return data as { orderNumber: number; orderDay: number };
}

describe('آدیت ۱ — Midnight Rollback شمارهٔ سفارش (مرزِ روزِ تهران)', () => {
    it('۰۰:۰۰:۰۱ تهران → orderDay کلیدِ روزِ جدید و orderNumber = ۱', async () => {
        // ۱۴۰۵/۰۶/۱۵ ساعت ۰۰:۰۰:۰۱ تهران = 2026-09-05T20:30:01Z
        vi.useFakeTimers({ now: new Date('2026-09-05T20:30:01.000Z'), toFake: ['Date'] });
        expect(jalaliDayKey(new Date())).toBe(14050615);

        const data = await createAtFakeTime(0);
        expect(data.orderDay).toBe(14050615);
        expect(data.orderNumber).toBe(1);
    });

    it('همان روز، سفارش هشتم → orderNumber ادامهٔ روزِ جاری (۸)', async () => {
        vi.useFakeTimers({ now: new Date('2026-09-05T20:30:01.000Z'), toFake: ['Date'] });
        const data = await createAtFakeTime(7);
        expect(data.orderDay).toBe(14050615);
        expect(data.orderNumber).toBe(8);
    });

    it('۲۳:۵۹:۵۸ تهران (قبل از نیمه‌شب) → هنوز orderDay روزِ قبلی', async () => {
        // ۲۳:۵۹:۵۸ تهرانِ ۱۴۰۵/۰۶/۱۴ = 2026-09-05T20:29:58Z (نیمه‌شبِ تهران = 20:30 UTC)
        vi.useFakeTimers({ now: new Date('2026-09-05T20:29:58.000Z'), toFake: ['Date'] });
        expect(jalaliDayKey(new Date())).toBe(14050614);

        const data = await createAtFakeTime(3);
        expect(data.orderDay).toBe(14050614);
        expect(data.orderNumber).toBe(4);
    });

    it('مرزِ دقیق: بازهٔ [start,end) روزِ ۱۴۰۵/۰۶/۱۵ با کلیدِ سفارش‌های همان روز یکی است', () => {
        // سندِ مرز: نیمه‌شبِ تهرانِ روزِ بعد = پایانِ بازه
        const { start, end } = tehranDayRange(1405, 6, 15);
        vi.useFakeTimers({ now: end, toFake: ['Date'] });
        expect(jalaliDayKey(new Date())).toBe(14050616); // یک میلی‌ثانیه بعد از مرز → روز جدید
        vi.useFakeTimers({ now: start, toFake: ['Date'] });
        expect(jalaliDayKey(new Date())).toBe(14050615); // لحظهٔ مرز → روز جدید شروع شده
        vi.useRealTimers();
    });
});
