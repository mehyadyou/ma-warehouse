import { Request, Response } from 'express';
import { checkinService } from './checkin.service';
import { asyncHandler } from '../../middleware/asyncHandler';
import { SubmitCheckinInput, MarkPrintedInput } from './checkin.schema';

export const checkinController = {
  submit: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user?.warehouseId;
    const userId      = req.user?.id;
    if (!warehouseId || !userId) {
      res.status(403).json({ error: 'دسترسی نامعتبر' });
      return;
    }
    const { items, clientKey } = req.body as SubmitCheckinInput;
    const result = await checkinService.submitCheckin(warehouseId, userId, items, clientKey);

    // اعلان به مدیران و رویداد ریل‌تایم توسط دیسپچر اوتباکس (تراکنشی و بدون گم‌شدن پیام) ارسال می‌شود
    res.status(201).json({
      message: 'ورود کالا با موفقیت ثبت شد',
      cartons: result.cartons,
      totalUnits: result.totalUnits,
    });
  }),

  listRecent: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user?.warehouseId;
    if (!warehouseId) { res.status(403).json({ error: 'دسترسی نامعتبر' }); return; }
    const cartons = await checkinService.listRecentCartons(warehouseId);
    res.json({ cartons });
  }),

  listPrinted: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user?.warehouseId;
    if (!warehouseId) { res.status(403).json({ error: 'دسترسی نامعتبر' }); return; }
    const cartons = await checkinService.listPrintedCartons(warehouseId);
    res.json({ cartons });
  }),

  markPrinted: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user?.warehouseId;
    if (!warehouseId) { res.status(403).json({ error: 'دسترسی نامعتبر' }); return; }
    const { cartonIds } = req.body as MarkPrintedInput;
    const marked = await checkinService.markCartonsPrinted(warehouseId, cartonIds);
    res.json({ marked });
  }),
};
