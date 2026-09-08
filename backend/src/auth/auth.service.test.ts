import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        user: {
            findUnique: vi.fn(),
            findFirst: vi.fn(),
            findMany: vi.fn(),
            create: vi.fn(),
            update: vi.fn(),
            updateMany: vi.fn(),
        },
        refreshToken: {
            findUnique: vi.fn(),
            create: vi.fn(),
            update: vi.fn(),
            updateMany: vi.fn(),
            delete: vi.fn(),
            deleteMany: vi.fn(),
        },
        warehouse: {
            findUnique: vi.fn(),
        },
    },
}));

vi.mock('bcryptjs', () => ({
    default: {
        compare: vi.fn(),
        hash: vi.fn().mockResolvedValue('hashed'),
    },
}));

vi.mock('../config/jwt', () => ({
    signToken: vi.fn(() => 'access-token'),
}));

import { authService } from './auth.service';
import { prisma } from '../utils/prisma';
import bcrypt from 'bcryptjs';

beforeEach(() => {
    vi.clearAllMocks();
});

const baseUser = (overrides: Record<string, any> = {}) => ({
    id: 'u1',
    name: 'مدیر',
    phone: '09307406877',
    password: 'hashed-password',
    role: 'MANAGER',
    avatarUrl: null,
    warehouseId: null,
    isActive: true,
    deletedAt: null,
    failedLoginAttempts: 0,
    lockUntil: null,
    mustChangePassword: false,
    createdAt: new Date(),
    ...overrides,
});

describe('authService.login', () => {
    it('ورود موفق: ریست تلاش‌ها + صدور access و refresh', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        (bcrypt.compare as any).mockResolvedValue(true);
        (prisma.refreshToken.create as any).mockResolvedValue({});

        const result = await authService.login('09307406877', 'password1');

        expect(prisma.user.update).toHaveBeenCalledWith({
            where: { id: 'u1' },
            data: { failedLoginAttempts: 0, lockUntil: null },
        });
        expect(prisma.refreshToken.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({
                    userId: 'u1',
                    tokenHash: expect.any(String),
                    expiresAt: expect.any(Date),
                }),
            })
        );
        expect(result.token).toBe('access-token');
        expect(result.refreshToken).toBeTruthy();
        expect(result.user).not.toHaveProperty('password');
        expect(result.user.mustChangePassword).toBe(false);
    });

    it('انباردارِ انبار بایگانیشده → 403 فریز (حتی با رمز درست)', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(
            baseUser({ role: 'WAREHOUSE_KEEPER', warehouseId: 'wh1' })
        );
        (bcrypt.compare as any).mockResolvedValue(true);
        (prisma.warehouse.findUnique as any).mockResolvedValue({ deletedAt: new Date() });

        await expect(authService.login('09307406877', 'password1')).rejects.toMatchObject({
            statusCode: 403,
            message: expect.stringContaining('بایگانیشده'),
        });
        // هیچ توکنی صادر نشود
        expect(prisma.refreshToken.create).not.toHaveBeenCalled();
    });

    it('انباردارِ انبار فعال → ورود موفق; وضعیت انبار از DB چک میشود', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(
            baseUser({ role: 'WAREHOUSE_KEEPER', warehouseId: 'wh1' })
        );
        (bcrypt.compare as any).mockResolvedValue(true);
        (prisma.warehouse.findUnique as any).mockResolvedValue({ deletedAt: null });
        (prisma.refreshToken.create as any).mockResolvedValue({});

        const result = await authService.login('09307406877', 'password1');

        expect(prisma.warehouse.findUnique).toHaveBeenCalledWith({
            where: { id: 'wh1' },
            select: { deletedAt: true },
        });
        expect(result.token).toBe('access-token');
    });

    it('رمز اشتباه: افزایش شمارش تلاش‌های ناموفق', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser({ failedLoginAttempts: 1 }));
        (bcrypt.compare as any).mockResolvedValue(false);

        await expect(authService.login('09307406877', 'wrong1')).rejects.toThrow('اشتباه است');

        expect(prisma.user.updateMany).toHaveBeenCalledWith({
            where: { id: 'u1', failedLoginAttempts: 1 },
            data: { failedLoginAttempts: { increment: 1 } },
        });
    });

    it('رسیدن به سقف تلاش‌ها → قفل موقت حساب', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser({ failedLoginAttempts: 4 }));
        (bcrypt.compare as any).mockResolvedValue(false);

        await expect(authService.login('09307406877', 'wrong1')).rejects.toThrow('اشتباه است');

        const data = (prisma.user.updateMany as any).mock.calls[0][0].data;
        expect(data.failedLoginAttempts).toBe(0);
        expect(data.lockUntil).toBeInstanceOf(Date);
    });

    it('حساب قفل‌شده → AppError 423', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(
            baseUser({ lockUntil: new Date(Date.now() + 5 * 60 * 1000) })
        );

        await expect(authService.login('09307406877', 'password1')).rejects.toMatchObject({
            statusCode: 423,
            message: expect.stringContaining('قفل'),
        });
        expect(bcrypt.compare).not.toHaveBeenCalled();
    });

    it('کاربر غیرفعال/حذف‌شده → پیام یکسان 401', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser({ isActive: false }));
        await expect(authService.login('09307406877', 'password1')).rejects.toThrow('اشتباه است');

        (prisma.user.findUnique as any).mockResolvedValue(baseUser({ deletedAt: new Date() }));
        await expect(authService.login('09307406877', 'password1')).rejects.toThrow('اشتباه است');
    });
});

