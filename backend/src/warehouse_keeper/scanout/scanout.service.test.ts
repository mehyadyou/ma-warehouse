import { describe, it, expect, vi, beforeEach } from 'vitest';
import { scanOutService } from './scanout.service';

const mocks = vi.hoisted(() => {
    const tx = {
        carton: { updateMany: vi.fn().mockResolvedValue({ count: 1 }), count: vi.fn().mockResolvedValue(0) },
        order: {
            updateMany: vi.fn().mockResolvedValue({ count: 1 }),
            findUnique: vi.fn(),
        },
        transfer: {
            findUnique: vi.fn(),
            updateMany: vi.fn().mockResolvedValue({ count: 1 }),
        },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        transaction: { create: vi.fn().mockResolvedValue({}) },
        warehouse: { findUnique: vi.fn().mockResolvedValue({ name: 'انبار اصلی' }) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
        $queryRaw: vi.fn().mockResolvedValue([{ units: 0 }]),
    };
    const orderRow = (overrides: any = {}) => ({
        id: 'order1', warehouseId: 'wh1', status: 'PENDING',
        customerPhone: null, city: 'تهران', address: null,
        items: [{ productId: 'p1', modelId: 'm1', quantity: 2 }],
        ...overrides,
    });
    return {
        tx,
        orderRow,
        transaction: vi.fn((fn: (t: unknown) => unknown) => fn(tx)),
        findUnique: vi.fn(),
        findFirst: vi.fn(),
        findMany: vi.fn(),
        activityLogCreate: vi.fn().mockResolvedValue({}),
    };
});

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: mocks.transaction,
        carton: { findUnique: mocks.findUnique, findFirst: mocks.findFirst, findMany: mocks.findMany },
        activityLog: { create: mocks.activityLogCreate },
    },
}));

import { prisma } from '../../utils/prisma';
import { signPayload, buildQrForSerial } from '../../utils/qr';

function makeCarton(overrides: any = {}) {
    return {
        id: 'c1', productId: 'p1', modelId: 'm1', warehouseId: 'wh1',
        scannedOutAt: null, status: 'IN_STOCK', orderId: null,
        isIndividual: false,
        product: { id: 'p1', name: 'کالای A', unit: 'عدد' },
        model: { id: 'm1', name: 'مدل ۱', unitsPerBox: 10, packageType: 'کارتن' },
        order: null,
        ...overrides,
    };
}

beforeEach(() => {
    vi.clearAllMocks();
    mocks.tx.carton.updateMany.mockResolvedValue({ count: 1 });
    mocks.tx.carton.count.mockResolvedValue(0);
    mocks.tx.order.updateMany.mockResolvedValue({ count: 1 });
    mocks.tx.order.findUnique.mockReset();
    mocks.tx.transfer.findUnique.mockReset();
    mocks.tx.transfer.updateMany.mockReset();
    mocks.tx.transfer.updateMany.mockResolvedValue({ count: 1 });
    mocks.tx.$queryRaw.mockReset();
    mocks.tx.$queryRaw.mockResolvedValue([{ units: 0 }]);
    mocks.tx.warehouse.findUnique.mockResolvedValue({ name: 'انبار اصلی' });
    mocks.tx.outboxEvent.create.mockResolvedValue({});
    mocks.findUnique.mockReset();
    mocks.findFirst.mockReset();
    mocks.findMany.mockReset();
});

const orderRow = (overrides: any = {}) => ({
        id: 'order1', warehouseId: 'wh1', status: 'PENDING',
        customerPhone: null, city: 'تهران', address: null,
        items: [{ productId: 'p1', modelId: 'm1', quantity: 2 }],
        ...overrides,
    });

