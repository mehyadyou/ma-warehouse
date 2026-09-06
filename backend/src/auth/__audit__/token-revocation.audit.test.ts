/**
 * ═══ تست حساسِ پیش از انتشار — سناریو ۴ ═══
 * «Token Revocation Cascade» — چرخهٔ کاملِ ابطال:
 *   login → refresh → تغییرِ رمز → ابطالِ سراسری:
 *   ۱) تغییرِ رمز → tokenVersion +۱ و ابطالِ همهٔ RefreshToken های فعال
 *   ۲) access توکنِ قدیمی (ver=۰) در middleware authenticate → 401
 *   ۳) access توکنِ جدید (ver=۱) → عبور + بازنویسی نقش/انبار از DB
 *   ۴) استفادهٔ مجدد از refresh چرخش‌خورده → ابطالِ کلِ خانواده (rollback-theft defense)
 *
 * این تست از JWT واقعی (امضا/امضاسنجی واقعی با JWT_SECRET) استفاده می‌کند تا
 * کلِ مسیرِ رمزنگاری — نه فقط شاخه‌ها — پوشش داده شود.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
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
        warehouse: { findUnique: vi.fn() },
        auditLog: { create: vi.fn() },
    },
}));

vi.mock('bcryptjs', () => ({
    default: {
        compare: vi.fn(),
        hash: vi.fn().mockResolvedValue('new-hashed'),
    },
}));

import { authService } from '../../auth/auth.service';
import { authenticate } from '../../middleware/auth';
import { signToken } from '../../config/jwt';
import { prisma } from '../../utils/prisma';
import bcrypt from 'bcryptjs';

beforeEach(() => {
    vi.clearAllMocks();
});

const baseUser = (overrides: Record<string, any> = {}) => ({
    id: 'u1',
    name: 'مدیر',
    phone: '09307406877',
    password: 'old-hashed',
    role: 'MANAGER',
    avatarUrl: null,
    warehouseId: null,
    isActive: true,
    deletedAt: null,
    failedLoginAttempts: 0,
    lockUntil: null,
    mustChangePassword: false,
    tokenVersion: 0,
    createdAt: new Date(),
    ...overrides,
});

function makeRes() {
    return {
        status: vi.fn().mockReturnThis(),
        json: vi.fn(),
    } as any;
}

describe('آدیت ۴ — Token Revocation Cascade (تغییر رمز → ابطال سراسری)', () => {
    it('گام ۱ — تغییرِ رمز: tokenVersion +۱ و ابطالِ همهٔ refresh های فعال', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(baseUser());
        (prisma.user.update as any).mockResolvedValue(baseUser({ tokenVersion: 1 }));
        (prisma.refreshToken.updateMany as any).mockResolvedValue({ count: 3 });

        await authService.updateProfile('u1', { password: '123456' });

        expect(prisma.user.update).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { id: 'u1' },
                data: expect.objectContaining({ tokenVersion: { increment: 1 } }),
            }),
        );
        expect(prisma.refreshToken.updateMany).toHaveBeenCalledWith({
            where: { userId: 'u1', revokedAt: null },
            data: { revokedAt: expect.any(Date) },
        });
        expect(bcrypt.hash).toHaveBeenCalledWith('123456', 12);
    });

    it('گام ۲ — access توکنِ صادرشده قبل از تغییرِ رمز (ver=0) → 401 و بدونِ next', async () => {
        const oldToken = signToken({ id: 'u1', role: 'MANAGER' }, 0); // ver ۰

        (prisma.user.findUnique as any).mockResolvedValue({
            isActive: true,
            deletedAt: null,
            role: 'MANAGER',
            warehouseId: null,
            tokenVersion: 1, // پس از تغییرِ رمز
        });

        const req = { headers: { authorization: `Bearer ${oldToken}` } } as any;
        const res = makeRes();
        const next = vi.fn();

        await authenticate(req, res, next);

        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith(
            expect.objectContaining({ error: expect.stringContaining('منقضی') }),
        );
        expect(next).not.toHaveBeenCalled();
        expect(req.user).toBeUndefined();
    });

    it('گام ۳ — access توکنِ جدید (ver=1) → عبور می‌کند و نقش/انبار از DB تازه می‌شود', async () => {
        const newToken = signToken({ id: 'u1', role: 'MANAGER' }, 1);

        (prisma.user.findUnique as any).mockResolvedValue({
            isActive: true,
            deletedAt: null,
            role: 'MANAGER',
            warehouseId: null,
            tokenVersion: 1,
        });

        const req = { headers: { authorization: `Bearer ${newToken}` } } as any;
        const res = makeRes();
        const next = vi.fn();

        await authenticate(req, res, next);

        expect(next).toHaveBeenCalledTimes(1);
        expect(req.user).toMatchObject({ id: 'u1', role: 'MANAGER', ver: 1 });
    });

    it('گام ۴ — refresh چرخش‌خورده (استفادهٔ مجدد) → ابطالِ کلِ خانواده و 401', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue({
            id: 'r-old',
            userId: 'u1',
            tokenHash: 'hash-of-reused',
            revokedAt: new Date(), // قبلاً چرخش شده
            replacedBy: 'hash-of-child',
            expiresAt: new Date(Date.now() + 86_400_000),
        });

        await expect(authService.refresh('reused-refresh-token')).rejects.toMatchObject({
            statusCode: 401,
        });

        expect(prisma.refreshToken.deleteMany).toHaveBeenCalledWith({
            where: { userId: 'u1', revokedAt: null, replacedBy: null },
        });
        // هیچ توکن جدیدی صادر نشده باشد
        expect(prisma.refreshToken.create).not.toHaveBeenCalled();
    });

    it('گام ۵ — refresh فعالِ سالم پس از تغییرِ رمز، ver جدید می‌گیرد (ورودِ مجددِ کاربرِ قانونی سالم است)', async () => {
        (prisma.refreshToken.findUnique as any).mockResolvedValue({
            id: 'r-live',
            userId: 'u1',
            tokenHash: 'hash-of-live',
            revokedAt: null,
            replacedBy: null,
            expiresAt: new Date(Date.now() + 86_400_000),
        });
        (prisma.user.findUnique as any).mockResolvedValue(baseUser({ tokenVersion: 1 }));
        (prisma.warehouse.findUnique as any).mockResolvedValue(null); // مدیر — بدونِ انبار
        (prisma.$transaction as any).mockImplementation(async (fn: any) =>
            fn({
                refreshToken: {
                    update: vi.fn().mockResolvedValue({}),
                    create: vi.fn().mockResolvedValue({}),
                },
            }),
        );

        const result = await authService.refresh('valid-refresh-token');

        expect(result.token).toBeTruthy();
        // ver توکنِ جدید باید ۱ باشد (نسخهٔ فعلیِ کاربر)
        const payload = JSON.parse(Buffer.from(result.token.split('.')[1], 'base64url').toString());
        expect(payload.ver).toBe(1);
    });
});
