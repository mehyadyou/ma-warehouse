import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth';
import { requireActiveWarehouse } from '../middleware/requireActiveWarehouse';
import { userRateLimit } from '../middleware/rateLimit';
import { validate } from '../middleware/validate';
import { submitCheckinSchema, markPrintedSchema } from './checkin/checkin.schema';
import { scanOutSchema, manualExitSchema, assignDriverSchema as scanoutAssignDriverSchema } from './scanout/scanout.schema';
import { assignDriverSchema } from './drivers/drivers.schema';
import { createCarrierSchema, updateCarrierSchema, reorderCarriersSchema } from './carriers/carriers.schema';
import { warehouseController } from './warehouse/warehouse.controller';
import { checkinController } from './checkin/checkin.controller';
import { scanOutController } from './scanout/scanout.controller';
import { loadingPlanController } from './loadingplan/loadingplan.controller';
import { qrcodeController } from './qrcode/qrcode.controller';
import { labelsController } from './labels/labels.controller';
import { driversController } from './drivers/drivers.controller';
import { carriersController } from './carriers/carriers.controller';
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

// ── Printed cartons (لیبل‌های چاپ‌شده از پنل دسکتاپ) ──
router.get('/cartons/printed', checkinController.listPrinted);
router.post('/cartons/printed', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'w:printed' }), validate(markPrintedSchema), checkinController.markPrinted);

// ── Scan-out ──
router.post('/scan-out', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'w:scanout' }), validate(scanOutSchema), scanOutController.scan);
router.post('/scan-out/manual', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:scanout:manual' }), validate(manualExitSchema), scanOutController.manual);
router.post('/scan-out/assign-driver', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'w:scanout:driver' }), validate(scanoutAssignDriverSchema), scanOutController.assignDriver);

// ── دستورات جابه‌جایی/خروج مدیر (دوفازی) — برای اجرا با اسکن ──
router.get('/transfers', warehouseController.listPendingTransfers);

// ── Loading plan ──
router.post('/loading-plan',          loadingPlanController.generate);

// ── Labels for print panel ──
router.get('/labels',                 labelsController.getLabels);

// ── Drivers (رانندگان تعریف‌شده توسط مدیریت) ──
router.get('/drivers',                driversController.listDrivers);
router.put('/drivers/:id', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:driver' }), validate(assignDriverSchema), driversController.assignDriver);

// ── Carriers (باربری‌ها — مدیریت توسط انباردار) ──
router.get('/carriers',               carriersController.list);
router.post('/carriers', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:carrier' }), validate(createCarrierSchema), carriersController.create);
// بازچینی صف بارگیری — قبل از `/:id` تا «reorder» به‌عنوان شناسه تفسیر نشود
router.put('/carriers/reorder', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:carrier' }), validate(reorderCarriersSchema), carriersController.reorder);
router.put('/carriers/:id', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:carrier' }), validate(updateCarrierSchema), carriersController.update);
router.delete('/carriers/:id', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'w:carrier' }), carriersController.remove);

export const warehouseRoutes = router;