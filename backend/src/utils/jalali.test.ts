import { describe, it, expect } from 'vitest';
import { jalaliToGregorian, jalaliYear } from './jalali';

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
