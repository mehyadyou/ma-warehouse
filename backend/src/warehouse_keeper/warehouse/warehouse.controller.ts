import { Request, Response } from 'express';
import { warehouseService } from './warehouse.service';
import { searchService } from '../../manager/search/search.service';
import { transfersService } from '../../manager/transfers/transfers.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const warehouseController = {
    getMyWarehouse: asyncHandler(async (req: Request, res: Response) => {
        const warehouseId = req.user!.warehouseId as string;
        if (!warehouseId) return res.status(400).json({ error: 'انباری به این کاربر متصل نیست' });
        const warehouse = await warehouseService.getMyWarehouse(warehouseId);
        res.json({ warehouse });
    }),
    getOrders: asyncHandler(async (req: Request, res: Response) => {
        const rawLimit = Number(req.query.limit ?? 100);
        const limit = Number.isInteger(rawLimit) && rawLimit > 0 ? Math.min(rawLimit, 500) : 100;
        const orders = await warehouseService.getOrders(req.user!.warehouseId as string, limit);
        res.json({ orders });
    }),
    getInventory: asyncHandler(async (req: Request, res: Response) => {
        const inventory = await warehouseService.getInventory(req.user!.warehouseId as string);
        res.json({ inventory });
    }),
    getInventorySummary: asyncHandler(async (req: Request, res: Response) => {
        const summary = await warehouseService.getInventorySummary(req.user!.warehouseId as string);
        res.json({ summary });
    }),
    getProductInventory: asyncHandler(async (req: Request, res: Response) => {
        const warehouseId = req.user!.warehouseId as string;
        if (!warehouseId) return res.status(400).json({ error: 'انباری به این کاربر متصل نیست' });
        const page = req.query.page !== undefined ? Number(req.query.page) : undefined;
        const pageSize = req.query.pageSize !== undefined ? Number(req.query.pageSize) : undefined;
        const data = await warehouseService.getProductInventory(warehouseId, {
            q: String(req.query.q ?? '').trim() || undefined,
            onlyInStock: String(req.query.onlyInStock ?? '') === 'true',
            ...(Number.isInteger(page) && page! > 0 ? { page } : {}),
            ...(Number.isInteger(pageSize) && pageSize! > 0 ? { pageSize: Math.min(pageSize!, 500) } : {}),
        });
        if (!data) return res.status(404).json({ error: 'انبار یافت نشد' });
        res.json(data);
    }),
    getProductModels: asyncHandler(async (req: Request, res: Response) => {
        const warehouseId = req.user!.warehouseId as string;
        if (!warehouseId) return res.status(400).json({ error: 'انباری به این کاربر متصل نیست' });
        const data = await warehouseService.getProductModels(warehouseId, String(req.params.productId));
        if (!data) return res.status(404).json({ error: 'محصول یافت نشد' });
        res.json(data);
    }),
    getTransactions: asyncHandler(async (req: Request, res: Response) => {
        const transactions = await warehouseService.getTransactions(req.user!.warehouseId as string, req.query.date as string);
        res.json({ transactions });
    }),
    getProducts: asyncHandler(async (req: Request, res: Response) => {
        const q = String(req.query.q ?? '').trim();
        const page = req.query.page !== undefined ? Number(req.query.page) : undefined;
        const pageSize = req.query.pageSize !== undefined ? Number(req.query.pageSize) : undefined;
        const products = await warehouseService.getProducts({
            ...(q ? { q } : {}),
            ...(Number.isInteger(page) && page! > 0 ? { page } : {}),
            ...(Number.isInteger(pageSize) && pageSize! > 0 ? { pageSize: Math.min(pageSize!, 500) } : {}),
        });
        res.json(Array.isArray(products) ? { products } : products);
    }),
    searchBySerial: asyncHandler(async (req: Request, res: Response) => {
        const serial = String(req.query.serial ?? '').trim();
        if (!serial) {
            res.status(400).json({ error: 'سریال کالا را وارد کنید' });
            return;
        }
        const carton = await searchService.searchBySerial(serial, req.user!.warehouseId as string);
        if (!carton) {
            res.status(404).json({ error: 'کارتنی با این سریال در انبار شما یافت نشد' });
            return;
        }
        res.json({ carton });
    }),
    searchShipments: asyncHandler(async (req: Request, res: Response) => {
        const filters = {
            sender:   String(req.query.sender ?? '').trim(),
            receiver: String(req.query.receiver ?? '').trim(),
            product:  String(req.query.product ?? '').trim(),
            model:    String(req.query.model ?? '').trim(),
            q:        String(req.query.q ?? '').trim(),
            warehouseId: req.user!.warehouseId as string,
        };
        if (!filters.sender && !filters.receiver && !filters.product && !filters.model && !filters.q) {
            res.status(400).json({ error: 'حداقل یکی از فیلدها را وارد کنید' });
            return;
        }
        const result = await searchService.searchShipments(filters);
        res.json(result);
    }),
    listPendingTransfers: asyncHandler(async (req: Request, res: Response) => {
        const warehouseId = req.user!.warehouseId as string;
        if (!warehouseId) return res.status(400).json({ error: 'انباری به این کاربر متصل نیست' });
        const rawLimit = Number(req.query.limit ?? 50);
        const limit = Number.isInteger(rawLimit) && rawLimit > 0 ? Math.min(rawLimit, 100) : 50;
        const transfers = await transfersService.listTransfers(limit, warehouseId);
        res.json({ transfers });
    }),
};
