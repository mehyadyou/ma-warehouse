import { Request, Response } from 'express';
import { ordersService } from './orders.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const ordersController = {
  getReadyOrders: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user!.warehouseId;
    // راننده‌ای که تیکش توسط انباردار برداشته شده → پنل خالی است، نه خطا
    if (!warehouseId) return res.json({ orders: [], hasWarehouse: false });

    const orders = await ordersService.getReadyOrders(req.user!.id, warehouseId);
    res.json({ orders, hasWarehouse: true });

  }),
};