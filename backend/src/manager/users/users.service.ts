import { prisma } from '../../utils/prisma';
import bcrypt from 'bcryptjs';
import { realtime } from '../../realtime/realtime';
import { RealtimeEvents } from '../../realtime/events';
import { roleLabel } from '../shared';
import { AppError } from '../../common/exceptions/AppError';
import { assertPasswordPolicy } from '../../common/password';
import { writeAuditStandalone } from '../../utils/audit';
import type { Prisma, Role } from '@prisma/client';

const VALID_ROLES: Role[] = ['MANAGER', 'WAREHOUSE_KEEPER', 'DRIVER'];
const PHONE_REGEX = /^09\d{9}$/;

function assertRole(role: string): asserts role is Role {
    if (!VALID_ROLES.includes(role as Role)) {
        throw new AppError('نقش نامعتبر است', 400);
    }
}

function assertPhone(phone: string) {
    if (!PHONE_REGEX.test(phone)) {
        throw new AppError('شماره موبایل باید ۱۱ رقم و با 09 شروع شود', 400);
    }
}

export const usersService = {
    //لیست کاربران فعال
    getAllUsers: async () => {
        const users = await prisma.user.findMany({
            where: { isActive: true },
            select: {
                id: true,
                name: true,
                phone: true,
                role: true,
                warehouseId: true,
                warehouse: true,
                createdAt: true,
            },
            orderBy: { createdAt: 'desc' },
        });
        return users;
    },

    //گزارش کامل یک کاربر (آخرین فعالیت + مسئولیت + آمار)
    getUserReport: async (userId: string) => {
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                name: true,
                phone: true,
                role: true,
                avatarUrl: true,
                isActive: true,
                createdAt: true,
                warehouse: { select: { id: true, name: true } },
            },
        });
        if (!user) throw new AppError('کاربر یافت نشد', 404);

        // تراکنش‌ها (ورود کالا / مرجوعی)
        const transactions = await prisma.transaction.findMany({
            where: { userId },
            select: { id: true, type: true, productName: true, quantity: true, createdAt: true },
            orderBy: { createdAt: 'desc' },
            take: 10,
        });

        // سفارش‌های ساخته‌شده توسط کاربر
        const orders = await prisma.order.findMany({
            where: { createdById: userId },
            select: { id: true, status: true, createdAt: true },
            orderBy: { createdAt: 'desc' },
            take: 10,
        });

        // تحویل‌ها (راننده)
        const deliveries = await prisma.delivery.findMany({
            where: { driverId: userId },
            select: { id: true, status: true, deliveredAt: true, createdAt: true },
            orderBy: { createdAt: 'desc' },
            take: 10,
        });

        // آمار — ورود کالا فقط تراکنش‌های IN؛ واحدها فقط ورودی/مرجوعی (خروجی‌ها در موجودی منفی نمی‌شوند)
        const [checkins, checkinUnits, returns, ordersCount, deliveriesCount] = await Promise.all([
            prisma.transaction.count({ where: { userId, type: 'IN' } }),
            prisma.transaction.aggregate({
                where: { userId, type: { in: ['IN', 'RETURN'] } },
                _sum: { quantity: true },
            }),
            prisma.transaction.count({ where: { userId, type: 'RETURN' } }),
            prisma.order.count({ where: { createdById: userId } }),
            prisma.delivery.count({ where: { driverId: userId } }),
        ]);

        // ترکیب همه رویدادها برای آخرین فعالیت
        const events: { type: string; label: string; createdAt: Date }[] = [
            ...transactions.map(t => ({
                type: t.type === 'RETURN' ? 'RETURN' : 'CHECKIN',
                label: `${t.productName} — تعداد ${t.quantity}`,
                createdAt: t.createdAt,
            })),
            ...orders.map(o => ({
                type: 'ORDER',
                label: `ثبت سفارش (${o.status})`,
                createdAt: o.createdAt,
            })),
            ...deliveries.map(d => ({
                type: 'DELIVERY',
                label: d.deliveredAt ? 'تحویل سفارش به مشتری' : 'شروع ارسال',
                createdAt: d.deliveredAt ?? d.createdAt,
            })),
        ];
        events.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

        return {
            user,
            stats: {
                totalCheckins: checkins,
                totalUnits: checkinUnits._sum.quantity ?? 0,
                totalReturns: returns,
                totalOrders: ordersCount,
                totalDeliveries: deliveriesCount,
            },
            lastActivity: events[0] ?? null,
            recentActivities: events.slice(0, 10),
        };
    },

    //ساخت کاربر جدید (یا فعالسازی مجدد کاربر حذف شده)
    createUser: async (name: string, phone: string, password: string, role: string, warehouseId?: string, managerId?: string) => {
        assertRole(role);
        assertPhone(phone);
        if (role === 'WAREHOUSE_KEEPER' && !warehouseId) {
            throw new AppError('برای ساخت انباردار، انتخاب انبار الزامی است', 400);
        }
        assertPasswordPolicy(password, role);

        const existingUser = await prisma.user.findUnique({ where: { phone } });

        // اگر کاربر قبلی حذف شده بود (soft-delete)، فعالش کن
        if (existingUser && !existingUser.isActive) {
            const hashedPassword = await bcrypt.hash(password, 12);
            const reactivated = await prisma.user.update({
                where: { id: existingUser.id },
                data: {
                    name,
                    password: hashedPassword,
                    role: role as Role,
                    warehouseId: warehouseId || null,
                    isActive: true,
                    deletedAt: null,
                    // رمز جدیدِ تعیین‌شده توسط مدیر موقتی است — کاربر باید در اولین ورود عوضش کند
                    mustChangePassword: true,
                },
                select: {
                    id: true,
                    name: true,
                    phone: true,
                    role: true,
                    warehouseId: true,
                    createdAt: true,
                },
            });

            //ثبت در تاریخچه
            if (managerId) {
                const warehouseName = warehouseId
                    ? (await prisma.warehouse.findUnique({ where: { id: warehouseId }, select: { name: true } }))?.name
                    : null;
                await prisma.activityLog.create({
                    data: {
                        type: 'user_created',
                        label: `«${name}» دوباره فعال شد — نقش: ${roleLabel(role)}${warehouseName ? ` — انبار ${warehouseName}` : ''}`,
                        userId: managerId,
                    },
                }).catch(() => {});
            }
            return reactivated;
        }

        if (existingUser) {
            throw new AppError('این شماره موبایل قبلاً ثبت شده است', 409);
        }

        const hashedPassword = await bcrypt.hash(password, 12);

        const user = await prisma.user.create({
            data: {
                name,
                phone,
                password: hashedPassword,
                role: role as Role,
                warehouseId: warehouseId || null,
                // رمز اولیه‌ای که مدیر تعیین کرده موقتی است — کاربر باید در اولین ورود عوضش کند
                mustChangePassword: true,
            },
            select: {
                id: true,
                name: true,
                phone: true,
                role: true,
                warehouseId: true,
                createdAt: true,
            },
        });

        //ثبت در تاریخچه
        if (managerId) {
            const warehouseName = warehouseId
                ? (await prisma.warehouse.findUnique({ where: { id: warehouseId }, select: { name: true } }))?.name
                : null;
            await prisma.activityLog.create({
                data: {
                    type: 'user_created',
                    label: `«${name}» ساخته شد — نقش: ${roleLabel(role)}${warehouseName ? ` — انبار ${warehouseName}` : ''}`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return user;
    },

    //ویرایش کاربر
    updateUser: async (id: string, data: { name?: string; phone?: string; password?: string; role?: string; warehouseId?: string | null }, managerId?: string) => {
        const user = await prisma.user.findUnique({ where: { id } });
        if (!user) {
            throw new AppError('کاربر یافت نشد', 404);
        }

        //مدیر سیستم قابل ویرایش نیست
        if (user.role === 'MANAGER') {
            throw new AppError('نمی‌توان حساب مدیر سیستم را ویرایش کرد', 400);
        }

        if (data.role) {
            assertRole(data.role);
            //تغییر به انباردار بدون انبار مجاز نیست
            if (data.role === 'WAREHOUSE_KEEPER' && !data.warehouseId && !user.warehouseId) {
                throw new AppError('برای نقش انباردار، انتخاب انبار الزامی است', 400);
            }
        }
        if (data.phone) {
            assertPhone(data.phone);
        }

        const updateData: Prisma.UserUpdateInput = {};

        if (data.name) updateData.name = data.name;
        if (data.phone) {
            const existingPhone = await prisma.user.findUnique({ where: { phone: data.phone } });
            if (existingPhone && existingPhone.id !== id) {
                throw new AppError('این شماره موبایل قبلاً ثبت شده است', 409);
            }
            updateData.phone = data.phone;
        }
        if (data.password) {
            // نقش مؤثر: اگر نقش هم‌زمان عوض می‌شود همان، وگرنه نقش فعلی کاربر
            const target = await prisma.user.findUnique({ where: { id }, select: { role: true } });
            assertPasswordPolicy(data.password, (data.role as string) ?? target?.role);
            updateData.password = await bcrypt.hash(data.password, 12);
            // رمزی که مدیر برای کاربر تعیین می‌کند موقتی است — کاربر باید در اولین ورود عوضش کند
            updateData.mustChangePassword = true;
        }
        if (data.role) updateData.role = data.role as Role;
        if (data.warehouseId !== undefined) {
            updateData.warehouse = data.warehouseId
                ? { connect: { id: data.warehouseId } }
                : { disconnect: true };
        }

        const updatedUser = await prisma.user.update({
            where: { id },
            data: updateData,
            select: {
                id: true,
                name: true,
                phone: true,
                role: true,
                warehouseId: true,
                createdAt: true,
            },
        });

        // تغییر نقش یا انبار → همه‌ی توکن‌های قبلی کاربر باطل شوند
        const roleChanged = data.role && data.role !== user.role;
        const warehouseChanged =
            data.warehouseId !== undefined &&
            (data.warehouseId || null) !== user.warehouseId;
        if (roleChanged || warehouseChanged) {
            await prisma.user.update({
                where: { id },
                data: { tokenVersion: { increment: 1 } },
            });
            await prisma.refreshToken.updateMany({
                where: { userId: id, revokedAt: null },
                data: { revokedAt: new Date() },
            });
            // سوکت‌های زندهٔ کاربر به اتاق انبار جدید منتقل شوند تا رویدادهای
            // سفارش (order:created و ...) را از انبار درست دریافت کند
            realtime.moveUserToWarehouse(id, (data.warehouseId ?? null) as string | null);
        }

        //ثبت در تاریخچه + ممیزی (تغییر نقش / تغییر انبار)
        if (managerId) {
            if (roleChanged) {
                await prisma.activityLog.create({
                    data: {
                        type: 'user_role_changed',
                        label: `«${user.name}»: ${roleLabel(user.role)} → ${roleLabel(data.role)}`,
                        userId: managerId,
                    },
                }).catch(() => {});
                await writeAuditStandalone({
                    actorId: managerId, action: 'user.change_role', entity: 'User', entityId: id,
                    before: { role: user.role }, after: { role: data.role },
                }).catch(() => {});
            }
            if (warehouseChanged) {
                const [oldW, newW] = await Promise.all([
                    user.warehouseId
                        ? prisma.warehouse.findUnique({ where: { id: user.warehouseId }, select: { name: true } })
                        : null,
                    data.warehouseId
                        ? prisma.warehouse.findUnique({ where: { id: data.warehouseId }, select: { name: true } })
                        : null,
                ]);
                await prisma.activityLog.create({
                    data: {
                        type: 'user_warehouse_changed',
                        label: `«${user.name}»: ${oldW?.name ?? 'بدون انبار'} → ${newW?.name ?? 'بدون انبار'}`,
                        userId: managerId,
                    },
                }).catch(() => {});
                await writeAuditStandalone({
                    actorId: managerId, action: 'user.change_warehouse', entity: 'User', entityId: id,
                    before: { warehouseId: user.warehouseId }, after: { warehouseId: data.warehouseId ?? null },
                }).catch(() => {});
            }
        }

        return updatedUser;
    },

    //حذف کاربر (Soft Delete + خروج اجباری)
    deleteUser: async (id: string, managerId?: string) => {
        const user = await prisma.user.findUnique({ where: { id } });
        if (!user) {
            throw new AppError('کاربر یافت نشد', 404);
        }

        if (user.role === 'MANAGER') {
            throw new AppError('نمی‌توان مدیر سیستم را حذف کرد', 400);
        }

        await prisma.user.update({
            where: { id },
            data: {
                isActive: false,
                deletedAt: new Date(),
                tokenVersion: { increment: 1 },
            },
        });

        // باطل‌کردن همه‌ی توکن‌های رفرش کاربر حذف‌شده
        await prisma.refreshToken.updateMany({
            where: { userId: id, revokedAt: null },
            data: { revokedAt: new Date() },
        });

        //ثبت در تاریخچه + ممیزی
        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'user_deleted',
                    label: `«${user.name}» (${roleLabel(user.role)}) حذف شد`,
                    userId: managerId,
                },
            }).catch(() => {});
            await writeAuditStandalone({
                actorId: managerId, action: 'user.delete', entity: 'User', entityId: id,
                before: { name: user.name, role: user.role, isActive: true }, after: { isActive: false },
            }).catch(() => {});
        }

        // خروج اجباری از پنل از طریق Socket
        realtime.toUser(id, RealtimeEvents.USER_FORCE_LOGOUT, {});

        return { message: 'کاربر با موفقیت حذف شد' };
    },
};