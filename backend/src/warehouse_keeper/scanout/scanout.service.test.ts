import { describe, it, expect, vi, beforeEach } from 'vitest';
import { scanOutService } from './scanout.service';

const mocks = vi.hoisted(() => {
    const tx = {
        carton: {
            updateMany: vi.fn().mockResolvedValue({ count: 1 }),
            count: vi.fn().mockResolvedValue(0),
            findMany: vi.fn().mockResolvedValue([]),
        },
        order: {
            updateMany: vi.fn().mockResolvedValue({ count: 1 }),
            findUnique: vi.fn(),
        },
        transfer: {
            findUnique: vi.fn(),
            updateMany: vi.fn().mockResolvedValue({ count: 1 }),
        },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        auditLog: { create: vi.fn().mockResolvedValue({}) },
        transaction: { create: vi.fn().mockResolvedValue({}) },
        warehouse: { findUnique: vi.fn().mockResolvedValue({ name: 'انبار اصلی' }) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
        delivery: { upsert: vi.fn().mockResolvedValue({}) },
        user: { findUnique: vi.fn() },
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
        orderFindMany: vi.fn(),
        transferFindMany: vi.fn(),
        cartonCount: vi.fn().mockResolvedValue(0),
        productFindUnique: vi.fn(),
        productModelFindUnique: vi.fn(),
        activityLogCreate: vi.fn().mockResolvedValue({}),
        orderFindUnique: vi.fn(),
        userFindUnique: vi.fn(),
    };
});

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: mocks.transaction,
        carton: {
            findUnique: mocks.findUnique,
            findFirst: mocks.findFirst,
            findMany: mocks.findMany,
            count: mocks.cartonCount,
        },
        order: { findMany: mocks.orderFindMany, findUnique: mocks.orderFindUnique },
        transfer: { findMany: mocks.transferFindMany },
        product: { findUnique: mocks.productFindUnique },
        productModel: { findUnique: mocks.productModelFindUnique },
        user: { findUnique: mocks.userFindUnique },
        $queryRaw: mocks.tx.$queryRaw,
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
    mocks.orderFindMany.mockReset();
    mocks.transferFindMany.mockReset();
    mocks.cartonCount.mockReset();
    mocks.cartonCount.mockResolvedValue(0);
    mocks.productFindUnique.mockReset();
    mocks.productModelFindUnique.mockReset();
    mocks.orderFindUnique.mockReset();
    mocks.userFindUnique.mockReset();
    mocks.tx.user.findUnique.mockReset();
    mocks.tx.delivery.upsert.mockReset();
    mocks.tx.delivery.upsert.mockResolvedValue({});
    mocks.tx.auditLog.create.mockReset();
    mocks.tx.auditLog.create.mockResolvedValue({});
    mocks.tx.carton.findMany.mockReset();
    mocks.tx.carton.findMany.mockResolvedValue([]);
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

describe('scanOutService.scanOut - اتصال خودکار (بدون انتخاب صریح)', () => {
    it('یک سفارش فعال منطبق (محصول+مدل) → اتصال خودکار و خروج موفق', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', items: [{ productId: 'p1', modelId: 'm1', quantity: 2 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(0);
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.orderFindMany).toHaveBeenCalledOnce();
        // ملاک فقط محصول+مدل: findMany باید با محصول و مدل کارتن فیلتر شود
        const where = mocks.orderFindMany.mock.calls[0][0].where;
        expect(where.warehouseId).toBe('wh1');
        expect(where.status.in).toEqual(['PENDING', 'SHIPPED']);
        expect(where.items.some.productId).toBe('p1');
        expect(where.items.some.modelId).toBe('m1');
        expect(mocks.tx.carton.updateMany).toHaveBeenCalled();
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledOnce();
    });

    it('چند سفارش فعال منطبق → خطای انتخاب صریح با لیست هدف‌های ممکن (بدون خروج)', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', orderNumber: 1, city: 'تهران', receiverName: 'رضا', carrier: 'باربری', items: [{ productId: 'p1', modelId: 'm1', quantity: 2 }] },
            { id: 'order2', orderNumber: 2, city: 'کرج', receiverName: 'علی', carrier: 'تیپاکس', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(0);

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('چند سفارش');
        // لیست هدف‌ها برای انتخاب صریح انباردار داخل پاسخ می‌آید
        expect(result.candidates).toHaveLength(2);
        expect(result.candidates![0]).toEqual(expect.objectContaining({ kind: 'order', id: 'order1', orderNumber: 1 }));
        expect(result.candidates![1]).toEqual(expect.objectContaining({ kind: 'order', id: 'order2', orderNumber: 2 }));
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('اسکن با انتخاب صریح بعد از لیست هدف‌ها → خروج موفق (تأیید مسیر پیکر)', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.order.findUnique.mockResolvedValue(orderRow());

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1', orderId: 'order2' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.tx.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ orderId: 'order2' }) })
        );
    });

    it('سفارش منطبق ولی ظرفیت تکمیل‌شده → بدون اتصال، خطای اجازهٔ خروج', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', items: [{ productId: 'p1', modelId: 'm1', quantity: 2 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(2); // سقف قلم تکمیل شده

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('اجازهٔ خروج ندارد');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('بدون سفارش، یک دستور جابه‌جایی/خروج فعال منطبق → اتصال خودکار به دستور', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.orderFindMany.mockResolvedValue([]);
        mocks.transferFindMany.mockResolvedValue([{ id: 't1', quantity: 10 }]);
        mocks.tx.transfer.findUnique.mockResolvedValue({
            id: 't1', fromWarehouseId: 'wh1', toWarehouseId: null,
            productId: 'p1', modelId: 'm1', quantity: 10, status: 'PENDING',
        });

        const result = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: 'S1' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.transferFindMany).toHaveBeenCalledOnce();
        expect(mocks.tx.carton.updateMany).toHaveBeenCalled();
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

describe('scanOutService.manualExit - خروج دستی (بدون QR)', () => {
    const product = { id: 'p1', name: 'پیچ مینی', unit: 'عدد', deletedAt: null };
    const model = { id: 'm1', name: 'مدل ۲', productId: 'p1', deletedAt: null, unitsPerBox: 1, packageType: 'تکی' };

    beforeEach(() => {
        mocks.productFindUnique.mockResolvedValue(product);
        mocks.productModelFindUnique.mockResolvedValue(model);
        // موجودی: یک کارتن تکی IN_STOCK
        mocks.tx.carton.findMany.mockResolvedValue([
            { id: 'c1', isIndividual: true, model: { unitsPerBox: 1 } },
        ]);
    });

    it('محصول+مدل+تعداد مطابق یک سفارش فعال → خروج موفق و اتصال به سفارش', async () => {
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(0);
        mocks.tx.order.findUnique.mockResolvedValue(orderRow({ items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] }));
        mocks.tx.carton.updateMany.mockResolvedValue({ count: 1 });

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1 }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.tx.carton.updateMany).toHaveBeenCalled();
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledOnce();
        const outTx = mocks.tx.transaction.create.mock.calls.map((c: any[]) => c[0].data).filter((d: any) => d.type === 'OUT');
        expect(outTx).toHaveLength(1);
        expect(outTx[0].quantity).toBe(1);
    });

    it('مطابق یک دستور خروج/جابه‌جایی فعال → خروج موفق به دستور', async () => {
        mocks.orderFindMany.mockResolvedValue([]);
        mocks.transferFindMany.mockResolvedValue([{ id: 't1', quantity: 10 }]);
        mocks.tx.transfer.findUnique.mockResolvedValue({
            id: 't1', fromWarehouseId: 'wh1', toWarehouseId: null,
            productId: 'p1', modelId: 'm1', quantity: 10, status: 'PENDING',
        });

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1 }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.tx.carton.updateMany).toHaveBeenCalled();
    });

    it('هیچ سفارش/دستور فعال منطبق → خطای اجازهٔ خروج ندارد', async () => {
        mocks.orderFindMany.mockResolvedValue([]);
        mocks.transferFindMany.mockResolvedValue([]);

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1 }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('اجازهٔ خروج ندارد');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('چند سفارش فعال منطبق → خطای انتخاب صریح با لیست هدف‌های ممکن', async () => {
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', orderNumber: 1, city: 'تهران', receiverName: 'رضا', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
            { id: 'order2', orderNumber: 2, city: 'کرج', receiverName: 'علی', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(0);

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1 }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('چند سفارش');
        expect(result.candidates).toHaveLength(2);
        expect(result.candidates![0]).toEqual(expect.objectContaining({ kind: 'order', id: 'order1' }));
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('خروج دستی با هدف صریح (orderId از پیکر) → موفق حتی با چند سفارش فعال', async () => {
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
            { id: 'order2', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(0);
        mocks.tx.order.findUnique.mockResolvedValue(orderRow({ id: 'order2', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] }));
        mocks.tx.carton.updateMany.mockResolvedValue({ count: 1 });

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1, orderId: 'order2' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.tx.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ orderId: 'order2' }) })
        );
    });

    it('انتخاب هم‌زمان سفارش و دستور در خروج دستی → رد', async () => {
        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1, orderId: 'o1', transferId: 't1' }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('فقط یکی');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('موجودی کافی نباشد → خطا', async () => {
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(0);
        mocks.tx.carton.findMany.mockResolvedValue([]);

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 3 }, 'wh1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('موجودی کافی');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('با انتخاب راننده → رکورد تحویل IN_TRANSIT برای همان سفارش ساخته می‌شود', async () => {
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
        ]);
        mocks.cartonCount.mockResolvedValue(0);
        mocks.tx.order.findUnique.mockResolvedValue(orderRow({ items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] }));
        mocks.tx.carton.updateMany.mockResolvedValue({ count: 1 });
        // رانندهٔ تیک‌خورده: بررسی قبل از تراکنش + داخل تراکنش
        mocks.userFindUnique.mockResolvedValue({
            id: 'd1', name: 'علی', phone: '09120000000', role: 'DRIVER', isActive: true, deletedAt: null, warehouseId: 'wh1',
        });
        mocks.tx.user.findUnique.mockResolvedValue({
            id: 'd1', name: 'علی', phone: '09120000000', role: 'DRIVER', isActive: true, deletedAt: null, warehouseId: 'wh1',
        });

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1, driverId: 'd1' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(true);
        expect(mocks.tx.delivery.upsert).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { orderId: 'order1' },
                create: expect.objectContaining({ driverId: 'd1', status: 'IN_TRANSIT' }),
            })
        );
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order:driver:assigned' }) })
        );
        expect(result.carton.driver).toEqual(expect.objectContaining({ id: 'd1', name: 'علی' }));
    });

    it('راننده‌ای که تیک نخورده → خطای واضح و بدون خروج', async () => {
        mocks.orderFindMany.mockResolvedValue([
            { id: 'order1', items: [{ productId: 'p1', modelId: 'm1', quantity: 5 }] },
        ]);
        mocks.userFindUnique.mockResolvedValue({
            id: 'd1', name: 'علی', role: 'DRIVER', isActive: true, deletedAt: null, warehouseId: 'wh-other',
        });

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1, driverId: 'd1' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('تیک');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });

    it('انتخاب راننده برای خروجِ دستور مدیر → خطای واضح', async () => {
        mocks.orderFindMany.mockResolvedValue([]);
        mocks.transferFindMany.mockResolvedValue([{ id: 't1', quantity: 10 }]);

        const result = await scanOutService.manualExit(
            { productId: 'p1', modelId: 'm1', quantity: 1, driverId: 'd1' }, 'wh1', 'user1',
        );
        expect(result.valid).toBe(false);
        expect(result.error).toContain('دستور');
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
    });
});

