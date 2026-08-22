import { prisma } from '../../utils/prisma';
import bcrypt from 'bcryptjs';
import { buildWarehouseInventory } from '../shared';
import { AppError } from '../../common/exceptions/AppError';
import { assertPasswordPolicy } from '../../common/password';
import { writeAuditStandalone } from '../../utils/audit';
import { jalaliToGregorian } from '../../utils/jalali';

// محاسبهٔ نام پیشنهادی با پسوند فارسی برای انبار — چک علیه نام‌های فعال و بایگانیشده
async function nextAvailableWarehouseName(base: string): Promise<string> {
    const faDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const toFa = (n: number) => String(n).split('').map(d => faDigits[+d]).join('');
    for (let i = 2; i <= 1000; i++) {
        const candidate = `${base} (${toFa(i)})`;
        const [active, archived] = await Promise.all([
            prisma.warehouse.findFirst({ where: { name: candidate, deletedAt: null }, select: { id: true } }),
            prisma.warehouse.findFirst({ where: { name: candidate, deletedAt: { not: null } }, select: { id: true } }),
        ]);
        if (!active && !archived) return candidate;
    }
    return `${base} (${toFa(Date.now() % 10000)})`;
}

// نام همنام با انبار بایگانیشده → خطای 409 مخصوص دیالوگ سمت اپ
async function archivedWarehouseConflict(warehouseName: string): Promise<AppError | null> {
    const archived = await prisma.warehouse.findFirst({
        where: { name: warehouseName, deletedAt: { not: null } },
        select: { id: true, name: true, deletedAt: true },
    });
    if (!archived) return null;
    return new AppError(
        `انبار «${warehouseName}» در بایگانی است`,
        409,
        'ARCHIVED_CONFLICT',
        {
            id: archived.id,
            name: archived.name,
            archivedAt: archived.deletedAt,
            suggestedName: await nextAvailableWarehouseName(warehouseName),
        },
    );
}

