import { prisma } from '../../utils/prisma';
import { Prisma } from '@prisma/client';
import { tehranDayRange } from '../../utils/jalali';

const MAX_PAGE_SIZE = 100;
const DETAIL_CARTON_CAP = 200;
const DETAIL_TX_CAP = 200;
const DETAIL_TRANSFER_CAP = 100;

export type ExitTypeFilter = 'any' | 'carton' | 'individual' | 'none';

export interface ProductHistoryFilters {
    /** جستجوی آزاد در نام محصول */
    q?: string;
    productId?: string;
    warehouseId?: string;
    /** کارتنی / تکی / بدون کارتن (لِگاسی فقط تراکنشی) / همه */
    exitType?: ExitTypeFilter;
    /** همه یا بخشی از شمارهٔ سریال کارتن */
    serial?: string;
    /** شمارهٔ تماس مشتری — محصولاتی که به سفارش‌های او وصله */
    customerPhone?: string;
    /** از تاریخ (ISO yyyy-mm-dd) — بر اساس اولین ورود */
    from?: string;
    /** تا تاریخ (ISO yyyy-mm-dd) — بر اساس اولین ورود */
    to?: string;
    /** تاریخ دقیق شمسی (yyyy-mm-dd) — فقط محصولاتی که در همین روزِ تهران فعالیتی داشته‌اند */
    activityDate?: string;
    page?: number;
    pageSize?: number;
}

const J_DATE_RE = /^(\d{4})-(\d{1,2})-(\d{1,2})$/;

/** تجزیهٔ تاریخ شمسیِ متنی (۱۴۰۵-۰۶-۱۵) — undefined یعنی نامعتبر (مثل تاریخِ میلادی) */
export function parseJalaliDateStr(s?: string): { jy: number; jm: number; jd: number } | undefined {
    if (!s?.trim()) return undefined;
    const m = J_DATE_RE.exec(s.trim());
    if (!m) return undefined;
    const jy = Number(m[1]);
    const jm = Number(m[2]);
    const jd = Number(m[3]);
    // محدودهٔ منطقیِ تقویم شمسی — سالِ میلادی (مثل 2026) را رد می‌کند
    if (jy < 1300 || jy > 1500 || jm < 1 || jm > 12 || jd < 1 || jd > 31) return undefined;
    return { jy, jm, jd };
}

/** بازهٔ [start, end) روزِ تهران برای فیلترِ تاریخِ دقیق — undefined یعنی بدون فیلتر */
function dayRangeOf(s?: string): { start: Date; end: Date } | undefined {
    const j = parseJalaliDateStr(s);
    return j ? tehranDayRange(j.jy, j.jm, j.jd) : undefined;
}

const clampInt = (v: number | undefined, def: number, max: number): number => {
    const n = Math.floor(v ?? def);
    if (!Number.isFinite(n)) return def;
    return Math.min(max, Math.max(1, n));
};

interface ListRow {
    productId: string;
    productName: string;
    archived: boolean;
    cartonTotal: number;
    inStock: number;
    shipped: number;
    returned: number;
    exited: number;
    individualTotal: number;
    individualInStock: number;
    txIn: number | null;
    txOut: number | null;
    txReturn: number | null;
    firstEntryAt: Date | null;
    lastActivityAt: Date | null;
}

