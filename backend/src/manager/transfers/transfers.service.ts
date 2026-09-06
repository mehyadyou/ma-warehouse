import { Prisma, type PrismaClient } from '@prisma/client';
import { prisma } from '../../utils/prisma';
import { runSerializable } from '../../utils/serializableTx';
import { AppError } from '../../common/exceptions/AppError';

export interface TransferInput {
    fromWarehouseId: string;
    toWarehouseId?: string | null;
    productId: string;
    modelId?: string | null;
    quantity: number;
    description?: string;
}

export interface MappedTransfer {
    id: string;
    fromWarehouseId: string;
    fromWarehouseName: string;
    toWarehouseId: string | null;
    toWarehouseName: string | null;
    productId: string;
    productName: string;
    modelId: string | null;
    modelName: string | null;
    quantity: number;
    description: string;
    status: 'PENDING' | 'DONE' | 'CANCELED';
    completedAt: Date | null;
    executedUnits: number;
    remainingUnits: number;
    createdAt: Date;
}

type DbClient = Prisma.TransactionClient | PrismaClient;

/**
 * واحدهای اجراشدهٔ یک دستور = مجموع واحدهای کارتن‌هایی که با این دستور از انبار مبدأ
 * خارج شده‌اند (اسکن شده‌اند). نشانگر: transferId تنظیم + scannedOutAt غیرخالی —
 * هم برای جابه‌جایی (کارتن در مقصد IN_STOCK است) و هم برای خروج (EXITED) درست کار می‌کند.
 */
export async function transferExecutedUnits(client: DbClient, transferId: string): Promise<number> {
    const rows = await client.$queryRaw<{ units: number }[]>`
        SELECT COALESCE(SUM(
            CASE
                WHEN c."isIndividual" THEN 1
                ELSE COALESCE(pm."unitsPerBox", 1)
            END
        ), 0)::int AS units
        FROM "Carton" c
        LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
        WHERE c."transferId" = ${transferId}
            AND c."scannedOutAt" IS NOT NULL
    `;
    return Number(rows[0]?.units ?? 0);
}

/** بستن خودکار دستور وقتی سهمیه به صفر رسید — guard هم‌زمانی */
export async function completeTransferIfDone(
    client: DbClient,
    transferId: string,
    executedUnits: number,
): Promise<boolean> {
    const transfer = await client.transfer.findUnique({
        where: { id: transferId },
        select: { quantity: true, status: true },
    });
    if (!transfer || transfer.status !== 'PENDING') return false;
    if (executedUnits < transfer.quantity) return false;
    const flipped = await client.transfer.updateMany({
        where: { id: transferId, status: 'PENDING' },
        data: { status: 'DONE', completedAt: new Date() },
    });
    return flipped.count === 1;
}

