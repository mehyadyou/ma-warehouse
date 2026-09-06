import crypto from 'crypto';
import { prisma } from '../utils/prisma';
import { AppError } from '../common/exceptions/AppError';

/// اسکوپ‌های مجاز API عمومی — هر کلید زیرمجموعه‌ای از این‌هاست
export const API_SCOPES = [
    'products',
    'inventory',
    'orders',
    'transactions',
    'cartons',
    'warehouses',
    'carriers',
    'deliveries',
    'users',
] as const;

export type ApiScope = (typeof API_SCOPES)[number];

const hashKey = (key: string) => crypto.createHash('sha256').update(key).digest('hex');

export const apiKeysService = {
    /// ساخت کلید جدید — کلید خام فقط یک بار در پاسخ برمی‌گردد (بعداً قابل بازیابی نیست)
    create: async (
        creatorId: string,
        input: { name: string; scopes: string[]; expiresAt?: Date | null },
    ) => {
        // اعتبارسنجی اسکوپ‌ها
        const invalid = input.scopes.filter((s) => !API_SCOPES.includes(s as ApiScope));
        if (invalid.length > 0) {
            throw new AppError(`اسکوپ نامعتبر: ${invalid.join(', ')}`, 422);
        }
        if (input.scopes.length === 0) {
            throw new AppError('حداقل یک محدودهٔ دسترسی انتخاب کنید', 422);
        }

        // قالب کلید: ma_live_<32 بایت hex> — قابل تشخیص و امن
        const rawKey = `ma_live_${crypto.randomBytes(24).toString('hex')}`;
        const prefix = rawKey.slice(0, 16);

        const key = await prisma.apiKey.create({
            data: {
                name: input.name.trim(),
                prefix,
                keyHash: hashKey(rawKey),
                scopes: input.scopes,
                expiresAt: input.expiresAt ?? null,
                createdById: creatorId,
            },
        });

        return {
            id: key.id,
            name: key.name,
            scopes: key.scopes,
            expiresAt: key.expiresAt,
            createdAt: key.createdAt,
            /// ⚠️ تنها بار که کلید خام دیده می‌شود — داشبورد باید آن را همان لحظه نشان دهد
            key: rawKey,
        };
    },

    list: async () => {
        const keys = await prisma.apiKey.findMany({
            orderBy: { createdAt: 'desc' },
            select: {
                id: true, name: true, prefix: true, scopes: true,
                isActive: true, expiresAt: true, lastUsedAt: true,
                useCount: true, createdAt: true, revokedAt: true,
            },
        });

        const now = new Date();
        return keys.map((k) => ({
            ...k,
            /// منقضی‌شده‌ها در داشبورد مشخص شوند
            isExpired: k.expiresAt ? k.expiresAt.getTime() < now.getTime() : false,
        }));
    },

    /// ابطال (نرم) — کلید دیگر کار نمی‌کند ولی رکورد برای ممیزی می‌ماند
    revoke: async (id: string) => {
        const key = await prisma.apiKey.findUnique({ where: { id } });
        if (!key) throw new AppError('کلید یافت نشد', 404);
        if (key.revokedAt) throw new AppError('این کلید قبلاً باطل شده است', 409);

        await prisma.apiKey.update({
            where: { id },
            data: { isActive: false, revokedAt: new Date() },
        });
        return { ok: true };
    },

    /// فعال‌سازی دوباره کلید باطل‌شده
    restore: async (id: string) => {
        const key = await prisma.apiKey.findUnique({ where: { id } });
        if (!key) throw new AppError('کلید یافت نشد', 404);
        if (!key.revokedAt) throw new AppError('این کلید باطل نشده است', 409);

        await prisma.apiKey.update({
            where: { id },
            data: { isActive: true, revokedAt: null },
        });
        return { ok: true };
    },

    /// حذف قطعی رکورد
    remove: async (id: string) => {
        const key = await prisma.apiKey.findUnique({ where: { id } });
        if (!key) throw new AppError('کلید یافت نشد', 404);
        await prisma.apiKey.delete({ where: { id } });
        return { ok: true };
    },
};
