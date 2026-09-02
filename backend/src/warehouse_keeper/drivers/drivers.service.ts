import { prisma } from '../../utils/prisma';
import { AppError } from '../../common/exceptions/AppError';
import { writeAuditStandalone } from '../../utils/audit';
import { realtime } from '../../realtime/realtime';

export const driversService = {
    /// لیست رانندگان تعریف‌شده توسط مدیریت — فقط کاربران فعال با نقش راننده
    /// اتصال راننده به انبار همان `User.warehouseId` است؛ تیک انباردار همین فیلد را می‌نویسد.
    listDrivers: async (myWarehouseId?: string) => {
        const drivers = await prisma.user.findMany({
            where: { role: 'DRIVER', isActive: true, deletedAt: null },
            select: {
                id: true,
                name: true,
                phone: true,
                avatarUrl: true,
                warehouseId: true,
                warehouse: { select: { id: true, name: true } },
                createdAt: true,
            },
            orderBy: { createdAt: 'desc' },
        });

        // فلگ‌های تیک: متصل به انبارِ خودم / متصل به انبارِ دیگر (کمرنگ + قفل)
        return drivers.map((d) => ({
            id: d.id,
            name: d.name,
            phone: d.phone,
            avatarUrl: d.avatarUrl,
            createdAt: d.createdAt,
            warehouseId: d.warehouseId,
            warehouseName: d.warehouse?.name ?? null,
            assignedToMe: !!myWarehouseId && d.warehouseId === myWarehouseId,
            assignedToOther: !!myWarehouseId && !!d.warehouseId && d.warehouseId !== myWarehouseId,
        }));
    },

    /// تیک زدن/برداشتن تیک راننده توسط انباردار — اتصال/قطع راننده به انبارِ خودِ انباردار.
    /// انحصار «یک راننده فقط یک انبار» با همان فیلد warehouseId تضمین می‌شود؛
    /// updateMany شرطی داخل تراکنش از مسابقه (دو انباردار هم‌زمان) جلوگیری می‌کند.
    assignDriver: async (
        driverId: string,
        myWarehouseId: string,
        assigned: boolean,
        actorId?: string,
    ) => {
        const driver = await prisma.user.findFirst({
            where: { id: driverId, role: 'DRIVER', isActive: true, deletedAt: null },
            select: { id: true, name: true, phone: true, warehouseId: true },
        });
        if (!driver) throw new AppError('راننده یافت نشد', 404);

        const warehouse = await prisma.warehouse.findUnique({
            where: { id: myWarehouseId },
            select: { name: true },
        });
        if (!warehouse) throw new AppError('انبار شما یافت نشد', 404);

        // بررسی‌های اولیه برای پیام‌های خطای خوانا — تصمیم نهایی داخل تراکنش با updateMany شرطی است
        if (assigned && driver.warehouseId && driver.warehouseId !== myWarehouseId) {
            throw new AppError('این راننده به انبار دیگری متصل است', 409);
        }
        if (!assigned && driver.warehouseId !== myWarehouseId) {
            throw new AppError('این راننده به انبار شما متصل نیست', 409);
        }

        await prisma.$transaction(async (tx) => {
            // ضد-مسابقه: فقط اگر راننده هنوز به جای دیگری متصل نشده باشد (یا متصل به خودم باشد)
            const updated = await tx.user.updateMany({
                where: assigned
                    ? {
                          id: driver.id,
                          role: 'DRIVER',
                          OR: [{ warehouseId: null }, { warehouseId: myWarehouseId }],
                      }
                    : { id: driver.id, warehouseId: myWarehouseId },
                data: assigned ? { warehouseId: myWarehouseId } : { warehouseId: null },
            });
            if (updated.count !== 1) {
                throw new AppError('این راننده به انبار دیگری متصل است', 409);
            }

            // رویداد تراکنشی — همان‌لحظه به راننده و همهٔ انباردارها اطلاع داده می‌شود
            await tx.outboxEvent.create({
                data: {
                    aggregate: 'driver',
                    type: assigned ? 'driver:assigned' : 'driver:unassigned',
                    payload: {
                        driverId: driver.id,
                        driverName: driver.name,
                        driverPhone: driver.phone,
                        warehouseId: myWarehouseId,
                        warehouseName: warehouse.name,
                        actorId: actorId ?? null,
                        assigned,
                    },
                },
            });
        });

        // سوکت راننده به اتاق انبار جدید/خالی منتقل می‌شود تا رویدادهای زنده را بگیرد
        realtime.moveUserToWarehouse(driver.id, assigned ? myWarehouseId : null);

        // تاریخچه + ممیزی (غیرحساس به موفقیت عملیات اصلی)
        if (actorId) {
            await prisma.activityLog.create({
                data: {
                    type: 'user_warehouse_changed',
                    label: assigned
                        ? `«${driver.name}» به انبار ${warehouse.name} متصل شد (توسط انباردار)`
                        : `«${driver.name}» از انبار ${warehouse.name} جدا شد (توسط انباردار)`,
                    userId: actorId,
                },
            }).catch(() => {});
            await writeAuditStandalone({
                actorId, action: 'user.change_warehouse', entity: 'User', entityId: driverId,
                before: { warehouseId: driver.warehouseId ?? null },
                after: assigned ? { warehouseId: myWarehouseId } : { warehouseId: null },
            }).catch(() => {});
        }

        return { id: driver.id, name: driver.name, warehouseId: assigned ? myWarehouseId : null };
    },
};