// ── دستورات جابه‌جایی/خروج (دوفازی) ──
// فاز ۱ (مدیر): ثبت دستور با مقدار مشخص → PENDING — هیچ تغییری روی کارتن‌ها اعمال نمی‌شود.
// فاز ۲ (انباردار): اجرا با اسکن کارتن‌ها (scanout.service) تا تکمیل سهمیه → DONE.
// استثنای مستند: محصولات لِگاسی (بدون کارتن) قابل اسکن نیستند → همان اجرای مستقیم مدیر.
export const transfersService = {
    createTransfer: async (input: TransferInput, userId: string) => {
        const isTransfer = Boolean(input.toWarehouseId?.trim());
        const toWarehouseId = isTransfer ? input.toWarehouseId!.trim() : null;

        return runSerializable(async (tx) => {
            // ۱. اعتبارسنجی انبارها
            const fromWarehouse = await tx.warehouse.findUnique({
                where: { id: input.fromWarehouseId.trim() },
            });
            if (!fromWarehouse || fromWarehouse.deletedAt) {
                throw new AppError('انبار مبدأ یافت نشد', 404);
            }

            let toWarehouse: { id: string; name: string; deletedAt: Date | null } | null = null;
            if (toWarehouseId) {
                toWarehouse = await tx.warehouse.findUnique({
                    where: { id: toWarehouseId },
                });
                if (!toWarehouse || toWarehouse.deletedAt) {
                    throw new AppError('انبار مقصد یافت نشد', 404);
                }
                if (toWarehouse.id === fromWarehouse.id) {
                    throw new AppError('انبار مبدأ و مقصد نمی‌توانند یکی باشند', 400);
                }
            }

            // ۲. اعتبارسنجی محصول و مدل
            const product = await tx.product.findUnique({
                where: { id: input.productId.trim() },
            });
            if (!product || product.deletedAt) {
                throw new AppError('محصول یافت نشد', 404);
            }

            const modelId = input.modelId?.trim() || null;
            let model: { id: string; name: string; productId: string; deletedAt: Date | null } | null = null;
            if (modelId) {
                model = await tx.productModel.findUnique({ where: { id: modelId } });
                if (!model || model.deletedAt) {
                    throw new AppError('مدل یافت نشد', 404);
                }
                if (model.productId !== product.id) {
                    throw new AppError('مدل انتخابی متعلق به این محصول نیست', 400);
                }
            }

            const quantity = Math.floor(input.quantity);
            if (quantity < 1) {
                throw new AppError('تعداد باید عددی مثبت باشد', 400);
            }

            // ۳. مبنای موجودی: کارتن‌دار یا لِگاسی
            const anyCarton = await tx.carton.findFirst({
                where: { warehouseId: fromWarehouse.id, productId: product.id },
                select: { id: true },
            });

            let status: 'PENDING' | 'DONE' = 'PENDING';
            let completedAt: Date | null = null;

            if (!anyCarton) {
                // ── مسیر لِگاسی (بدون کارتن): اجرای مستقیم — دفتر تراکنش‌ها مبنای موجودی است ──
                const legacyRows = await tx.$queryRaw<{ balance: number }[]>`
                    SELECT COALESCE(SUM(
                        CASE
                            WHEN t.type = 'IN' THEN t.quantity
                            WHEN t.type = 'OUT' THEN -t.quantity
                            ELSE 0
                        END
                    ), 0)::int AS balance
                    FROM "Transaction" t
                    WHERE t."warehouseId" = ${fromWarehouse.id}
                        AND t."productId" = ${product.id}
                `;
                const available = Math.max(0, Number(legacyRows[0]?.balance ?? 0));
                if (available < quantity) {
                    throw new AppError(`موجودی کافی نیست (موجودی: ${available})`, 400);
                }

                await tx.transaction.create({
                    data: {
                        type: 'OUT',
                        productName: product.name + (model ? ` (${model.name})` : ''),
                        productId: product.id,
                        quantity,
                        warehouseId: fromWarehouse.id,
                        userId,
                    },
                });
                if (toWarehouse) {
                    await tx.transaction.create({
                        data: {
                            type: 'IN',
                            productName: product.name + (model ? ` (${model.name})` : ''),
                            productId: product.id,
                            quantity,
                            warehouseId: toWarehouse.id,
                            userId,
                        },
                    });
                }
                status = 'DONE';
                completedAt = new Date();
            } else {
                // ── مسیر کارتنی: فقط دستور ثبت می‌شود — اجرا با اسکن انباردار
                // بررسی موجودی در لحظهٔ ثبت (هماهنگ با سفارش‌ها)؛ تکمیل جزئی مجاز است
                const availableRows = await tx.$queryRaw<{ available: number }[]>`
                    SELECT COALESCE(SUM(
                        CASE
                            WHEN c."isIndividual" THEN 1
                            ELSE COALESCE(pm."unitsPerBox", 1)
                        END
                    ), 0)::int AS available
                    FROM "Carton" c
                    LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
                    WHERE c."warehouseId" = ${fromWarehouse.id}
                        AND c."productId" = ${product.id}
                        AND c."modelId" = ${modelId ?? null}
                        AND c.status = 'IN_STOCK'
                `;
                const available = Number(availableRows[0]?.available ?? 0);
                if (available < quantity) {
                    throw new AppError(`موجودی کافی نیست (موجودی: ${available})`, 400);
                }
            }

            // ۴. ثبت دستور
            const transfer = await tx.transfer.create({
                data: {
                    fromWarehouseId: fromWarehouse.id,
                    toWarehouseId: toWarehouseId ?? null,
                    productId: product.id,
                    modelId: modelId ?? null,
                    quantity,
                    description: input.description?.trim() ?? '',
                    status,
                    completedAt,
                    createdById: userId,
                },
            });

            const transferLabel = toWarehouse
                ? `دستور جابه‌جایی ${product.name}${model ? ' — ' + model.name : ''} از ${fromWarehouse.name} به ${toWarehouse.name} (${quantity} واحد)`
                : `دستور خروج ${product.name}${model ? ' — ' + model.name : ''} از ${fromWarehouse.name} (${quantity} واحد)`;
            await tx.activityLog.create({
                data: {
                    type: toWarehouse ? 'product_transfer' : 'product_exit',
                    label: transferLabel,
                    userId,
                },
            });

            // رویداد تراکنشی — انباردارِ مبدأ/مقصد همان لحظه از دستور تازه باخبر می‌شود
            // (در انتظار اجرا، یا در مسیر لِگاسی: اجرای مستقیم توسط مدیریت)
            await tx.outboxEvent.create({
                data: {
                    aggregate: 'transfer',
                    type: 'transfer:created',
                    payload: {
                        transferId: transfer.id,
                        kind: toWarehouse ? 'transfer' : 'exit',
                        fromWarehouseId: fromWarehouse.id,
                        fromWarehouseName: fromWarehouse.name,
                        toWarehouseId: toWarehouseId ?? null,
                        toWarehouseName: toWarehouse?.name ?? null,
                        productId: product.id,
                        productName: product.name,
                        modelId: modelId ?? null,
                        modelName: model?.name ?? null,
                        quantity,
                        description: transfer.description,
                        status,
                        createdAt: new Date().toISOString(),
                    },
                },
            });

            return mapTransfer(
                {
                    id: transfer.id,
                    fromWarehouseId: fromWarehouse.id,
                    toWarehouseId: toWarehouseId ?? null,
                    productId: product.id,
                    modelId: modelId ?? null,
                    quantity,
                    description: transfer.description,
                    status,
                    completedAt,
                    createdAt: transfer.createdAt,
                },
                {
                    fromWarehouseName: fromWarehouse.name,
                    toWarehouseName: toWarehouse?.name ?? null,
                    productName: product.name,
                    modelName: model?.name ?? null,
                },
                0,
            );
        });
    },

    /** لغو دستور توسط مدیر — فقط در انتظار و بدون هیچ اسکن اجراشده */
    cancelTransfer: async (id: string, userId: string) => {
        const transfer = await prisma.transfer.findUnique({
            where: { id },
            include: {
                fromWarehouse: { select: { name: true } },
                toWarehouse: { select: { name: true } },
                product: { select: { name: true } },
                model: { select: { name: true } },
            },
        });
        if (!transfer) throw new AppError('دستور یافت نشد', 404);
        if (transfer.status !== 'PENDING') {
            throw new AppError('فقط دستورهای «در انتظار» قابل لغو هستند', 400);
        }
        const scanned = await prisma.carton.count({
            where: { transferId: id, scannedOutAt: { not: null } },
        });
        if (scanned > 0) {
            throw new AppError('این دستور شروع به اجرا شده و قابل لغو نیست', 400);
        }
        await prisma.transfer.update({
            where: { id },
            data: { status: 'CANCELED' },
        });
        await prisma.activityLog.create({
            data: {
                type: transfer.toWarehouseId ? 'product_transfer' : 'product_exit',
                label: `لغو دستور ${transfer.toWarehouseId ? 'جابه‌جایی' : 'خروج'} ${transfer.quantity} واحدی`,
                userId,
            },
        });

        // رویداد تراکنشی‌گونه — انباردارهای مبدأ (و مقصد) از لغو دستور باخبر می‌شوند
        await prisma.outboxEvent.create({
            data: {
                aggregate: 'transfer',
                type: 'transfer:canceled',
                payload: {
                    transferId: transfer.id,
                    kind: transfer.toWarehouseId ? 'transfer' : 'exit',
                    fromWarehouseId: transfer.fromWarehouseId,
                    fromWarehouseName: (transfer as any).fromWarehouse?.name ?? '',
                    toWarehouseId: transfer.toWarehouseId ?? null,
                    toWarehouseName: (transfer as any).toWarehouse?.name ?? null,
                    productId: transfer.productId,
                    productName: (transfer as any).product?.name ?? '',
                    modelId: transfer.modelId ?? null,
                    modelName: (transfer as any).model?.name ?? null,
                    quantity: transfer.quantity,
                    canceledAt: new Date().toISOString(),
                },
            },
        });
    },

    /**
     * لیست دستورات — برای مدیر همه، برای انباردار فقط دستورات انبار خودش.
     * @param fromWarehouseId وقتی داده شود فقط دستورهای این انبار (و غیر لغوشده) برمی‌گردد
     */
    listTransfers: async (limit = 20, fromWarehouseId?: string): Promise<MappedTransfer[]> => {
        const safeLimit = Math.min(50, Math.max(1, Math.floor(limit)));
        const rows = await prisma.transfer.findMany({
            where: fromWarehouseId
                ? { fromWarehouseId, status: { not: 'CANCELED' } }
                : undefined,
            orderBy: { createdAt: 'desc' },
            take: safeLimit,
            include: {
                fromWarehouse: { select: { name: true } },
                toWarehouse: { select: { name: true } },
                product: { select: { name: true } },
                model: { select: { name: true } },
            },
        });

        if (rows.length === 0) return [];

        // واحدهای اجراشده برای همهٔ دستورها یکجا
        const executedRows = await prisma.$queryRaw<{ transferId: string; units: number }[]>`
            SELECT c."transferId" AS "transferId",
                COALESCE(SUM(
                    CASE
                        WHEN c."isIndividual" THEN 1
                        ELSE COALESCE(pm."unitsPerBox", 1)
                    END
                ), 0)::int AS units
            FROM "Carton" c
            LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
            WHERE c."transferId" IN (${Prisma.join(rows.map((r) => r.id))})
                AND c."scannedOutAt" IS NOT NULL
            GROUP BY c."transferId"
        `;
        const executedMap = new Map(executedRows.map((r) => [r.transferId, Number(r.units)]));

        return rows.map((row) =>
            mapTransfer(
                {
                    id: row.id,
                    fromWarehouseId: row.fromWarehouseId,
                    toWarehouseId: row.toWarehouseId,
                    productId: row.productId,
                    modelId: row.modelId,
                    quantity: row.quantity,
                    description: row.description,
                    status: row.status,
                    completedAt: row.completedAt,
                    createdAt: row.createdAt,
                },
                {
                    fromWarehouseName: row.fromWarehouse.name,
                    toWarehouseName: row.toWarehouse?.name ?? null,
                    productName: row.product.name,
                    modelName: row.model?.name ?? null,
                },
                executedMap.get(row.id) ?? 0,
            ),
        );
    },
};

function mapTransfer(
    t: {
        id: string;
        fromWarehouseId: string;
        toWarehouseId: string | null;
        productId: string;
        modelId: string | null;
        quantity: number;
        description: string;
        status: 'PENDING' | 'DONE' | 'CANCELED';
        completedAt: Date | null;
        createdAt: Date;
    },
    names: {
        fromWarehouseName: string;
        toWarehouseName: string | null;
        productName: string;
        modelName: string | null;
    },
    executedUnits: number,
): MappedTransfer {
    return {
        id: t.id,
        fromWarehouseId: t.fromWarehouseId,
        fromWarehouseName: names.fromWarehouseName,
        toWarehouseId: t.toWarehouseId,
        toWarehouseName: names.toWarehouseName,
        productId: t.productId,
        productName: names.productName,
        modelId: t.modelId,
        modelName: names.modelName,
        quantity: t.quantity,
        description: t.description,
        status: t.status,
        completedAt: t.completedAt,
        executedUnits,
        remainingUnits: Math.max(0, t.quantity - executedUnits),
        createdAt: t.createdAt,
    };
}

export type { MappedTransfer as MappedTransferType };