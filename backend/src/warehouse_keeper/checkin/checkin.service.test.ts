import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        warehouse: { findUnique: vi.fn() },
        product: { findMany: vi.fn() },
        carton: { findMany: vi.fn(), updateMany: vi.fn() },
        idempotencyKey: { findUnique: vi.fn() },
        $transaction: vi.fn(),
    },
}));

vi.mock('../../utils/qr', () => ({
    buildQrForSerial: vi.fn((parts: { serial: string; uuid: string }) => ({
        qrPayload: `MA|SN|${parts.serial}|${parts.uuid}|hmac`,
        hmac: 'hmac',
    })),
    verifySerialPayload: vi.fn(),
}));

vi.mock('../../utils/serial', () => ({
    nextSerial: vi.fn().mockResolvedValue('MA-1405-000001'),
    // تخصیص دسته‌ای: سریال‌های ترتیبی MA-1405-000001.. برمی‌گرداند
    nextSerials: vi.fn().mockImplementation(async (_tx: unknown, count: number) =>
        Array.from(
            { length: Math.max(0, count) },
            (_, i) => `MA-1405-${String(i + 1).padStart(6, '0')}`,
        ),
    ),
}));

import { checkinService, CheckinItem } from './checkin.service';
import { prisma } from '../../utils/prisma';
import { buildQrForSerial, verifySerialPayload } from '../../utils/qr';

beforeEach(() => {
    vi.clearAllMocks();
    (prisma.warehouse.findUnique as any).mockResolvedValue({ name: 'انبار تست' });
    (prisma.product.findMany as any).mockResolvedValue([
        { id: 'p1', name: 'کالای A', models: [{ id: 'm1', productId: 'p1', name: 'مدل ۱', unitsPerBox: 10, packageType: 'کارتن' }] },
    ]);
    (prisma.carton.findMany as any).mockResolvedValue([]);
});

describe('checkinService.submitCheckin - validation', () => {
    it('warehouseId نداشته باشد → 403', async () => {
        await expect(
            checkinService.submitCheckin('', 'user1', [{ productId: 'p1', cartonCount: 1, individualCount: 0 }])
        ).rejects.toThrow('انباردار به انباری وصل نیست');
    });

    it('آیتم خالی → 400', async () => {
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [])
        ).rejects.toThrow('حداقل یک محصول وارد کنید');
    });

    it('محصول یافت نشده → 404', async () => {
        (prisma.product.findMany as any).mockResolvedValue([]);
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{ productId: 'missing', cartonCount: 1, individualCount: 0 }])
        ).rejects.toThrow('محصول یافت نشد');
    });

    it('تعداد منفی → 400', async () => {
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{ productId: 'p1', cartonCount: -1, individualCount: 0 }])
        ).rejects.toThrow('تعداد نمی‌تواند منفی باشد');
    });

    it('هر دو صفر → 400', async () => {
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{ productId: 'p1', cartonCount: 0, individualCount: 0 }])
        ).rejects.toThrow('برای هر ردیف حداقل یک کارتن یا یک تکی وارد کنید');
    });

    it('ظرفیت بسته صفر → 400', async () => {
        (prisma.product.findMany as any).mockResolvedValue([
            { id: 'p1', name: 'کالا', models: [{ id: 'm1', productId: 'p1', name: 'مدل', unitsPerBox: 0, packageType: 'کارتن' }] },
        ]);
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{ productId: 'p1', modelId: 'm1', cartonCount: 1, individualCount: 0 }])
        ).rejects.toThrow('ظرفیت بسته');
    });

    it('مرجوعی بدون سریال → 400', async () => {
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{
                productId: 'p1', entryType: 'RETURNED', serialNumber: undefined,
                cartonCount: 0, individualCount: 1,
            }])
        ).rejects.toThrow('سریال');
    });

    it('مرجوعی با cartonCount > 0 → 400', async () => {
        (prisma.carton.findMany as any).mockResolvedValue([
            { serialNumber: 'S1', status: 'SHIPPED', scannedOutAt: new Date(), entryType: 'NEW' },
        ]);
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{
                productId: 'p1', entryType: 'RETURNED', serialNumber: 'S1',
                cartonCount: 1, individualCount: 0,
            }])
        ).rejects.toThrow('مرجوعی فقط باید');
    });

    it('مدل متعلق به محصول دیگری است → 400', async () => {
        (prisma.product.findMany as any).mockResolvedValue([
            { id: 'p1', name: 'کالای A', models: [{ id: 'm1', productId: 'p1', name: 'مدل ۱', unitsPerBox: 10, packageType: 'کارتن' }] },
            { id: 'p2', name: 'کالای B', models: [{ id: 'm2', productId: 'p2', name: 'مدل ۲', unitsPerBox: 5, packageType: 'کارتن' }] },
        ]);
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{
                productId: 'p1', modelId: 'm2', cartonCount: 1, individualCount: 0,
            }])
        ).rejects.toThrow('متعلق به این محصول نیست');
    });

    it('مرجوعی رقابتی: سریال هم‌زمان مرجوع شده → 400', async () => {
        (prisma.carton.findMany as any).mockResolvedValue([
            { serialNumber: 'S1', status: 'SHIPPED', scannedOutAt: new Date(), entryType: 'NEW' },
        ]);
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            return await cb({
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 0 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            });
        });

        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{
                productId: 'p1', entryType: 'RETURNED', serialNumber: 'S1',
                cartonCount: 0, individualCount: 1,
            }])
        ).rejects.toThrow('قبلاً مرجوع شده است');
    });

    it('کارتنِ برگشتی که هنوز در انبار است (مرجوعی دوباره بدون خروجِ مجدد) → رد', async () => {
        (prisma.carton.findMany as any).mockResolvedValue([
            { serialNumber: 'S1', status: 'IN_STOCK', scannedOutAt: null, entryType: 'RETURNED' },
        ]);

        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{
                productId: 'p1', entryType: 'RETURNED', serialNumber: 'S1',
                cartonCount: 0, individualCount: 1,
            }])
        ).rejects.toThrow('هنوز در انبار موجود است');
    });
});

