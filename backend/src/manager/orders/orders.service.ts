import { Prisma, PrismaClient } from '@prisma/client';
import { prisma } from '../../utils/prisma';
import crypto from 'crypto';
import { AppError } from '../../common/exceptions/AppError';
import { writeAudit } from '../../utils/audit';
import { runSerializable } from '../../utils/serializableTx';
import { jalaliDayKey } from '../../utils/jalali';

const orderInclude = {
    warehouse: { select: { name: true } },
    delivery: {
        select: { status: true, deliveredAt: true, notes: true, driver: { select: { name: true } } },
    },
    badges: { select: { count: true } },
    items: { include: { product: { select: { name: true } } } },
} satisfies Prisma.OrderInclude;

type OrderWithRefs = Prisma.OrderGetPayload<{ include: typeof orderInclude }>;

// ⚠️ خط‌مشی دقت اعشاری (L5):
// قیمت/نرخ ارز در DB با Decimal(18,2)/(18,6) ذخیره می‌شود و اینجا فقط برای نمایش به Number
// تبدیل می‌شود — هیچ محاسبه‌ای (جمع فاکتور، ضرب در نرخ) روی مقدار تبدیل‌شده انجام نمی‌شود.
// اگر در آینده محاسبه لازم شد، باید در سطح Prisma.Decimal انجام شود و تبدیل فقط در لحظهٔ خروجی JSON باشد.
const toNumber = (v: Prisma.Decimal | null | undefined): number | null =>
    v == null ? null : Number(v);

function mapOrder(o: OrderWithRefs) {
    return {
        id: o.id,
        orderNumber: o.orderNumber,
        version: o.version,
        status: o.status,
        shippingMethod: o.shippingMethod,
        carrier: o.carrier,
        city: o.city,
        postalCode: o.postalCode,
        address: o.address,
        customerPhone: o.customerPhone,
        senderName: o.senderName,
        senderNationalId: o.senderNationalId,
        senderPhone: o.senderPhone,
        receiverName: o.receiverName,
        createdAt: o.createdAt,
        updatedAt: o.updatedAt,
        warehouseName: o.warehouse.name,
        deliveryStatus: o.delivery?.status ?? null,
        deliveredAt: o.delivery?.deliveredAt ?? null,
        notes: o.delivery?.notes ?? null,
        driverName: o.delivery?.driver?.name ?? null,
        badgeCount: o.badges?.reduce((sum, b) => sum + (b.count ?? 0), 0) ?? 0,
        items: o.items.map((i) => ({
            id: i.id,
            productId: i.productId,
            quantity: i.quantity,
            model: i.model,
            price: toNumber(i.price),
            exchangeRate: toNumber(i.exchangeRate),
            productName: i.product.name,
        })),
    };
}

export interface OrderItemInput {
    productId: string;
    quantity: number;
    model?: string | null;
    modelId?: string | null;
    price?: number | null;
    exchangeRate?: number | null;
}

