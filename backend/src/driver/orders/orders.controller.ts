import { Request, Response } from 'express';
import { ordersService } from './orders.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const ordersController = {
  getReadyOrders: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'راننده به انباری متصل نیست' });

    const orders = await ordersService.getReadyOrders(warehouseId);
    res.json({ orders });

  }),
};