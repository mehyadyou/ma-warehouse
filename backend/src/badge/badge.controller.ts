import { Request, Response } from 'express';
import { badgeService } from './badge.service';
import { asyncHandler } from '../middleware/asyncHandler';

export const badgeController = {
    list: asyncHandler(async (req: Request, res: Response) => {
        const warehouseId = req.user?.warehouseId;
        if (!warehouseId) {
            return res.status(403).json({ message: 'به هیچ انباری متصل نیستید' });
        }
        const orderId = typeof req.query.orderId === 'string' ? req.query.orderId : undefined;
        const limit = typeof req.query.limit === 'string' ? Number(req.query.limit) : 200;
        // فیلتر چاپ: true → فقط چاپ‌شده | false → فقط چاپ‌نشده | بدون پارامتر → همه
        let printed: boolean | undefined;
        if (req.query.printed === 'true') printed = true;
        else if (req.query.printed === 'false') printed = false;
        const badges = await badgeService.listForWarehouse(warehouseId, orderId, Number.isFinite(limit) ? limit : 200, printed);
        res.json(badges);

    }),

    markPrinted: asyncHandler(async (req: Request, res: Response) => {
        const warehouseId = req.user?.warehouseId;
        if (!warehouseId) {
            return res.status(403).json({ message: 'به هیچ انباری متصل نیستید' });
        }
        const badgeIds = Array.isArray(req.body?.badgeIds)
            ? (req.body.badgeIds as unknown[]).filter((v): v is string => typeof v === 'string')
            : [];
        if (badgeIds.length === 0) {
            return res.status(400).json({ message: 'شناسهٔ بیجک ارسال نشده است' });
        }
        const result = await badgeService.markPrinted(badgeIds, warehouseId);
        res.json(result);

    }),

    listByOrder: asyncHandler(async (req: Request, res: Response) => {
        const warehouseId = req.user?.warehouseId;
        if (!warehouseId) {
            return res.status(403).json({ message: 'به هیچ انباری متصل نیستید' });
        }
        const { orderId } = req.params as { orderId: string };
        const badges = await badgeService.listByOrderForWarehouse(orderId, warehouseId);
        if (badges === null) {
            return res.status(404).json({ message: 'بیجکی برای این سفارش یافت نشد' });
        }
        res.json(badges);

    }),
};