export const productHistoryService = {
    /** فهرست همهٔ محصولاتی که از ابتدا وارد سیستم شده‌اند + آمار تجمیعی هرکدام */
    list: async (f: ProductHistoryFilters) => {
        const page = clampInt(f.page, 1, 10_000);
        const pageSize = clampInt(f.pageSize, 20, MAX_PAGE_SIZE);

        const conds: Prisma.Sql[] = [];

        if (f.q?.trim()) {
            conds.push(Prisma.sql`p.name ILIKE ${'%' + f.q.trim() + '%'}`);
        }
        if (f.productId?.trim()) {
            conds.push(Prisma.sql`p.id = ${f.productId.trim()}`);
        }
        if (f.exitType === 'carton') {
            conds.push(Prisma.sql`COALESCE(ca.carton_only, 0) > 0`);
        } else if (f.exitType === 'individual') {
            conds.push(Prisma.sql`COALESCE(ca.individual_total, 0) > 0`);
        } else if (f.exitType === 'none') {
            conds.push(Prisma.sql`COALESCE(ca.carton_total, 0) = 0`);
        }
        if (f.from?.trim()) {
            conds.push(
                Prisma.sql`LEAST(COALESCE(ca.first_carton_at, ta.first_tx_at), COALESCE(ta.first_tx_at, ca.first_carton_at)) >= ${f.from.trim()}::timestamptz`,
            );
        }
        if (f.to?.trim()) {
            conds.push(
                Prisma.sql`LEAST(COALESCE(ca.first_carton_at, ta.first_tx_at), COALESCE(ta.first_tx_at, ca.first_carton_at)) < (${f.to.trim()}::date + INTERVAL '1 day')`,
            );
        }
        const dayRange = dayRangeOf(f.activityDate);
        if (dayRange) {
            // فعالیتِ همان روز: تراکنشِ ثبت‌شده، کارتنی که وارد شده یا کارتنی که از انبار اسکن/خارج شده
            conds.push(Prisma.sql`(
                EXISTS (SELECT 1 FROM "Transaction" td
                        WHERE td."productId" = p.id
                          AND td."createdAt" >= ${dayRange.start} AND td."createdAt" < ${dayRange.end})
                OR EXISTS (SELECT 1 FROM "Carton" cd
                        WHERE cd."productId" = p.id
                          AND ((cd."createdAt" >= ${dayRange.start} AND cd."createdAt" < ${dayRange.end})
                            OR (cd."scannedOutAt" IS NOT NULL AND cd."scannedOutAt" >= ${dayRange.start} AND cd."scannedOutAt" < ${dayRange.end})))
            )`);
        }

        const whereSql = conds.length
            ? Prisma.sql`AND ${Prisma.join(conds, ' AND ')}`
            : Prisma.empty;

        // کارتن‌های هم‌سنتز با فیلترهای انبار/سریال/مشتری — اگر هیچ فیلتری نیست سبک‌تر همان است
        const cartonConds: Prisma.Sql[] = [Prisma.sql`TRUE`];
        if (f.warehouseId?.trim()) {
            cartonConds.push(Prisma.sql`c."warehouseId" = ${f.warehouseId.trim()}`);
        }
        if (f.serial?.trim()) {
            cartonConds.push(Prisma.sql`c."serialNumber" ILIKE ${'%' + f.serial.trim() + '%'}`);
        }
        if (f.customerPhone?.trim()) {
            cartonConds.push(
                Prisma.sql`c."orderId" IN (SELECT o.id FROM "Order" o WHERE o."customerPhone" = ${f.customerPhone.trim()})`,
            );
        }
        const cartonWhere = Prisma.join(cartonConds, ' AND ');

        const rows = await prisma.$queryRaw<Array<ListRow & { total: bigint }>>`
            WITH carton_agg AS (
                SELECT c."productId",
                       COUNT(*) AS carton_total,
                       COUNT(*) FILTER (WHERE c.status = 'IN_STOCK') AS in_stock,
                       COUNT(*) FILTER (WHERE c.status = 'SHIPPED') AS shipped,
                       COUNT(*) FILTER (WHERE c.status = 'RETURNED') AS returned,
                       COUNT(*) FILTER (WHERE c.status = 'EXITED') AS exited,
                       COUNT(*) FILTER (WHERE c."isIndividual") AS individual_total,
                       COUNT(*) FILTER (WHERE c."isIndividual" AND c.status = 'IN_STOCK') AS individual_in_stock,
                       COUNT(*) FILTER (WHERE NOT c."isIndividual") AS carton_only,
                       MIN(c."createdAt") AS first_carton_at,
                       MAX(COALESCE(c."scannedOutAt", c."createdAt")) AS last_carton_at
                FROM "Carton" c
                WHERE ${cartonWhere}
                GROUP BY c."productId"
            ),
            tx_agg AS (
                SELECT t."productId",
                       SUM(t.quantity) FILTER (WHERE t.type = 'IN') AS tx_in,
                       SUM(t.quantity) FILTER (WHERE t.type = 'OUT') AS tx_out,
                       SUM(t.quantity) FILTER (WHERE t.type = 'RETURN') AS tx_return,
                       MIN(t."createdAt") AS first_tx_at,
                       MAX(t."createdAt") AS last_tx_at
                FROM "Transaction" t
                WHERE t."productId" IS NOT NULL
                  ${f.warehouseId?.trim() ? Prisma.sql`AND t."warehouseId" = ${f.warehouseId.trim()}` : Prisma.empty}
                GROUP BY t."productId"
            )
            SELECT
                p.id AS "productId",
                p.name AS "productName",
                (p."deletedAt" IS NOT NULL) AS archived,
                COALESCE(ca.carton_total, 0) AS "cartonTotal",
                COALESCE(ca.in_stock, 0) AS "inStock",
                COALESCE(ca.shipped, 0) AS shipped,
                COALESCE(ca.returned, 0) AS returned,
                COALESCE(ca.exited, 0) AS exited,
                COALESCE(ca.individual_total, 0) AS "individualTotal",
                COALESCE(ca.individual_in_stock, 0) AS "individualInStock",
                ta.tx_in AS "txIn",
                ta.tx_out AS "txOut",
                ta.tx_return AS "txReturn",
                LEAST(COALESCE(ca.first_carton_at, ta.first_tx_at), COALESCE(ta.first_tx_at, ca.first_carton_at)) AS "firstEntryAt",
                GREATEST(COALESCE(ca.last_carton_at, ta.last_tx_at), COALESCE(ta.last_tx_at, ca.last_carton_at)) AS "lastActivityAt",
                COUNT(*) OVER() AS total
            FROM "Product" p
            LEFT JOIN carton_agg ca ON ca."productId" = p.id
            LEFT JOIN tx_agg ta ON ta."productId" = p.id
            WHERE (ca."productId" IS NOT NULL OR ta."productId" IS NOT NULL)
              ${whereSql}
            ORDER BY "lastActivityAt" DESC NULLS LAST, p.name ASC
            LIMIT ${pageSize} OFFSET ${(page - 1) * pageSize}
        `;

        const total = Number(rows[0]?.total ?? 0);
        return {
            rows: rows.map((r) => ({
                productId: r.productId,
                productName: r.productName,
                archived: r.archived,
                cartonTotal: Number(r.cartonTotal),
                inStock: Number(r.inStock),
                shipped: Number(r.shipped),
                returned: Number(r.returned),
                exited: Number(r.exited),
                individualTotal: Number(r.individualTotal),
                individualInStock: Number(r.individualInStock),
                txIn: r.txIn == null ? null : Number(r.txIn),
                txOut: r.txOut == null ? null : Number(r.txOut),
                txReturn: r.txReturn == null ? null : Number(r.txReturn),
                firstEntryAt: r.firstEntryAt,
                lastActivityAt: r.lastActivityAt,
            })),
            pagination: { page, pageSize, total, hasMore: page * pageSize < total },
        };
    },

    /** سابقهٔ کامل یک محصول — کارت‌ها با سریال/سفارش/مشتری + تراکنش‌ها + جابه‌جایی/خروج */
    detail: async (
        productId: string,
        opts: { warehouseId?: string; modelId?: string; activityDate?: string } = {},
    ) => {
        const product = await prisma.product.findUnique({
            where: { id: productId },
            include: {
                models: {
                    select: { id: true, name: true, unitsPerBox: true, packageType: true, deletedAt: true },
                    orderBy: { name: 'asc' },
                },
            },
        });
        if (!product) return null;

        // فیلترِ «فقط این روز» — کارتنی که همان روز وارد یا خارج شده
        const dayRange = dayRangeOf(opts.activityDate);

        const cartonWhere: Prisma.CartonWhereInput = {
            productId,
            ...(opts.modelId ? { modelId: opts.modelId } : {}),
            ...(opts.warehouseId ? { warehouseId: opts.warehouseId } : {}),
            ...(dayRange
                ? {
                      OR: [
                          { createdAt: { gte: dayRange.start, lt: dayRange.end } },
                          { scannedOutAt: { gte: dayRange.start, lt: dayRange.end } },
                      ],
                  }
                : {}),
        };

        const [cartons, transactions, transfers] = await prisma.$transaction([
            prisma.carton.findMany({
                where: cartonWhere,
                orderBy: { createdAt: 'desc' },
                take: DETAIL_CARTON_CAP,
                include: {
                    model: { select: { name: true } },
                    warehouse: { select: { name: true } },
                    order: {
                        select: {
                            id: true,
                            orderNumber: true,
                            status: true,
                            senderName: true,
                            receiverName: true,
                            customerPhone: true,
                            city: true,
                            carrier: true,
                            createdAt: true,
                            delivery: {
                                select: { status: true, deliveredAt: true, driver: { select: { name: true } } },
                            },
                        },
                    },
                },
            }),
            prisma.transaction.findMany({
                where: {
                    productId,
                    ...(opts.warehouseId ? { warehouseId: opts.warehouseId } : {}),
                    ...(dayRange ? { createdAt: { gte: dayRange.start, lt: dayRange.end } } : {}),
                },
                orderBy: { createdAt: 'desc' },
                take: DETAIL_TX_CAP,
                include: {
                    warehouse: { select: { name: true } },
                    user: { select: { name: true } },
                },
            }),
            prisma.transfer.findMany({
                where: {
                    productId,
                    ...(opts.modelId ? { modelId: opts.modelId } : {}),
                    ...(dayRange ? { createdAt: { gte: dayRange.start, lt: dayRange.end } } : {}),
                },
                orderBy: { createdAt: 'desc' },
                take: DETAIL_TRANSFER_CAP,
                include: {
                    fromWarehouse: { select: { name: true } },
                    toWarehouse: { select: { name: true } },
                    createdBy: { select: { name: true } },
                },
            }),
        ]);

        const counts = {
            cartons: cartons.length,
            inStock: cartons.filter((c) => c.status === 'IN_STOCK').length,
            shipped: cartons.filter((c) => c.status === 'SHIPPED').length,
            returned: cartons.filter((c) => c.status === 'RETURNED').length,
            exited: cartons.filter((c) => c.status === 'EXITED').length,
            individuals: cartons.filter((c) => c.isIndividual).length,
            txIn: transactions.filter((t) => t.type === 'IN').reduce((s, t) => s + t.quantity, 0),
            txOut: transactions.filter((t) => t.type === 'OUT').reduce((s, t) => s + t.quantity, 0),
            txReturn: transactions.filter((t) => t.type === 'RETURN').reduce((s, t) => s + t.quantity, 0),
        };

        return {
            product: {
                id: product.id,
                name: product.name,
                unit: product.unit,
                archived: product.deletedAt != null,
                createdAt: product.createdAt,
                models: product.models.map((m) => ({
                    id: m.id,
                    name: m.name,
                    unitsPerBox: m.unitsPerBox,
                    packageType: m.packageType,
                    archived: m.deletedAt != null,
                })),
            },
            counts,
            cartons: cartons.map((c) => ({
                id: c.id,
                serialNumber: c.serialNumber,
                qrUuid: c.qrUuid,
                isIndividual: c.isIndividual,
                status: c.status,
                entryType: c.entryType,
                createdAt: c.createdAt,
                printedAt: c.printedAt,
                scannedOutAt: c.scannedOutAt,
                warehouseName: c.warehouse.name,
                modelName: c.model?.name ?? null,
                order: c.order
                    ? {
                          id: c.order.id,
                          orderNumber: c.order.orderNumber,
                          status: c.order.status,
                          senderName: c.order.senderName,
                          receiverName: c.order.receiverName,
                          customerPhone: c.order.customerPhone,
                          city: c.order.city,
                          carrier: c.order.carrier,
                          createdAt: c.order.createdAt,
                          deliveryStatus: c.order.delivery?.status ?? null,
                          deliveredAt: c.order.delivery?.deliveredAt ?? null,
                          driverName: c.order.delivery?.driver?.name ?? null,
                      }
                    : null,
            })),
            transactions: transactions.map((t) => ({
                id: t.id,
                type: t.type,
                quantity: t.quantity,
                productName: t.productName,
                warehouseName: t.warehouse.name,
                userName: t.user.name,
                createdAt: t.createdAt,
            })),
            transfers: transfers.map((t) => ({
                id: t.id,
                quantity: t.quantity,
                status: t.status,
                description: t.description,
                isExit: t.toWarehouseId == null,
                fromWarehouseName: t.fromWarehouse.name,
                toWarehouseName: t.toWarehouse?.name ?? null,
                createdByName: t.createdBy.name,
                createdAt: t.createdAt,
                completedAt: t.completedAt,
            })),
            truncated: {
                cartons: cartons.length >= DETAIL_CARTON_CAP,
                transactions: transactions.length >= DETAIL_TX_CAP,
                transfers: transfers.length >= DETAIL_TRANSFER_CAP,
            },
        };
    },
};
