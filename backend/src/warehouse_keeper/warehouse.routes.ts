import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth';
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
router.use(authenticate, authorize('WAREHOUSE_KEEPER'));

// ── Warehouse ──
router.get('/my-warehouse',           warehouseController.getMyWarehouse);
router.get('/orders',                 warehouseController.getOrders);
router.get('/inventory',              warehouseController.getInventory);
router.get('/inventory-summary',      warehouseController.getInventorySummary);
router.get('/inventory/products',     warehouseController.getProductInventory);
router.get('/inventory/product/:productId', warehouseController.getProductModels);
router.get('/transactions',           warehouseController.getTransactions);
router.get('/products',               warehouseController.getProducts);

// ── QR Template ──
router.get('/qr-template',            qrcodeController.getTemplate);

// ── Check-in ──
router.post('/checkin', validate(submitCheckinSchema), checkinController.submit);
router.get('/checkin/recent', checkinController.listRecent);

// ── Shipped cartons ──
router.get('/cartons/shipped', scanOutController.listShipped);

// ── Scan-out ──
router.post('/scan-out', validate(scanOutSchema), scanOutController.scan);

// ── Loading plan ──
router.post('/loading-plan',          loadingPlanController.generate);

// ── Labels for print panel ──
router.get('/labels',                 labelsController.getLabels);

export const warehouseRoutes = router;