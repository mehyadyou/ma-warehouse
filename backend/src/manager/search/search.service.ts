import { prisma } from '../../utils/prisma';
import type { Prisma } from '@prisma/client';

const toNumber = (v: Prisma.Decimal | null | undefined): number | null =>
    v == null ? null : Number(v);

const orderInclude = {
    warehouse: { select: { name: true } },
    delivery: {
        select: { status: true, deliveredAt: true, notes: true, driver: { select: { name: true } } },
    },
    items: { include: { product: { select: { name: true } } } },
} satisfies Prisma.OrderInclude;

export const searchService = {
    //جستجوی محصولات
    searchProducts: async (query: string) => {
        const result = await prisma.$queryRaw<Array<{
            id: string; name: string; unit: string; modelName: string | null; price: Prisma.Decimal | null;
        }>>`
            SELECT p.id, p.name, p.unit,
                   pm.name as "modelName", pm.price
            FROM "Product" p
            LEFT JOIN "ProductModel" pm ON pm."productId" = p.id
            WHERE (p.name ILIKE ${'%' + query + '%'}
               OR pm.name ILIKE ${'%' + query + '%'})
              AND p."deletedAt" IS NULL
            ORDER BY p.name ASC
            LIMIT 15
        `;
        return result.map((r) => ({ ...r, price: toNumber(r.price) }));
    },

    //جستجوی کارتن با سریال — نمایش مکان فعلی و مرحله
    searchBySerial: async (query: string) => {
        const rows = await prisma.$queryRaw<Array<{
            id: string; productId: string; serialNumber: string | null; status: string; entryType: string;
            isIndividual: boolean; createdAt: Date; scannedOutAt: Date | null;
            productName: string; unit: string; modelName: string | null; unitsPerBox: number | null;
            warehouseName: string; orderId: string | null; senderName: string | null; receiverName: string | null;
            orderStatus: string | null; city: string | null; address: string | null; customerPhone: string | null;
            deliveryStatus: string | null; deliveredAt: Date | null; driverName: string | null;
        }>>`
            SELECT
                c.id, c."productId", c."serialNumber", c.status as "cartonStatus", c."entryType",
                c."isIndividual", c."createdAt", c."scannedOutAt",
                p.name as "productName", p.unit,
                m.name as "modelName", m."unitsPerBox",
                w.name as "warehouseName",
                o.id as "orderId", o."senderName", o."receiverName", o.status as "orderStatus",
                o.city, o.address, o."customerPhone",
                d.status as "deliveryStatus", d."deliveredAt",
                u.name as "driverName"
            FROM "Carton" c
            JOIN "Product" p ON c."productId" = p.id
            JOIN "Warehouse" w ON c."warehouseId" = w.id
            LEFT JOIN "ProductModel" m ON c."modelId" = m.id
            LEFT JOIN "Order" o ON c."orderId" = o.id
            LEFT JOIN "Delivery" d ON d."orderId" = o.id
            LEFT JOIN "User" u ON d."driverId" = u.id
            WHERE c."serialNumber" = ${query} OR c."qrUuid" = ${query}
            LIMIT 1
        `;
        const carton = rows[0] ?? null;
        if (!carton) return null;

        // سفارش‌های ثبت‌شده برای همین کالا/مدل (وقتی کارتن به سفارشی وصله نشده)
        let relatedOrders: any[] = [];
        if (!carton.orderId) {
            relatedOrders = await prisma.orderItem.findMany({
                where: {
                    productId: carton.productId,
                    ...(carton.modelName ? { model: carton.modelName } : {}),
                },
                select: {
                    quantity: true,
                    order: {
                        select: {
                            id: true, status: true, senderName: true, receiverName: true,
                            createdAt: true,
                        },
                    },
                },
                orderBy: { order: { createdAt: 'desc' } },
                take: 5,
            });
        }
        return { ...carton, relatedOrders };
    },

    //جستجوی ارسالی‌ها (فرستنده/گیرنده/کالا/مدل) — نمایش مرحله ارسال
    searchShipments: async (filters: { sender?: string; receiver?: string; product?: string; model?: string }) => {
        const where: Prisma.OrderWhereInput = {
            AND: [
                filters.sender
                    ? { senderName: { contains: filters.sender, mode: 'insensitive' as const } }
                    : null,
                filters.receiver
                    ? { receiverName: { contains: filters.receiver, mode: 'insensitive' as const } }
                    : null,
                filters.product || filters.model
                    ? {
                          items: {
                              some: {
                                  AND: [
                                      filters.product
                                          ? { product: { name: { contains: filters.product, mode: 'insensitive' as const } } }
                                          : null,
                                      filters.model
                                          ? { model: { contains: filters.model, mode: 'insensitive' as const } }
                                          : null,
                                  ].filter(Boolean),
                              },
                          },
                      }
                    : null,
            ].filter(Boolean),
        };

        const orders = await prisma.order.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            take: 20,
            include: orderInclude,
        });

        return orders.map((o) => ({
            id: o.id,
            status: o.status,
            shippingMethod: o.shippingMethod,
            carrier: o.carrier,
            city: o.city,
            postalCode: o.postalCode,
            address: o.address,
            customerPhone: o.customerPhone,
            senderName: o.senderName,
            receiverName: o.receiverName,
            createdAt: o.createdAt,
            updatedAt: o.updatedAt,
            warehouseName: o.warehouse.name,
            deliveryStatus: o.delivery?.status ?? null,
            deliveredAt: o.delivery?.deliveredAt ?? null,
            notes: o.delivery?.notes ?? null,
            driverName: o.delivery?.driver?.name ?? null,
            items: o.items.map((i) => ({
                id: i.id,
                quantity: i.quantity,
                model: i.model,
                price: toNumber(i.price),
                productName: i.product.name,
            })),
        }));
    },
};
