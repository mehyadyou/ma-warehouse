import { prisma } from '../../utils/prisma';

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
                WHERE oi."orderId" IN (${orderIds})
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

    getInventorySummary: async (warehouseId: string) => {
        const cartons = await prisma.carton.findMany({
            where: { warehouseId },
            include: {
                product: { select: { id: true, name: true, unit: true, deletedAt: true } },
                model: { select: { id: true, name: true, unitsPerBox: true } },
            },
            orderBy: [
                { product: { name: 'asc' } },
                { model: { name: 'asc' } },
                { createdAt: 'desc' },
            ],
        });

        const productMap = new Map<string, any>();
        let totalUnits = 0;
        let totalCartons = 0;
        let shippedUnits = 0;
        let shippedCartons = 0;
        let returnedUnits = 0;
        let returnedCartons = 0;

        for (const carton of cartons) {
            // کارتن‌های محصول بایگانی‌شده از نمای این صفحه پنهان می‌مانند (اما QR و اسکن سالم است)
            if (carton.product.deletedAt) continue;
            const units = carton.isIndividual ? 1 : carton.model?.unitsPerBox ?? 0;

            if (carton.status === 'SHIPPED') {
                shippedUnits += units;
                shippedCartons += 1;
                continue;
            }

            if (carton.status !== 'IN_STOCK') continue;

            if (carton.entryType === 'RETURNED') {
                returnedUnits += units;
                returnedCartons += 1;
            }

            totalUnits += units;
            totalCartons += 1;

            const productKey = carton.productId;
            let productEntry = productMap.get(productKey);
            if (!productEntry) {
                productEntry = {
                    productId: carton.product.id,
                    name: carton.product.name,
                    unit: carton.product.unit?.trim() || 'عدد',
                    totalCount: 0,
                    cartonCount: 0,
                    individualCount: 0,
                    modelCount: 0,
                    models: [] as any[],
                    _modelMap: new Map<string, any>(),
                };
                productMap.set(productKey, productEntry);
            }

            productEntry.totalCount += units;
            if (carton.isIndividual) {
                productEntry.individualCount += 1;
            } else {
                productEntry.cartonCount += 1;
            }

            const modelKey = carton.model?.id ?? '__NO_MODEL__';
            let modelEntry = productEntry._modelMap.get(modelKey);
            if (!modelEntry) {
                modelEntry = {
                    modelId: carton.model?.id,
                    name: carton.model?.name ?? 'بدون مدل',
                    unit: carton.product.unit?.trim() || 'عدد',
                    totalCount: 0,
                    cartonCount: 0,
                    individualCount: 0,
                };
                productEntry._modelMap.set(modelKey, modelEntry);
                productEntry.models.push(modelEntry);
            }

            modelEntry.totalCount += units;
            if (carton.isIndividual) {
                modelEntry.individualCount += 1;
            } else {
                modelEntry.cartonCount += 1;
            }
        }

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
                ON (
                    t."productName" = p.name
                    OR t."productName" LIKE (p.name || ' (%)')
                )
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
            totalUnits: products.reduce((sum, p) => sum + Number(p.totalCount || 0), 0),
            totalCartons,
            totalProducts: products.length,
            totalModels: products.reduce(
                (sum, product) => sum + product.models.length,
                0,
            ),
            shippedUnits,
            shippedCartons,
            returnedUnits,
            returnedCartons,
            products,
        };
    },

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
                ON (
                    t."productName" = p.name
                    OR t."productName" LIKE (p.name || ' (%)')
                )
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
    getProducts: async () => {
        return await prisma.product.findMany({
            where: { deletedAt: null },
            orderBy: { name: 'asc' },
            include: {
                models: {
                    where: { deletedAt: null },
                    orderBy: { name: 'asc' },
                    select: {
                        id: true,
                        name: true,
                        price: true,
                        packageType: true,
                        unitsPerBox: true,
                    },
                },
            },
        });
    },
};