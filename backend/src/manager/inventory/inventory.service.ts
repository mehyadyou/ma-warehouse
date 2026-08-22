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

    //موجودی هر انبار — کارتن + لِگاسی + انبارهای بدون موجودی (گزارش وضعیت انبارها)
    getWarehouseInventory: async () => {
        const warehouses = await prisma.warehouse.findMany({
            where: { deletedAt: null },
            orderBy: { name: 'asc' },
            select: { id: true, name: true },
        });
        const warehouseNames = new Map(warehouses.map(w => [w.id, w.name]));

        // ── کارتن‌های در هر انبار (فقط ترکیب‌هایی که کارتن دارند) ──
        const cartonInventory = await prisma.$queryRaw<{ warehouseId: string; warehouseName: string; productId: string; productName: string; unit: string | null; count: number }[]>`
            SELECT
                w.id as "warehouseId",
                w.name as "warehouseName",
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
            FROM "Carton" c
            JOIN "Warehouse" w ON w.id = c."warehouseId" AND w."deletedAt" IS NULL
            JOIN "Product" p ON p.id = c."productId" AND p."deletedAt" IS NULL
            LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
            GROUP BY w.id, w.name, p.id, p.name, p.unit
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
        const legacyInventory = await prisma.$queryRaw<{ productId: string; productName: string; unit: string | null; warehouseId: string; legacyCount: number }[]>`
            SELECT
                p.id as "productId",
                p.name as "productName",
                p.unit,
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
            GROUP BY p.id, p.name, p.unit, t."warehouseId"
        `;

        // ── تجمیع به‌صورت ردیف‌های تخت ──
        const rows: {
            warehouseId: string;
            warehouseName: string;
            productId: string;
            productName: string;
            unit: string;
            count: number;
        }[] = [];
        const seen = new Set<string>();

        // کارتن‌ها: فقط محصولات دارای کارتن
        for (const row of cartonInventory) {
            if (!cartonBaseProducts.has(row.productId)) continue;
            rows.push({
                warehouseId: row.warehouseId,
                warehouseName: row.warehouseName,
                productId: row.productId,
                productName: row.productName,
                unit: row.unit?.trim() || 'عدد',
                count: Number(row.count || 0),
            });
            seen.add(`${row.warehouseId}:${row.productId}`);
        }

        // لِگاسی: فقط محصولات بدون کارتن
        for (const row of legacyInventory) {
            if (cartonBaseProducts.has(row.productId)) continue;
            if (!row.warehouseId) continue;
            const key = `${row.warehouseId}:${row.productId}`;
            if (seen.has(key)) continue;
            seen.add(key);
            rows.push({
                warehouseId: row.warehouseId,
                warehouseName: warehouseNames.get(row.warehouseId) ?? 'نامشخص',
                productId: row.productId,
                productName: row.productName,
                unit: row.unit?.trim() || 'عدد',
                count: Number(row.legacyCount || 0),
            });
        }

        // انبارهای بدون هیچ موجودی — با ردیف صفر
        for (const w of warehouses) {
            if (!rows.some(r => r.warehouseId === w.id)) {
                rows.push({
                    warehouseId: w.id,
                    warehouseName: w.name,
                    productId: '',
                    productName: '',
                    unit: 'عدد',
                    count: 0,
                });
            }
        }

        rows.sort((a, b) =>
            a.warehouseName.localeCompare(b.warehouseName, 'fa') ||
            a.productName.localeCompare(b.productName, 'fa'),
        );
        return rows;
    },

    //موجودی محصولات به تفکیک انبار — برای نمودارهای عمودی
    // خروجی: مجموع هر محصول در همهٔ انبارها + ریز موجودی هر انبار (با منطق یکسان کارتن/لِگاسی)
    // page/pageSize: صفحه‌بندی محصولات (مرتب‌شده بر موجودی نزولی) — سقف ۵۰۰؛ بدون پارامتر = رفتار قدیمی (همه)
    getProductInventory: async (opts: { page?: number; pageSize?: number; q?: string; onlyInStock?: boolean; warehouseId?: string } = {}) => {
        // ── حالت تک‌انبار: فقط محصولات انبار انتخاب‌شده (کارتن + لِگاسی همان انبار) ──
        if (opts.warehouseId) {
            const warehouse = await prisma.warehouse.findFirst({
                where: { id: opts.warehouseId, deletedAt: null },
                select: { id: true, name: true },
            });
            if (!warehouse) return null;

            const cartonInventory = await prisma.$queryRaw<{ productId: string; productName: string; unit: string | null; count: number }[]>`
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
                    AND c."warehouseId" = ${opts.warehouseId}
                LEFT JOIN "ProductModel" pm ON c."modelId" = pm.id
                WHERE p."deletedAt" IS NULL
                GROUP BY p.id, p.name, p.unit
            `;

            const cartonRows = await prisma.$queryRaw<{ productId: string; cartonRows: number }[]>`
                SELECT c."productId" as "productId", COUNT(*)::int as "cartonRows"
                FROM "Carton" c
                WHERE c."warehouseId" = ${opts.warehouseId}
                GROUP BY c."productId"
            `;
            const cartonBaseProducts = new Set(
                cartonRows.filter(r => Number(r.cartonRows || 0) > 0).map(r => r.productId),
            );

            const legacyInventory = await prisma.$queryRaw<{ productId: string; legacyCount: number }[]>`
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
                    AND t."warehouseId" = ${opts.warehouseId}
                WHERE p."deletedAt" IS NULL
                GROUP BY p.id
            `;

            const modelInfo = await prisma.$queryRaw<{ productId: string; modelCount: number; modelNames: string[] }[]>`
                SELECT
                    pm."productId" as "productId",
                    COUNT(*)::int as "modelCount",
                    COALESCE(array_agg(pm.name ORDER BY pm.name), '{}') as "modelNames"
                FROM "ProductModel" pm
                WHERE pm."deletedAt" IS NULL
                GROUP BY pm."productId"
            `;
            const modelMap = new Map(
                (modelInfo as { productId: string; modelCount: number; modelNames: string[] }[]).map(item => [
                    item.productId,
                    { modelCount: Number(item.modelCount || 0), modelNames: item.modelNames ?? [] },
                ]),
            );

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

            let all = Array.from(productTotals.values())
                .sort((a, b) => b.totalCount - a.totalCount)
                .map(p => ({
                    ...p,
                    modelCount: modelMap.get(p.productId)?.modelCount ?? 0,
                    modelNames: modelMap.get(p.productId)?.modelNames ?? [],
                }));

            const q = opts.q?.trim().toLowerCase();
            if (q) all = all.filter(p => p.name.toLowerCase().includes(q));
            if (opts.onlyInStock) all = all.filter(p => Number(p.totalCount || 0) !== 0);

            const total = all.length;
            const usePaging = opts.page !== undefined && opts.pageSize !== undefined;
            const page = usePaging ? Math.max(1, Math.floor(opts.page as number)) : 1;
            const pageSize = usePaging
                ? Math.min(500, Math.max(1, Math.floor(opts.pageSize as number)))
                : Math.max(1, total);
            const start = (page - 1) * pageSize;
            const products = all.slice(start, start + pageSize);

            return {
                products,
                total,
                page,
                pageSize,
                hasMore: start + products.length < total,
                warehouses: [
                    {
                        warehouseId: warehouse.id,
                        warehouseName: warehouse.name,
                        totalCount: products.reduce((sum, p) => sum + Number(p.totalCount || 0), 0),
                        totalItems: total,
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
        }

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

        // ── مدل‌های هر محصول (نام + تعداد) — یک کوئری گروهی، بدون سربار هر-کارت ──
        const modelInfo = await prisma.$queryRaw<{
            productId: string;
            modelCount: number;
            modelNames: string[];
        }[]>`
            SELECT
                pm."productId" as "productId",
                COUNT(*)::int as "modelCount",
                COALESCE(array_agg(pm.name ORDER BY pm.name), '{}') as "modelNames"
            FROM "ProductModel" pm
            WHERE pm."deletedAt" IS NULL
            GROUP BY pm."productId"
        `;
        const modelMap = new Map(
            (modelInfo as { productId: string; modelCount: number; modelNames: string[] }[]).map(item => [
                item.productId,
                { modelCount: Number(item.modelCount || 0), modelNames: item.modelNames ?? [] },
            ]),
        );

        const allProducts = Array.from(productTotals.values())
            .sort((a, b) => b.totalCount - a.totalCount)
            .map(p => ({
                ...p,
                modelCount: modelMap.get(p.productId)?.modelCount ?? 0,
                modelNames: modelMap.get(p.productId)?.modelNames ?? [],
            }));

        // فیلترهای سمت سرور — جستجو و فقط-موجودی (قبل از صفحه‌بندی)
        const q = opts.q?.trim().toLowerCase();
        let filtered = allProducts;
        if (q) filtered = filtered.filter(p => p.name.toLowerCase().includes(q));
        if (opts.onlyInStock) filtered = filtered.filter(p => Number(p.totalCount || 0) !== 0);

        // صفحه‌بندی (پیش‌فرض: همه)
        const usePaging = opts.page !== undefined && opts.pageSize !== undefined;
        const safePage = usePaging ? Math.max(1, Math.floor(opts.page as number)) : 1;
        const safeSize = usePaging
            ? Math.min(500, Math.max(1, Math.floor(opts.pageSize as number)))
            : filtered.length;
        const start = (safePage - 1) * safeSize;
        const products = usePaging
            ? filtered.slice(start, start + safeSize)
            : filtered;

        // آیتم‌های هر انبار هم می‌تواند با هزاران محصول بزرگ شود → فقط N تای برتر + شمارنده
        const MAX_WAREHOUSE_ITEMS = 50;
        // با فیلتر فعال، آیتم‌های انبار فقط محصولات منطبق را نشان می‌دهند (هماهنگ با جستجو)
        const filteredIds = q || opts.onlyInStock
            ? new Set(filtered.map(p => p.productId))
            : null;
        const warehouseList = warehouses.map(w => {
            let items = Array.from((warehouseItems.get(w.id) ?? new Map()).values())
                .filter(item => Number(item.count || 0) !== 0);
            if (filteredIds) items = items.filter(it => filteredIds.has(it.productId));
            items.sort((a, b) => b.count - a.count);
            return {
                warehouseId: w.id,
                warehouseName: w.name,
                totalCount: items.reduce((sum, item) => sum + Number(item.count || 0), 0),
                totalItems: items.length,
                items: items.slice(0, MAX_WAREHOUSE_ITEMS),
            };
        });

        return { products, total: filtered.length, page: safePage, pageSize: safeSize, hasMore: start + products.length < filtered.length, warehouses: warehouseList };
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