describe('checkinService.submitCheckin - موفقیت', () => {
    it('ساخت کارتن‌ها و تعداد invididual', async () => {
        let txFn: any;
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            const tx = {
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            };
            txFn = tx;
            return await cb(tx);
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [
            { productId: 'p1', modelId: 'm1', cartonCount: 2, individualCount: 1 },
        ]);

        expect(result.cartons).toHaveLength(3); // 2 کارتن + 1 تکی
        expect(result.totalUnits).toBe(21); // (2*10) + 1
        expect(txFn.carton.create).toHaveBeenCalledTimes(3);
    });

    it('هر کارتن و تکی جدید سریال اختصاصی و QR سریال می‌گیرد', async () => {
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            return await cb({
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            });
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [
            { productId: 'p1', modelId: 'm1', cartonCount: 1, individualCount: 1 },
        ]);

        // هر واحد سریال یکتا می‌گیرد (تخصیص دسته‌ای ترتیبی)
        expect(result.cartons[0].serialNumber).toBe('MA-1405-000001');
        expect(result.cartons[1].serialNumber).toBe('MA-1405-000002');
        expect(buildQrForSerial).toHaveBeenCalledWith(
            expect.objectContaining({ serial: 'MA-1405-000001' })
        );
        expect(buildQrForSerial).toHaveBeenCalledWith(
            expect.objectContaining({ serial: 'MA-1405-000002' })
        );
        expect(result.cartons[0].qrPayload).toContain('MA-1405-000001');
    });

    it('مرجوعی: سریال کارتن خروج‌زده حفظ می‌شود و QR همان سریال است', async () => {
        (prisma.carton.findMany as any).mockResolvedValue([
            { serialNumber: 'S1', status: 'SHIPPED', scannedOutAt: new Date(), entryType: 'NEW' },
        ]);
        let txFn: any;
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            const tx = {
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            };
            txFn = tx;
            return await cb(tx);
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [{
            productId: 'p1', entryType: 'RETURNED', serialNumber: 'S1',
            cartonCount: 0, individualCount: 1,
        }]);

        expect(result.cartons[0].serialNumber).toBe('S1');
        expect(buildQrForSerial).toHaveBeenCalledWith(
            expect.objectContaining({ serial: 'S1', uuid: expect.any(String) })
        );
        expect(txFn.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { serialNumber: 'S1', scannedOutAt: { not: null } },
                data: { serialNumber: null },
            })
        );
    });

    it('مرجوعیِ دوباره پس از خروجِ مجدد (چرخهٔ دوم همان سریال) → مجاز', async () => {
        // سریال S1 قبلاً یک بار مرجوعی شده (entryType RETURNED) و دوباره از انبار خارج شده است
        (prisma.carton.findMany as any).mockResolvedValue([
            { serialNumber: 'S1', status: 'SHIPPED', scannedOutAt: new Date(), entryType: 'RETURNED' },
        ]);
        let txFn: any;
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            const tx = {
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            };
            txFn = tx;
            return await cb(tx);
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [{
            productId: 'p1', entryType: 'RETURNED', serialNumber: 'S1',
            cartonCount: 0, individualCount: 1,
        }]);

        // سریال از کارتنِ برگشتیِ خروج‌زده پاک می‌شود و کارتنِ برگشتیِ تازه ساخته می‌شود
        expect(result.cartons).toHaveLength(1);
        expect(result.cartons[0].serialNumber).toBe('S1');
        expect(result.cartons[0].entryType).toBe('RETURNED');
        expect(txFn.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { serialNumber: 'S1', scannedOutAt: { not: null } },
                data: { serialNumber: null },
            })
        );
    });

    it('مرجوعی با اسکن QR جدید: سریال از QR استخراج می‌شود', async () => {
        (verifySerialPayload as any).mockReturnValue({ serial: 'MA-1405-000015', uuid: 'u1' });
        (prisma.carton.findMany as any).mockResolvedValue([
            { serialNumber: 'MA-1405-000015', status: 'SHIPPED', scannedOutAt: new Date(), entryType: 'NEW' },
        ]);
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            return await cb({
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            });
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [{
            productId: 'p1', entryType: 'RETURNED', qrPayload: 'MA|SN|MA-1405-000015|u1|hmac',
            cartonCount: 0, individualCount: 1,
        }]);

        expect(result.cartons[0].serialNumber).toBe('MA-1405-000015');
    });

    it('مرجوعی با QR بدون سریال (فرمت قدیمی) → خطا', async () => {
        (verifySerialPayload as any).mockImplementation(() => {
            throw new Error('فرمت QR نامعتبر است');
        });
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{
                productId: 'p1', entryType: 'RETURNED', qrPayload: 'MA|P|M|1|u|hmac',
                cartonCount: 0, individualCount: 1,
            }])
        ).rejects.toThrow('دستی وارد کنید');
    });

    it('مرجوعی بدون QR (withoutQr=true): سریال تازه + تراکنش RETURN + ورود IN_STOCK', async () => {
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            const tx = {
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 0 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            };
            return await cb(tx);
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [{
            productId: 'p1', entryType: 'RETURNED', withoutQr: true,
            cartonCount: 0, individualCount: 1,
        }]);

        expect(result.cartons).toHaveLength(1);
        expect(result.cartons[0].serialNumber).toBe('MA-1405-000001');
        expect(result.cartons[0].entryType).toBe('RETURNED');
        expect(result.cartons[0].isIndividual).toBe(true);
        expect(buildQrForSerial).toHaveBeenCalledWith(
            expect.objectContaining({ serial: 'MA-1405-000001' })
        );
    });

    it('مرجوعی بدون سریال و بدون فلگ withoutQr → 400', async () => {
        await expect(
            checkinService.submitCheckin('wh1', 'user1', [{
                productId: 'p1', entryType: 'RETURNED', withoutQr: false,
                cartonCount: 0, individualCount: 1,
            }])
        ).rejects.toThrow('سریال');
    });

    it('qrPayload قابل verify است', async () => {
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            return await cb({
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            });
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [
            { productId: 'p1', modelId: 'm1', cartonCount: 1, individualCount: 0 },
        ]);

        expect(result.cartons[0].qrPayload).toBeTruthy();
        expect(typeof result.cartons[0].qrPayload).toBe('string');
    });

    it('کلید ایدمپوتنسی تکراری → پاسخ قبلی بدون ثبت دوباره', async () => {
        (prisma.idempotencyKey.findUnique as any).mockResolvedValue({
            responseJson: { cartons: [], totalUnits: 0 },
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [
            { productId: 'p1', modelId: 'm1', cartonCount: 1, individualCount: 0 },
        ], 'same-key');

        expect(result).toEqual({ cartons: [], totalUnits: 0 });
        expect(prisma.$transaction).not.toHaveBeenCalled();
    });

    it('کلید ایدمپوتنسی جدید → ثبت کامل و ذخیره پاسخ در تراکنش', async () => {
        (prisma.idempotencyKey.findUnique as any).mockResolvedValue(null);
        let txFn: any;
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            const tx = {
                carton: { create: vi.fn().mockResolvedValue({}), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
                transaction: { create: vi.fn().mockResolvedValue({}) },
                activityLog: { create: vi.fn().mockResolvedValue({}) },
                outboxEvent: { create: vi.fn().mockResolvedValue({}) },
                idempotencyKey: { create: vi.fn().mockResolvedValue({}) },
            };
            txFn = tx;
            return await cb(tx);
        });

        const result = await checkinService.submitCheckin('wh1', 'user1', [
            { productId: 'p1', modelId: 'm1', cartonCount: 1, individualCount: 0 },
        ], 'new-key');

        expect(result.cartons).toHaveLength(1);
        expect(txFn.idempotencyKey.create).toHaveBeenCalledOnce();
        expect(txFn.outboxEvent.create).toHaveBeenCalledOnce();
        expect(txFn.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'checkin:completed' }) })
        );
    });
});