describe('scanOutService.scanOut - QR معتبر', () => {
    it('اسکن موفق با QR (با انتخاب صریح سفارش)', async () => {
        const { qrPayload } = signPayload({
            productCode: 'P', modelCode: 'M', capacityPerBox: 10, uuid: 'c1',
        });
        mocks.findUnique.mockResolvedValue(makeCarton());
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut({ qrPayload, serialNumber: '', orderId: 'order1' }, 'wh1');
        expect(result.valid).toBe(true);
        expect(mocks.findUnique).toHaveBeenCalledWith({ where: { id: 'c1' }, include: expect.anything() });
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledOnce();
    });

    it('اسکن موفق با QR جدید (سریال) (با انتخاب صریح سفارش)', async () => {
        const { qrPayload } = buildQrForSerial({ serial: 'MA-1405-000001', uuid: 'c1' });
        mocks.findUnique.mockResolvedValue(makeCarton({ serialNumber: 'MA-1405-000001' }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut({ qrPayload, serialNumber: '', orderId: 'order1' }, 'wh1');
        expect(result.valid).toBe(true);
        expect(mocks.findUnique).toHaveBeenCalledWith(
            { where: { serialNumber: 'MA-1405-000001' }, include: expect.anything() }
        );
    });

    it('QR نامعتبر → valid: false', async () => {
        const result = await scanOutService.scanOut({ qrPayload: 'INVALID_QR', serialNumber: '' }, 'wh1');
        expect(result.valid).toBe(false);
        expect(result.error).toBeDefined();
    });
});

describe('scanOutService.scanOut - سریال', () => {
    it('اسکن موفق با سریال (با انتخاب صریح سفارش)', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ serialNumber: 'S1' }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1');
        expect(result.valid).toBe(true);
        expect(mocks.findFirst).toHaveBeenCalledWith(
            expect.objectContaining({ where: expect.objectContaining({ OR: expect.any(Array) }) })
        );
    });
});

describe('scanOutService.scanOut - اعتبارسنجی', () => {
    it('کارتن یافت نشده → valid: false', async () => {
        mocks.findFirst.mockResolvedValue(null);
        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'X' }, 'wh1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('ثبت نشده');
    });

    it('انبار متفاوت → valid: false', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ warehouseId: 'wh-other' }));
        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('انبار دیگری');
    });

    it('قبلاً خروج داده شده → valid: false', async () => {
        mocks.findFirst.mockResolvedValue(
            makeCarton({ scannedOutAt: new Date(), status: 'SHIPPED' }),
        );
        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('قبلاً خروج');
    });

    it('وضعیت نامعتبر → valid: false', async () => {
        mocks.findFirst.mockResolvedValue(
            makeCarton({ status: 'DAMAGED', warehouseId: 'wh1' }),
        );
        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('DAMAGED');
    });
});

describe('scanOutService.scanOut - انتخاب صریح', () => {
    it('اسکن بدون سفارش یا دستور → رد با پیام «اجازهٔ خروج ندارد»', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));

        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('اجازهٔ خروج ندارد');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('انتخاب هم‌زمان سفارش و دستور → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1', transferId: 't1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('فقط یکی');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('مسابقه همزمان: برنده ۱ نفر؛ باخته خطای قبلاً خروج میگیرد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());
        mocks.tx.carton.updateMany.mockResolvedValueOnce({ count: 0 });

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('قبلاً خروج');
    });
});

describe('scanOutService.scanOut - اتصال کارتن به سفارش (orderId)', () => {

    it('اسکن با orderId: کارتن به سفارش متصل، سفارش SHIPPED و رویداد order_shipped', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1', 'user1',
        );

        expect(result.valid).toBe(true);
        // کارتن با orderId به سفارش متصل می‌شود
        expect(mocks.tx.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { id: 'c1', status: 'IN_STOCK', scannedOutAt: null },
                data: expect.objectContaining({ status: 'SHIPPED', orderId: 'order1' }),
            })
        );
        expect(mocks.tx.order.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 'order1', status: 'PENDING' } })
        );
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order_shipped', aggregate: 'order' }) })
        );
        expect(mocks.tx.transaction.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'OUT' }) })
        );
    });

    it('تطابق محصول/مدل: کارتن ناهمخوان → رد با پیام مشخص', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null, productId: 'p9', modelId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('همخوانی ندارد');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('سفارش یافت نشد → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(null);

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'nope' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('سفارش یافت نشد');
    });

    it('سفارش متعلق به انبار دیگر → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow({ warehouseId: 'wh-other' }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('انبار دیگری');
    });

    it('سفارش DELIVERED → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow({ status: 'DELIVERED' }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('قابل خروج نیست');
    });

    it('سقف تعداد: وقتی کارتن‌های قلم تکمیل شده → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());
        mocks.tx.carton.count.mockResolvedValue(2); // quantity=2 → تکمیل

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('تکمیل شده');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('کارتن از قبل به سفارش دیگری متصل است → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: 'order-other' }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('سفارش دیگری');
    });
});

