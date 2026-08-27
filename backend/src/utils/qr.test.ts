import { describe, it, expect } from 'vitest';
import { buildQrForSerial, verifySerialPayload } from './qr';

describe('qr — فرمت سریال (v2/v3)', () => {
    it('v3: محصول/مدل/ظرفیت داخل QR می‌آید و سریال قابل استخراج است', () => {
        const { qrPayload } = buildQrForSerial({
            serial: 'MA-1405-000012',
            uuid: 'u1',
            productName: 'سینک ظرفشویی',
            modelName: 'SL116',
            capacityPerBox: 2,
        });
        const parts = qrPayload.split('|');
        expect(parts.length).toBe(8); // MA|SN|serial|uuid|product|model|capacity|hmac
        expect(parts[0]).toBe('MA');
        expect(parts[1]).toBe('SN');
        expect(parts[2]).toBe('MA-1405-000012');
        expect(parts[4]).toBe('سینک ظرفشویی');
        expect(parts[5]).toBe('SL116');
        expect(parts[6]).toBe('2');

        const verified = verifySerialPayload(qrPayload);
        expect(verified.serial).toBe('MA-1405-000012');
        expect(verified.uuid).toBe('u1');
    });

    it('v2 (بدون اطلاعات محصول) همچنان قابل اعتبارسنجی است', () => {
        const { qrPayload } = buildQrForSerial({ serial: 'MA-1405-000001', uuid: 'c1' });
        const parts = qrPayload.split('|');
        expect(parts.length).toBe(5); // MA|SN|serial|uuid|hmac

        const verified = verifySerialPayload(qrPayload);
        expect(verified.serial).toBe('MA-1405-000001');
        expect(verified.uuid).toBe('c1');
    });

    it('کاراکتر | در نام محصول/مدل پاکسازی می‌شود', () => {
        const { qrPayload } = buildQrForSerial({
            serial: 'S1',
            uuid: 'u1',
            productName: 'سینک | ظرفشویی',
            modelName: 'A|B',
            capacityPerBox: 2,
        });
        const parts = qrPayload.split('|');
        expect(parts.length).toBe(8);
        expect(parts[4]).toBe('سینک / ظرفشویی');
        expect(parts[5]).toBe('A/B');
    });

    it('دستکاری محتوا → امضا نامعتبر است', () => {
        const { qrPayload } = buildQrForSerial({
            serial: 'MA-1405-000012',
            uuid: 'u1',
            productName: 'سینک ظرفشویی',
            modelName: 'SL116',
            capacityPerBox: 2,
        });
        const tampered = qrPayload.replace('MA-1405-000012', 'MA-1405-999999');
        expect(() => verifySerialPayload(tampered)).toThrow('امضای QR نامعتبر است');
    });

    it('فرمت ناشناخته → خطا', () => {
        expect(() => verifySerialPayload('MA|SN|S1|u1')).toThrow('فرمت QR نامعتبر است');
        expect(() => verifySerialPayload('MA|P|M|1|u|hmac')).toThrow('فرمت QR نامعتبر است');
    });
});
