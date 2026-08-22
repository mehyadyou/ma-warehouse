import { Request, Response } from 'express';
import { inventoryService } from './inventory.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const inventoryController = {
  getInventorySummary: asyncHandler(async (req: Request, res: Response) => {
    const summary = await inventoryService.getInventorySummary();
    res.json(summary);

  }),

  getWarehouseInventory: asyncHandler(async (req: Request, res: Response) => {
    const data = await inventoryService.getWarehouseInventory();
    res.json({ inventory: data });

  }),

  getProductInventory: asyncHandler(async (req: Request, res: Response) => {
    const page = req.query.page !== undefined ? Number(req.query.page) : undefined;
    const pageSize = req.query.pageSize !== undefined ? Number(req.query.pageSize) : undefined;
    const q = req.query.q !== undefined ? String(req.query.q) : undefined;
    const onlyInStock = req.query.onlyInStock === 'true';
    const warehouseId = req.query.warehouseId !== undefined ? String(req.query.warehouseId) : undefined;
    const data = await inventoryService.getProductInventory({
      ...(Number.isInteger(page) && (page as number) > 0 ? { page: page as number } : {}),
      ...(Number.isInteger(pageSize) && (pageSize as number) > 0 ? { pageSize: Math.min(pageSize as number, 500) } : {}),
      ...(q !== undefined && q.trim().length > 0 ? { q } : {}),
      ...(onlyInStock ? { onlyInStock: true } : {}),
      ...(warehouseId !== undefined && warehouseId.trim().length > 0 ? { warehouseId } : {}),
    });
    if (!data) {
      res.status(404).json({ error: 'انبار یافت نشد' });
      return;
    }
    res.json(data);

  }),

  getProductModels: asyncHandler(async (req: Request, res: Response) => {
    const data = await inventoryService.getProductModels(String(req.params.productId));
    if (!data) {
      res.status(404).json({ error: 'محصول یافت نشد' });
      return;
    }
    res.json(data);

  }),
};