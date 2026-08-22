import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth';
import { requireActiveWarehouse } from '../middleware/requireActiveWarehouse';
import { userRateLimit } from '../middleware/rateLimit';
import { validate } from '../middleware/validate';
import { submitCheckinSchema } from './checkin/checkin.schema';
import { scanOutSchema } from './scanout/scanout.schema';
import { warehouseController } from './warehouse/warehouse.controller';
import { checkinController } from './checkin/checkin.controller';
import { scanOutController } from './scanout/scanout.controller';
import { loadingPlanController } from './loadingplan/loadingplan.controller';
import { qrcodeController } from './qrcode/qrcode.controller';
import { labelsController } from './labels/labels.controller';
const router = Router();

router.use(authenticate, authorize('WAREHOUSE_KEEPER'), requireActiveWarehouse);

// ── Warehouse ──
router.get('/my-warehouse',           warehouseController.getMyWarehouse);
router.get('/orders',                 warehouseController.getOrders);
router.get('/inventory',              warehouseController.getInventory);
router.get('/inventory-summary',      userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:invsum' }), warehouseController.getInventorySummary);
router.get('/inventory/products',     warehouseController.getProductInventory);
router.get('/inventory/product/:productId', warehouseController.getProductModels);
router.get('/transactions',           warehouseController.getTransactions);
router.get('/products',               warehouseController.getProducts);

// ── Search (limited to own warehouse) ──
router.get('/search/serial', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'w:ss' }), warehouseController.searchBySerial);
router.get('/search/shipments', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'w:ssh' }), warehouseController.searchShipments);

// ── QR Template ──
router.get('/qr-template',            qrcodeController.getTemplate);

// ── Check-in ──
router.post('/checkin', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:checkin' }), validate(submitCheckinSchema), checkinController.submit);
router.get('/checkin/recent', checkinController.listRecent);

// ── Shipped cartons ──
router.get('/cartons/shipped', scanOutController.listShipped);
router.get('/orders/:id/cartons', scanOutController.listOrderCartons);

// ── Scan-out ──
router.post('/scan-out', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'w:scanout' }), validate(scanOutSchema), scanOutController.scan);

// ── دستورات جابه‌جایی/خروج مدیر (دوفازی) — برای اجرا با اسکن ──
router.get('/transfers', warehouseController.listPendingTransfers);

// ── Loading plan ──
router.post('/loading-plan',          loadingPlanController.generate);

// ── Labels for print panel ──
router.get('/labels',                 labelsController.getLabels);

export const warehouseRoutes = router;