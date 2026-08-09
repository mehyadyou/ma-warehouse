import { Request, Response } from 'express';
import { warehouseService } from './warehouse.service';
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
        const data = await warehouseService.getProductInventory(warehouseId);
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
        const products = await warehouseService.getProducts();
        res.json({ products });
    }),
};
