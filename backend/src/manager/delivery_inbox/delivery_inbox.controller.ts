import { Request, Response } from 'express';
import { deliveryInboxService } from './delivery_inbox.service';
import { asyncHandler } from '../../middleware/asyncHandler';

const parseNum = (v: unknown) =>
    typeof v === 'string' && v.trim() !== '' ? Number(v) : undefined;

export const deliveryInboxController = {
    /// صندوق تحویل — فیلتر راننده (driverId) و روز/ماه/سال شمسی (year/month/day)
    list: asyncHandler(async (req: Request, res: Response) => {
        const driverId =
            typeof req.query.driverId === 'string' && req.query.driverId !== ''
                ? req.query.driverId
                : undefined;
        const year = parseNum(req.query.year);
        const month = parseNum(req.query.month);
        const day = parseNum(req.query.day);

        if (year !== undefined && (!Number.isInteger(year) || year < 1300 || year > 1500)) {
            return res.status(400).json({ error: 'سال نامعتبر است' });
        }
        if (month !== undefined && (!Number.isInteger(month) || month < 1 || month > 12)) {
            return res.status(400).json({ error: 'ماه نامعتبر است' });
        }
        if (day !== undefined && (!Number.isInteger(day) || day < 1 || day > 31)) {
            return res.status(400).json({ error: 'روز نامعتبر است' });
        }
        if (year === undefined && (month !== undefined || day !== undefined)) {
            return res.status(400).json({ error: 'برای فیلتر ماه/روز باید سال را هم مشخص کنید' });
        }

        const deliveries = await deliveryInboxService.list({ driverId, year, month, day });
        res.json({ deliveries });
    }),

    /// لیست راننده‌های دارای بیجک — برای فیلتر راننده
    drivers: asyncHandler(async (_req: Request, res: Response) => {
        const drivers = await deliveryInboxService.listDrivers();
        res.json({ drivers });
    }),
};