// ── موجودی قابل سفارش هر محصول در یک انبار ──
// هماهنگ با منطق موجودی سراسری: محصولاتی که کارتن دارند از کارتن‌های IN_STOCK شمرده می‌شوند
// و بقیه (لِگاسی) از جمع تراکنش‌های IN−OUT همان انبار — بدون این هماهنگی،
// کالای لِگاسی با موجودی واقعی، «موجودی کافی نیست» می‌گرفت.
export const getProductStock = async (
    warehouseId: string,
    productIds: string[],
    client: Prisma.TransactionClient | PrismaClient = prisma,
): Promise<Map<string, number>> => {
    const ids = [...new Set(productIds.filter(Boolean))];
    if (ids.length === 0) return new Map();

    // محصولات دارای کارتن در این انبار (حتی بدون موجودی) → مبنای کارتن
    const cartonRows = await client.$queryRaw<{ productId: string }[]>`
        SELECT DISTINCT c."productId" as "productId"
        FROM "Carton" c
        WHERE c."warehouseId" = ${warehouseId}
    `;
    const cartonBaseProducts = new Set(cartonRows.map((r) => r.productId));

    // مجموع کارتن‌های IN_STOCK برای محصولات کارتنی
    const cartonInventory = await client.$queryRaw<{ productId: string; available: number }[]>`
        SELECT c."productId" as "productId",
            COALESCE(SUM(
                CASE
                    WHEN c."isIndividual" THEN 1
                    ELSE COALESCE(pm."unitsPerBox", 0)
                END
            ), 0)::int AS available
        FROM "Carton" c
        LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
        WHERE c."warehouseId" = ${warehouseId}
            AND c.status = 'IN_STOCK'
            AND c."productId" IN (${Prisma.join(ids)})
        GROUP BY c."productId"
    `;
    const cartonAvailable = new Map(
        cartonInventory.map((r) => [r.productId, Number(r.available || 0)]),
    );

    // تراکنش‌های لِگاسی برای محصولات بدون کارتن
    const legacyInventory = await client.$queryRaw<{ productId: string; legacyCount: number }[]>`
        SELECT t."productId" as "productId",
            COALESCE(SUM(
                CASE
                    WHEN t.type = 'IN' THEN t.quantity
                    WHEN t.type = 'OUT' THEN -t.quantity
                    ELSE 0
                END
            ), 0)::int AS "legacyCount"
        FROM "Transaction" t
        WHERE t."warehouseId" = ${warehouseId}
            AND t."productId" IN (${Prisma.join(ids)})
        GROUP BY t."productId"
    `;
    const legacyMap = new Map(
        legacyInventory.map((r) => [r.productId, Number(r.legacyCount || 0)]),
    );

    const result = new Map<string, number>();
    for (const id of ids) {
        result.set(
            id,
            cartonBaseProducts.has(id)
                ? (cartonAvailable.get(id) ?? 0)
                : (legacyMap.get(id) ?? 0),
        );
    }
    return result;
};

export type OrderStatusFilter = 'pending' | 'in_transit' | 'delivered' | 'other';

// فیلتر وضعیت برای جستجو/لیست — هماهنگ با کلیدهای موبایل (order.status + delivery.status)
export const orderStatusWhere = (status: OrderStatusFilter): Prisma.OrderWhereInput => {
    switch (status) {
        case 'pending':
            return { status: 'PENDING' };
        case 'in_transit':
            return { status: 'SHIPPED' };
        case 'delivered':
            return {
                OR: [
                    { status: 'DELIVERED' },
                    { delivery: { is: { status: 'DELIVERED' } } },
                ],
            };
        case 'other':
            return { status: { notIn: ['PENDING', 'SHIPPED', 'DELIVERED'] } };
    }
};

// آیا این سفارش اصلاً بیجک دارد؟ فقط باربری/تیپاکس (یا هر carrier غیرخالی)
// نه «شهری». برای برگه نیز برچسب باربری تعیین می‌شود.
const BADGE_SHIPPING = new Set(['باربری', 'تیپاکس']);

export function isBadgeEligible(shippingMethod: string | null | undefined, carrier?: string | null): boolean {
    const method = (shippingMethod ?? '').trim();
    if (BADGE_SHIPPING.has(method)) return true;
    // fallback: اگر carrier ثبت شده (مثلاً روشی دستی) هم بیجک ساخته شود
    return !!carrier?.trim();
}

/// عکسِ قلمِ اولِ سفارش برای برگهٔ بیجک: نام مدل + نحوهٔ بسته‌بندی و تعداد هر بسته.
/// (هر سفارش یک بیجک دارد؛ برای سفارش‌های چندقلمی، قلم اول مبنای نمایش است)
/// اگر مدل انتخاب نشده باشد (متن دستی قدیمی) فقط نام مدلِ متنی ثبت می‌شود.
async function badgeItemSnapshot(
    tx: Prisma.TransactionClient | PrismaClient,
    items: Array<{ model?: string | null; modelId?: string | null }>,
): Promise<{ modelName: string | null; packageType: string | null; unitsPerBox: number | null }> {
    const first = items[0];
    if (!first) return { modelName: null, packageType: null, unitsPerBox: null };
    const fallbackModel = first.model?.trim() || null;
    if (!first.modelId) {
        return { modelName: fallbackModel, packageType: null, unitsPerBox: null };
    }
    const model = await tx.productModel.findUnique({
        where: { id: first.modelId },
        select: { name: true, packageType: true, unitsPerBox: true },
    });
    if (!model) {
        return { modelName: fallbackModel, packageType: null, unitsPerBox: null };
    }
    return {
        modelName: model.name,
        packageType: model.packageType?.trim() || null,
        unitsPerBox: model.unitsPerBox ?? null,
    };
}

