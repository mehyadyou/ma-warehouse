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
    it('تغییر رمز با پالیسی ضعیف رد می‌شود', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        await expect(
            authService.updateProfile('u1', { password: 'short' })
        ).rejects.toThrow('حداقل 10 کاراکتر');
        // بدون عدد → خطای «یک عدد» (طولش از حداقل رد شده)
        await expect(
            authService.updateProfile('u1', { password: 'abcdefghijk' })
        ).rejects.toThrow('یک عدد');
        // بدون حرف (فقط عدد) → خطای «یک حرف»
        await expect(
            authService.updateProfile('u1', { password: '12345678901' })
        ).rejects.toThrow('یک حرف');
        // رمز فارسی (حروف فارسی + عدد) → باید پذیرفته شود
        (prisma.user.update as any).mockResolvedValue(baseUser());
        await authService.updateProfile('u1', { password: 'پارسکالا1234' });
        expect(prisma.user.update).toHaveBeenCalled();
    });

    it('تغییر رمز موفق: هش + برداشتن پرچم تغییر اجباری', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        (prisma.user.update as any).mockResolvedValue(baseUser());

        await authService.updateProfile('u1', { password: 'newpass1234' });

        const data = (prisma.user.update as any).mock.calls[0][0].data;
        expect(data.password).toBe('hashed');
        expect(data.mustChangePassword).toBe(false);
        expect(data.failedLoginAttempts).toBe(0);
    });
});
