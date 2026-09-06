import { describe, it, expect, vi } from 'vitest';

// ─── تست قفل بوت‌استرپ: create-first-manager فقط یک بار ───
// نکتهٔ مهم: متغیر ماژول (bootstrapComplete) در طول عمر فایل تست باقی می‌ماند،
// پس این تست‌ها «به ترتیب» یک سناریوی پیوسته را آزمایش می‌کنند:
//   ۱) اولین ساخت موفق → ۲) فراخوانی دوباره حتی با DB خالی → 403
// این دقیقاً همان تضمین پروداکشن است: بعد از اولین مدیر، مسیر هرگز باز نمی‌شود.

vi.mock('../utils/prisma', () => ({
    prisma: {
        user: {
            findFirst: vi.fn(),
            create: vi.fn(),
        },
    },
}));
vi.mock('bcryptjs', () => ({
    default: { hash: vi.fn().mockResolvedValue('hashed'), compare: vi.fn() },
}));
vi.mock('../config/jwt', () => ({ signToken: vi.fn() }));
vi.mock('../utils/audit', () => ({
    writeAuditStandalone: vi.fn().mockResolvedValue(undefined),
}));

import { authService } from './auth.service';
import { prisma } from '../utils/prisma';

describe('authService.createFirstManager — قفل بوت‌استرپ (سناریوی ترتیبی)', () => {
    it('گام ۱ — بار اول: وقتی مدیری نیست → ساخت موفق', async () => {
        (prisma.user.findFirst as any).mockResolvedValue(null);
        (prisma.user.create as any).mockResolvedValue({
            id: 'u-new', name: 'مدیر اول', phone: '09120000000', role: 'MANAGER',
        });

        const result = await authService.createFirstManager('مدیر اول', '09120000000', '123456');
        expect(result.role).toBe('MANAGER');
        expect(prisma.user.create).toHaveBeenCalledTimes(1);
    });

    it('گام ۲ — بار دوم حتی با DB خالی: 403 (قفل در-پرداز فعال شده)', async () => {
        (prisma.user.findFirst as any).mockResolvedValue(null); // DB را خالی فرض کن
        await expect(
            authService.createFirstManager('مدیر دوم', '09120000001', '123456'),
        ).rejects.toMatchObject({ statusCode: 403 });
        // هیچ create دومی انجام نشده
        expect(prisma.user.create).toHaveBeenCalledTimes(1);
    });

    it('گام ۳ — مسیر با قفل همیشگی بسته می‌ماند', async () => {
        (prisma.user.findFirst as any).mockResolvedValue(null);
        await expect(
            authService.createFirstManager('مدیر سوم', '09120000002', '123456'),
        ).rejects.toMatchObject({ statusCode: 403 });
        await expect(
            authService.createFirstManager('مدیر چهارم', '09120000003', '123456'),
        ).rejects.toMatchObject({ statusCode: 403 });
        expect(prisma.user.create).toHaveBeenCalledTimes(1);
    });
});

// ─── سناریوی جدا: مدیر از قبل در DB هست (مثلاً بعد از ری‌استارت سرور) ───
// ماژول تازه → state تازه → شبیه‌سازی ری‌استارت
describe('authService.createFirstManager — ری‌استارت سرور (ماژول تازه)', () => {
    vi.resetModules();
    const prismaFresh = { user: { findFirst: vi.fn(), create: vi.fn() } };
    vi.doMock('../utils/prisma', () => ({ prisma: prismaFresh }));
    vi.doMock('bcryptjs', () => ({
        default: { hash: vi.fn().mockResolvedValue('hashed'), compare: vi.fn() },
    }));
    vi.doMock('../config/jwt', () => ({ signToken: vi.fn() }));
    vi.doMock('../utils/audit', () => ({
        writeAuditStandalone: vi.fn().mockResolvedValue(undefined),
    }));

    it('مدیر از قبل در DB → 403 «قبلاً ثبت شده» و قفل مجدد در-پرداز', async () => {
        const { authService: fresh } = await import('./auth.service');

        prismaFresh.user.findFirst.mockResolvedValue({ id: 'existing' });
        await expect(
            fresh.createFirstManager('مدیر دوم', '09120000001', '123456'),
        ).rejects.toMatchObject({
            statusCode: 403,
            message: expect.stringContaining('قبلاً'),
        });

        // بعدش حتی با DB خالی هم 403 — قفل دوباره فعال شد
        prismaFresh.user.findFirst.mockResolvedValue(null);
        await expect(
            fresh.createFirstManager('مدیر سوم', '09120000002', '123456'),
        ).rejects.toMatchObject({ statusCode: 403 });
        expect(prismaFresh.user.create).not.toHaveBeenCalled();
    });
});
