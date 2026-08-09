import { prisma } from '../utils/prisma';
import { signToken } from '../config/jwt';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { AppError } from '../common/exceptions/AppError';
import { assertPasswordPolicy } from '../common/password';
import type { Prisma } from '@prisma/client';

const MAX_FAILED_ATTEMPTS = 5;
const LOCK_DURATION_MS = 15 * 60 * 1000;

// مدت اعتبار توکن رفرش — منبع حقیقت: REFRESH_TOKEN_TTL (مثل "14d" یا "90d")
const parseTtl = (value: string): number => {
    const match = /^(\d+)([smhd])$/.exec(value.trim());
    if (!match) throw new Error(`REFRESH_TOKEN_TTL نامعتبر است: ${value}`);
    const n = Number(match[1]);
    const unit = match[2];
    const ms = { s: 1000, m: 60_000, h: 3_600_000, d: 86_400_000 }[unit]!;
    return n * ms;
};
const REFRESH_TTL_MS = parseTtl(process.env.REFRESH_TOKEN_TTL || '90d');

const hashToken = (token: string) => crypto.createHash('sha256').update(token).digest('hex');
const generateRefreshToken = () => crypto.randomBytes(48).toString('hex');

const userProfileSelect = {
    id: true,
    name: true,
    phone: true,
    role: true,
    avatarUrl: true,
    warehouseId: true,
    createdAt: true,
    mustChangePassword: true,
} satisfies Prisma.UserSelect;

