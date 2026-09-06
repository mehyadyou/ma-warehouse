import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { asyncHandler } from '../middleware/asyncHandler';

/// سقف صفحه — جلوگیری از بار سنگین روی DB
const MAX_PAGE_SIZE = 100;
const DEFAULT_PAGE_SIZE = 25;

function pagination(req: Request) {
    const page = Math.max(1, Number(req.query.page) || 1);
    const pageSize = Math.min(MAX_PAGE_SIZE, Math.max(1, Number(req.query.pageSize) || DEFAULT_PAGE_SIZE));
    return { skip: (page - 1) * pageSize, take: pageSize, page, pageSize };
}

function paginated(res: Response, data: unknown[], total: number, page: number, pageSize: number) {
    res.set('Cache-Control', 'public, max-age=30');
    res.json({
        data,
        meta: {
            total,
            page,
            pageSize,
            totalPages: Math.ceil(total / pageSize) || 1,
        },
    });
}

export const publicApiController = {
    /// GET /api/v1/products?q=&page=&pageSize= — شامل مدل‌ها
    products: asyncHandler(async (req: Request, res: Response) => {
        const { skip, take, page, pageSize } = pagination(req);
        const q = typeof req.query.q === 'string' ? req.query.q.trim() : '';
        const where = {
            deletedAt: null,
            ...(q ? { name: { contains: q, mode: 'insensitive' as const } } : {}),
        };
        const [data, total] = await Promise.all([
            prisma.product.findMany({
                where,
                skip,
                take,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true, name: true, unit: true, createdAt: true, updatedAt: true,
                    models: {
                        where: { deletedAt: null },
                        select: { id: true, name: true, price: true, packageType: true, unitsPerBox: true },
                    },
                },
            }),
            prisma.product.count({ where }),
        ]);
        paginated(res, data, total, page, pageSize);
    }),

    /// GET /api/v1/inventory?warehouseId= — موجودی فعلی هر محصول/مدل
    inventory: asyncHandler(async (req: Request, res: Response) => {
        const { skip, take, page, pageSize } = pagination(req);
        const warehouseId = typeof req.query.warehouseId === 'string' ? req.query.warehouseId : undefined;
        const where = {
            status: 'IN_STOCK' as const,
            ...(warehouseId ? { warehouseId } : {}),
        };
        // گروه‌بندی بر اساس محصول+مدل
        const grouped = await prisma.carton.groupBy({
            by: ['productId', 'modelId', 'warehouseId'],
            where,
            _count: { _all: true },
            skip,
            take,
            orderBy: { _count: { productId: 'desc' } },
        });
        const totalRow = await prisma.carton.groupBy({
            by: ['productId', 'modelId', 'warehouseId'],
            where,
            _count: { _all: true },
        });

        const productIds = [...new Set(grouped.map((g) => g.productId))];
        const modelIds = grouped.map((g) => g.modelId).filter((v): v is string => !!v);
        const [products, models, warehouses] = await Promise.all([
            prisma.product.findMany({ where: { id: { in: productIds } }, select: { id: true, name: true, unit: true } }),
            modelIds.length ? prisma.productModel.findMany({ where: { id: { in: modelIds } }, select: { id: true, name: true } }) : Promise.resolve([]),
            prisma.warehouse.findMany({ where: { id: { in: grouped.map((g) => g.warehouseId) } }, select: { id: true, name: true } }),
        ]);
        const pName = new Map(products.map((p) => [p.id, p.name]));
        const mName = new Map(models.map((m) => [m.id, m.name]));
        const wName = new Map(warehouses.map((w) => [w.id, w.name]));

        const data = grouped.map((g) => ({
            productId: g.productId,
            productName: pName.get(g.productId) ?? null,
            modelId: g.modelId,
            modelName: g.modelId ? mName.get(g.modelId) ?? null : null,
            warehouseId: g.warehouseId,
            warehouseName: wName.get(g.warehouseId) ?? null,
            quantity: g._count._all,
        }));
        paginated(res, data, totalRow.length, page, pageSize);
    }),

    /// GET /api/v1/orders?status=&from=&to=&page= — سفارش‌ها با اقلام
    orders: asyncHandler(async (req: Request, res: Response) => {
        const { skip, take, page, pageSize } = pagination(req);
        const where = {
            ...(req.query.status && ['PENDING', 'SHIPPED', 'DELIVERED', 'CANCELED'].includes(String(req.query.status))
                ? { status: String(req.query.status) as 'PENDING' | 'SHIPPED' | 'DELIVERED' | 'CANCELED' }
                : {}),
            ...(req.query.from || req.query.to
                ? {
                    createdAt: {
                        ...(req.query.from ? { gte: new Date(String(req.query.from)) } : {}),
                        ...(req.query.to ? { lte: new Date(String(req.query.to)) } : {}),
                    },
                }
                : {}),
        };
        const [data, total] = await Promise.all([
            prisma.order.findMany({
                where,
                skip,
                take,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true, orderNumber: true, orderDay: true, status: true,
                    shippingMethod: true, carrier: true, city: true,
                    customerPhone: true, receiverName: true, createdAt: true, updatedAt: true,
                    warehouse: { select: { id: true, name: true } },
                    items: {
                        select: {
                            productId: true, quantity: true, model: true, price: true,
                            product: { select: { name: true } },
                        },
                    },
                },
            }),
            prisma.order.count({ where }),
        ]);
        paginated(res, data, total, page, pageSize);
    }),

    /// GET /api/v1/transactions?type=&from=&to=&warehouseId= — تراکنش‌ها
    transactions: asyncHandler(async (req: Request, res: Response) => {
        const { skip, take, page, pageSize } = pagination(req);
        const where = {
            ...(req.query.type && ['IN', 'OUT', 'RETURN'].includes(String(req.query.type))
                ? { type: String(req.query.type) as 'IN' | 'OUT' | 'RETURN' }
                : {}),
            ...(typeof req.query.warehouseId === 'string' ? { warehouseId: String(req.query.warehouseId) } : {}),
            ...(req.query.from || req.query.to
                ? {
                    createdAt: {
                        ...(req.query.from ? { gte: new Date(String(req.query.from)) } : {}),
                        ...(req.query.to ? { lte: new Date(String(req.query.to)) } : {}),
                    },
                }
                : {}),
        };
        const [data, total] = await Promise.all([
            prisma.transaction.findMany({
                where,
                skip,
                take,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true, type: true, productName: true, quantity: true, createdAt: true,
                    productId: true,
                    warehouse: { select: { id: true, name: true } },
                    user: { select: { id: true, name: true } },
                },
            }),
            prisma.transaction.count({ where }),
        ]);
        paginated(res, data, total, page, pageSize);
    }),

    /// GET /api/v1/cartons?status=&warehouseId=&serial= — کارتن‌ها با سریال
    cartons: asyncHandler(async (req: Request, res: Response) => {
        const { skip, take, page, pageSize } = pagination(req);
        const where = {
            ...(req.query.status && ['IN_STOCK', 'SHIPPED', 'RETURNED', 'EXITED'].includes(String(req.query.status))
                ? { status: String(req.query.status) as 'IN_STOCK' | 'SHIPPED' | 'RETURNED' | 'EXITED' }
                : {}),
            ...(typeof req.query.warehouseId === 'string' ? { warehouseId: String(req.query.warehouseId) } : {}),
            ...(typeof req.query.serial === 'string' && req.query.serial
                ? { serialNumber: { contains: String(req.query.serial) } }
                : {}),
        };
        const [data, total] = await Promise.all([
            prisma.carton.findMany({
                where,
                skip,
                take,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true, serialNumber: true, status: true, isIndividual: true,
                    entryType: true, scannedOutAt: true, printedAt: true, createdAt: true,
                    product: { select: { id: true, name: true } },
                    model: { select: { id: true, name: true } },
                    warehouse: { select: { id: true, name: true } },
                    orderId: true,
                },
            }),
            prisma.carton.count({ where }),
        ]);
        paginated(res, data, total, page, pageSize);
    }),

    /// GET /api/v1/warehouses
    warehouses: asyncHandler(async (_req: Request, res: Response) => {
        const data = await prisma.warehouse.findMany({
            where: { deletedAt: null },
            select: { id: true, name: true, address: true, createdAt: true },
            orderBy: { name: 'asc' },
        });
        res.json({ data, meta: { total: data.length } });
    }),

    /// GET /api/v1/carriers
    carriers: asyncHandler(async (_req: Request, res: Response) => {
        const data = await prisma.carrier.findMany({
            select: { id: true, name: true, priority: true, phone: true, address: true },
            orderBy: { priority: 'asc' },
        });
        res.json({ data, meta: { total: data.length } });
    }),

    /// GET /api/v1/deliveries?status=&driverId= — تحویل‌ها با عکس بیجک
    deliveries: asyncHandler(async (req: Request, res: Response) => {
        const { skip, take, page, pageSize } = pagination(req);
        const where = {
            ...(req.query.status && ['IN_TRANSIT', 'DELIVERED'].includes(String(req.query.status))
                ? { status: String(req.query.status) as 'IN_TRANSIT' | 'DELIVERED' }
                : {}),
            ...(typeof req.query.driverId === 'string' ? { driverId: String(req.query.driverId) } : {}),
        };
        const [data, total] = await Promise.all([
            prisma.delivery.findMany({
                where,
                skip,
                take,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true, status: true, deliveredAt: true, notes: true, receiptUrl: true, createdAt: true,
                    driver: { select: { id: true, name: true, phone: true } },
                    order: {
                        select: {
                            id: true, orderNumber: true, carrier: true, city: true,
                            receiverName: true, customerPhone: true,
                        },
                    },
                },
            }),
            prisma.delivery.count({ where }),
        ]);
        paginated(res, data, total, page, pageSize);
    }),

    /// GET /api/v1/users — کاربران بدون دادهٔ حساس
    users: asyncHandler(async (_req: Request, res: Response) => {
        const data = await prisma.user.findMany({
            where: { deletedAt: null, isActive: true },
            select: { id: true, name: true, phone: true, role: true, warehouseId: true, createdAt: true },
            orderBy: { createdAt: 'desc' },
        });
        res.json({ data, meta: { total: data.length } });
    }),
};
