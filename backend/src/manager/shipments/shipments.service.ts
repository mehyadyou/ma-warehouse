import { prisma } from '../../utils/prisma';

// کلید تاریخ محلی (همان منطق پنجرهٔ تاریخ در گزارش تراکنش‌ها)
const localDateKey = (d: Date) => {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
};

export const shipmentsService = {
    //گزارش ارسالی‌ها: تعداد هر انبار + تاریخچهٔ روزانه + آخرین ارسالی
    getShipmentsReport: async () => {
        const orders = await prisma.order.findMany({
            select: {
                id: true,
                warehouseId: true,
                status: true,
                city: true,
                receiverName: true,
                senderName: true,
                carrier: true,
                createdAt: true,
                createdBy: { select: { name: true } },
                items: {
                    select: {
                        quantity: true,
                        model: true,
                        product: { select: { name: true, unit: true } },
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        });

        const warehouses = await prisma.warehouse.findMany({
            where: { deletedAt: null },
            select: { id: true, name: true },
            orderBy: { name: 'asc' },
        });
        const nameMap = new Map(warehouses.map(w => [w.id, w.name]));

        type Item = { productName: string; quantity: number; unit: string };
        const toItems = (items: (typeof orders)[number]['items']): Item[] =>
            items.map(it => ({
                productName: it.product.name + (it.model ? ` (${it.model})` : ''),
                quantity: it.quantity,
                unit: it.product.unit?.trim() || 'عدد',
            }));

        type OrderEntry = {
            orderId: string;
            status: string;
            city: string | null;
            receiverName: string | null;
            senderName: string | null;
            carrier: string | null;
            createdByName: string | null;
            createdAt: string;
            totalUnits: number;
            items: Item[];
        };
        type Day = { date: string; count: number; items: OrderEntry[] };
        type Wh = { warehouseId: string; totalCount: number; lastShipmentAt: Date | null; daily: Map<string, Day> };

        const byWarehouse = new Map<string, Wh>();
        for (const o of orders) {
            if (!o.warehouseId) continue;
            let w = byWarehouse.get(o.warehouseId);
            if (!w) {
                w = { warehouseId: o.warehouseId, totalCount: 0, lastShipmentAt: null, daily: new Map() };
                byWarehouse.set(o.warehouseId, w);
            }
            w.totalCount += 1;
            if (!w.lastShipmentAt || o.createdAt > w.lastShipmentAt) w.lastShipmentAt = o.createdAt;

            const dateKey = localDateKey(o.createdAt);
            let day = w.daily.get(dateKey);
            if (!day) {
                day = { date: dateKey, count: 0, items: [] };
                w.daily.set(dateKey, day);
            }
            day.count += 1;
            const orderItems = toItems(o.items);
            day.items.push({
                orderId: o.id,
                status: o.status,
                city: o.city,
                receiverName: o.receiverName,
                senderName: o.senderName,
                carrier: o.carrier,
                createdByName: o.createdBy?.name ?? null,
                createdAt: o.createdAt.toISOString(),
                totalUnits: orderItems.reduce((s, it) => s + it.quantity, 0),
                items: orderItems,
            });
        }

        const lastOrder = orders[0] ?? null;
        const lastShipment =
            lastOrder && lastOrder.warehouseId
                ? {
                      orderId: lastOrder.id,
                      warehouseId: lastOrder.warehouseId,
                      warehouseName: nameMap.get(lastOrder.warehouseId) ?? 'نامشخص',
                      status: lastOrder.status,
                      city: lastOrder.city,
                      receiverName: lastOrder.receiverName,
                      senderName: lastOrder.senderName,
                      carrier: lastOrder.carrier,
                      createdByName: lastOrder.createdBy?.name ?? null,
                      createdAt: lastOrder.createdAt.toISOString(),
                      totalUnits: lastOrder.items.reduce((s, it) => s + it.quantity, 0),
                      items: toItems(lastOrder.items),
                  }
                : null;

        const warehouseList = Array.from(byWarehouse.values())
            .map(w => ({
                warehouseId: w.warehouseId,
                warehouseName: nameMap.get(w.warehouseId) ?? 'نامشخص',
                totalCount: w.totalCount,
                lastShipmentAt: w.lastShipmentAt?.toISOString() ?? null,
                daily: Array.from(w.daily.values())
                    .sort((a, b) => b.date.localeCompare(a.date))
                    .map(d => ({ date: d.date, count: d.count, items: d.items })),
            }))
            .sort((a, b) => (b.lastShipmentAt ?? '').localeCompare(a.lastShipmentAt ?? ''));

        return {
            totalShipments: orders.length,
            totalUnits: orders.reduce((s, o) => s + o.items.reduce((x, it) => x + it.quantity, 0), 0),
            totalWarehouses: warehouseList.length,
            lastShipment,
            warehouses: warehouseList,
        };
    },
};