describe('scanOutService.assignDriver - تخصیص بار به راننده (بعد از اسکن)', () => {
    const driverRow = (overrides: any = {}) => ({
        id: 'd1', name: 'علی', phone: '09120000000',
        role: 'DRIVER', isActive: true, deletedAt: null, warehouseId: 'wh1',
        ...overrides,
    });

    it('سفارش + رانندهٔ تیک‌خورده → رکورد تحویل IN_TRANSIT، ممیزی و رویداد', async () => {
        mocks.tx.order.findUnique.mockResolvedValue({
            id: 'order1', orderNumber: 8, warehouseId: 'wh1', status: 'SHIPPED', delivery: null,
        });
        mocks.tx.user.findUnique.mockResolvedValue(driverRow());
        mocks.tx.warehouse.findUnique.mockResolvedValue({ name: 'خزایی' });

        const result = await scanOutService.assignDriver({ orderId: 'order1', driverId: 'd1' }, 'wh1', 'user1');
        expect(result.valid).toBe(true);
        expect(mocks.tx.delivery.upsert).toHaveBeenCalledWith({
            where: { orderId: 'order1' },
            create: { orderId: 'order1', driverId: 'd1', status: 'IN_TRANSIT' },
            update: { driverId: 'd1', status: 'IN_TRANSIT' },
        });
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({
                    aggregate: 'order',
                    type: 'order:driver:assigned',
                    payload: expect.objectContaining({
                        orderId: 'order1', orderNumber: 8, driverId: 'd1', driverName: 'علی', warehouseId: 'wh1',
                    }),
                }),
            })
        );
        expect(mocks.tx.auditLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ action: 'order.assign_driver', entityId: 'order1' }) })
        );
        expect(result.assignment).toEqual(expect.objectContaining({ orderId: 'order1', driverId: 'd1', driverName: 'علی' }));
    });

    it('راننده‌ای که برای این انبار تیک نخورده → خطا', async () => {
        mocks.tx.order.findUnique.mockResolvedValue({
            id: 'order1', orderNumber: 8, warehouseId: 'wh1', status: 'SHIPPED', delivery: null,
        });
        mocks.tx.user.findUnique.mockResolvedValue(driverRow({ warehouseId: 'wh-other' }));

        const result = await scanOutService.assignDriver({ orderId: 'order1', driverId: 'd1' }, 'wh1', 'user1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('تیک');
        expect(mocks.tx.delivery.upsert).not.toHaveBeenCalled();
    });

    it('راننده یافت نشد → خطا', async () => {
        mocks.tx.order.findUnique.mockResolvedValue({
            id: 'order1', orderNumber: 8, warehouseId: 'wh1', status: 'SHIPPED', delivery: null,
        });
        mocks.tx.user.findUnique.mockResolvedValue(null);

        const result = await scanOutService.assignDriver({ orderId: 'order1', driverId: 'd1' }, 'wh1', 'user1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('یافت نشد');
        expect(mocks.tx.delivery.upsert).not.toHaveBeenCalled();
    });

    it('سفارش از انبار دیگر → خطا', async () => {
        mocks.tx.order.findUnique.mockResolvedValue({
            id: 'order1', orderNumber: 8, warehouseId: 'wh-other', status: 'SHIPPED', delivery: null,
        });

        const result = await scanOutService.assignDriver({ orderId: 'order1', driverId: 'd1' }, 'wh1', 'user1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('انبار شما نیست');
    });

    it('بار قبلاً تحویل شده → قابل تغییر نیست', async () => {
        mocks.tx.order.findUnique.mockResolvedValue({
            id: 'order1', orderNumber: 8, warehouseId: 'wh1', status: 'SHIPPED',
            delivery: { status: 'DELIVERED', driverId: 'd1' },
        });

        const result = await scanOutService.assignDriver({ orderId: 'order1', driverId: 'd1' }, 'wh1', 'user1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('تحویل شده');
        expect(mocks.tx.delivery.upsert).not.toHaveBeenCalled();
    });

    it('تغییر راننده پیش از تحویل مجاز است', async () => {
        mocks.tx.order.findUnique.mockResolvedValue({
            id: 'order1', orderNumber: 8, warehouseId: 'wh1', status: 'SHIPPED',
            delivery: { status: 'IN_TRANSIT', driverId: 'd-old' },
        });
        mocks.tx.user.findUnique.mockResolvedValue(driverRow({ id: 'd2', name: 'رضا' }));

        const result = await scanOutService.assignDriver({ orderId: 'order1', driverId: 'd2' }, 'wh1', 'user1');
        expect(result.valid).toBe(true);
        expect(mocks.tx.delivery.upsert).toHaveBeenCalledWith(
            expect.objectContaining({ update: { driverId: 'd2', status: 'IN_TRANSIT' } })
        );
    });
});
