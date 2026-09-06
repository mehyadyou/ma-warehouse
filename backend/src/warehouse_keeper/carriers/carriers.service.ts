import { prisma } from '../../utils/prisma';
import { AppError } from '../../common/exceptions/AppError';

/// تشخیص خطای یکتایی Prisma (P2002) — مثلاً نام تکراری باربری
const isUniqueViolation = (e: any) => e?.code === 'P2002';

export const carriersService = {
    /// لیست همهٔ باربری‌ها — مرتب بر اساس اولویت (صعودی) و سپس نام؛
    /// اولویت ۰ = بالای صف = دورترین = اولین بارِ برنامهٔ بارگیری راننده (ته وانت)؛
    /// پایین صف = نزدیک‌ترین = آخرین بار
    list: async () => {
        return prisma.carrier.findMany({
            orderBy: [{ priority: 'asc' }, { name: 'asc' }],
        });
    },

    /// ثبت باربری جدید — نام تکراری → 409.
    /// بدون اولویت → انتهای صف (آخرین بار) اضافه می‌شود؛ جایگاه در صف با درگ‌انددراپ تعیین می‌شود
    create: async (name: string, phone?: string, address?: string) => {
        try {
            // اولویت بعدی = یک بیشتر از بیشترینِ موجود (اختلاف اولویت‌ها در بازچینی دوباره نرمال می‌شود)
            const agg = await prisma.carrier.aggregate({ _max: { priority: true } });
            return await prisma.carrier.create({
                data: {
                    name,
                    priority: (agg._max.priority ?? -1) + 1,
                    phone: phone?.trim() || null,
                    address: address?.trim() || null,
                },
            });
        } catch (e: any) {
            if (isUniqueViolation(e)) {
                throw new AppError('این باربری قبلاً ثبت شده است', 409);
            }
            throw e;
        }
    },

    /// ویرایش باربری — فقط فیلدهای ارسالی تغییر می‌کنند
    update: async (id: string, data: { name?: string; priority?: number; phone?: string | null; address?: string | null }) => {
        const existing = await prisma.carrier.findUnique({ where: { id } });
        if (!existing) throw new AppError('باربری یافت نشد', 404);

        try {
            return await prisma.carrier.update({
                where: { id },
                data: {
                    name: data.name !== undefined ? data.name : existing.name,
                    priority: data.priority !== undefined ? data.priority : existing.priority,
                    phone: data.phone !== undefined ? (data.phone?.trim() || null) : existing.phone,
                    address: data.address !== undefined ? (data.address?.trim() || null) : existing.address,
                },
            });
        } catch (e: any) {
            if (isUniqueViolation(e)) {
                throw new AppError('این باربری قبلاً ثبت شده است', 409);
            }
            throw e;
        }
    },

    /// بازچینی صف بارگیری (درگ‌انددراپ انباردار) — [ids] دقیقاً همان ترتیب جدید است؛
    /// بالای صف = دورترین = اولین بار و پایین صف = نزدیک‌ترین = آخرین بار.
    /// اولویت‌ها ۰..n بازنویسی می‌شوند تا برنامهٔ بارگیری راننده همان ترتیب را بگیرد.
    /// داخل همان تراکنش رویداد زنده ساخته می‌شود تا پنل راننده بلافاصله صف تازه را بگیرد.
    reorder: async (ids: string[]) => {
        const rows = await prisma.carrier.findMany({ select: { id: true } });
        const existing = new Set(rows.map((r) => r.id));
        if (ids.length !== rows.length || ids.some((id) => !existing.has(id))) {
            throw new AppError('ترتیب ارسالی با لیست باربری‌ها همخوانی ندارد', 400);
        }

        await prisma.$transaction(async (tx) => {
            for (const [i, id] of ids.entries()) {
                await tx.carrier.update({ where: { id }, data: { priority: i } });
            }
            // رویداد تراکنشی — با موفقیت ذخیرهٔ ترتیب جدید، به راننده‌ها اطلاع داده می‌شود
            await tx.outboxEvent.create({
                data: {
                    aggregate: 'carrier',
                    type: 'carriers:reordered',
                    payload: { ids, count: ids.length },
                },
            });
        });
        return prisma.carrier.findMany({
            orderBy: [{ priority: 'asc' }, { name: 'asc' }],
        });
    },

    /// حذف باربری — سفارش‌های قبلی نام باربری را متن‌گونه نگه داشته‌اند و دست‌نخورده می‌مانند
    remove: async (id: string) => {
        const existing = await prisma.carrier.findUnique({ where: { id } });
        if (!existing) throw new AppError('باربری یافت نشد', 404);
        await prisma.carrier.delete({ where: { id } });
        return { id };
    },
};