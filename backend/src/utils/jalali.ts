// تبدیل تاریخ شمسی به میلادی — الگوریتم استاندارد jalaali-js (Kazimierz M. Borkowski)
// همان الگوریتمی که تابع jalaliYear برای سمت معکوس استفاده می‌کند.

const BREAKS = [-61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178];

function div(a: number, b: number): number {
    return Math.trunc(a / b);
}

function mod(a: number, b: number): number {
    return a - Math.trunc(a / b) * b;
}

// تعیین روزِ مارس (میلادی) که سال شمسی از آن شروع می‌شود
function jalCal(jy: number, withoutLeap: boolean): { gy: number; march: number; leap?: number } {
    const bl = BREAKS.length;
    const gy = jy + 621;
    let leapJ = -14;
    let jp = BREAKS[0]!;
    let jump = 0;
    let leap = 0;

    if (jy < jp || jy >= BREAKS[bl - 1]!) {
        throw new Error('Invalid Jalaali year ' + jy);
    }

    for (let i = 1; i < bl; i += 1) {
        const jm = BREAKS[i]!;
        jump = jm - jp;
        if (jy < jm) break;
        leapJ = leapJ + div(jump, 33) * 8 + div(mod(jump, 33), 4);
        jp = jm;
    }
    let n = jy - jp;

    leapJ = leapJ + div(n, 33) * 8 + div(mod(n, 33) + 3, 4);
    if (mod(jump, 33) === 4 && jump - n === 4) leapJ += 1;

    const leapG = div(gy, 4) - div((div(gy, 100) + 1) * 3, 4) - 150;
    const march = 20 + leapJ - leapG;

    if (withoutLeap) return { gy, march };

    if (jump - n < 6) {
        const adjusted = n - jump + div(jump + 4, 33) * 33;
        n = adjusted;
    }
    leap = mod(mod(n + 1, 33) - 1, 4);
    if (leap === -1) leap = 4;

    return { gy, march, leap };
}

// روز ژولیانی از تاریخ میلادی
function g2d(gy: number, gm: number, gd: number): number {
    let d = div((gy + div(gm - 8, 6) + 100100) * 1461, 4)
        + div(153 * mod(gm + 9, 12) + 2, 5)
        + gd - 34840408;
    d = d - div(div(gy + 100100 + div(gm - 8, 6), 100) * 3, 4) + 752;
    return d;
}