/// نام باربری که روی برگهٔ بیجک می‌آید: تیپاکس → «تیپاکس»، باربری → carrier ثبت‌شده
/// (برای باربری، carrier می‌تواند null → fallback همان روش)
export function badgeCarrierLabel(shippingMethod: string | null | undefined, carrier?: string | null): string {
    const method = (shippingMethod ?? '').trim();
    if (method === 'تیپاکس') return 'تیپاکس';
    if (method === 'باربری') return carrier?.trim() || 'باربری';
    return carrier?.trim() || method || '—';
}

/// اعتبارسنجی فیلدهای اجباری تیپاکس — هم در ثبت و هم ویرایش اعمال می‌شود
/// تا از پاسخ‌های دور زدن فرم (API مستقیم) جلوگیری شود.
function validateTipax(shippingMethod: string | null | undefined, data: {
    senderNationalId?: string | null;
    senderPhone?: string | null;
    receiverName?: string | null;
    customerPhone?: string | null;
    city?: string | null;
    address?: string | null;
    postalCode?: string | null;
}): void {
    const method = (shippingMethod ?? '').trim();
    if (method !== 'تیپاکس') return;

    const nationalId = (data.senderNationalId ?? '').trim();
    if (!/^\d{10}$/.test(nationalId)) {
        throw new AppError('برای تیپاکس، کد ملی فرستنده (۱۰ رقم) الزامی است', 400);
    }
    if (!(data.senderPhone ?? '').trim()) {
        throw new AppError('برای تیپاکس، شمارهٔ تماس فرستنده الزامی است', 400);
    }
    if (!(data.receiverName ?? '').trim()) {
        throw new AppError('برای تیپاکس، نام گیرنده الزامی است', 400);
    }
    if (!(data.customerPhone ?? '').trim()) {
        throw new AppError('برای تیپاکس، شمارهٔ تماس گیرنده الزامی است', 400);
    }
    if (!(data.city ?? '').trim()) {
        throw new AppError('برای تیپاکس، شهر گیرنده الزامی است', 400);
    }
    if (!(data.address ?? '').trim()) {
        throw new AppError('برای تیپاکس، آدرس دقیق گیرنده الزامی است', 400);
    }
    if (!(data.postalCode ?? '').trim()) {
        throw new AppError('برای تیپاکس، کد پستی الزامی است', 400);
    }
}

