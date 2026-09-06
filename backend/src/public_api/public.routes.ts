import { Router } from 'express';
import { authenticateApiKey, requireScope } from './public.middleware';
import { publicApiController } from './public.controller';
import { rateLimit } from '../middleware/rateLimit';

const router = Router();

// کل API عمومی با کلید احراز می‌شود + سقف ترافیک ملایم به‌ازای کلید/IP
router.use(authenticateApiKey, rateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'v1' }));

// ─── داده‌ای (فقط‌خواندنی) ───
router.get('/products',      requireScope('products'),      publicApiController.products);
router.get('/inventory',     requireScope('inventory'),     publicApiController.inventory);
router.get('/orders',        requireScope('orders'),        publicApiController.orders);
router.get('/transactions',  requireScope('transactions'),  publicApiController.transactions);
router.get('/cartons',       requireScope('cartons'),       publicApiController.cartons);
router.get('/warehouses',    requireScope('warehouses'),    publicApiController.warehouses);
router.get('/carriers',      requireScope('carriers'),      publicApiController.carriers);
router.get('/deliveries',    requireScope('deliveries'),    publicApiController.deliveries);
router.get('/users',         requireScope('users'),         publicApiController.users);

export const publicApiV1Routes = router;

// ─── توضیح OpenAPI برای داشبورد/کلاینت‌ها ───
const endpoint = (scope: string, summary: string, params: string[] = []) => ({
    [`/api/v1/${scope === 'products' ? 'products' : scope}`]: {
        get: {
            summary,
            security: [{ bearerAuth: [] }],
            parameters: params.map((p) => ({ name: p, in: 'query', schema: { type: 'string' } })),
            responses: { '200': { description: 'OK' }, '401': { description: 'invalid key' }, '403': { description: 'scope missing' } },
        },
    },
});

export const openApiSpec = {
    openapi: '3.0.3',
    info: {
        title: 'MA Warehouse — Public API v1',
        version: '1.0.0',
        description: 'API فقط‌خواندنی برای سیستم‌های بیرونی (حسابداری، BI و…) — احراز با کلید ma_live_* در هدر Authorization: Bearer',
    },
    security: [{ bearerAuth: [] }],
    components: {
        securitySchemes: {
            bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'API key' },
        },
    },
    paths: {
        ...endpoint('products', 'لیست محصولات با مدل‌ها', ['q', 'page', 'pageSize']),
        ...endpoint('inventory', 'موجودی فعلی به تفکیک محصول/مدل/انبار', ['warehouseId', 'page', 'pageSize']),
        ...endpoint('orders', 'سفارش‌ها با اقلام', ['status', 'from', 'to', 'page', 'pageSize']),
        ...endpoint('transactions', 'تراکنش‌های ورود/خروج/مرجوعی', ['type', 'warehouseId', 'from', 'to', 'page', 'pageSize']),
        ...endpoint('cartons', 'کارتن‌ها با سریال', ['status', 'warehouseId', 'serial', 'page', 'pageSize']),
        ...endpoint('warehouses', 'انبارها'),
        ...endpoint('carriers', 'باربری‌ها'),
        ...endpoint('deliveries', 'تحویل‌ها', ['status', 'driverId', 'page', 'pageSize']),
        ...endpoint('users', 'کاربران فعال'),
    },
};
