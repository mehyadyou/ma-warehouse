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
router.get('/products/archived', productsController.getArchivedProducts);
router.post('/products', productsController.createProduct);
router.put('/products/:id', productsController.updateProduct);
router.delete('/products/:id', productsController.deleteProduct);
router.post('/products/:id/restore', productsController.restoreProduct);
router.put('/product-models/:id', productsController.updateProductModel);
router.delete('/product-models/:id', productsController.deleteProductModel);
router.post('/product-models/:id/restore', productsController.restoreProductModel);

// ── Orders ──
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

export const managerRoutes = router;