describe('scanOutService.scanOut - اجرای دستور جابه‌جایی/خروج (دوفازی)', () => {
    const transferRow = (overrides: any = {}) => ({
        id: 't1', fromWarehouseId: 'wh1', toWarehouseId: 'wh2',
        productId: 'p1', modelId: 'm1', quantity: 20, status: 'PENDING',
        ...overrides,
    });

    it('جابه‌جایی: کارتن به انبار مقصد منتقل، OUT+IN ثبت و دستور با تکمیل سهمیه DONE می‌شود', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        // جعبه ۱۰تایی و سهمیه ۱۰ → با یک اسکن سهمیه کامل می‌شود
        mocks.tx.transfer.findUnique.mockResolvedValue(transferRow({ quantity: 10 }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', transferId: 't1' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        // کارتن به انبار مقصد می‌رود (وضعیت IN_STOCK می‌ماند) و به دستور متصل می‌شود
        expect(mocks.tx.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { id: 'c1', status: 'IN_STOCK', scannedOutAt: null },
                data: expect.objectContaining({ warehouseId: 'wh2', transferId: 't1', orderId: null }),
            })
        );
        // OUT از مبدأ + IN در مقصد
        expect(mocks.tx.transaction.create).toHaveBeenCalledTimes(2);
        expect(mocks.tx.transaction.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'OUT', warehouseId: 'wh1' }) })
        );
        expect(mocks.tx.transaction.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'IN', warehouseId: 'wh2' }) })
        );
        // سهمیه کامل شد → دستور DONE
        expect(mocks.tx.transfer.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 't1', status: 'PENDING' }, data: expect.objectContaining({ status: 'DONE' }) })
        );
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'carton_transferred', aggregate: 'carton' }) })
        );
        expect(result.carton.transfer).toEqual(
            expect.objectContaining({ id: 't1', toWarehouseId: 'wh2' })
        );
    });

    it('خروج دائمی: کارتن EXITED می‌شود و فقط OUT ثبت می‌شود', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.transfer.findUnique.mockResolvedValue(transferRow({ toWarehouseId: null }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', transferId: 't1' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.tx.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({ status: 'EXITED', transferId: 't1', orderId: null }),
            })
        );
        expect(mocks.tx.transaction.create).toHaveBeenCalledTimes(1);
        expect(mocks.tx.transaction.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'OUT' }) })
        );
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'carton_exited' }) })
        );
    });

    it('سهمیه: اسکن بیش از مقدار باقی‌مانده → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        // جعبه ۱۰تایی؛ سهمیه ۲۰ و قبلاً ۱۵ واحد اسکن شده → ۲۵ > ۲۰
        mocks.tx.$queryRaw.mockResolvedValue([{ units: 15 }]);
        mocks.tx.transfer.findUnique.mockResolvedValue(transferRow({ quantity: 20 }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', transferId: 't1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('سقف مقدار');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('تطابق: کارتن ناهمخوان با کالای دستور → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null, productId: 'p9', modelId: null }));
        mocks.tx.transfer.findUnique.mockResolvedValue(transferRow());

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', transferId: 't1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('همخوانی ندارد');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('دستور غیر PENDING → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.transfer.findUnique.mockResolvedValue(transferRow({ status: 'DONE' }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', transferId: 't1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('دیگر فعال نیست');
    });

    it('دستور از انبار دیگر → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.transfer.findUnique.mockResolvedValue(transferRow({ fromWarehouseId: 'wh-other' }));

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', transferId: 't1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('انبار شما نیست');
    });

    it('دستور یافت نشد → رد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.transfer.findUnique.mockResolvedValue(null);

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', transferId: 't1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('یافت نشد');
    });
});

describe('scanOutService.listShippedCartons', () => {
    it('لیست کارتن‌های خروج‌زده را برمیگرداند', async () => {
        mocks.findMany.mockResolvedValue([
            { id: 'c1', status: 'SHIPPED', product: { name: 'کالا' }, model: { name: 'مدل' }, order: { id: 'o1' } },
        ]);

        const result = await scanOutService.listShippedCartons('wh1');
        expect(result).toHaveLength(1);
        expect(mocks.findMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: expect.objectContaining({ warehouseId: 'wh1', status: 'SHIPPED' }) })
        );
    });
});

describe('scanOutService.listOrderCartons', () => {
    it('کارتن‌های خروج‌زدهٔ یک سفارش را با فیلتر انبار برمیگرداند', async () => {
        mocks.findMany.mockResolvedValue([
            { id: 'c1', status: 'SHIPPED', product: { name: 'کالا' }, model: null },
        ]);

        const result = await scanOutService.listOrderCartons('order1', 'wh1');
        expect(result).toHaveLength(1);
        expect(mocks.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: expect.objectContaining({ orderId: 'order1', status: 'SHIPPED', warehouseId: 'wh1' }),
            })
        );
    });
});
