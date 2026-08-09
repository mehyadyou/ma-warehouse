import { Request, Response } from 'express';
import { badgeService } from './badge.service';
import { asyncHandler } from '../middleware/asyncHandler';

export const badgeController = {
    list: asyncHandler(async (req: Request, res: Response) => {
        const orderId = typeof req.query.orderId === 'string' ? req.query.orderId : undefined;
        const limit = typeof req.query.limit === 'string' ? Number(req.query.limit) : 200;
        const badges = await badgeService.list(orderId, Number.isFinite(limit) ? limit : 200);
        res.json(badges);

    }),

    listByOrder: asyncHandler(async (req: Request, res: Response) => {
        const { orderId } = req.params as { orderId: string };
        const badges = await badgeService.listByOrder(orderId);
        if (badges === null) {
            return res.status(404).json({ message: 'بیجکی برای این سفارش یافت نشد' });
        }
        res.json(badges);

    }),
};
