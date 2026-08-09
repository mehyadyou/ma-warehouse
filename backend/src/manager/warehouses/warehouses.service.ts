import { prisma } from '../../utils/prisma';
import bcrypt from 'bcryptjs';
import { buildWarehouseInventory } from '../shared';
import { AppError } from '../../common/exceptions/AppError';

export const warehousesService = {
    //لیست انبارها (با نام انباردار) — فقط انبارهای فعال
    getAllWarehouses: async () => {
        return await prisma.warehouse.findMany({
            where: { deletedAt: null },
            include: {
                users: {
                    where: { isActive: true },
                    select: { id: true, name: true },
                },
                _count: {
                    select: { users: true },
                },
            },
        });
    },

    //ساخت انبار جدید
    createWarehouse: async (name: string, address?: string) => {
        const warehouse = await prisma.warehouse.create({
            data: { name, address },
        });
        return warehouse;
    },

    //ویرایش انبار (نام + آدرس + انباردار)
    updateWarehouse: async (id: string, data: { name?: string; address?: string | null; keeperId?: string | null }) => {
        const warehouse = await prisma.warehouse.findUnique({ where: { id } });
        if (!warehouse) {
            throw new AppError('انبار یافت نشد', 404);
        }
        if (warehouse.deletedAt) {
            throw new AppError('این انبار بایگانی‌شده است؛ ابتدا آن را بازگردانی کنید', 400);
        }

        const updateData: any = {};
        if (data.name) updateData.name = data.name;
        if (data.address !== undefined) updateData.address = data.address || null;

        // مدیریت انباردار
        if (data.keeperId !== undefined) {
            if (!data.keeperId) {
                throw new AppError('انتخاب انباردار برای انبار الزامی است', 400);
            }
            // کاربر انتخاب شده باید انباردارِ فعال باشد
            const keeperUser = await prisma.user.findUnique({ where: { id: data.keeperId } });
            if (!keeperUser || !keeperUser.isActive) {
                throw new AppError('کاربر انتخاب شده یافت نشد یا غیرفعال است', 400);
            }
            if (keeperUser.role !== 'WAREHOUSE_KEEPER') {
                throw new AppError('فقط کاربر با نقش انباردار می‌تواند به انبار منصوب شود', 400);
            }

            // انباردارهای فعلی این انبار (به‌جز خود کاربر جدید) — برای ابطال توکن‌هایشان
            const removedKeepers = await prisma.user.findMany({
                where: { warehouseId: id, role: 'WAREHOUSE_KEEPER', isActive: true, id: { not: data.keeperId } },
                select: { id: true },
            });
            // کاربر جدید از انبار دیگری منتقل شده → توکنش باید باطل شود (داده‌ی انبار کهنه دارد)
            const keeperMoved = keeperUser.warehouseId !== id;

            await prisma.$transaction([
                // فقط نقش انباردار خارج می‌شود — سایر نقش‌های متصل به انبار دست نمی‌خورند
                prisma.user.updateMany({
                    where: { warehouseId: id, role: 'WAREHOUSE_KEEPER', isActive: true, id: { not: data.keeperId } },
                    data: { warehouseId: null, tokenVersion: { increment: 1 } },
                }),
                // منصوب کردن کاربر جدید به این انبار
                prisma.user.update({
                    where: { id: data.keeperId },
                    data: {
                        warehouseId: id,
                        ...(keeperMoved ? { tokenVersion: { increment: 1 } } : {}),
                    },
                }),
            ]);

            // ابطال توکن‌های رفرش: انباردارهای خارج‌شده + انباردار جدید (اگر منتقل شده باشد)
            const affectedIds = removedKeepers.map((k) => k.id);
            if (keeperMoved) affectedIds.push(data.keeperId);
            if (affectedIds.length > 0) {
                await prisma.refreshToken.updateMany({
                    where: { userId: { in: affectedIds }, revokedAt: null },
                    data: { revokedAt: new Date() },
                });
            }
        }

        const updated = await prisma.warehouse.update({
            where: { id },
            data: updateData,
        });
        return updated;
    },

    //بایگانی انبار — صرفاً علامت‌گذاری برای مخفی‌شدن از لیست/آمار
    //هیچ relation یا داده‌ای دست‌کاری نمی‌شود تا در بازیابی، همه‌چیز دقیقاً سر جایش برگردد
    deleteWarehouse: async (id: string, managerId?: string) => {
        const warehouse = await prisma.warehouse.findUnique({ where: { id } });
        if (!warehouse) {
            throw new AppError('انبار یافت نشد', 404);
        }
        if (warehouse.deletedAt) {
            throw new AppError('این انبار قبلاً بایگانی شده است', 400);
        }

        await prisma.warehouse.update({
            where: { id },
            data: { deletedAt: new Date() },
        });

        //ثبت در تاریخچه
        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'warehouse_archived',
                    label: `انبار «${warehouse.name}» بایگانی شد — با بازیابی، همهٔ داده‌ها و انباردار سر جای خود برمی‌گردند`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return warehouse;
    },

    //بازیابی انبار بایگانی‌شده — رفع deletedAt کافی است؛ بقیهٔ اطلاعات دست‌نخورده باقی مانده‌اند
    restoreWarehouse: async (id: string, managerId?: string) => {
        const warehouse = await prisma.warehouse.findUnique({ where: { id } });
        if (!warehouse) throw new AppError('انبار یافت نشد', 404);
        if (!warehouse.deletedAt) throw new AppError('این انبار بایگانی نشده است', 400);

        await prisma.warehouse.update({ where: { id }, data: { deletedAt: null } });

        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'warehouse_restored',
                    label: `انبار «${warehouse.name}» از بایگانی بازگردانده شد — کارتن‌ها، انباردار و سوابق همچنان در جای خود هستند`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return prisma.warehouse.findUnique({
            where: { id },
            include: {
                users: {
                    where: { isActive: true },
                    select: { id: true, name: true },
                },
                _count: { select: { users: true, cartons: true, orders: true } },
            },
        });
    },

    //لیست انبارهای بایگانی‌شده (برای بازیابی)
    getArchivedWarehouses: async () => {
        return await prisma.warehouse.findMany({
            where: { deletedAt: { not: null } },
            orderBy: { deletedAt: 'desc' },
            include: {
                _count: { select: { cartons: true, orders: true, users: true } },
            },
        });
    },

    //ساخت انبار + انباردار همزمان (با Transaction)
    createWarehouseWithKeeper: async (
        warehouseName: string,
        keeperName: string,
        keeperPhone: string,
        keeperPassword: string
    ) => {
        const existingUser = await prisma.user.findUnique({
            where: { phone: keeperPhone },
        });
        if (existingUser) {
            throw new AppError('این شماره موبایل قبلاً ثبت شده است', 409);
        }

        const hashedPassword = await bcrypt.hash(keeperPassword, 12);

        const result = await prisma.$transaction(async (tx) => {
            const warehouse = await tx.warehouse.create({
                data: { name: warehouseName },
            });

            const keeper = await tx.user.create({
                data: {
                    name: keeperName,
                    phone: keeperPhone,
                    password: hashedPassword,
                    role: 'WAREHOUSE_KEEPER',
                    warehouseId: warehouse.id,
                },
                select: {
                    id: true,
                    name: true,
                    phone: true,
                    role: true,
                },
            });

            return { warehouse, keeper };
        });

        return result;
    },

    //تراکنش‌های یک انبار در یک روز
    getTransactionsByDate: async (warehouseId: string, date: string) => {
        const startOfDay = new Date(date);
        startOfDay.setHours(0, 0, 0, 0);
        const endOfDay = new Date(date);
        endOfDay.setHours(23, 59, 59, 999);

        const result = await prisma.$queryRaw`
            SELECT 
                t.id, t.type, t."productName", t.quantity, 
                t."warehouseId", t."userId", t."createdAt",
                u.name as "userName"
            FROM "Transaction" t
            JOIN "User" u ON t."userId" = u.id
            WHERE t."warehouseId" = ${warehouseId}
            AND t."createdAt" >= ${startOfDay}
            AND t."createdAt" <= ${endOfDay}
            ORDER BY t."createdAt" DESC
        `;

        return result;
    },

    //جزئیات کامل یک انبار — آمار ورود/خروج + موجودی (صفحه جزئیات انبار)
    getWarehouseDetail: async (warehouseId: string) => {
        const warehouse = await prisma.warehouse.findUnique({
            where: { id: warehouseId },
            include: {
                users: {
                    where: { role: 'WAREHOUSE_KEEPER', isActive: true },
                    select: { id: true, name: true },
                    take: 1,
                },
            },
        });
        if (!warehouse) throw new AppError('انبار یافت نشد', 404);

        const [txAgg, orders, cartons] = await Promise.all([
            prisma.$queryRaw<{ totalCount: number; inCount: number; outCount: number; inUnits: number; outUnits: number; returnedUnits: number }[]>`
                SELECT
                    COUNT(*)::int as "totalCount",
                    COUNT(*) FILTER (WHERE t.type IN ('IN', 'RETURN'))::int as "inCount",
                    COUNT(*) FILTER (WHERE t.type = 'OUT')::int as "outCount",
                    COALESCE(SUM(CASE WHEN t.type IN ('IN', 'RETURN') THEN t.quantity ELSE 0 END), 0)::int as "inUnits",
                    COALESCE(SUM(CASE WHEN t.type = 'OUT' THEN t.quantity ELSE 0 END), 0)::int as "outUnits",
                    COALESCE(SUM(CASE WHEN t.type = 'RETURN' THEN t.quantity ELSE 0 END), 0)::int as "returnedUnits"
                FROM "Transaction" t
                WHERE t."warehouseId" = ${warehouseId}
            `,
            prisma.order.findMany({
                where: { warehouseId },
                select: { id: true, status: true },
            }),
            prisma.carton.findMany({
                where: { warehouseId },
                include: {
                    product: { select: { id: true, name: true, unit: true, deletedAt: true } },
                    model: { select: { id: true, name: true, unitsPerBox: true } },
                },
            }),
        ]);

        const inventory = buildWarehouseInventory(cartons);
        const orderCount = orders.length;
        const activeOrderCount = orders.filter(
            o => !['DELIVERED', 'CANCELED'].includes(o.status),
        ).length;
        const tx = txAgg[0];

        return {
            warehouse: {
                id: warehouse.id,
                name: warehouse.name,
                address: warehouse.address,
                keeperId: warehouse.users?.[0]?.id ?? null,
                keeperName: warehouse.users?.[0]?.name ?? null,
            },
            stats: {
                transactionCount: Number(tx?.totalCount ?? 0),
                inCount: Number(tx?.inCount ?? 0),
                outCount: Number(tx?.outCount ?? 0),
                inUnits: Number(tx?.inUnits ?? 0),
                outUnits: Number(tx?.outUnits ?? 0),
                returnedUnits: Number(tx?.returnedUnits ?? 0),
                productCount: inventory.totalProducts,
                totalUnits: inventory.totalUnits,
                totalCartons: inventory.totalCartons,
                orderCount,
                activeOrderCount,
            },
            inventory,
        };
    },
};