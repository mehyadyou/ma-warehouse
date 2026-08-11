import { Prisma } from '@prisma/client';
import { prisma } from '../../utils/prisma';
import { cached } from '../../utils/cache';

export const warehouseService = {
    getMyWarehouse: async (warehouseId: string) => {
        const result = await prisma.$queryRaw`
            SELECT w.*, u.name as "keeperName"
            FROM "Warehouse" w
            LEFT JOIN "User" u ON u."warehouseId" = w.id AND u.role = 'WAREHOUSE_KEEPER'
            WHERE w.id = ${warehouseId}
            LIMIT 1
        `;
        return (result as any[])[0] || null;
    },

    getOrders: async (warehouseId: string, limit = 100) => {
        const orders = await prisma.$queryRaw`
            SELECT 
                o.id,
                o."warehouseId",
                o.status,
                o."createdById",
                o."shippingMethod",
                o.carrier,
                o.city,
                o."postalCode",
                o.address,
                o."customerPhone",
                o."senderName",
                o."receiverName",
                o."createdAt",
                o."updatedAt",
                u.name as "createdByName"
            FROM "Order" o
            JOIN "User" u ON o."createdById" = u.id
            WHERE o."warehouseId" = ${warehouseId}
            ORDER BY o."createdAt" DESC
            LIMIT ${limit}
        `;

        const orderIds = (orders as any[]).map((o) => o.id);
        if (orderIds.length > 0) {
            // یک کوئری واحد برای اقلام همه‌ی سفارش‌ها — به‌جای حلقه‌ی N+1
            const items = await prisma.$queryRaw`
                SELECT oi."orderId", oi.*, p.name as "productName"
                FROM "OrderItem" oi
                JOIN "Product" p ON oi."productId" = p.id
                WHERE oi."orderId" IN (${Prisma.join(orderIds)})
            `;
            const byOrder = new Map<string, any[]>();
            for (const item of items as any[]) {
                const list = byOrder.get(item.orderId);
                if (list) list.push(item);
                else byOrder.set(item.orderId, [item]);
            }
            for (const order of orders as any[]) {
                order.items = byOrder.get(order.id) ?? [];
            }
        }

        return orders;
    },

    getInventory: async (warehouseId: string) => {
        return await prisma.$queryRaw`
            SELECT
                p.name as "productName",
                COALESCE(SUM(
                    CASE
                        WHEN c.status = 'IN_STOCK' THEN
                            CASE
                                WHEN c."isIndividual" = true THEN 1
                                ELSE COALESCE(pm."unitsPerBox", 0)
                            END
                        ELSE 0
                    END
                ), 0)::int as stock
            FROM "Product" p
            LEFT JOIN "Carton" c
                ON c."productId" = p.id
                AND c."warehouseId" = ${warehouseId}
            LEFT JOIN "ProductModel" pm ON c."modelId" = pm.id
            WHERE p."deletedAt" IS NULL
            GROUP BY p.name
            ORDER BY p.name
        `;
    },

    getInventorySummary: async (warehouseId: string) => cached(`inv:summary:${warehouseId}`, 45, async () => {
        // ── تجمیع کارتن‌ها در SQL (به‌جای بارگذاری همه در RAM) ──
        const cartonStats = await prisma.$queryRaw<{
            productId: string; productName: string; unit: string | null;
            modelId: string | null; modelName: string | null;
            totalCount: number; cartonCount: number; individualCount: number;
        }[]>`
            SELECT
                p.id AS "productId", p.name AS "productName", p.unit,
                pm.id AS "modelId", pm.name AS "modelName",
                SUM(CASE WHEN c.status = 'IN_STOCK' THEN
                        CASE WHEN c."isIndividual" THEN 1 ELSE COALESCE(pm."unitsPerBox", 0) END
                    ELSE 0 END)::int AS "totalCount",
                COUNT(*) FILTER (WHERE c.status = 'IN_STOCK' AND NOT c."isIndividual")::int AS "cartonCount",
                COUNT(*) FILTER (WHERE c.status = 'IN_STOCK' AND c."isIndividual")::int AS "individualCount"
            FROM "Carton" c
            JOIN "Product" p ON p.id = c."productId" AND p."deletedAt" IS NULL
            LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
            WHERE c."warehouseId" = ${warehouseId}
            GROUP BY p.id, p.name, p.unit, pm.id, pm.name
        `;

        const statusStats = await prisma.$queryRaw<{
            shippedUnits: number; shippedCartons: number;
            returnedUnits: number; returnedCartons: number;
            totalUnits: number; totalCartons: number;
        }[]>`
            SELECT
                SUM(CASE WHEN c.status = 'SHIPPED' THEN
                        CASE WHEN c."isIndividual" THEN 1 ELSE COALESCE(pm."unitsPerBox", 0) END
                    ELSE 0 END)::int AS "shippedUnits",
                COUNT(*) FILTER (WHERE c.status = 'SHIPPED')::int AS "shippedCartons",
                SUM(CASE WHEN c.status = 'IN_STOCK' AND c."entryType" = 'RETURNED' THEN
                        CASE WHEN c."isIndividual" THEN 1 ELSE COALESCE(pm."unitsPerBox", 0) END
                    ELSE 0 END)::int AS "returnedUnits",
                COUNT(*) FILTER (WHERE c.status = 'IN_STOCK' AND c."entryType" = 'RETURNED')::int AS "returnedCartons",
                SUM(CASE WHEN c.status = 'IN_STOCK' THEN
                        CASE WHEN c."isIndividual" THEN 1 ELSE COALESCE(pm."unitsPerBox", 0) END
                    ELSE 0 END)::int AS "totalUnits",
                COUNT(*) FILTER (WHERE c.status = 'IN_STOCK')::int AS "totalCartons"
            FROM "Carton" c
            LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
            WHERE c."warehouseId" = ${warehouseId}
        `;

        const productMap = new Map<string, any>();
        for (const row of cartonStats) {
            const productKey = row.productId;
            let productEntry = productMap.get(productKey);
            if (!productEntry) {
                productEntry = {
                    productId: row.productId,
                    name: row.productName,
                    unit: row.unit?.trim() || 'عدد',
                    totalCount: 0,
                    cartonCount: 0,
                    individualCount: 0,
                    modelCount: 0,
                    models: [] as any[],
                    _modelMap: new Map<string, any>(),
                };
                productMap.set(productKey, productEntry);
            }

            productEntry.totalCount += Number(row.totalCount || 0);
            productEntry.cartonCount += Number(row.cartonCount || 0);
            productEntry.individualCount += Number(row.individualCount || 0);

            const modelKey = row.modelId ?? '__NO_MODEL__';
            let modelEntry = productEntry._modelMap.get(modelKey);
            if (!modelEntry) {
                modelEntry = {
                    modelId: row.modelId,
                    name: row.modelName ?? 'بدون مدل',
                    unit: row.unit?.trim() || 'عدد',
                    totalCount: 0,
                    cartonCount: 0,
                    individualCount: 0,
                };
                productEntry._modelMap.set(modelKey, modelEntry);
                productEntry.models.push(modelEntry);
            }
            modelEntry.totalCount += Number(row.totalCount || 0);
            modelEntry.cartonCount += Number(row.cartonCount || 0);
            modelEntry.individualCount += Number(row.individualCount || 0);
        }

        const shipped = statusStats[0] ?? { shippedUnits: 0, shippedCartons: 0, returnedUnits: 0, returnedCartons: 0, totalUnits: 0, totalCartons: 0 };

        // ── تراکنش‌های لِگاسی: محصولات بدون کارتن در این انبار ──
        // فقط انبار خود کاربر (warehouseId) — هیچ انبار دیگری در هیچ کوئری‌ای دیده نمی‌شود
        const legacyInventory = await prisma.$queryRaw<{
            productId: string;
            name: string;
            unit: string | null;
            legacyCount: number;
        }[]>`
            SELECT
                p.id as "productId",
                p.name,
                p.unit,
                COALESCE(SUM(
                    CASE
                        WHEN t.type = 'IN' THEN t.quantity
                        WHEN t.type = 'OUT' THEN -t.quantity
                        ELSE 0
                    END
                ), 0)::int as "legacyCount"
            FROM "Product" p
            LEFT JOIN "Transaction" t
                ON t."productId" = p.id
                AND t."warehouseId" = ${warehouseId}
            WHERE p."deletedAt" IS NULL
            GROUP BY p.id, p.name, p.unit
        `;

        for (const row of legacyInventory) {
            if (productMap.has(row.productId)) continue;
            productMap.set(row.productId, {
                productId: row.productId,
                name: row.name,
                unit: row.unit?.trim() || 'عدد',
                totalCount: Number(row.legacyCount || 0),
                cartonCount: 0,
                individualCount: 0,
                modelCount: 0,
                models: [] as any[],
                _modelMap: new Map<string, any>(),
            });
        }

        // مرتب‌سازی مثل پنل مدیر: بیشترین موجودی اول
        const products = Array.from(productMap.values())
            .sort((a, b) => b.totalCount - a.totalCount)
            .map((product) => {
                const models = (product.models as any[])
                    .sort((a, b) => a.name.localeCompare(b.name))
                    .map((model) => ({
                        modelId: model.modelId,
                        name: model.name,
                        unit: model.unit,
                        totalCount: model.totalCount,
                        cartonCount: model.cartonCount,
                        individualCount: model.individualCount,
                    }));

                return {
                    productId: product.productId,
                    name: product.name,
                    unit: product.unit,
                    totalCount: product.totalCount,
                    cartonCount: product.cartonCount,
                    individualCount: product.individualCount,
                    modelCount: models.length,
                    models,
                };
            });

        return {
            totalUnits: Number(shipped.totalUnits || 0),
            totalCartons: Number(shipped.totalCartons || 0),
            totalProducts: products.length,
            totalModels: products.reduce(
                (sum, product) => sum + product.models.length,
                0,
            ),
            shippedUnits: Number(shipped.shippedUnits || 0),
            shippedCartons: Number(shipped.shippedCartons || 0),
            returnedUnits: Number(shipped.returnedUnits || 0),
            returnedCartons: Number(shipped.returnedCartons || 0),
            products,
        };
    }),

    //موجودی محصولات فقط در انبار خود کاربر — همان منطق پنل مدیر (کارتن + لِگاسی)
    //تضمین دسترسی: هیچ کوئری‌ای خارج از warehouseId کاربر اجرا نمی‌شود
    getProductInventory: async (warehouseId: string) => {
        const warehouse = await prisma.warehouse.findFirst({
            where: { id: warehouseId, deletedAt: null },
            select: { id: true, name: true },
        });
        if (!warehouse) return null;

        // کارتن‌های همین انبار
        const cartonInventory = await prisma.$queryRaw<{
            productId: string;
            productName: string;
            unit: string | null;
            count: number;
        }[]>`
            SELECT 
                p.id as "productId",
                p.name as "productName",
                p.unit,
                COALESCE(SUM(
                    CASE
                        WHEN c.status = 'IN_STOCK' THEN
                            CASE
                                WHEN c."isIndividual" = true THEN 1
                                ELSE COALESCE(pm."unitsPerBox", 0)
                            END
                        ELSE 0
                    END
                ), 0)::int as "count"
            FROM "Product" p
            LEFT JOIN "Carton" c 
                ON c."productId" = p.id 
                AND c."warehouseId" = ${warehouseId}
            LEFT JOIN "ProductModel" pm ON c."modelId" = pm.id
            WHERE p."deletedAt" IS NULL
            GROUP BY p.id, p.name, p.unit
        `;

        // محصولاتی که در همین انبار کارتن دارند (بقیه با لِگاسی تکمیل می‌شوند)
        const cartonRows = await prisma.$queryRaw<{ productId: string; cartonRows: number }[]>`
            SELECT c."productId" as "productId", COUNT(*)::int as "cartonRows"
            FROM "Carton" c
            WHERE c."warehouseId" = ${warehouseId}
            GROUP BY c."productId"
        `;
        const cartonBaseProducts = new Set(
            cartonRows.filter(r => Number(r.cartonRows || 0) > 0).map(r => r.productId),
        );

        // تراکنش‌های لِگاسی فقط همین انبار
        const legacyInventory = await prisma.$queryRaw<{
            productId: string;
            legacyCount: number;
        }[]>`
            SELECT
                p.id as "productId",
                COALESCE(SUM(
                    CASE
                        WHEN t.type = 'IN' THEN t.quantity
                        WHEN t.type = 'OUT' THEN -t.quantity
                        ELSE 0
                    END
                ), 0)::int as "legacyCount"
            FROM "Product" p
            LEFT JOIN "Transaction" t
                ON t."productId" = p.id
                AND t."warehouseId" = ${warehouseId}
            WHERE p."deletedAt" IS NULL
            GROUP BY p.id
        `;

        const productTotals = new Map<string, { productId: string; name: string; unit: string; totalCount: number }>();
        const ensureProduct = (productId: string, name: string, unit: string | null) => {
            if (!productTotals.has(productId)) {
                productTotals.set(productId, {
                    productId,
                    name,
                    unit: unit?.trim() || 'عدد',
                    totalCount: 0,
                });
            }
        };

        for (const row of cartonInventory) {
            ensureProduct(row.productId, row.productName, row.unit);
            const count = cartonBaseProducts.has(row.productId) ? Number(row.count || 0) : 0;
            productTotals.get(row.productId)!.totalCount += count;
        }

        for (const row of legacyInventory) {
            if (cartonBaseProducts.has(row.productId)) continue;
            const name = productTotals.get(row.productId)?.name ?? row.productId;
            const unit = productTotals.get(row.productId)?.unit ?? 'عدد';
            ensureProduct(row.productId, name, unit);
            productTotals.get(row.productId)!.totalCount += Number(row.legacyCount || 0);
        }

        const products = Array.from(productTotals.values())
            .sort((a, b) => b.totalCount - a.totalCount);

        return {
            products,
            warehouses: [
                {
                    warehouseId: warehouse.id,
                    warehouseName: warehouse.name,
                    totalCount: products.reduce((sum, p) => sum + Number(p.totalCount || 0), 0),
                    items: products
                        .filter(p => Number(p.totalCount || 0) !== 0)
                        .map(p => ({
                            productId: p.productId,
                            name: p.name,
                            unit: p.unit,
                            count: p.totalCount,
                        })),
                },
            ],
        };
    },

    //مدل‌های یک محصول با موجودی فقط در انبار خود کاربر — همشکل پنل مدیر
    getProductModels: async (warehouseId: string, productId: string) => {
        const product = await prisma.product.findFirst({
            where: { id: productId, deletedAt: null },
            select: { id: true, name: true, unit: true },
        });
        if (!product) return null;

        const warehouse = await prisma.warehouse.findFirst({
            where: { id: warehouseId, deletedAt: null },
            select: { id: true, name: true },
        });

        const modelTotals = await prisma.$queryRaw<{
            modelId: string;
            name: string;
            packageType: string | null;
            unitsPerBox: number | null;
            count: number;
        }[]>`
            SELECT 
                pm.id as "modelId",
                pm.name,
                pm."packageType",
                pm."unitsPerBox",
                COALESCE(SUM(
                    CASE
                        WHEN c.status = 'IN_STOCK' THEN
                            CASE
                                WHEN c."isIndividual" = true THEN 1
                                ELSE COALESCE(pm."unitsPerBox", 0)
                            END
                        ELSE 0
                    END
                ), 0)::int as "count"
            FROM "ProductModel" pm
            LEFT JOIN "Carton" c 
                ON c."modelId" = pm.id
                AND c."warehouseId" = ${warehouseId}
            WHERE pm."productId" = ${productId}
            AND pm."deletedAt" IS NULL
            GROUP BY pm.id, pm.name, pm."packageType", pm."unitsPerBox"
            ORDER BY "count" DESC, pm.name ASC
        `;

        const models = (modelTotals as typeof modelTotals).map(row => {
            const count = Number(row.count || 0);
            return {
                modelId: row.modelId,
                name: row.name,
                packageType: row.packageType?.trim() || null,
                unitsPerBox: row.unitsPerBox,
                count,
                // فقط انبار خود کاربر
                warehouses: count > 0 && warehouse
                    ? [{ warehouseId: warehouse.id, warehouseName: warehouse.name, count }]
                    : [],
            };
        });

        return {
            product: {
                id: product.id,
                name: product.name,
                unit: product.unit?.trim() || 'عدد',
            },
            models,
        };
    },

    getTransactions: async (warehouseId: string, date?: string) => {
        if (date) {
            return await prisma.$queryRaw`
                SELECT t.*, u.name as "userName"
                FROM "Transaction" t
                JOIN "User" u ON t."userId" = u.id
                WHERE t."warehouseId" = ${warehouseId}
                AND t."createdAt"::date = ${date}::date
                ORDER BY t."createdAt" DESC LIMIT 50
            `;
        } else {
            return await prisma.$queryRaw`
                SELECT t.*, u.name as "userName"
                FROM "Transaction" t
                JOIN "User" u ON t."userId" = u.id
                WHERE t."warehouseId" = ${warehouseId}
                ORDER BY t."createdAt" DESC LIMIT 50
            `;
        }
    },

    //محصولات برای انباردار (فقط خواندنی + ظرفیت مدل‌ها) — بدون محصولات بایگانی‌شده
    getProducts: async (opts: { q?: string; page?: number; pageSize?: number } = {}) => {
        const where: Prisma.ProductWhereInput = {
            deletedAt: null,
            ...(opts.q?.trim()
                ? {
                      OR: [
                          { name: { contains: opts.q.trim(), mode: 'insensitive' } },
                          { models: { some: { name: { contains: opts.q.trim(), mode: 'insensitive' } } } },
                      ],
                  }
                : {}),
        };
        const include = {
            models: {
                where: { deletedAt: null },
                orderBy: { name: 'asc' as const },
                select: {
                    id: true,
                    name: true,
                    price: true,
                    packageType: true,
                    unitsPerBox: true,
                },
            },
        } satisfies Prisma.ProductInclude;

        if (opts.page !== undefined && opts.pageSize !== undefined) {
            const skip = (Math.max(1, opts.page) - 1) * Math.max(1, opts.pageSize);
            const [products, total] = await prisma.$transaction([
                prisma.product.findMany({
                    where,
                    orderBy: { name: 'asc' },
                    include,
                    skip,
                    take: Math.max(1, opts.pageSize),
                }),
                prisma.product.count({ where }),
            ]);
            return { products, items: products.length, total, page: opts.page, pageSize: opts.pageSize };
        }

        return await prisma.product.findMany({ where, orderBy: { name: 'asc' }, include });
    },
};