export const warehousesService = {
    //لیست انبارها (با نام انباردار) — فقط انبارهای فعال
    getAllWarehouses: async () => {
        const warehouses = await prisma.warehouse.findMany({
            where: { deletedAt: null },
            include: {
                users: {
                    where: { role: 'WAREHOUSE_KEEPER', isActive: true },
                    select: { id: true, name: true },
                    take: 1,
                },
            },
        });

        if (warehouses.length === 0) return warehouses;

        // تعداد واقعی محصولات هر انبار: فقط کارتن‌های موجودِ محصولِ فعال (هماهنگ با صفحه جزئیات)
        const cartons = await prisma.carton.findMany({
            where: {
                warehouseId: { in: warehouses.map((w) => w.id) },
                status: 'IN_STOCK',
                product: { deletedAt: null },
            },
            select: { warehouseId: true, productId: true },
        });
        const productSets = new Map<string, Set<string>>();
        for (const row of cartons) {
            let set = productSets.get(row.warehouseId);
            if (!set) {
                set = new Set();
                productSets.set(row.warehouseId, set);
            }
            set.add(row.productId);
        }

        return warehouses.map((w) => ({
            ...w,
            productCount: productSets.get(w.id)?.size ?? 0,
        }));
    },

    //ساخت انبار جدید — نام همنام با بایگانیشده → 409 ARCHIVED_CONFLICT
    createWarehouse: async (name: string, address?: string) => {
        const trimmed = (name || '').trim();
        if (!trimmed) throw new AppError('نام انبار الزامی است', 400);

        const activeDup = await prisma.warehouse.findFirst({ where: { name: trimmed, deletedAt: null }, select: { id: true } });
        if (activeDup) throw new AppError('انباری با این نام قبلاً ثبت شده است', 409);

        const conflict = await archivedWarehouseConflict(trimmed);
        if (conflict) throw conflict;

        try {
            return await prisma.warehouse.create({
                data: { name: trimmed, address },
            });
        } catch (e: any) {
            // race: نام بین چک و ساخت ثبت شد (partial unique index)
            if (e?.code === 'P2002') {
                throw new AppError('انباری با این نام در حال حاضر ثبت شده است؛ صفحه را تازه کنید', 409);
            }
            throw e;
        }
    },

    //ویرایش انبار (نام + آدرس + انباردار)
    updateWarehouse: async (id: string, data: { name?: string; address?: string | null; keeperId?: string | null }, managerId?: string) => {
        const warehouse = await prisma.warehouse.findUnique({ where: { id } });
        if (!warehouse) {
            throw new AppError('انبار یافت نشد', 404);
        }
        if (warehouse.deletedAt) {
            throw new AppError('این انبار بایگانی‌شده است؛ ابتدا آن را بازگردانی کنید', 400);
        }

        const updateData: any = {};
        if (data.name) {
            const trimmed = data.name.trim();
            const activeDup = await prisma.warehouse.findFirst({ where: { name: trimmed, deletedAt: null, NOT: { id } }, select: { id: true } });
            if (activeDup) throw new AppError('انباری با این نام قبلاً ثبت شده است', 409);
            const archivedDup = await prisma.warehouse.findFirst({ where: { name: trimmed, deletedAt: { not: null }, NOT: { id } }, select: { id: true } });
            if (archivedDup) throw new AppError('انباری با این نام در بایگانی است؛ ابتدا آن را بازگردانی کنید یا نام دیگری انتخاب کنید', 409);
            updateData.name = trimmed;
        }
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

            // انباردارهای فعلی این انبار — برای مقایسه، خارج‌کردن و ابطال توکن‌هایشان
            const currentKeepers = await prisma.user.findMany({
                where: { warehouseId: id, role: 'WAREHOUSE_KEEPER', isActive: true },
                select: { id: true, name: true },
            });
            const removedKeepers = currentKeepers.filter((k) => k.id !== data.keeperId);
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

            // ثبت در تاریخچه + ممیزی — فقط وقتی انباردار واقعاً تغییر کرده باشد
            const keeperChanged = !(
                currentKeepers.length === 1 && currentKeepers[0].id === data.keeperId
            );
            if (managerId && keeperChanged) {
                const removedLabel = removedKeepers.length > 0
                    ? ` — ${removedKeepers.map((k) => k.name).join('، ')} خارج شدند`
                    : '';
                await prisma.activityLog.create({
                    data: {
                        type: 'warehouse_keeper_changed',
                        label: `انباردار «${keeperUser.name}» برای انبار «${warehouse.name}» تعیین شد${removedLabel}`,
                        userId: managerId,
                    },
                }).catch(() => {});
                await writeAuditStandalone({
                    actorId: managerId, action: 'warehouse.change_keeper', entity: 'Warehouse', entityId: id,
                    before: { keepers: currentKeepers.map((k) => ({ id: k.id, name: k.name })) },
                    after: { keeperId: data.keeperId, keeperName: keeperUser.name },
                }).catch(() => {});
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
        keeperPassword: string,
        managerId?: string,
    ) => {
        const name = (keeperName || '').trim();
        const phone = (keeperPhone || '').trim();
        if (!name) throw new AppError('نام انباردار الزامی است', 400);
        if (!/^09\d{9}$/.test(phone)) {
            throw new AppError('شماره موبایل معتبر نیست؛ باید ۱۱ رقم با پیشوند 09 باشد', 400);
        }
        assertPasswordPolicy(keeperPassword);

        const existingUser = await prisma.user.findUnique({
            where: { phone },
        });
        if (existingUser) {
            throw new AppError('این شماره موبایل قبلاً ثبت شده است', 409);
        }

        // نام همنام با انبار بایگانیشده → 409 (دیالوگ سمت اپ)
        const wsName = (warehouseName || '').trim();
        if (!wsName) throw new AppError('نام انبار الزامی است', 400);
        const activeDup = await prisma.warehouse.findFirst({ where: { name: wsName, deletedAt: null }, select: { id: true } });
        if (activeDup) throw new AppError('انباری با این نام قبلاً ثبت شده است', 409);
        const conflict = await archivedWarehouseConflict(wsName);
        if (conflict) throw conflict;

        const hashedPassword = await bcrypt.hash(keeperPassword, 12);

        try {
            const result = await prisma.$transaction(async (tx) => {
                const warehouse = await tx.warehouse.create({
                    data: { name: wsName },
                });

                const keeper = await tx.user.create({
                    data: {
                        name,
                        phone,
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

            // ثبت در تاریخچه + ممیزی
            if (managerId) {
                await prisma.activityLog.create({
                    data: {
                        type: 'warehouse_created',
                        label: `انبار «${wsName}» با انباردار «${name}» ساخته شد`,
                        userId: managerId,
                    },
                }).catch(() => {});
                await writeAuditStandalone({
                    actorId: managerId, action: 'warehouse.create', entity: 'Warehouse', entityId: result.warehouse.id,
                    before: {},
                    after: { name: wsName, keeperId: result.keeper.id, keeperName: name },
                }).catch(() => {});
            }

            return result;
        } catch (e: any) {
            if (e?.code === 'P2002') {
                throw new AppError('انباری با این نام در حال حاضر ثبت شده است؛ صفحه را تازه کنید', 409);
            }
            throw e;
        }
    },

    //تراکنش‌های یک انبار در یک روز
    getTransactionsByDate: async (warehouseId: string, date: string) => {
        const warehouse = await prisma.warehouse.findUnique({
            where: { id: warehouseId },
            select: { deletedAt: true },
        });
        if (!warehouse) throw new AppError('انبار یافت نشد', 404);
        if (warehouse.deletedAt) throw new AppError('این انبار بایگانیشده است؛ ابتدا آن را بازگردانی کنید', 400);

        // پنجرهٔ روز بر اساس تاریخ شمسی که اپ ارسال می‌کند (مثلاً 1405-05-27)
        const [y, m, d] = (date || '').split('-').map(Number);
        if (!y || !m || !d || m < 1 || m > 12 || d < 1 || d > 31) {
            throw new AppError('تاریخ نامعتبر است', 400);
        }
        const noon = jalaliToGregorian(y, m, d);
        const startOfDay = new Date(noon.getFullYear(), noon.getMonth(), noon.getDate());
        const endOfDay = new Date(noon.getFullYear(), noon.getMonth(), noon.getDate(), 23, 59, 59, 999);

        const result = await prisma.$queryRaw`
            SELECT 
                t.id, t.type, t."productName", t.quantity, 
                t."warehouseId", t."userId", t."createdAt",
                u.name as "userName",
                p.unit as "unit"
            FROM "Transaction" t
            JOIN "User" u ON t."userId" = u.id
            LEFT JOIN "Product" p ON t."productId" = p.id
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
        if (warehouse.deletedAt) throw new AppError('این انبار بایگانیشده است؛ ابتدا آن را بازگردانی کنید', 400);

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