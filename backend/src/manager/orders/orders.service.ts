import { prisma } from '../../utils/prisma';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { AppError } from '../../common/exceptions/AppError';
import type { Prisma } from '@prisma/client';

const orderInclude = {
    warehouse: { select: { name: true } },
    delivery: {
        select: { status: true, deliveredAt: true, notes: true, driver: { select: { name: true } } },
    },
    _count: { select: { badges: true } },
    items: { include: { product: { select: { name: true } } } },
} satisfies Prisma.OrderInclude;

type OrderWithRefs = Prisma.OrderGetPayload<{ include: typeof orderInclude }>;

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
        badgeCount: o._count.badges,
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

        await prisma.$transaction(async (tx) => {
            const badgeRows = senderName && receiverName
                ? Array.from({ length: items.reduce((sum, item) => sum + Math.max(1, item.quantity || 1), 0) }, (_, i) => ({
                    id: crypto.randomUUID(),
                    sequence: i + 1,
                    senderName,
                    receiverName,
                }))
                : [];

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
                            price: item.price ?? null,
                            exchangeRate: item.exchangeRate ?? null,
                        })),
                    },
                    badges: badgeRows.length ? { createMany: { data: badgeRows } } : undefined,
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
                await tx.orderItem.deleteMany({ where: { orderId: id } });
                await tx.orderItem.createMany({
                    data: data.items.map((item) => ({
                        id: crypto.randomUUID(),
                        orderId: id,
                        productId: item.productId,
                        quantity: item.quantity,
                        model: item.model || null,
                        price: item.price ?? null,
                        exchangeRate: item.exchangeRate ?? null,
                    })),
                });
            }

            // بازتولید بیجک‌ها بر اساس داده جدید
            const sender = data.senderName !== undefined ? data.senderName : existing.senderName;
            const receiver = data.receiverName !== undefined ? data.receiverName : existing.receiverName;
            await tx.badge.deleteMany({ where: { orderId: id } });
            if (sender && receiver) {
                const currentItems = data.items && data.items.length > 0
                    ? data.items
                    : await tx.orderItem.findMany({ where: { orderId: id }, select: { quantity: true } });
                const totalUnits = currentItems.reduce((sum: number, item: any) => sum + Math.max(1, item.quantity || 1), 0);
                await tx.badge.createMany({
                    data: Array.from({ length: totalUnits }, (_, i) => ({
                        id: crypto.randomUUID(),
                        orderId: id,
                        sequence: i + 1,
                        senderName: sender,
                        receiverName: receiver,
                    })),
                });
            }

            //ثبت در فعالیت‌های اخیر
            await tx.activityLog.create({
                data: {
                    type: 'order_updated',
                    label: `${existing.senderName ?? 'فرستنده'} → ${existing.receiverName ?? 'گیرنده'}`,
                    orderId: id,
                    userId: existing.createdById,
                },
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
            select: { id: true, warehouseId: true, senderName: true, receiverName: true, createdById: true },
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

            //ثبت در فعالیت‌های اخیر (حتی بعد از حذف سفارش)
            await tx.activityLog.create({
                data: {
                    type: 'order_deleted',
                    label: `${order.senderName ?? 'فرستنده'} → ${order.receiverName ?? 'گیرنده'}`,
                    orderId: id,
                    userId: order.createdById,
                },
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