export const authService = {
    login: async (phone: string, password: string) => {
        const user = await prisma.user.findUnique({ where: { phone } });

        // پیام یکسان برای همه‌ی حالت‌های شکست — جلوگیری از کشف شماره‌های ثبت‌شده
        if (!user || !user.isActive || user.deletedAt) {
            throw new AppError('شماره موبایل یا رمز عبور اشتباه است', 401);
        }

        // قفل موقت حساب پس از تلاش‌های ناموفق
        if (user.lockUntil && user.lockUntil.getTime() > Date.now()) {
            throw new AppError('تلاش‌های ناموفق زیاد بود؛ حساب موقتاً قفل شده است', 423);
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            // شمارش اتمی تلاش‌های ناموفق؛ در آستانه‌ی قفل، حساب قفل می‌شود
            const nextAttempts = user.failedLoginAttempts + 1;
            const shouldLock = nextAttempts >= MAX_FAILED_ATTEMPTS;
            await prisma.user.updateMany({
                where: { id: user.id, failedLoginAttempts: user.failedLoginAttempts },
                data: shouldLock
                    ? { failedLoginAttempts: 0, lockUntil: new Date(Date.now() + LOCK_DURATION_MS) }
                    : { failedLoginAttempts: { increment: 1 } },
            });
            throw new AppError('شماره موبایل یا رمز عبور اشتباه است', 401);
        }

        await prisma.user.update({
            where: { id: user.id },
            data: { failedLoginAttempts: 0, lockUntil: null },
        });

        const token = signToken({
            id: user.id,
            role: user.role,
            warehouseId: user.warehouseId || undefined,
        }, user.tokenVersion);

        const refreshToken = generateRefreshToken();
        await prisma.refreshToken.create({
            data: {
                userId: user.id,
                tokenHash: hashToken(refreshToken),
                expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
            },
        });

        return {
            token,
            refreshToken,
            user: {
                id: user.id,
                name: user.name,
                phone: user.phone,
                role: user.role,
                avatarUrl: user.avatarUrl,
                warehouseId: user.warehouseId,
                createdAt: user.createdAt,
                mustChangePassword: user.mustChangePassword,
            },
        };
    },

    // تازه‌سازی نشست با چرخش توکن رفرش (بازگشت به توکنِ قبلی = احتمال سرقت → ابطال خانواده)
    refresh: async (refreshToken: string) => {
        const tokenHash = hashToken(refreshToken);
        const stored = await prisma.refreshToken.findUnique({ where: { tokenHash } });
        if (!stored) throw new AppError('توکن نامعتبر است', 401);

        // استفاده‌ی مجدد از توکنِ چرخش‌خورده → ابطال کل خانواده
        if (stored.revokedAt !== null || stored.replacedBy !== null) {
            await prisma.refreshToken.deleteMany({
                where: { userId: stored.userId, revokedAt: null, replacedBy: null },
            });
            throw new AppError('نشست شما نامعتبر است؛ لطفاً دوباره وارد شوید', 401);
        }
        if (stored.expiresAt.getTime() < Date.now()) {
            await prisma.refreshToken.delete({ where: { id: stored.id } });
            throw new AppError('نشست شما منقضی شده است؛ لطفاً دوباره وارد شوید', 401);
        }

        const user = await prisma.user.findUnique({ where: { id: stored.userId } });
        if (!user || !user.isActive || user.deletedAt) {
            throw new AppError('حساب کاربری نامعتبر است', 401);
        }

        const newRefreshToken = generateRefreshToken();
        await prisma.$transaction(async (tx) => {
            await tx.refreshToken.update({
                where: { id: stored.id },
                data: { revokedAt: new Date(), replacedBy: hashToken(newRefreshToken) },
            });
            await tx.refreshToken.create({
                data: {
                    userId: user.id,
                    tokenHash: hashToken(newRefreshToken),
                    expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
                },
            });
        });

        return {
            token: signToken({
                id: user.id,
                role: user.role,
                warehouseId: user.warehouseId || undefined,
            }, user.tokenVersion),
            refreshToken: newRefreshToken,
        };
    },

    // خروج — ابطال توکن رفرش جاری
    logout: async (refreshToken: string) => {
        const tokenHash = hashToken(refreshToken);
        await prisma.refreshToken.updateMany({ where: { tokenHash }, data: { revokedAt: new Date() } });
    },

    getUserById: async (id: string) => {
        const user = await prisma.user.findUnique({ where: { id } });
        if (!user) throw new AppError('کاربر یافت نشد', 404);
        return { id: user.id, name: user.name, phone: user.phone, role: user.role, warehouseId: user.warehouseId };
    },

    //پروفایل کاربر جاری
    getProfile: async (id: string) => {
        const user = await prisma.user.findUnique({ where: { id }, select: userProfileSelect });
        if (!user) throw new AppError('کاربر یافت نشد', 404);
        return user;
    },

    //ویرایش پروفایل (نام + شماره موبایل + رمز عبور)
    updateProfile: async (id: string, data: { name?: string; phone?: string; password?: string }) => {
        const user = await prisma.user.findUnique({ where: { id } });
        if (!user) throw new AppError('کاربر یافت نشد', 404);

        const updateData: Prisma.UserUpdateInput = {};
        if (data.name !== undefined) {
            if (!data.name.trim()) throw new AppError('نام نمی‌تواند خالی باشد');
            updateData.name = data.name.trim();
        }
        if (data.phone !== undefined) {
            const phone = data.phone.trim();
            if (!phone) throw new AppError('شماره موبایل نمی‌تواند خالی باشد');
            const existing = await prisma.user.findUnique({ where: { phone } });
            if (existing && existing.id !== id) {
                throw new AppError('این شماره موبایل قبلاً ثبت شده است', 409);
            }
            updateData.phone = phone;
        }
        if (data.password !== undefined && data.password) {
            assertPasswordPolicy(data.password);
            updateData.password = await bcrypt.hash(data.password, 12);
            updateData.mustChangePassword = false;
            updateData.failedLoginAttempts = 0;
            // ابطال همه‌ی توکن‌های قبلی (اکسس و رفرش با ver کهنه)
            updateData.tokenVersion = { increment: 1 };
            await prisma.refreshToken.updateMany({
                where: { userId: id, revokedAt: null },
                data: { revokedAt: new Date() },
            });
        }

        const updated = await prisma.user.update({
            where: { id },
            data: updateData,
            select: userProfileSelect,
        });
        return updated;
    },

    //آپدیت آواتار
    updateAvatar: async (id: string, avatarUrl: string) => {
        return await prisma.user.update({
            where: { id },
            data: { avatarUrl },
            select: userProfileSelect,
        });
    },

    createFirstManager: async (name: string, phone: string, password: string) => {
        const existingManager = await prisma.user.findFirst({
            where: { role: 'MANAGER' },
            select: { id: true },
        });
        if (existingManager) {
            throw new AppError('مدیر سیستم قبلاً ثبت شده است');
        }
        assertPasswordPolicy(password);

        const user = await prisma.user.create({
            data: {
                name,
                phone,
                password: await bcrypt.hash(password, 12),
                role: 'MANAGER',
            },
            select: { id: true, name: true, phone: true, role: true },
        });
        return user;
    },
};
