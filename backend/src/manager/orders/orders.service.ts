import { Prisma } from '@prisma/client';
import { prisma } from '../../utils/prisma';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { AppError } from '../../common/exceptions/AppError';
import { writeAudit } from '../../utils/audit';

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

export const ordersService = {
    //لیست کامل ارسالی‌ها برای مدیر — صفحه‌بندی با پیش‌فرض ۱۰۰
    listOrders: async (page = 1, pageSize = 100) => {
        const safePage = Math.max(1, Math.floor(page));
        const safeSize = Math.min(500, Math.max(1, Math.floor(pageSize)));
        const [orders, total] = await prisma.$transaction([
            prisma.order.findMany({
                orderBy: { createdAt: 'desc' },
                include: orderInclude,
                skip: (safePage - 1) * safeSize,
                take: safeSize,
            }),
            prisma.order.count(),
        ]);
        return {
            orders: orders.map(mapOrder),
            pagination: { page: safePage, pageSize: safeSize, total, hasMore: safePage * safeSize < total },
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
        receiverName?: string
    ) => {
        const orderId = crypto.randomUUID();
        const normalizedCity = city?.trim() || null;
        const normalizedPostal = normalizedCity ? (postalCode?.trim() ?? '') : null;

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

        // چک موجودی کارتنی IN_STOCK — جلوگیری از ثبت سفارش برای کالای ناموجود
        const stockRows = await prisma.$queryRaw<{ productId: string; available: number }[]>`
            SELECT c."productId",
                SUM(CASE WHEN c."isIndividual" THEN 1 ELSE COALESCE(pm."unitsPerBox", 0) END)::int AS available
            FROM "Carton" c
            LEFT JOIN "ProductModel" pm ON pm.id = c."modelId"
            WHERE c."warehouseId" = ${warehouseId} AND c.status = 'IN_STOCK'
                AND c."productId" IN (${Prisma.join(productIds)})
            GROUP BY c."productId"
        `;
        const stockMap = new Map(stockRows.map((r) => [r.productId, Number(r.available || 0)]));
        for (const item of items) {
            const available = stockMap.get(item.productId) ?? 0;
            if (available < item.quantity) {
                throw new AppError('موجودی کافی نیست', 400);
            }
        }

        await prisma.$transaction(async (tx) => {
            const totalUnits = items.reduce((sum, item) => sum + Math.max(1, item.quantity || 1), 0);

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
                    customerPhone: customerPhone || null,
                    senderName: senderName || null,
                    receiverName: receiverName || null,
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
                    badges: senderName && receiverName
                        ? { create: { count: totalUnits, senderName, receiverName } }
                        : undefined,
                },
            });

            //ثبت در فعالیت‌های اخیر + رویداد تراکنشی برای اعلان ریل‌تایم به انباردار
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
            receiverName?: string;
            version?: number;
        }
    ) => {
        const existing = await prisma.order.findUnique({ where: { id } });
        if (!existing) throw new AppError('سفارش یافت نشد', 404);
        if (data.version !== undefined && data.version !== existing.version) {
            throw new AppError('سفارش توسط کاربر دیگری تغییر کرده است — صفحه را تازه کنید', 409);
        }

        await prisma.$transaction(async (tx) => {
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
            const sender = data.senderName !== undefined ? data.senderName : existing.senderName;
            const receiver = data.receiverName !== undefined ? data.receiverName : existing.receiverName;
            await tx.badge.deleteMany({ where: { orderId: id } });
            if (sender && receiver) {
                const currentItems = data.items && data.items.length > 0
                    ? data.items
                    : await tx.orderItem.findMany({ where: { orderId: id }, select: { quantity: true } });
                const totalUnits = currentItems.reduce((sum: number, item: any) => sum + Math.max(1, item.quantity || 1), 0);
                await tx.badge.create({
                    data: { orderId: id, count: totalUnits, senderName: sender, receiverName: receiver },
                });
            }

            //ثبت در فعالیت‌های اخیر + ممیزی
            await tx.activityLog.create({
                data: {
                    type: 'order_updated',
                    label: `${existing.senderName ?? 'فرستنده'} → ${existing.receiverName ?? 'گیرنده'}`,
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
                    payload: { orderId: id, warehouseId: existing.warehouseId, updatedAt: new Date().toISOString() },
                },
            });
        });

        const order = await prisma.order.findUniqueOrThrow({ where: { id }, include: orderInclude });
        return mapOrder(order);
    },

    //حذف سفارش — فقط تا قبل از ورود به مرحله خروج
    deleteOrder: async (id: string) => {
        const order = await prisma.order.findUnique({
            where: { id },
            select: { id: true, warehouseId: true, status: true, senderName: true, receiverName: true, createdById: true },
        });
        if (!order) throw new AppError('سفارش یافت نشد', 404);

        const cartons = await prisma.carton.findMany({
            where: { orderId: id },
            select: { scannedOutAt: true },
        });
        if (cartons.some((c) => c.scannedOutAt !== null)) {
            throw new AppError('این سفارش وارد مرحلهٔ خروج کالا شده و قابل حذف نیست', 400);
        }

        const delivery = await prisma.delivery.findUnique({
            where: { orderId: id },
            select: { id: true },
        });
        if (delivery) {
            throw new AppError('این سفارش وارد مرحلهٔ ارسال شده و قابل حذف نیست', 400);
        }

        await prisma.$transaction(async (tx) => {
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

    //لیست باربری‌ها
    getCarriers: async () => {
        const filePath = resolveCarriersFile();
        const raw = fs.readFileSync(filePath, 'utf-8');
        return JSON.parse(raw);
    },

    //افزودن باربری جدید — با قفل داخل‌فرایندی دور read-modify-write
    //(برای چند نمونه، این قفل کافی نیست و باید قفل توزیع‌شده/دیتابیسی جایگزین شود)
    createCarrier: async (name: string, priority: number, phone?: string, address?: string) => {
        const filePath = resolveCarriersFile();
        return carrierFileLock.withLock(async () => {
            const carriers = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

            if (carriers.find((c: any) => c.name === name)) {
                throw new AppError('این باربری قبلاً ثبت شده است', 409);
            }

            carriers.push({ name, priority, phone, address });
            fs.writeFileSync(filePath, JSON.stringify(carriers, null, 2), 'utf-8');
            return { name, priority, phone, address };
        });
    },
};

// قفل سریال داخل‌فرایندی: دو درخواست هم‌زمان به فایل دسترسی هم‌زمان ندارند
const carrierFileLock = {
    _chain: Promise.resolve(),
    withLock<T>(fn: () => Promise<T>): Promise<T> {
        const next = this._chain.then(fn, fn);
        this._chain = next.then(() => undefined, () => undefined);
        return next;
    },
};

// مسیر فایل باربری‌ها: اول نسخهٔ اجرایی (dist)، بعد منبع (src) — در dev و prod کار می‌کند
function resolveCarriersFile(): string {
    const candidates = [
        path.join(__dirname, '..', '..', 'config', 'carriers.json'),
        path.join(process.cwd(), 'src', 'config', 'carriers.json'),
    ];
    const found = candidates.find((p) => fs.existsSync(p));
    if (!found) {
        throw new AppError('فایل باربری‌ها یافت نشد', 500);
    }
    return found;
}
