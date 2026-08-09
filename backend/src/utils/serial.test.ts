import { describe, it, expect, vi } from 'vitest';
import { jalaliYear } from './jalali';
import { nextSerial } from './serial';

describe('jalaliYear', () => {
    it('تبدیل تاریخ میلادی به سال شمسی', () => {
        expect(jalaliYear(new Date(2026, 2, 21))).toBe(1405); // 1 فروردین ۱۴۰۵
        expect(jalaliYear(new Date(2025, 2, 21))).toBe(1404); // 1 فروردین ۱۴۰۴
        expect(jalaliYear(new Date(2026, 7, 8))).toBe(1405); // ۱۷ مرداد ۱۴۰۵
        expect(jalaliYear(new Date(2027, 2, 20))).toBe(1405); // ۲۹ اسفند ۱۴۰۵
        expect(jalaliYear(new Date(2027, 2, 21))).toBe(1406); // 1 فروردین ۱۴۰۶
    });
});

describe('nextSerial', () => {
    it('شماره‌ی ترتیبی با پیشوند سال شمسی و صفرگذاری', async () => {
        const tx = {
            serialSequence: {
                upsert: vi.fn().mockResolvedValue({ year: 1405, lastSeq: 7 }),
            },
        } as any;

        expect(await nextSerial(tx)).toBe('MA-1405-000007');
        expect(tx.serialSequence.upsert).toHaveBeenCalledWith({
            where: { year: 1405 },
            update: { lastSeq: { increment: 1 } },
            create: { year: 1405, lastSeq: 1 },
        });
    });

    it('سال نو: شمارنده از ۱ شروع می‌شود', async () => {
        const tx = {
            serialSequence: {
                upsert: vi.fn().mockResolvedValue({ year: 1406, lastSeq: 1 }),
            },
        } as any;

        const year = jalaliYear(new Date());
        expect(await nextSerial(tx)).toBe(`MA-${year}-000001`);
    });
});
