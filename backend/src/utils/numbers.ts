import { AppError } from '../common/exceptions/AppError';

// تبدیل ارقام فارسی/عربی به انگلیسی + حذف جداکننده‌های هزارگان (٬ ، , و فاصله)
export function normalizeDigits(input: string): string {
    let s = input.replace(/[٬,،\s]/g, '');
    s = s.replace(/[۰-۹]/g, d => String('۰۱۲۳۴۵۶۷۸۹'.indexOf(d)));
    s = s.replace(/[٠-٩]/g, d => String('٠١٢٣٤٥٦٧٨٩'.indexOf(d)));
    return s;
}

// عدد صحیح اختیاری (ظرفیت بسته و…) — ارقام فارسی/عربی پذیرفته می‌شود
export function parseOptionalInt(raw: unknown, fieldLabel: string): number | null {
    if (raw === undefined || raw === null) return null;
    const s = normalizeDigits(String(raw)).trim();
    if (s === '') return null;
    if (!/^\d+$/.test(s)) throw new AppError(`${fieldLabel} باید عدد صحیح باشد`, 400);
    const n = Number.parseInt(s, 10);
    if (n <= 0) throw new AppError(`${fieldLabel} باید بزرگتر از صفر باشد`, 400);
    return n;
}

// عدد اعشاری اختیاری (قیمت) — ارقام فارسی/عربی پذیرفته می‌شود
export function parseOptionalPrice(raw: unknown, fieldLabel: string): number | null {
    if (raw === undefined || raw === null) return null;
    const s = normalizeDigits(String(raw)).trim();
    if (s === '') return null;
    if (!/^-?\d+(\.\d+)?$/.test(s)) throw new AppError(`${fieldLabel} باید عدد باشد`, 400);
    const n = Number.parseFloat(s);
    if (n < 0) throw new AppError(`${fieldLabel} نمی‌تواند منفی باشد`, 400);
    if (n > 1e14) throw new AppError(`${fieldLabel} بیش از حد بزرگ است`, 400);
    return n;
}
