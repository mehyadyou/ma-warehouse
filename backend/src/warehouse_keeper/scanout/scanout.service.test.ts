import { describe, it, expect, vi, beforeEach } from 'vitest';
import { scanOutService } from './scanout.service';

const mocks = vi.hoisted(() => {
    const tx = {
        carton: { updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
        order: { updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        transaction: { create: vi.fn().mockResolvedValue({}) },
        warehouse: { findUnique: vi.fn().mockResolvedValue({ name: 'انبار اصلی' }) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
    };
    return {
        tx,
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
    mocks.tx.order.updateMany.mockResolvedValue({ count: 1 });
    mocks.tx.warehouse.findUnique.mockResolvedValue({ name: 'انبار اصلی' });
    mocks.tx.outboxEvent.create.mockResolvedValue({});
    mocks.findUnique.mockReset();
    mocks.findFirst.mockReset();
    mocks.findMany.mockReset();
});

describe('scanOutService.scanOut - QR معتبر', () => {
    it('اسکن موفق با QR', async () => {
        const { qrPayload } = signPayload({
            productCode: 'P', modelCode: 'M', capacityPerBox: 10, uuid: 'c1',
        });
        mocks.findUnique.mockResolvedValue(makeCarton());

        const result = await scanOutService.scanOut({ qrPayload, serialNumber: '' }, 'wh1');
        expect(result.valid).toBe(true);
        expect(mocks.findUnique).toHaveBeenCalledWith({ where: { id: 'c1' }, include: expect.anything() });
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledOnce();
    });

    it('اسکن موفق با QR جدید (سریال)', async () => {
        const { qrPayload } = buildQrForSerial({ serial: 'MA-1405-000001', uuid: 'c1' });
        mocks.findUnique.mockResolvedValue(makeCarton({ serialNumber: 'MA-1405-000001' }));

        const result = await scanOutService.scanOut({ qrPayload, serialNumber: '' }, 'wh1');
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
    it('اسکن موفق با سریال', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ serialNumber: 'S1' }));

        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1');
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

describe('scanOutService.scanOut - چرخش وضعیت سفارش', () => {
    it('وقتی کارتن به سفارش متصل باشد، سفارش SHIPPED میشود', async () => {
        mocks.findFirst.mockResolvedValue(
            makeCarton({ orderId: 'order1', order: { id: 'order1', customerPhone: null, city: 'تهران', address: null } }),
        );

        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1', 'user1');
        expect(result.valid).toBe(true);
        expect(mocks.tx.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 'c1', status: 'IN_STOCK', scannedOutAt: null } })
        );
        expect(mocks.tx.order.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 'order1', status: 'PENDING' } })
        );
        expect(mocks.tx.activityLog.create).toHaveBeenCalledOnce();
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'order_shipped' }) })
        );
        expect(mocks.tx.transaction.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'OUT' }) })
        );
    });

    it('وقتی کارتن به سفارش متصل نباشد، فقط کارتن آپدیت میشود', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));

        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1');
        expect(result.valid).toBe(true);
        expect(mocks.tx.carton.updateMany).toHaveBeenCalledOnce();
        expect(mocks.tx.order.updateMany).not.toHaveBeenCalled();
        expect(mocks.tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'carton_shipped' }) })
        );
    });

    it('مسابقه همزمان: برنده ۱ نفر؛ باخته خطای قبلاً خروج میگیرد', async () => {
        mocks.findFirst.mockResolvedValue(makeCarton({ orderId: null }));
        mocks.tx.carton.updateMany.mockResolvedValueOnce({ count: 0 });

        const result = await scanOutService.scanOut({ qrPayload: '', serialNumber: 'S1' }, 'wh1');
        expect(result.valid).toBe(false);
        expect(result.error).toContain('قبلاً خروج');
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