describe('authService.refresh', () => {
    const storedToken = (overrides: Record<string, any> = {}) => ({
        id: 'rt1',
        userId: 'u1',
        tokenHash: 'hash',
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
        revokedAt: null,
        replacedBy: null,
        ...overrides,
    });

    it('چرخش موفق: ابطال توکن قبلی + صدور جفت جدید', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue(storedToken());
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            const tx = {
                refreshToken: {
                    update: vi.fn().mockResolvedValue({}),
                    create: vi.fn().mockResolvedValue({}),
                },
            };
            return await cb(tx);
        });

        const result = await authService.refresh('valid-refresh-token');

        const tx = (prisma.$transaction as any).mock.calls[0][0];
        const mockTx = {
            refreshToken: {
                update: vi.fn().mockResolvedValue({}),
                create: vi.fn().mockResolvedValue({}),
            },
        };
        await tx(mockTx);

        expect(mockTx.refreshToken.update).toHaveBeenCalledWith({
            where: { id: 'rt1' },
            data: expect.objectContaining({ revokedAt: expect.any(Date), replacedBy: expect.any(String) }),
        });
        expect(mockTx.refreshToken.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ userId: 'u1' }) })
        );
        expect(result.token).toBe('access-token');
        expect(result.refreshToken).not.toBe('valid-refresh-token');
    });

    it('استفاده مجدد از توکن چرخش‌خورده → ابطال کل خانواده', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue(
            storedToken({ revokedAt: new Date(), replacedBy: 'new-hash' })
        );

        await expect(authService.refresh('stolen-refresh-token')).rejects.toThrow('نامعتبر است');

        expect(prisma.refreshToken.deleteMany).toHaveBeenCalledWith({
            where: { userId: 'u1', revokedAt: null, replacedBy: null },
        });
    });

    it('توکن منقضی → حذف و خطای 401', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue(
            storedToken({ expiresAt: new Date(Date.now() - 1000) })
        );

        await expect(authService.refresh('expired-refresh-token')).rejects.toThrow('منقضی');
        expect(prisma.refreshToken.delete).toHaveBeenCalledWith({ where: { id: 'rt1' } });
    });

    it('توکن ناشناخته → 401', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue(null);
        await expect(authService.refresh('unknown-token')).rejects.toThrow('نامعتبر');
    });

    it('انباردارِ انبار بایگانیشده → 403 فریز (نشست تازهسازی نمیشود)', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue(storedToken());
        (prisma.user.findUnique as any).mockResolvedValue(
            baseUser({ role: 'WAREHOUSE_KEEPER', warehouseId: 'wh1' })
        );
        (prisma.warehouse.findUnique as any).mockResolvedValue({ deletedAt: new Date() });

        await expect(authService.refresh('keeper-refresh-token')).rejects.toMatchObject({
            statusCode: 403,
            message: expect.stringContaining('بایگانیشده'),
        });
        // چرخش توکن نباید اتفاق بیفتد
        expect(prisma.$transaction).not.toHaveBeenCalled();
    });

    it('انباردارِ انبار فعال → رفرش موفق', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue(storedToken());
        (prisma.user.findUnique as any).mockResolvedValue(
            baseUser({ role: 'WAREHOUSE_KEEPER', warehouseId: 'wh1' })
        );
        (prisma.warehouse.findUnique as any).mockResolvedValue({ deletedAt: null });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => {
            const tx = {
                refreshToken: {
                    update: vi.fn().mockResolvedValue({}),
                    create: vi.fn().mockResolvedValue({}),
                },
            };
            return await cb(tx);
        });

        const result = await authService.refresh('keeper-refresh-token');

        expect(result.token).toBe('access-token');
        expect(result.refreshToken).toBeTruthy();
    });
});

