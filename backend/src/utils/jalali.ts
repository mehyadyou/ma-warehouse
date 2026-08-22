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

// تبدیل تاریخ میلادی به شمسی (الگوریتم استاندارد jalaali-js) — فقط برای استخراج سال شمسی
export function jalaliYear(date: Date): number {
    let gy = date.getFullYear();
    const gm = date.getMonth() + 1;
    const gd = date.getDate();

    const gDaysInMonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    let jy = gy <= 1600 ? 0 : 979;
    gy -= jy <= 0 ? 621 : 1600;
    const gy2 = gm > 2 ? gy + 1 : gy;
    let days = (365 * gy)
        + Math.floor((gy2 + 3) / 4)
        - Math.floor((gy2 + 99) / 100)
        + Math.floor((gy2 + 399) / 400)
        - 80
        + gDaysInMonth[gm - 1]!
        + gd;

    jy += 33 * Math.floor(days / 12053);
    days %= 12053;
    jy += 4 * Math.floor(days / 1461);
    days %= 1461;
    jy += Math.floor((days - 1) / 365);
    if (days > 365) days = (days - 1) % 365;

    const jm = days < 186 ? 1 + Math.floor(days / 31) : 7 + Math.floor((days - 186) / 30);
    const jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30);

    return jy;
}