describe('checkinService - چاپ لیبل', () => {
    it('listRecentCartons فقط کارتن‌های چاپ‌نشده را برمی‌گرداند', async () => {
        (prisma.carton.findMany as any).mockResolvedValue([{ id: 'c1' }]);
        await checkinService.listRecentCartons('wh1');
        expect(prisma.carton.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: expect.objectContaining({ status: 'IN_STOCK', printedAt: null }),
            })
        );
    });

    it('listRecentCartons سقف دلخواه را به take می‌دهد (صف چاپ پنل: ۵۰۰)', async () => {
        (prisma.carton.findMany as any).mockResolvedValue([]);
        await checkinService.listRecentCartons('wh1', 500);
        expect(prisma.carton.findMany).toHaveBeenCalledWith(
            expect.objectContaining({ take: 500 })
        );
    });

    it('listPrintedCartons کارتن‌های چاپ‌شده را با ترتیب چاپ برمی‌گرداند', async () => {
        (prisma.carton.findMany as any).mockResolvedValue([{ id: 'c1', printedAt: new Date() }]);
        const res = await checkinService.listPrintedCartons('wh1');
        expect(res).toHaveLength(1);
        expect(prisma.carton.findMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { warehouseId: 'wh1', printedAt: { not: null } },
                orderBy: { printedAt: 'desc' },
            })
        );
    });

    it('markCartonsPrinted فقط کارتن‌های همین انبار و چاپ‌نشده را علامت می‌زند', async () => {
        (prisma.carton.updateMany as any).mockResolvedValue({ count: 2 });
        const res = await checkinService.markCartonsPrinted('wh1', ['c1', 'c2']);
        expect(res).toBe(2);
        expect(prisma.carton.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { id: { in: ['c1', 'c2'] }, warehouseId: 'wh1', printedAt: null },
                data: { printedAt: expect.any(Date) },
            })
        );
    });

    it('markCartonsPrinted با لیست خالی → ۰ بدون درخواست دیتابیس', async () => {
        const res = await checkinService.markCartonsPrinted('wh1', []);
        expect(res).toBe(0);
        expect(prisma.carton.updateMany).not.toHaveBeenCalled();
    });
});
