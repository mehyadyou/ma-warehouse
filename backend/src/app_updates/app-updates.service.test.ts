import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../utils/prisma', () => ({
    prisma: {
        appRelease: {
            findFirst: vi.fn(),
            findUnique: vi.fn(),
            create: vi.fn(),
            delete: vi.fn(),
            findMany: vi.fn(),
        },
    },
}));

import { appUpdatesService, compareVersions } from './app-updates.service';
import { prisma } from '../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

describe('compareVersions — مقایسهٔ نسخهٔ معنایی', () => {
    it('major بالاتر بزرگ‌تر است', () => {
        expect(compareVersions('2.0.0', '1.9.9')).toBeGreaterThan(0);
    });
    it('minor بالاتر بزرگ‌تر است', () => {
        expect(compareVersions('1.2.0', '1.1.9')).toBeGreaterThan(0);
    });
    it('patch دو رقمی درست مقایسه می‌شود (۱۰ > ۹)', () => {
        expect(compareVersions('1.0.10', '1.0.9')).toBeGreaterThan(0);
    });
    it('برابر → صفر', () => {
        expect(compareVersions('1.2.3', '1.2.3')).toBe(0);
    });
    it('کوچک‌تر → منفی', () => {
        expect(compareVersions('1.0.0', '1.0.1')).toBeLessThan(0);
    });
});

describe('appUpdatesService.check', () => {
    const release = (overrides: Record<string, any> = {}) => ({
        versionName: '1.2.0',
        versionCode: 12,
        changelog: 'رفع اشکال و بهبودها',
        isForce: false,
        apkUrl: '/uploads/apk/ma-12.apk',
        apkSizeBytes: 50_000_000,
        apkSha256: 'abc123',
        minAndroidSdk: 0,
        ...overrides,
    });

    it('نسخهٔ جدیدتر فعال → updateAvailable با مشخصات کامل', async () => {
        (prisma.appRelease.findFirst as any).mockResolvedValue(release());

        const result = await appUpdatesService.check(11);

        expect(result.updateAvailable).toBe(true);
        expect(result).toMatchObject({
            versionName: '1.2.0',
            versionCode: 12,
            changelog: 'رفع اشکال و بهبودها',
            isForce: false,
            apkSha256: 'abc123',
        });
    });

    it('همان نسخه یا جدیدتر → بدون آپدیت', async () => {
        (prisma.appRelease.findFirst as any).mockResolvedValue(release({ versionCode: 12 }));
        expect((await appUpdatesService.check(12)).updateAvailable).toBe(false);
        expect((await appUpdatesService.check(13)).updateAvailable).toBe(false);
    });

    it('هیچ نسخه‌ای منتشر نشده → بدون آپدیت', async () => {
        (prisma.appRelease.findFirst as any).mockResolvedValue(null);
        expect((await appUpdatesService.check(1)).updateAvailable).toBe(false);
    });

    it('نسخهٔ اجباری → isForce:true برای پاپ‌آپ غیرقابل‌بستن', async () => {
        (prisma.appRelease.findFirst as any).mockResolvedValue(release({ isForce: true }));
        const result = await appUpdatesService.check(11);
        expect(result.updateAvailable).toBe(true);
        expect((result as any).isForce).toBe(true);
    });

    it('دستگاه قدیمی‌تر از minAndroidSdk → آپدیت پیشنهاد نمی‌شود', async () => {
        (prisma.appRelease.findFirst as any).mockResolvedValue(release({ minAndroidSdk: 30 }));
        expect((await appUpdatesService.check(11, 28)).updateAvailable).toBe(false);
        // دستگاه جدیدتر مشکلی ندارد
        expect((await appUpdatesService.check(11, 33)).updateAvailable).toBe(true);
    });
});

describe('appUpdatesService.publish — انتشار', () => {
    it('versionCode تکراری → 409', async () => {
        (prisma.appRelease.findUnique as any).mockResolvedValue({ id: 'x', versionCode: 12 });

        await expect(
            appUpdatesService.publish('u1', {
                versionName: '1.2.0',
                versionCode: 12,
                changelog: 'x',
                tmpPath: __filename,
            }),
        ).rejects.toMatchObject({ statusCode: 409 });
    });

    it('versionCode نامعتبر → 422', async () => {
        await expect(
            appUpdatesService.publish('u1', {
                versionName: '1.2.0',
                versionCode: 0,
                changelog: 'x',
                tmpPath: __filename,
            }),
        ).rejects.toMatchObject({ statusCode: 422 });
    });

    it('انتشار موفق → هش sha256 محاسبه و فایل به apk منتقل می‌شود', async () => {
        const fs = await import('fs');
        const os = await import('os');
        const path = await import('path');
        const tmp = path.join(os.tmpdir(), `test-apk-${Date.now()}.apk`);
        fs.writeFileSync(tmp, 'fake-apk-content-for-hash');

        (prisma.appRelease.findUnique as any).mockResolvedValue(null);
        (prisma.appRelease.create as any).mockImplementation(({ data }: any) => Promise.resolve({ id: 'r1', ...data }));

        const result = await appUpdatesService.publish('u1', {
            versionName: '1.3.0',
            versionCode: 13,
            changelog: 'نسخهٔ جدید',
            tmpPath: tmp,
            originalName: 'app.apk',
        });

        expect(result.versionCode).toBe(13);
        expect(result.apkSha256).toMatch(/^[a-f0-9]{64}$/);
        expect(result.apkUrl).toBe('/uploads/apk/ma-13.apk');
        // حجم واقعی فایل منتقل‌شده ثبت شده (tmp بعد از move دیگر نیست)
        const moved = path.join(process.cwd(), 'uploads', 'apk', 'ma-13.apk');
        expect(result.apkSizeBytes).toBe(fs.statSync(moved).size);
        expect(fs.existsSync(tmp)).toBe(false); // فایل tmp منتقل شده
        if (fs.existsSync(moved)) fs.unlinkSync(moved);
    });
});

describe('appUpdatesService.delete — حذف نسخه', () => {
    it('نسخهٔ ناموجود → 404', async () => {
        (prisma.appRelease.findUnique as any).mockResolvedValue(null);
        await expect(appUpdatesService.delete('nope')).rejects.toMatchObject({ statusCode: 404 });
    });

    it('حذف موفق → رکورد حذف و فایل APK پاک می‌شود', async () => {
        (prisma.appRelease.findUnique as any).mockResolvedValue({
            id: 'r1',
            apkUrl: '/uploads/apk/ma-99.apk',
        });
        (prisma.appRelease.delete as any).mockResolvedValue({});

        const result = await appUpdatesService.delete('r1');
        expect(result).toEqual({ ok: true });
        expect(prisma.appRelease.delete).toHaveBeenCalledWith({ where: { id: 'r1' } });
    });
});