// تاریخ میلادی از روز ژولیانی
function d2g(jdn: number): { gy: number; gm: number; gd: number } {
    let j = 4 * jdn + 139361631;
    j = j + div(div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
    const i = div(mod(j, 1461), 4) * 5 + 308;
    const gd = div(mod(i, 153), 5) + 1;
    const gm = mod(div(i, 153), 12) + 1;
    const gy = div(j, 1461) - 100100 + div(8 - gm, 6);
    return { gy, gm, gd };
}

// روز ژولیانی از تاریخ شمسی
function j2d(jy: number, jm: number, jd: number): number {
    const r = jalCal(jy, true);
    return g2d(r.gy, 3, r.march) + (jm - 1) * 31 - div(jm, 7) * (jm - 7) + jd - 1;
}

// تبدیل تاریخ شمسی به میلادی — ساعت ۱۲ ظهر (مبدأ محلی) برای دوری از لبه‌های DST
export function jalaliToGregorian(jy: number, jm: number, jd: number): Date {
    const g = d2g(j2d(jy, jm, jd));
    return new Date(g.gy, g.gm - 1, g.gd, 12);
}

// تبدیل تاریخ میلادی به شمسی (الگوریتم استاندارد jalaali-js)
// بر اساس سالِ تحویل (نوروز): اختلافِ روز از نوروز همان سال، ماه/روز شمسی را می‌دهد.
export function gregorianToJalali(gy: number, gm: number, gd: number): { year: number; month: number; day: number } {
    const jdn = g2d(gy, gm, gd);

    // حدس اولیه: سال شمسی ≈ سال میلادی − ۶۲۱؛ اگر قبل از نوروز بود یک سال کم کن
    let jy = gy - 621;
    const nowruzOf = (j: number) => g2d(jalCal(j, true).gy, 3, jalCal(j, true).march);
    let nowruz = nowruzOf(jy);
    if (jdn < nowruz) {
        jy -= 1;
        nowruz = nowruzOf(jy);
    }

    const dayOfYear = jdn - nowruz + 1; // ۱ تا ۳۶۵/۳۶۶
    let jm: number;
    let jd: number;
    if (dayOfYear <= 186) {
        // شش ماه اول هر کدام ۳۱ روز
        jm = 1 + Math.floor((dayOfYear - 1) / 31);
        jd = dayOfYear - 31 * (jm - 1);
    } else {
        // ماه‌های ۷ تا ۱۱ سی روزه و اسفند ۲۹/۳۰ روزه
        const rest = dayOfYear - 186;
        jm = 7 + Math.floor((rest - 1) / 30);
        jd = rest - 30 * (jm - 7);
    }
    return { year: jy, month: jm, day: jd };
}

// سال شمسی از روی تاریخ محلیِ همین ماشین (رفتار قبلی حفظ شده)
export function jalaliYear(date: Date): number {
    return gregorianToJalali(date.getFullYear(), date.getMonth() + 1, date.getDate()).year;
}

// اجزای تاریخِ میلادیِ «دیوارِ ساعتِ تهران» از روی یک لحظه — روزِ کسب‌وکارِ کاربر
function tehranGregorianParts(date: Date): { year: number; month: number; day: number } {
    const parts = new Intl.DateTimeFormat('en-US', {
        timeZone: 'Asia/Tehran',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
    }).formatToParts(date);
    const get = (type: string) => Number(parts.find((p) => p.type === type)?.value);
    return { year: get('year'), month: get('month'), day: get('day') };
}

/**
 * کلیدِ روزِ شمسیِ تهران برای یک لحظه — سال*۱۰۰۰۰ + ماه*۱۰۰ + روز (مثل 14050614).
 * مبنای «شمارهٔ روزانهٔ سفارش» (هر روز از ۱) است تا مرزِ روز با روزِ کاریِ کاربر یکی باشد.
 */
export function jalaliDayKey(date: Date): number {
    const g = tehranGregorianParts(date);
    const j = gregorianToJalali(g.year, g.month, g.day);
    return j.year * 10000 + j.month * 100 + j.day;
}

// ساعتِ کاملِ «دیوارِ ساعتِ تهران» از یک لحظه — برای ساختِ مرزِ روز
function tehranWallClock(date: Date): {
    year: number; month: number; day: number;
    hour: number; minute: number; second: number;
} {
    const parts = new Intl.DateTimeFormat('en-US', {
        timeZone: 'Asia/Tehran',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hourCycle: 'h23',
    }).formatToParts(date);
    const get = (type: string) => Number(parts.find((p) => p.type === type)?.value);
    return {
        year: get('year'), month: get('month'), day: get('day'),
        hour: get('hour'), minute: get('minute'), second: get('second'),
    };
}

/**
 * لحظه‌ای که ساعتِ تهران ۰۰:۰۰:۰۰ِ تاریخِ میلادیِ داده‌شده را نشان می‌دهد.
 * مستقل از منطقهٔ زمانیِ سرور — با حدسِ UTC+3:30 شروع و با Intl تصحیح می‌شود
 * (تغییرات DST تاریخی تهران را هم پوشش می‌دهد).
 */
function tehranMidnight(gy: number, gm: number, gd: number): Date {
    const expected = new Date(Date.UTC(gy, gm - 1, gd));
    const ey = expected.getUTCFullYear();
    const em = expected.getUTCMonth() + 1; // نرمال‌سازی سرریزِ روز (مثل gd+1 بعد از روز آخرِ ماه)
    const ed = expected.getUTCDate();
    let t = new Date(Date.UTC(gy, gm - 1, gd) - 210 * 60 * 1000); // حدس: ۰۰:۰۰ تهران = ۲۰:۳۰ UTCِ روز قبل
    for (let i = 0; i < 3; i++) {
        const w = tehranWallClock(t);
        if (w.year === ey && w.month === em && w.day === ed && w.hour === 0 && w.minute === 0 && w.second === 0) break;
        const gotSec = w.hour * 3600 + w.minute * 60 + w.second;
        t = new Date(t.getTime() - gotSec * 1000);
    }
    return t;
}

/**
 * بازهٔ [start, end) یک روزِ شمسی بر اساس ساعتِ تهران — مستقل از منطقهٔ زمانیِ سرور.
 * مرزِ روز همان روزِ کاریِ کاربر است (نه UTC)، پس «فعالیتِ ۱۴۰۵/۰۶/۱۵» دقیقاً یعنی
 * هر چه از نیمه‌شبِ تهرانِ آن روز تا نیمه‌شبِ بعد ثبت شده.
 */
export function tehranDayRange(jy: number, jm: number, jd: number): { start: Date; end: Date } {
    // ظهرِ محلی برای استخراجِ تاریخِ میلادیِ درست از الگوریتمِ jalaali
    const noon = jalaliToGregorian(jy, jm, jd);
    const gy = noon.getFullYear();
    const gm = noon.getMonth() + 1;
    const gd = noon.getDate();
    const start = tehranMidnight(gy, gm, gd);
    const end = tehranMidnight(gy, gm, gd + 1); // سرریزِ روز در Date.UTC نرمال می‌شود
    return { start, end };
}
