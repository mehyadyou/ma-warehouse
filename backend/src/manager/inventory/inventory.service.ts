import { prisma } from '../../utils/prisma';
import { cached } from '../../utils/cache';

export const inventoryService = {
    //موجودی کل محصولات
    getInventorySummary: async () => cached('inv:summary', 45, async () => {
        const totalRegisteredProducts = await prisma.product.count({
            where: { deletedAt: null },
        });
        const cartonInventory = await prisma.$queryRaw`
            SELECT 
                p.id, p.name, p.unit,
                COUNT(c.id)::int as "cartonRows",
                COALESCE(SUM(
                    CASE
                        WHEN c.status = 'IN_STOCK' AND c."entryType" = 'RETURNED' THEN
                            CASE
                                WHEN c."isIndividual" = true THEN 1
                                ELSE COALESCE(pm."unitsPerBox", 0)
                            END
                        ELSE 0
                    END
                ), 0)::int as "returnedCount",
                COALESCE(SUM(
                    CASE
                        WHEN c.status = 'IN_STOCK' THEN
                            CASE
                                WHEN c."isIndividual" = true THEN 1
                                ELSE COALESCE(pm."unitsPerBox", 0)
                            END
                        ELSE 0
                    END
                ), 0)::int as "totalCount"
            FROM "Product" p
            LEFT JOIN "Carton" c
                ON c."productId" = p.id
                -- کارتن‌های انبار بایگانی‌شده در آمار موجودی محاسبه نمی‌شوند
                AND c."warehouseId" IN (SELECT "id" FROM "Warehouse" WHERE "deletedAt" IS NULL)
            LEFT JOIN "ProductModel" pm ON c."modelId" = pm.id
            WHERE p."deletedAt" IS NULL
            GROUP BY p.id, p.name
        `;

        const legacyInventory = await prisma.$queryRaw`
            SELECT
                p.id,
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
                -- تراکنش‌های انبار بایگانی‌شده در آمار موجودی محاسبه نمی‌شوند
                AND t."warehouseId" IN (SELECT "id" FROM "Warehouse" WHERE "deletedAt" IS NULL)
            GROUP BY p.id
        `;

        const legacyMap = new Map(
            (legacyInventory as { id: string; legacyCount: number }[]).map(item => [
                item.id,
                Number(item.legacyCount || 0),
            ]),
        );

        const inventory = (cartonInventory as { id: string; name: string; unit: string; cartonRows: number; totalCount: number }[])
            .map(item => {
                const hasCartonData = Number(item.cartonRows || 0) > 0;
                const totalCount = hasCartonData
                    ? Number(item.totalCount || 0)
                    : Number(legacyMap.get(item.id) || 0);

                return {
                    id: item.id,
                    name: item.name,
                    unit: item.unit?.trim() || 'عدد',
                    totalCount,
                };
            })
            .sort((a, b) => b.totalCount - a.totalCount);

        const totalInventoryUnits = inventory.reduce(
            (sum, item) => sum + Number(item.totalCount || 0),
            0,
        );

        const activeInventoryProducts = inventory.filter(
            item => Number(item.totalCount || 0) > 0,
        ).length;
        const returnedUnits = (cartonInventory as { returnedCount: number }[]).reduce(
            (sum, item) => sum + Number(item.returnedCount || 0),
            0,
        );

        return {
            totalRegisteredProducts,
            totalInventoryUnits,
            activeInventoryProducts,
            returnedUnits,
            inventory,
        };
    }),

    //موجودی هر انبار — فقط ترکیب‌هایی که کارتن دارند (بدون CROSS JOIN انفجاری)
    getWarehouseInventory: async () => {
        const result = await prisma.$queryRaw`
            SELECT
                w.id as "warehouseId",
                w.name as "warehouseName",
                p.id as "productId",
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
                ), 0)::int as "count"
            FROM "Carton" c
            JOIN "Warehouse" w ON w.id = c."warehouseId" AND w."deletedAt" IS NULL
            JOIN "Product" p ON p.id = c."productId" AND p."deletedAt" IS NULL
            LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
            GROUP BY w.id, w.name, p.id, p.name
            ORDER BY w.name, p.name
        `;
        return result;
    },

    //موجودی محصولات به تفکیک انبار — برای نمودارهای عمودی
    // خروجی: مجموع هر محصول در همهٔ انبارها + ریز موجودی هر انبار (با منطق یکسان کارتن/لِگاسی)
    getProductInventory: async () => {
        const warehouses = await prisma.warehouse.findMany({
            where: { deletedAt: null },
            orderBy: { name: 'asc' },
            select: { id: true, name: true },
        });

        // ── کارتن‌های در انبار: شمارش هر محصول در هر انبار (فقط ترکیب‌هایی که کارتن دارند) ──
        const cartonInventory = await prisma.$queryRaw<{ productId: string; productName: string; unit: string | null; warehouseId: string; count: number }[]>`
            SELECT
                p.id as "productId",
                p.name as "productName",
                p.unit,
                w.id as "warehouseId",
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
            FROM "Carton" c
            JOIN "Product" p ON p.id = c."productId" AND p."deletedAt" IS NULL
            JOIN "Warehouse" w ON w.id = c."warehouseId" AND w."deletedAt" IS NULL
            LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
            GROUP BY p.id, p.name, p.unit, w.id
        `;

        // ── شناسایی محصولات دارای کارتن (سایر محصولات با تراکنش‌های لِگاسی محاسبه می‌شوند) ──
        const cartonRows = await prisma.$queryRaw<{ productId: string; cartonRows: number }[]>`
            SELECT c."productId" as "productId", COUNT(*)::int as "cartonRows"
            FROM "Carton" c
            JOIN "Warehouse" w ON c."warehouseId" = w.id AND w."deletedAt" IS NULL
            GROUP BY c."productId"
        `;
        const cartonBaseProducts = new Set(
            cartonRows.filter(r => Number(r.cartonRows || 0) > 0).map(r => r.productId),
        );

        // ── تراکنش‌های لِگاسی هر محصول در هر انبار (فقط محصولات بدون کارتن) ──
        const legacyInventory = await prisma.$queryRaw<{ productId: string; warehouseId: string; legacyCount: number }[]>`
            SELECT
                p.id as "productId",
                t."warehouseId" as "warehouseId",
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
                AND t."warehouseId" IN (SELECT "id" FROM "Warehouse" WHERE "deletedAt" IS NULL)
            WHERE p."deletedAt" IS NULL
            GROUP BY p.id, t."warehouseId"
        `;

        // ── تجمیع ──
        const productTotals = new Map<string, { productId: string; name: string; unit: string; totalCount: number }>();
        // warehouseId → (productId → item)
        const warehouseItems = new Map<string, Map<string, { productId: string; name: string; unit: string; count: number }>>();

        const ensureProductTotal = (productId: string, name: string, unit: string | null) => {
            if (!productTotals.has(productId)) {
                productTotals.set(productId, {
                    productId,
                    name,
                    unit: unit?.trim() || 'عدد',
                    totalCount: 0,
                });
            }
        };
        const ensureWarehouseItem = (warehouseId: string, productId: string, name: string, unit: string | null) => {
            let items = warehouseItems.get(warehouseId);
            if (!items) {
                items = new Map();
                warehouseItems.set(warehouseId, items);
            }
            if (!items.has(productId)) {
                items.set(productId, { productId, name, unit: unit?.trim() || 'عدد', count: 0 });
            }
            return items.get(productId)!;
        };

        // کارتن‌ها: محصول دارای کارتن → شمارش کارتنی؛ بدون کارتن → صفر (با لِگاسی تکمیل می‌شود)
        for (const row of cartonInventory) {
            ensureProductTotal(row.productId, row.productName, row.unit);
            const count = cartonBaseProducts.has(row.productId) ? Number(row.count || 0) : 0;
            productTotals.get(row.productId)!.totalCount += count;
            const item = ensureWarehouseItem(row.warehouseId, row.productId, row.productName, row.unit);
            item.count += count;
        }

        // لِگاسی: فقط محصولات بدون کارتن، تراکنش‌هایشان به هر انبار نسبت داده می‌شود
        for (const row of legacyInventory) {
            if (cartonBaseProducts.has(row.productId)) continue;
            if (!row.warehouseId) continue;
            const name = productTotals.get(row.productId)?.name ?? row.productId;
            const unit = productTotals.get(row.productId)?.unit ?? 'عدد';
            ensureProductTotal(row.productId, name, unit);
            const count = Number(row.legacyCount || 0);
            productTotals.get(row.productId)!.totalCount += count;
            const item = ensureWarehouseItem(row.warehouseId, row.productId, name, unit);
            item.count += count;
        }

        const products = Array.from(productTotals.values())
            .sort((a, b) => b.totalCount - a.totalCount);

        const warehouseList = warehouses.map(w => {
            const items = Array.from((warehouseItems.get(w.id) ?? new Map()).values())
                .filter(item => Number(item.count || 0) !== 0)
                .sort((a, b) => b.count - a.count);
            return {
                warehouseId: w.id,
                warehouseName: w.name,
                totalCount: items.reduce((sum, item) => sum + Number(item.count || 0), 0),
                items,
            };
        });

        return { products, warehouses: warehouseList };
    },

    //مدل‌های یک محصول به‌همراه موجودی هر مدل در هر انبار
    getProductModels: async (productId: string) => {
        const product = await prisma.product.findFirst({
            where: { id: productId, deletedAt: null },
            select: { id: true, name: true, unit: true },
        });
        if (!product) return null;

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
                -- کارتن‌های انبار بایگانی‌شده در آمار موجودی محاسبه نمی‌شوند
                AND c."warehouseId" IN (SELECT "id" FROM "Warehouse" WHERE "deletedAt" IS NULL)
            WHERE pm."productId" = ${productId}
            AND pm."deletedAt" IS NULL
            GROUP BY pm.id, pm.name, pm."packageType", pm."unitsPerBox"
            ORDER BY "count" DESC, pm.name ASC
        `;

        const modelWarehouses = await prisma.$queryRaw<{
            modelId: string;
            warehouseId: string;
            warehouseName: string;
            count: number;
        }[]>`
            SELECT
                pm.id as "modelId",
                w.id as "warehouseId",
                w.name as "warehouseName",
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
            FROM "Carton" c
            JOIN "ProductModel" pm ON pm.id = c."modelId"
            JOIN "Warehouse" w ON w.id = c."warehouseId" AND w."deletedAt" IS NULL
            WHERE pm."productId" = ${productId}
            AND pm."deletedAt" IS NULL
            GROUP BY pm.id, pm.name, pm."packageType", pm."unitsPerBox", w.id, w.name
            ORDER BY pm.name, w.name
        `;

        const warehouseMap = new Map<string, { warehouseId: string; warehouseName: string; count: number }[]>();
        for (const row of modelWarehouses) {
            const list = warehouseMap.get(row.modelId) ?? [];
            if (Number(row.count || 0) > 0) {
                list.push({ warehouseId: row.warehouseId, warehouseName: row.warehouseName, count: Number(row.count || 0) });
            }
            warehouseMap.set(row.modelId, list);
        }

        const models = (modelTotals as typeof modelTotals)
            .map(row => ({
                modelId: row.modelId,
                name: row.name,
                packageType: row.packageType?.trim() || null,
                unitsPerBox: row.unitsPerBox,
                count: Number(row.count || 0),
                warehouses: warehouseMap.get(row.modelId) ?? [],
            }));

        return {
            product: {
                id: product.id,
                name: product.name,
                unit: product.unit?.trim() || 'عدد',
            },
            models,
        };
    },
};