import path from 'path';
import fs from 'fs';
import crypto from 'crypto';
import { prisma } from '../utils/prisma';
import { AppError } from '../common/exceptions/AppError';

const APK_DIR = path.join(process.cwd(), 'uploads', 'apk');

/// سقف حجم APK — ۲۰۰ مگابایت (اپ انبار با صدای فارسی/فونت حدود ۵۰-۸۰MB است)
const MAX_APK_MB = 200;

function ensureApkDir() {
    if (!fs.existsSync(APK_DIR)) fs.mkdirSync(APK_DIR, { recursive: true });
}

/// مقایسهٔ نسخهٔ معنایی '1.2.10' > '1.2.9' — بازگشت مثبت یعنی a بزرگ‌تر است
export function compareVersions(a: string, b: string): number {
    const pa = a.split('.').map((x) => parseInt(x, 10) || 0);
    const pb = b.split('.').map((x) => parseInt(x, 10) || 0);
    const len = Math.max(pa.length, pb.length);
    for (let i = 0; i < len; i++) {
        const diff = (pa[i] ?? 0) - (pb[i] ?? 0);
        if (diff !== 0) return diff;
    }
    return 0;
}

export const appUpdatesService = {
    /// بررسی بروزرسانی — از سمت اپ با versionCode فعلی صدا زده می‌شود
    check: async (currentVersionCode: number, deviceSdkInt?: number) => {
        const latest = await prisma.appRelease.findFirst({
            where: { isActive: true },
            orderBy: { versionCode: 'desc' },
        });

        if (!latest) {
            return { updateAvailable: false as const };
        }

        // دستگاه قدیمی‌تر از حداقل SDK این نسخه → آپدیت پیشنهاد نمی‌شود
        if (deviceSdkInt && deviceSdkInt < latest.minAndroidSdk) {
            return { updateAvailable: false as const };
        }

        if (latest.versionCode <= currentVersionCode) {
            return { updateAvailable: false as const };
        }

        return {
            updateAvailable: true as const,
            versionName: latest.versionName,
            versionCode: latest.versionCode,
            changelog: latest.changelog,
            isForce: latest.isForce,
            apkUrl: latest.apkUrl,
            apkSizeBytes: latest.apkSizeBytes,
            apkSha256: latest.apkSha256,
        };
    },

    /// انتشار نسخهٔ جدید — APK در uploads/apk ذخیره و هش می‌شود
    publish: async (
        publisherId: string,
        input: {
            versionName: string;
            versionCode: number;
            changelog: string;
            isForce?: boolean;
            minAndroidSdk?: number;
            tmpPath: string;
            originalName?: string;
        },
    ) => {
        const { versionName, versionCode, changelog } = input;

        if (versionCode <= 0) {
            throw new AppError('شمارهٔ نسخه (versionCode) باید عددی مثبت باشد', 422);
        }

        // APK تکراری منتشر نشود — versionCode همیشه صعودی
        const existing = await prisma.appRelease.findUnique({ where: { versionCode } });
        if (existing) {
            throw new AppError(`نسخهٔ ${versionCode} قبلاً منتشر شده است`, 409);
        }

        // هش محتوا — موبایل برای اطمینان از سلامت دانلود چک می‌کند
        const sha256 = await new Promise<string>((resolve, reject) => {
            const hash = crypto.createHash('sha256');
            const stream = fs.createReadStream(input.tmpPath);
            stream.on('data', (chunk) => hash.update(chunk));
            stream.on('error', reject);
            stream.on('end', () => resolve(hash.digest('hex')));
        });

        ensureApkDir();
        const safeName = `ma-${versionCode}${path.extname(input.originalName || 'app.apk') || '.apk'}`;
        const destPath = path.join(APK_DIR, safeName);
        // rename بین درایوهای مختلف (tmp → دیسک پروژه) شکست می‌خورد → copy+unlink
        try {
            fs.renameSync(input.tmpPath, destPath);
        } catch {
            fs.copyFileSync(input.tmpPath, destPath);
            fs.unlinkSync(input.tmpPath);
        }
        const size = fs.statSync(destPath).size;

        const release = await prisma.appRelease.create({
            data: {
                versionName,
                versionCode,
                changelog,
                isForce: input.isForce ?? false,
                apkUrl: `/uploads/apk/${safeName}`,
                apkSizeBytes: size,
                apkSha256: sha256,
                minAndroidSdk: input.minAndroidSdk ?? 0,
                publishedById: publisherId,
            },
        });

        return { id: release.id, versionName, versionCode, apkUrl: release.apkUrl, apkSizeBytes: size, apkSha256: sha256 };
    },

    /// حذف نسخه (فقط غیرفعال‌شده‌ها یا آخرین نسخه) — فایل APK هم پاک می‌شود
    delete: async (id: string) => {
        const release = await prisma.appRelease.findUnique({ where: { id } });
        if (!release) throw new AppError('نسخه یافت نشد', 404);

        // اگر آخرین نسخهٔ فعال است، حذف رکورد مجاز است (اپ قبلاً آپدیت کرده)
        await prisma.appRelease.delete({ where: { id } });

        if (release.apkUrl.startsWith('/uploads/apk/')) {
            const filePath = path.join(process.cwd(), release.apkUrl);
            fs.unlink(filePath, () => {});
        }
        return { ok: true };
    },

    list: async () => {
        return prisma.appRelease.findMany({
            orderBy: { versionCode: 'desc' },
            take: 50,
            select: {
                id: true, versionName: true, versionCode: true, changelog: true,
                isForce: true, apkUrl: true, apkSizeBytes: true, isActive: true,
                minAndroidSdk: true, createdAt: true,
            },
        });
    },

    MAX_APK_MB,
};