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
    const data = await inventoryService.getProductInventory();
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