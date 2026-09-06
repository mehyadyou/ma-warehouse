import { describe, it, expect } from 'vitest';
import { gregorianToJalali, jalaliToGregorian, jalaliYear, jalaliDayKey } from './jalali';

describe('jalaliToGregorian', () => {
    it('مرجع مستند jalaali-js: 1395/1/23 → 2016-04-11', () => {
        const d = jalaliToGregorian(1395, 1, 23);
        expect(d.getFullYear()).toBe(2016);
        expect(d.getMonth() + 1).toBe(4);
        expect(d.getDate()).toBe(11);
    });

    it('نوروز ۱۴۰۵ → 2026-03-21', () => {
        const d = jalaliToGregorian(1405, 1, 1);
        expect(d.getFullYear()).toBe(2026);
        expect(d.getMonth() + 1).toBe(3);
        expect(d.getDate()).toBe(21);
    });

    it('۱۴۰۵/۰۵/۲۷ (امروز) → 2026-08-18', () => {
        const d = jalaliToGregorian(1405, 5, 27);
        expect(d.getFullYear()).toBe(2026);
        expect(d.getMonth() + 1).toBe(8);
        expect(d.getDate()).toBe(18);
    });

    it('سال کبیسه: ۱۴۰۳/۱۲/۳۰ → 2025-03-20', () => {
        const d = jalaliToGregorian(1403, 12, 30);
        expect(d.getFullYear()).toBe(2025);
        expect(d.getMonth() + 1).toBe(3);
        expect(d.getDate()).toBe(20);
    });

    it('سال غیر کبیسه: ۱۴۰۴/۱۲/۲۹ → 2026-03-20', () => {
        const d = jalaliToGregorian(1404, 12, 29);
        expect(d.getFullYear()).toBe(2026);
        expect(d.getMonth() + 1).toBe(3);
        expect(d.getDate()).toBe(20);
    });

    it('پایان ۱۴۰۳ (کبیسه): ۱۴۰۳/۱۲/۳۰ + ۱ روز = نوروز ۱۴۰۴', () => {
        const d = jalaliToGregorian(1403, 12, 30);
        const next = new Date(d.getFullYear(), d.getMonth(), d.getDate() + 1);
        expect(jalaliYear(next)).toBe(1404);
        expect(next.getMonth() + 1).toBe(3);
        expect(next.getDate()).toBe(21);
    });
});

describe('gregorianToJalali', () => {
    it('نوروز ۱۴۰۵ → 2026-03-21 و برعکس', () => {
        expect(gregorianToJalali(2026, 3, 21)).toEqual({ year: 1405, month: 1, day: 1 });
    });

    it('آخرِ سال غیرکبیسه: 2026-03-20 → 1404/12/29', () => {
        expect(gregorianToJalali(2026, 3, 20)).toEqual({ year: 1404, month: 12, day: 29 });
    });

    it('آخرِ سال کبیسه: 2025-03-20 → 1403/12/30', () => {
        expect(gregorianToJalali(2025, 3, 20)).toEqual({ year: 1403, month: 12, day: 30 });
    });

    it('۱۴۰۵/۰۵/۲۷ ↔ 2026-08-18', () => {
        expect(gregorianToJalali(2026, 8, 18)).toEqual({ year: 1405, month: 5, day: 27 });
    });

    it('با jalaliToGregorian سازگار است (چند تاریخ کلیدی)', () => {
        for (const [jy, jm, jd] of [
            [1405, 1, 1],
            [1405, 5, 27],
            [1405, 6, 14],
            [1404, 12, 29],
            [1403, 12, 30],
            [1390, 1, 1],
        ] as const) {
            const g = jalaliToGregorian(jy, jm, jd);
            expect(gregorianToJalali(g.getFullYear(), g.getMonth() + 1, g.getDate())).toEqual({
                year: jy,
                month: jm,
                day: jd,
            });
        }
    });
});

describe('jalaliDayKey (روزِ شمسیِ تهران — مبنای شمارهٔ روزانهٔ سفارش)', () => {
    it('نیمه‌شب تهران (UTC+3:30) مرزِ روز را درست می‌سازد', () => {
        // ۱۴۰۵/۰۶/۱۴ = 2026-09-05 میلادی؛ نیمه‌شبِ تهرانِ آن روز = 2026-09-04T20:30Z
        expect(jalaliDayKey(new Date('2026-09-04T20:29:59Z'))).toBe(14050613);
        expect(jalaliDayKey(new Date('2026-09-04T20:30:00Z'))).toBe(14050614);
        expect(jalaliDayKey(new Date('2026-09-05T20:29:59Z'))).toBe(14050614);
        expect(jalaliDayKey(new Date('2026-09-05T20:30:00Z'))).toBe(14050615);
    });
});

describe('round-trip jalaliYear ↔ jalaliToGregorian', () => {
    it('هر دو جهت روی چند تاریخ کلیدی سازگارند', () => {
        const cases: [number, number, number][] = [
            [1405, 1, 1],
            [1405, 5, 27],
            [1404, 12, 29],
            [1403, 12, 30],
            [1390, 1, 1],
        ];
        for (const [jy, jm, jd] of cases) {
            const g = jalaliToGregorian(jy, jm, jd);
            expect(jalaliYear(g)).toBe(jy);
        }
    });
});
