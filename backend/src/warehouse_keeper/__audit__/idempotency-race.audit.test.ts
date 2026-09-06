/**
 * ═══ تست حساسِ پیش از انتشار — سناریو ۳ ═══
 * «قطعیِ اینترنتِ اپراتور» — ارسالِ دوبارهٔ همان ورودِ کالا با کلیدِ ایدمپوتنسیِ یکسان:
 *  - اولین درخواست → ثبت کامل + ذخیرهٔ پاسخ در IdempotencyKey (داخل همان تراکنش)
 *  - درخواستِ تکراری (بعد از قطعی/تایم‌اوت) → «همان پاسخِ قبلی» بدونِ ثبتِ دوباره
 *  - دو درخواستِ هم‌زمان با کلیدِ واحد → یکی می‌برد (P2002)، دیگری پاسخِ ذخیره‌شده می‌گیرد
 *
 * واقعی‌ترین حالتِ قطعی: کلاینت اولین پاسخ را نگرفته؛ سرور تراکنش را «تمام» کرده و
 * کلید ذخیره شده — پس مسیرِ «replay بعد از commit» (findUnique موجود) و مسیرِ
 * «تعارض هم‌زمان» (P2002 روی unique(userId,operation,key)) هر دو پوشش داده می‌شوند.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        idempotencyKey: { findUnique: vi.fn(), create: vi.fn() },
        warehouse: { findUnique: vi.fn() },
        product: { findMany: vi.fn() },
        carton: { findMany: vi.fn() },
    },
}));

vi.mock('../../utils/serializableTx', () => ({
    runSerializable: vi.fn(async (fn: (tx: unknown) => Promise<unknown>) => {
        const { prisma } = await import('../../utils/prisma');
        return prisma.$transaction(fn);
    }),
}));

import { checkinService } from '../checkin/checkin.service';
import { prisma } from '../../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

const ITEMS = [{ productId: 'p1', modelId: 'm1', cartonCount: 1, individualCount: 0 }];

function happyTx() {
    return {
        carton: {
            create: vi.fn().mockImplementation(({ data }: any) =>
                Promise.resolve({
                    id: data.id ?? 'c-new',
                    serialNumber: data.serialNumber ?? 'MA-1405-000001',
                    qrPayload: data.qrPayload ?? 'MA|SN|x|u|h',
                    isIndividual: false,
                }),
            ),
            updateMany: vi.fn().mockResolvedValue({ count: 1 }),
        },
        transaction: { create: vi.fn().mockResolvedValue({}) },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
        idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
        serialSequence: { upsert: vi.fn().mockResolvedValue({ lastSeq: 1 }) },
    };
}

function setupHappyPath() {
    (prisma.idempotencyKey.findUnique as any).mockResolvedValue(null);
    (prisma.warehouse.findUnique as any).mockResolvedValue({ name: 'انبار مرکزی' });
    (prisma.product.findMany as any).mockResolvedValue([
        { id: 'p1', name: 'کالا', models: [{ id: 'm1', productId: 'p1', unitsPerBox: 12, name: 'مدل' }] },
    ]);
    (prisma.carton.findMany as any).mockResolvedValue([]);
    const tx = happyTx();
    (prisma.$transaction as any).mockImplementation(async (fn: any) => fn(tx));
    return tx;
}

describe('آدیت ۳ — ایدمپوتنسی ورود کالا (قطعی شبکه / ارسال دوباره)', () => {
    it('مسیر ۱ — replay بعد از commit: کلید موجود → همان پاسخ قبلی، بدونِ هرگونه ثبت', async () => {
        const storedResponse = { cartons: [{ id: 'c-old', serialNumber: 'MA-1405-000007' }], totalUnits: 12 };
        (prisma.idempotencyKey.findUnique as any).mockResolvedValue({ responseJson: storedResponse });

        const result = await checkinService.submitCheckin('wh1', 'user1', ITEMS, 'op-key-1');

        expect(result).toEqual(storedResponse);
        expect(prisma.$transaction).not.toHaveBeenCalled(); // هیچ تراکنشی باز نشده
        expect(prisma.idempotencyKey.create).not.toHaveBeenCalled();
    });

    it('مسیر ۲ — تعارضِ هم‌زمان (P2002): بازنده پاسخِ برنده را می‌گیرد، کارتنِ دوباره ساخته نمی‌شود', async () => {
        // پیش‌چک: کلید هنوز نیست (درخواست هم‌زمان هنوز commit نشده)
        (prisma.idempotencyKey.findUnique as any)
            .mockResolvedValueOnce(null) // pre-check
            .mockResolvedValueOnce({ responseJson: { cartons: [{ id: 'c-winner' }], totalUnits: 12 } }); // بازیابی بعد از تعارض
        (prisma.warehouse.findUnique as any).mockResolvedValue({ name: 'انبار مرکزی' });
        (prisma.product.findMany as any).mockResolvedValue([
            { id: 'p1', name: 'کالا', models: [{ id: 'm1', productId: 'p1', unitsPerBox: 12, name: 'مدل' }] },
        ]);
        (prisma.carton.findMany as any).mockResolvedValue([]);

        const tx = happyTx();
        // کلیدِ ایدمپوتنسیِ «برنده» ذخیره شده → ذخیرهٔ «بازنده» با P2002 رد می‌شود
        tx.idempotencyKey.create.mockRejectedValue({
            code: 'P2002',
            meta: { target: 'userId_operation_key' },
        });
        (prisma.$transaction as any).mockImplementation(async (fn: any) => fn(tx));

        const result = await checkinService.submitCheckin('wh1', 'user1', ITEMS, 'op-key-1');

        expect(result).toEqual({ cartons: [{ id: 'c-winner' }], totalUnits: 12 });
        // هیچ کارتنی از سمتِ درخواستِ بازنده ثبتِ نهایی نمی‌شود: در Prisma واقعی، شکستِ
        // idempotencyKey.create کل تراکنش را rollback می‌کند (کارتن‌های ساخته‌شده هم برمی‌گردند)
        // و پاسخِ بازنده با پاسخِ ذخیره‌شدهٔ برنده جایگزین می‌شود — قابلِ مشاهده در result بالا.
        expect(tx.idempotencyKey.create).toHaveBeenCalledTimes(1); // تلاشِ ذخیرهٔ بازنده انجام شده
        expect(prisma.idempotencyKey.findUnique).toHaveBeenCalledTimes(2); // pre-check + بازیابیِ پاسخِ برنده
    });

    it('مسیر ۳ — ارسال اول با کلید جدید → ثبت کامل + ذخیرهٔ پاسخ در همان تراکنش', async () => {
        const tx = setupHappyPath();

        const result = await checkinService.submitCheckin('wh1', 'user1', ITEMS, 'op-key-2');

        expect(tx.carton.create).toHaveBeenCalledTimes(1);
        expect(tx.idempotencyKey.create).toHaveBeenCalledOnce();
        expect(tx.idempotencyKey.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({ userId: 'user1', operation: 'checkin', key: 'op-key-2' }),
            }),
        );
        expect(tx.outboxEvent.create).toHaveBeenCalledOnce();
        expect(typeof (result as any).totalUnits).toBe('number');
    });

    it('بدون clientKey → رفتار فعلی: مستقیم ثبت می‌شود (پوششِ رگرسیون)', async () => {
        const tx = setupHappyPath();
        await checkinService.submitCheckin('wh1', 'user1', ITEMS);
        expect(tx.carton.create).toHaveBeenCalledTimes(1);
        expect(tx.idempotencyKey.create).not.toHaveBeenCalled();
    });
});