export const ordersService = {
    //لیست کامل ارسالی‌ها برای مدیر — صفحه‌بندی با پیش‌فرض ۱۰۰ + شمارندهٔ وضعیت‌ها (هماهنگ با موبایل)
    listOrders: async (page = 1, pageSize = 100, status?: OrderStatusFilter) => {
        const safePage = Math.max(1, Math.floor(page));
        const safeSize = Math.min(500, Math.max(1, Math.floor(pageSize)));
        const where = status ? orderStatusWhere(status) : undefined;
        const [orders, total, countRows] = await prisma.$transaction([
            prisma.order.findMany({
                where,
                orderBy: { createdAt: 'desc' },
                include: orderInclude,
                skip: (safePage - 1) * safeSize,
                take: safeSize,
            }),
            prisma.order.count({ where }),
            prisma.$queryRaw<{ key: string; count: number }[]>`
                SELECT
                    CASE
                        WHEN d.status = 'DELIVERED' OR o.status = 'DELIVERED' THEN 'delivered'
                        WHEN d.status = 'IN_TRANSIT' OR o.status = 'SHIPPED' THEN 'in_transit'
                        WHEN o.status = 'PENDING' THEN 'pending'
                        ELSE 'other'
                    END as "key",
                    COUNT(*)::int as "count"
                FROM "Order" o
                LEFT JOIN "Delivery" d ON d."orderId" = o.id
                GROUP BY 1
            `,
        ]);
        const counts = { total, pending: 0, inTransit: 0, delivered: 0, other: 0 };
        for (const row of countRows) {
            const key = (row.key === 'in_transit' ? 'inTransit' : row.key) as keyof typeof counts;
            if (key in counts) counts[key] = Number(row.count || 0);
        }
        return {
            orders: orders.map(mapOrder),
            pagination: { page: safePage, pageSize: safeSize, total, hasMore: safePage * safeSize < total },
            counts,
        };
    },

    //ثبت سفارش خروجی
    createOrder: async (
        warehouseId: string,
        createdById: string,
        items: OrderItemInput[],
        shippingMethod: string,
        carrier?: string,
        city?: string,
        postalCode?: string,
        address?: string,
        customerPhone?: string,
        senderName?: string,
        receiverName?: string,
        senderNationalId?: string,
        senderPhone?: string
    ) => {
        const orderId = crypto.randomUUID();
        const normalizedCity = city?.trim() || null;
        const normalizedPostal = normalizedCity ? (postalCode?.trim() ?? '') : null;

        // فیلدهای اجباری تیپاکس — قبل از هر عملیات تا از دور زدن فرم جلوگیری شود
        validateTipax(shippingMethod, {
            senderNationalId, senderPhone, receiverName, customerPhone, city, address, postalCode,
        });

        // customerPhone در اسکیما اجباری است (String غیرنال) — به‌جای خطای ۵۰۰ دیتابیس، ۴۰۰ واضح
        const normalizedPhone = (customerPhone ?? '').trim();
        if (!normalizedPhone) {
            throw new AppError('شمارهٔ تماس گیرنده الزامی است', 400);
        }

        // اعتبارسنجی پیشینی: انبار و همه‌ی محصولات باید واقعاً وجود داشته باشند —
        // به‌جای خطای FK مبهم (P2003) پیام مشخص بده
        const warehouseExists = await prisma.warehouse.findUnique({
            where: { id: warehouseId },
            select: { id: true },
        });
        if (!warehouseExists) {
            throw new AppError('انبار یافت نشد', 400);
        }
        const productIds = [...new Set(items.map((item) => item.productId))];
        if (productIds.length === 0) {
            throw new AppError('سفارش باید حداقل یک قلم کالا داشته باشد', 400);
        }
        const foundProducts = await prisma.product.findMany({
            where: { id: { in: productIds } },
            select: { id: true },
        });
        const foundSet = new Set(foundProducts.map((p) => p.id));
        const missing = productIds.filter((id) => !foundSet.has(id));
        if (missing.length > 0) {
            throw new AppError('محصول یافت نشد', 400);
        }

        // اعتبارسنجی تعلق modelId به productId (مثل منطق checkin)
        const modelIds = [...new Set(items.map((it) => it.modelId).filter((v): v is string => !!v))];
        if (modelIds.length > 0) {
            const foundModels = await prisma.productModel.findMany({
                where: { id: { in: modelIds } },
                select: { id: true, productId: true },
            });
            const modelMap = new Map(foundModels.map((m) => [m.id, m.productId]));
            for (const item of items) {
                if (item.modelId && modelMap.get(item.modelId) !== item.productId) {
                    throw new AppError('مدل انتخاب‌شده متعلق به این محصول نیست', 400);
                }
            }
        }

        // چک موجودی + ثبت — داخل یک تراکنش Serializable تا دو ثبت هم‌زمان نتوانند
        // بیش از موجودی واقعی سفارش بدهند (تعارض هم‌زمانی با P2034 → retry خودکار).
        // شمارهٔ روزانه از OrderDaySequence با upsert اتمی می‌آید (نه count+1) تا
        // ۱۰۰ انبار در پیک روی یک کلید روز قفل/ریترای نشوند.
        await runSerializable(async (tx) => {
            const stockMap = await getProductStock(warehouseId, productIds, tx);
            for (const item of items) {
                const available = stockMap.get(item.productId) ?? 0;
                if (available < item.quantity) {
                    throw new AppError(`موجودی کافی نیست (موجودی: ${available})`, 400);
                }
            }

            // شمارهٔ روزانهٔ سفارش — هر روزِ شمسی (orderDay) شماره از ۱ شروع می‌شود.
            // upsert اتمی روی ردیف همان روز: هم‌زمان‌ها صف می‌شوند، شماره یکتا تضمینی است.
            const orderDay = jalaliDayKey(new Date());
            const seq = await tx.orderDaySequence.upsert({
                where: { day: orderDay },
                update: { lastNumber: { increment: 1 } },
                create: { day: orderDay, lastNumber: 1 },
            });
            const orderNumber = seq.lastNumber;

            const totalUnits = items.reduce((sum, item) => sum + Math.max(1, item.quantity || 1), 0);
            const itemSnapshot = await badgeItemSnapshot(tx, items);

            await tx.order.create({
                data: {
                    id: orderId,
                    warehouseId,
                    createdById,
                    status: 'PENDING',
                    shippingMethod,
                    carrier: carrier || null,
                    city: normalizedCity,
                    postalCode: normalizedPostal,
                    address: address || null,
                    customerPhone: normalizedPhone,
                    senderName: senderName || null,
                    senderNationalId: senderNationalId?.trim() || null,
                    senderPhone: senderPhone?.trim() || null,
                    receiverName: receiverName || null,
                    orderNumber,
                    orderDay,
                    items: {
                        create: items.map((item) => ({
                            id: crypto.randomUUID(),
                            productId: item.productId,
                            quantity: item.quantity,
                            model: item.model || null,
                            modelId: item.modelId || null,
                            price: item.price ?? null,
                            exchangeRate: item.exchangeRate ?? null,
                        })),
                    },
                    badges: isBadgeEligible(shippingMethod, carrier) && senderName && receiverName
                        ? {
                            create: {
                                count: totalUnits,
                                modelName: itemSnapshot.modelName,
                                packageType: itemSnapshot.packageType,
                                unitsPerBox: itemSnapshot.unitsPerBox,
                                senderName,
                                senderPhone: senderPhone?.trim() || null,
                                senderNationalId: senderNationalId?.trim() || null,
                                receiverName,
                                receiverCity: normalizedCity,
                                receiverPostalCode: normalizedPostal,
                                receiverAddress: address || null,
                                receiverPhone: normalizedPhone,
                            },
                        }
                        : undefined,
                },
            });

            // ثبت در فعالیت‌های اخیر + رویداد تراکنشی برای اعلان ریل‌تایم به انباردار
            await tx.activityLog.create({
                data: {
                    type: 'order_created',
                    label: `${senderName ?? 'فرستنده'} → ${receiverName ?? 'گیرنده'}`,
                    orderId,
                    userId: createdById,
                },
            });
            await tx.outboxEvent.create({
                data: {
                    aggregate: 'order',
                    type: 'order:created',
                    payload: {
                        orderId,
                        warehouseId,
                        senderName: senderName ?? null,
                        receiverName: receiverName ?? null,
                        createdAt: new Date().toISOString(),
                    },
                },
            });
        });

        const order = await prisma.order.findUniqueOrThrow({ where: { id: orderId }, include: orderInclude });
        return mapOrder(order);
    },

    //ویرایش سفارش — اطلاعات ارسال + اقلام + بازتولید بیجک
    updateOrder: async (
        id: string,
        data: {
            items?: OrderItemInput[];
            shippingMethod?: string;
            carrier?: string;
            city?: string;
            postalCode?: string;
            address?: string;
            customerPhone?: string;
            senderName?: string;
            senderNationalId?: string;
            senderPhone?: string;
            receiverName?: string;
            version?: number;
        }
    ) => {
        const existing = await prisma.order.findUnique({ where: { id } });
        if (!existing) throw new AppError('سفارش یافت نشد', 404);
        if (data.version !== undefined && data.version !== existing.version) {
            throw new AppError('سفارش توسط کاربر دیگری تغییر کرده است — صفحه را تازه کنید', 409);
        }

        // فیلدهای اجباری تیپاکس با مقادیر مؤثر (جدید یا موجود)
        const effShipping = data.shippingMethod ?? existing.shippingMethod;
        validateTipax(effShipping, {
            senderNationalId: data.senderNationalId !== undefined ? data.senderNationalId : existing.senderNationalId,
            senderPhone: data.senderPhone !== undefined ? data.senderPhone : existing.senderPhone,
            receiverName: data.receiverName !== undefined ? data.receiverName : existing.receiverName,
            customerPhone: data.customerPhone !== undefined ? data.customerPhone : existing.customerPhone,
            city: data.city !== undefined ? data.city : existing.city,
            address: data.address !== undefined ? data.address : existing.address,
            postalCode: data.postalCode !== undefined ? data.postalCode : existing.postalCode,
        });

        await runSerializable(async (tx) => {
            // قفل خوشبینانه: فقط اگر نسخه هنوز همان است، به‌روزرسانی می‌شود
            const updated = await tx.order.updateMany({
                where: { id, ...(data.version !== undefined ? { version: data.version } : {}) },
                data: {
                    shippingMethod: data.shippingMethod ?? existing.shippingMethod,
                    carrier: data.carrier !== undefined ? data.carrier : existing.carrier,
                    city: data.city !== undefined ? (data.city?.trim() || null) : existing.city,
                    postalCode: (() => {
                        const newCity = data.city !== undefined ? (data.city?.trim() || null) : existing.city;
                        const newPostal = data.postalCode !== undefined ? data.postalCode : existing.postalCode;
                        return newCity ? (newPostal?.trim() ?? '') : null;
                    })(),
                    address: data.address !== undefined ? data.address : existing.address,
                    customerPhone: data.customerPhone !== undefined ? data.customerPhone : existing.customerPhone,
                    senderName: data.senderName !== undefined ? data.senderName : existing.senderName,
                    senderNationalId: data.senderNationalId !== undefined ? (data.senderNationalId?.trim() || null) : existing.senderNationalId,
                    senderPhone: data.senderPhone !== undefined ? (data.senderPhone?.trim() || null) : existing.senderPhone,
                    receiverName: data.receiverName !== undefined ? data.receiverName : existing.receiverName,
                    updatedAt: new Date(),
                    version: { increment: 1 },
                },
            });
            if (updated.count !== 1) {
                throw new AppError('سفارش توسط کاربر دیگری تغییر کرده است — صفحه را تازه کنید', 409);
            }

            // بازنویسی اقلام
            if (data.items && data.items.length > 0) {
                // قفل ویرایش اقلام: اگر سفارش از PENDING عبور کرده یا کارتن خروج‌خورده دارد، اقلام قابل ویرایش نیستند
                const shipped = await tx.carton.count({
                    where: { orderId: id, scannedOutAt: { not: null } },
                });
                if (existing.status !== 'PENDING' || shipped > 0) {
                    throw new AppError('این سفارش وارد مرحلهٔ خروج شده و اقلام آن قابل ویرایش نیست', 400);
                }

                // اعتبارسنجی مانند createOrder: وجود محصولات + تعلق modelId + موجودی کافی
                const productIds = [...new Set(data.items.map((item) => item.productId))];
                const foundProducts = await prisma.product.findMany({
                    where: { id: { in: productIds } },
                    select: { id: true },
                });
                const foundSet = new Set(foundProducts.map((p) => p.id));
                if (productIds.some((id) => !foundSet.has(id))) {
                    throw new AppError('محصول یافت نشد', 400);
                }
                const modelIds = [...new Set(data.items.map((it) => it.modelId).filter((v): v is string => !!v))];
                if (modelIds.length > 0) {
                    const foundModels = await prisma.productModel.findMany({
                        where: { id: { in: modelIds } },
                        select: { id: true, productId: true },
                    });
                    const modelMap = new Map(foundModels.map((m) => [m.id, m.productId]));
                    for (const item of data.items) {
                        if (item.modelId && modelMap.get(item.modelId) !== item.productId) {
                            throw new AppError('مدل انتخاب‌شده متعلق به این محصول نیست', 400);
                        }
                    }
                }
                const stockMap = await getProductStock(existing.warehouseId, productIds, tx);
                for (const item of data.items) {
                    const available = stockMap.get(item.productId) ?? 0;
                    if (available < item.quantity) {
                        throw new AppError(`موجودی کافی نیست (موجودی: ${available})`, 400);
                    }
                }

                await tx.orderItem.deleteMany({ where: { orderId: id } });
                await tx.orderItem.createMany({
                    data: data.items.map((item) => ({
                        id: crypto.randomUUID(),
                        orderId: id,
                        productId: item.productId,
                        quantity: item.quantity,
                        model: item.model || null,
                        modelId: item.modelId || null,
                        price: item.price ?? null,
                        exchangeRate: item.exchangeRate ?? null,
                    })),
                });
            }

            // بازتولید بیجک بر اساس داده جدید (یک ردیف با count)
            // فقط باربری/تیپاکس بیجک می‌گیرد (نه «شهری»)
            const sender = data.senderName !== undefined ? data.senderName : existing.senderName;
            const receiver = data.receiverName !== undefined ? data.receiverName : existing.receiverName;
            const effCarrier = data.carrier !== undefined ? data.carrier : existing.carrier;
            const effCity = data.city !== undefined ? (data.city?.trim() || null) : existing.city;
            const effPostal = (() => {
                const newCity = data.city !== undefined ? (data.city?.trim() || null) : existing.city;
                const newPostal = data.postalCode !== undefined ? data.postalCode : existing.postalCode;
                return newCity ? (newPostal?.trim() ?? '') : null;
            })();
            const effSenderPhone = data.senderPhone !== undefined ? (data.senderPhone?.trim() || null) : existing.senderPhone;
            const effSenderNationalId = data.senderNationalId !== undefined ? (data.senderNationalId?.trim() || null) : existing.senderNationalId;
            await tx.badge.deleteMany({ where: { orderId: id } });
            if (isBadgeEligible(effShipping, effCarrier) && sender && receiver) {
                const currentItems = data.items && data.items.length > 0
                    ? data.items
                    : await tx.orderItem.findMany({
                        where: { orderId: id },
                        select: { quantity: true, model: true, modelId: true },
                    });
                const totalUnits = currentItems.reduce((sum: number, item: any) => sum + Math.max(1, item.quantity || 1), 0);
                const itemSnapshot = await badgeItemSnapshot(tx, currentItems);
                await tx.badge.create({
                    data: {
                        orderId: id,
                        count: totalUnits,
                        modelName: itemSnapshot.modelName,
                        packageType: itemSnapshot.packageType,
                        unitsPerBox: itemSnapshot.unitsPerBox,
                        senderName: sender,
                        senderPhone: effSenderPhone,
                        senderNationalId: effSenderNationalId,
                        receiverName: receiver,
                        receiverCity: effCity,
                        receiverPostalCode: effPostal,
                        receiverAddress: data.address !== undefined ? data.address : existing.address,
                        receiverPhone: data.customerPhone !== undefined ? data.customerPhone : existing.customerPhone,
                    },
                });
            }

            //ثبت در فعالیت‌های اخیر + ممیزی (با نام‌های مؤثرِ جدید، نه قدیمی)
            await tx.activityLog.create({
                data: {
                    type: 'order_updated',
                    label: `${sender ?? 'فرستنده'} → ${receiver ?? 'گیرنده'}`,
                    orderId: id,
                    userId: existing.createdById,
                },
            });
            await writeAudit(tx, {
                actorId: existing.createdById, action: 'order.update', entity: 'Order', entityId: id,
                before: { status: existing.status }, after: { status: existing.status, updatedAt: new Date().toISOString() },
            });
            await tx.outboxEvent.create({
                data: {
                    aggregate: 'order',
                    type: 'order:updated',
                    payload: {
                        orderId: id,
                        warehouseId: existing.warehouseId,
                        senderName: existing.senderName ?? null,
                        receiverName: existing.receiverName ?? null,
                        updatedAt: new Date().toISOString(),
                    },
                },
            });
        });

        const order = await prisma.order.findUniqueOrThrow({ where: { id }, include: orderInclude });
        return mapOrder(order);
    },

    //حذف سفارش — فقط تا قبل از ورود به مرحله خروج
    //چک‌ها داخل تراکنش Serializable هستند تا scan-out هم‌زمان نتواند بین چک و حذف بچسبد
    deleteOrder: async (id: string) => {
        const order = await prisma.order.findUnique({
            where: { id },
            select: { id: true, warehouseId: true, status: true, senderName: true, receiverName: true, createdById: true },
        });
        if (!order) throw new AppError('سفارش یافت نشد', 404);

        await runSerializable(async (tx) => {
            const cartons = await tx.carton.findMany({
                where: { orderId: id },
                select: { scannedOutAt: true },
            });
            if (cartons.some((c) => c.scannedOutAt !== null)) {
                throw new AppError('این سفارش وارد مرحلهٔ خروج کالا شده و قابل حذف نیست', 400);
            }

            const delivery = await tx.delivery.findUnique({
                where: { orderId: id },
                select: { id: true },
            });
            if (delivery) {
                throw new AppError('این سفارش وارد مرحلهٔ ارسال شده و قابل حذف نیست', 400);
            }

            await tx.carton.updateMany({ where: { orderId: id }, data: { orderId: null } });
            // حذف سفارش؛ اقلام، بیجک‌ها و ارسال با CASCADE پاک می‌شوند
            await tx.order.delete({ where: { id } });

            //ثبت در فعالیت‌های اخیر + ممیزی (حتی بعد از حذف سفارش)
            await tx.activityLog.create({
                data: {
                    type: 'order_deleted',
                    label: `${order.senderName ?? 'فرستنده'} → ${order.receiverName ?? 'گیرنده'}`,
                    orderId: id,
                    userId: order.createdById,
                },
            });
            await writeAudit(tx, {
                actorId: order.createdById, action: 'order.delete', entity: 'Order', entityId: id,
                before: { status: order.status, senderName: order.senderName, receiverName: order.receiverName },
                after: null,
            });
            await tx.outboxEvent.create({
                data: {
                    aggregate: 'order',
                    type: 'order:deleted',
                    payload: {
                        orderId: id,
                        warehouseId: order.warehouseId,
                        senderName: order.senderName ?? null,
                        receiverName: order.receiverName ?? null,
                    },
                },
            });
        });
    },

    //موجودی قابل سفارش محصولات مشخص در یک انبار — برای فرم ثبت سفارش
    getOrderStock: async (warehouseId: string, productIds: string[]) => {
        const warehouse = await prisma.warehouse.findUnique({
            where: { id: warehouseId },
            select: { id: true },
        });
        if (!warehouse) return null;
        const stock = await getProductStock(warehouseId, productIds);
        return Array.from(stock.entries()).map(([productId, available]) => ({
            productId,
            available,
        }));
    },

    //لیست باربری‌ها — از جدول دیتابیس (مدیریت با پنل انباردار)
    getCarriers: async () => {
        return prisma.carrier.findMany({
            orderBy: [{ priority: 'asc' }, { name: 'asc' }],
        });
    },

    //افزودن باربری جدید — نام یکتا است؛ تداخل → 409 دوستانه
    createCarrier: async (name: string, priority: number, phone?: string, address?: string) => {
        try {
            return await prisma.carrier.create({
                data: {
                    name,
                    priority,
                    phone: phone?.trim() || null,
                    address: address?.trim() || null,
                },
            });
        } catch (e: any) {
            if (e?.code === 'P2002') {
                throw new AppError('این باربری قبلاً ثبت شده است', 409);
            }
            throw e;
        }
    },
};