describe('authService.logout', () => {
    it('توکن رفرش جاری ابطال می‌شود', async () => {
        (prisma.refreshToken.updateMany as any).mockResolvedValue({ count: 1 });
        await authService.logout('my-refresh-token');
        expect(prisma.refreshToken.updateMany).toHaveBeenCalledWith({
            where: { tokenHash: expect.any(String) },
            data: { revokedAt: expect.any(Date) },
        });
    });
});

describe('authService.updateProfile', () => {
    it('تغییر رمز انباردار: فقط دقیقاً ۶ رقم عددی پذیرفته می‌شود', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser({ role: 'WAREHOUSE_KEEPER' }));
        // کوتاه‌تر از ۶ رقم → رد
        await expect(
            authService.updateProfile('u1', { password: 'short' })
        ).rejects.toThrow('دقیقاً ۶ رقم');
        // حرف + عدد ولی نه ۶ رقم → رد
        await expect(
            authService.updateProfile('u1', { password: 'abcdefghijk' })
        ).rejects.toThrow('دقیقاً ۶ رقم');
        // بیشتر از ۶ رقم → رد
        await expect(
            authService.updateProfile('u1', { password: '1234567' })
        ).rejects.toThrow('دقیقاً ۶ رقم');
        // حروف فارسی + عدد → رد
        await expect(
            authService.updateProfile('u1', { password: 'پارسکالا1234' })
        ).rejects.toThrow('دقیقاً ۶ رقم');
        // دقیقاً ۶ رقم → پذیرفته
        (prisma.user.update as any).mockResolvedValue(baseUser({ role: 'WAREHOUSE_KEEPER' }));
        await authService.updateProfile('u1', { password: '123456' });
        expect(prisma.user.update).toHaveBeenCalled();
    });

    it('تغییر رمز مدیر: رمز قوی (حرف+عدد، حداقل ۸ کاراکتر) الزامی است', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser({ role: 'MANAGER' }));
        // PIN شش‌رقمی برای مدیر → رد
        await expect(
            authService.updateProfile('u1', { password: '123456' })
        ).rejects.toThrow('حداقل ۸ کاراکتر');
        // رمز قوی → پذیرفته
        (prisma.user.update as any).mockResolvedValue(baseUser({ role: 'MANAGER' }));
        await authService.updateProfile('u1', { password: 'Manager123' });
        expect(prisma.user.update).toHaveBeenCalled();
    });

    it('تغییر رمز موفق: هش + برداشتن پرچم تغییر اجباری', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        (prisma.user.update as any).mockResolvedValue(baseUser());

        await authService.updateProfile('u1', { password: 'Manager123' });

        const data = (prisma.user.update as any).mock.calls[0][0].data;
        expect(data.password).toBe('hashed');
        expect(data.mustChangePassword).toBe(false);
        expect(data.failedLoginAttempts).toBe(0);
    });
});

describe('authService.verifyPassword', () => {
    it('رمز درست → ok:true', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        (bcrypt.compare as any).mockResolvedValue(true);

        const result = await authService.verifyPassword('u1', '123456');
        expect(result).toEqual({ ok: true });
        expect(bcrypt.compare).toHaveBeenCalledWith('123456', 'hashed-password');
    });

    it('رمز غلط → 401 «رمز عبور اشتباه است»', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        (bcrypt.compare as any).mockResolvedValue(false);

        await expect(
            authService.verifyPassword('u1', '111111')
        ).rejects.toThrow('رمز عبور اشتباه است');
    });

    it('کاربر غیرفعال/حذف‌شده → 401 «کاربر نامعتبر است»', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(
            baseUser({ isActive: false, deletedAt: new Date() }),
        );

        await expect(
            authService.verifyPassword('u1', '123456')
        ).rejects.toThrow('کاربر نامعتبر است');
        expect(bcrypt.compare).not.toHaveBeenCalled();
    });
});
