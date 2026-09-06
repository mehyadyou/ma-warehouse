import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth';
import { userRateLimit } from '../middleware/rateLimit';
import { validate } from '../middleware/validate';
import { createOrderSchema, updateOrderSchema, createCarrierSchema } from './orders/orders.schema';
import { dashboardController } from './dashboard/dashboard.controller';
import { usersController } from './users/users.controller';
import { warehousesController } from './warehouses/warehouses.controller';
import { productsController } from './products/products.controller';
import { ordersController } from './orders/orders.controller';
import { inventoryController } from './inventory/inventory.controller';
import { searchController } from './search/search.controller';
import { rateController } from './rate/rate.controller';
import { shipmentsController } from './shipments/shipments.controller';
import { transfersController } from './transfers/transfers.controller';
import { createTransferSchema } from './transfers/transfers.schema';
import { deliveryInboxController } from './delivery_inbox/delivery_inbox.controller';
import { assistantController } from './assistant/assistant.controller';
import { assistantConfigController } from './assistant/assistant-config.controller';
import { assistantChatSchema } from './assistant/assistant.schema';
import { assistantConfigSchema, assistantConfigTestSchema } from './assistant/assistant-config.service';
import { productHistoryController } from './product_history/product-history.controller';

const router = Router();

router.use(authenticate, authorize('MANAGER'));

// ── Dashboard ──
router.get('/dashboard', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:dash' }), dashboardController.dashboard);
router.get('/transactions', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:tx' }), dashboardController.getAllTransactionsByDate);
router.get('/recent-activities', dashboardController.getRecentActivities);
router.get('/history', dashboardController.getHistory);

// ── Users ──
router.get('/users', usersController.getAllUsers);
router.get('/users/:id/report', usersController.getUserReport);
router.post('/users', usersController.createUser);
router.put('/users/:id', usersController.updateUser);
router.delete('/users/:id', usersController.deleteUser);

// ── Warehouses ──
router.get('/warehouses', warehousesController.getAllWarehouses);
router.get('/warehouses/archived', warehousesController.getArchivedWarehouses);
router.post('/warehouses', warehousesController.createWarehouse);
router.put('/warehouses/:id', warehousesController.updateWarehouse);
router.delete('/warehouses/:id', warehousesController.deleteWarehouse);
router.post('/warehouses/:id/restore', warehousesController.restoreWarehouse);
router.post('/create-warehouse-with-keeper', warehousesController.createWarehouseWithKeeper);
router.get('/warehouses/:id/transactions', warehousesController.getTransactionsByDate);
router.get('/warehouses/:id/detail', warehousesController.getWarehouseDetail);

// ── Products ──
router.get('/products', productsController.getProducts);
router.get('/products/:id', productsController.getProduct);
router.get('/products/archived', productsController.getArchivedProducts);
router.post('/products', productsController.createProduct);
router.put('/products/:id', productsController.updateProduct);
router.delete('/products/:id', productsController.deleteProduct);
router.post('/products/:id/restore', productsController.restoreProduct);
router.post('/products/:id/models', productsController.addProductModels);
router.put('/product-models/:id', productsController.updateProductModel);
router.delete('/product-models/:id', productsController.deleteProductModel);
router.post('/product-models/:id/restore', productsController.restoreProductModel);

// ── Orders ──
router.get('/orders/stock', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'm:ostk' }), ordersController.getOrderStock);
router.get('/orders', ordersController.listOrders);
router.post('/orders', validate(createOrderSchema), ordersController.createOrder);
router.put('/orders/:id', validate(updateOrderSchema), ordersController.updateOrder);
router.delete('/orders/:id', ordersController.deleteOrder);
router.get('/carriers', ordersController.getCarriers);
router.post('/carriers', validate(createCarrierSchema), ordersController.createCarrier);

// ── Inventory ──
router.get('/inventory-summary', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:invsum' }), inventoryController.getInventorySummary);
router.get('/warehouse-inventory', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:winv' }), inventoryController.getWarehouseInventory);
router.get('/inventory', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:inv' }), inventoryController.getProductInventory);
router.get('/inventory/product/:productId', inventoryController.getProductModels);

// ── Search ──
router.get('/search-products', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'm:sp' }), searchController.searchProducts);
router.get('/search/serial', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'm:ss' }), searchController.searchBySerial);
router.get('/search/shipments', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'm:ssh' }), searchController.searchShipments);

// ── Rate ──
router.get('/rate/dollar', rateController.getDollarRate);

// ── Shipments Report ──
router.get('/shipments-report', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:shrep' }), shipmentsController.getShipmentsReport);

// ── Transfers (جابه‌جایی/خروج محصول) ──
router.post('/transfers', validate(createTransferSchema), transfersController.createTransfer);
router.get('/transfers', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:tr' }), transfersController.listTransfers);
router.post('/transfers/:id/cancel', userRateLimit({ windowMs: 60_000, max: 30, keyPrefix: 'm:trc' }), transfersController.cancelTransfer);

// ── Delivery Inbox (صندوق تحویل — عکس بیجک باربری) ──
router.get('/delivery-inbox/drivers', userRateLimit({ windowMs: 60_000, max: 60, keyPrefix: 'm:dinb' }), deliveryInboxController.drivers);
router.get('/delivery-inbox', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'm:dinb' }), deliveryInboxController.list);

// ── Assistant (دستیار هوش مصنوعی — فقط‌خواندنی) ──
router.post(
    '/assistant/chat',
    userRateLimit({ windowMs: 60_000, max: 15, keyPrefix: 'm:ai' }),
    validate(assistantChatSchema),
    assistantController.chat,
);
router.post(
    '/assistant/chat/stream',
    userRateLimit({ windowMs: 60_000, max: 15, keyPrefix: 'm:ai' }),
    validate(assistantChatSchema),
    assistantController.chatStream,
);

// ── Product History (سابقهٔ کامل محصولات از ابتدای سیستم) ──
router.get('/product-history', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'm:ph' }), productHistoryController.list);
router.get('/product-history/:id', userRateLimit({ windowMs: 60_000, max: 120, keyPrefix: 'm:phd' }), productHistoryController.detail);

// ── Assistant Model Config (پیکربندی مدل دستیار — از تنظیمات مدیریت) ──
router.get('/assistant/config', assistantConfigController.get);
router.put('/assistant/config', validate(assistantConfigSchema), assistantConfigController.update);
router.delete('/assistant/config', assistantConfigController.reset);
router.post('/assistant/config/test', validate(assistantConfigTestSchema), assistantConfigController.test);

export const managerRoutes = router;