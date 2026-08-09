import { Request, Response } from 'express';
import { deliveryService } from './delivery.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const deliveryController = {
  deliverOrder: asyncHandler(async (req: Request, res: Response) => {
    const orderId = req.params.orderId as string;
    const { notes } = req.body;
    const driverId = req.user!.id;

    const result = await deliveryService.deliverOrder(orderId, driverId, notes);
    res.json({ message: 'تحویل با موفقیت ثبت شد', ...result });

  }),

  getMyDeliveries: asyncHandler(async (req: Request, res: Response) => {
    const driverId = req.user!.id;
    const dateParam = req.query.date;
    const date = typeof dateParam === 'string' ? dateParam : undefined;
    const deliveries = await deliveryService.getMyDeliveries(driverId, date);
    res.json({ deliveries });

  }),
};