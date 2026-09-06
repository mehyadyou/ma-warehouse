/**
 * ═══ تست حساسِ پیش از انتشار — سناریو ۲ ═══
 * «جعل لیبل QR» — QR دست‌ساز با HMAC نامعتبر:
 *  - لایهٔ رمزنگاری (utils/qr): دستکاریِ هر بخش از payload → خطای «امضای QR نامعتبر است»
 *  - لایهٔ عملیات (scanout.service.scanOut): QR جعلی «قبل از هر دسترسی به دیتابیس» رد می‌شود
 *
 * نکتهٔ امنیتی: HMAC با QR_SECRET سرور امضا می‌شود؛ مهاجم بدونِ سکرت نمی‌تواند
 * سریالِ دیگری (مثلاً کارتن گران‌تر) جایگزین کند. این تستِ فرار (bypass attempt) است.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        carton: { findUnique: vi.fn(), findFirst: vi.fn() },
        order: { findFirst: vi.fn() },
        transfer: { findUnique: vi.fn() },
        activityLog: { create: vi.fn() },
    },
}));

vi.mock('../../utils/serializableTx', () => ({
    runSerializable: vi.fn(async (fn: (tx: unknown) => Promise<unknown>) => {
        const { prisma } = await import('../../utils/prisma');
        return prisma.$transaction(fn);
    }),
}));

import { scanOutService } from '../scanout/scanout.service';
import { buildQrForSerial, verifySerialPayload, verifyPayload, signPayload } from '../../utils/qr';
import { prisma } from '../../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

describe('آدیت ۲ — جعل لیبل QR (امضای HMAC)', () => {
    const valid = () =>
        buildQrForSerial({
            serial: 'MA-1405-000042',
            uuid: 'u-42',
            productName: 'سینک ظرفشویی',
            modelName: 'SL116',
            capacityPerBox: 2,
        });

    it('QR سالم → تأیید می‌شود (sanity)', () => {
        const { qrPayload } = valid();
        const v = verifySerialPayload(qrPayload);
        expect(v.serial).toBe('MA-1405-000042');
    });

    it('دستکاریِ سریال داخلِ payload → امضا رد می‌شود', () => {
        const { qrPayload } = valid();
        const tampered = qrPayload.replace('MA-1405-000042', 'MA-1405-999999');
        expect(() => verifySerialPayload(tampered)).toThrow('امضای QR نامعتبر است');
    });

    it('دستکاریِ نام محصول → امضا رد می‌شود', () => {
        const { qrPayload } = valid();
        const tampered = qrPayload.replace('سینک ظرفشویی', 'سینک گران‌قیمت');
        expect(() => verifySerialPayload(tampered)).toThrow('امضای QR نامعتبر است');
    });

    it('HMAC دست‌ساز (بدون سکرت) → رد می‌شود', () => {
        const forged = 'MA|SN|MA-1405-000042|u-42|سینک ظرفشویی|SL116|2|' + 'a'.repeat(32);
        expect(() => verifySerialPayload(forged)).toThrow('امضای QR نامعتبر است');
    });

    it('HMAC دست‌ساز روی فرمتِ قدیمی (v1) هم رد می‌شود', () => {
        const { qrPayload } = signPayload({ productCode: 'P1', modelCode: 'M1', capacityPerBox: 12, uuid: 'u1' });
        const forged = qrPayload.split('|').slice(0, 5).join('|') + '|' + 'b'.repeat(32);
        expect(() => verifyPayload(forged)).toThrow();
    });

    it('کوتاه‌کردن/بلندکردن HMAC → رد می‌شود', () => {
        const { qrPayload } = valid();
        const parts = qrPayload.split('|');
        const body = parts.slice(0, -1).join('|');
        expect(() => verifySerialPayload(`${body}|${'c'.repeat(16)}`)).toThrow('امضای QR نامعتبر است');
        expect(() => verifySerialPayload(`${body}|${'c'.repeat(64)}`)).toThrow('امضای QR نامعتبر است');
    });

    // ── لایهٔ عملیات: scanOut نباید QR جعلی را به DB برساند ──

    it('scanOut با QR جعلی → valid:false و «صفر کوئری دیتابیس»', async () => {
        const forged = 'MA|SN|MA-1405-000042|u-42|سینک ظرفشویی|SL116|2|' + 'f'.repeat(32);

        const result = await scanOutService.scanOut(
            { qrPayload: forged, serialNumber: '' },
            'wh1',
            'user1',
        );

        expect(result).toEqual({ valid: false, error: 'کد QR معتبر نیست' });
        // قبل از ردِ امضا هیچlookupی نباید انجام شده باشد
        expect(prisma.carton.findUnique).not.toHaveBeenCalled();
        expect(prisma.carton.findFirst).not.toHaveBeenCalled();
    });

    it('scanOut با سریالِ دستکاری‌شده اما HMAC سالمِ کارتنِ دیگر → امضا رد و به DB نمی‌رسد', async () => {
        const { qrPayload } = valid();
        const tampered = qrPayload.replace('MA-1405-000042', 'MA-1405-000043');

        const result = await scanOutService.scanOut(
            { qrPayload: tampered, serialNumber: '' },
            'wh1',
            'user1',
        );

        expect(result.valid).toBe(false);
        expect(prisma.carton.findUnique).not.toHaveBeenCalled();
        expect(prisma.carton.findFirst).not.toHaveBeenCalled();
    });
});
