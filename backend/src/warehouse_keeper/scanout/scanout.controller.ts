import { Request, Response } from 'express';
import { scanOutService } from './scanout.service';
import { notificationService } from '../../notification/notification.service';
import { realtime } from '../../realtime/realtime';
import { RealtimeEvents } from '../../realtime/events';
import { asyncHandler } from '../../middleware/asyncHandler';
import { ScanOutInput, ManualExitInput, AssignDriverInput } from './scanout.schema';

export const scanOutController = {
  scan: asyncHandler(async (req: Request, res: Response) => {
    const { qrPayload, serialNumber, orderId, transferId } = req.body as ScanOutInput;
    const userId      = req.user!.id;
    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'شما به هیچ انباری متصل نیستید' });

    const result = await scanOutService.scanOut({ qrPayload, serialNumber, orderId, transferId }, warehouseId, userId);

    if (!result.valid) {
      await notificationService.create(userId, 'خطای خروج', result.error, 'error', { type: 'SCAN_OUT_ERROR' });
      realtime.toUser(userId, RealtimeEvents.QR_ERROR, { error: result.error });
      return res.status(400).json(result);
    }

    // اعلان به مدیران و رویداد ریل‌تایم توسط دیسپچر اوتباکس (تراکنشی و بدون گم‌شدن پیام) ارسال می‌شود
    res.json(result);
  }),

  //تخصیص بار (سفارش خروج‌داده‌شده) به رانندهٔ تیک‌خورده — بعد از اسکن، انباردار راننده را انتخاب می‌کند
  assignDriver: asyncHandler(async (req: Request, res: Response) => {
    const { orderId, driverId } = req.body as AssignDriverInput;
    const userId      = req.user!.id;
    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'شما به هیچ انباری متصل نیستید' });

    const result = await scanOutService.assignDriver({ orderId, driverId }, warehouseId, userId);
    if (!result.valid) {
      return res.status(400).json({ error: result.error });
    }
    res.json(result.assignment);
  }),

  //خروج دستی (بدون QR) — محصول + مدل + تعداد، اعتبارسنجی مطابق سفارش/دستور مدیر
  manual: asyncHandler(async (req: Request, res: Response) => {
    const { productId, modelId, quantity, driverId, orderId, transferId } = req.body as ManualExitInput;
    const userId      = req.user!.id;
    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'شما به هیچ انباری متصل نیستید' });

    const result = await scanOutService.manualExit(
      { productId, modelId, quantity, driverId, orderId, transferId },
      warehouseId,
      userId,
    );
    if (!result.valid) {
      await notificationService.create(userId, 'خطای خروج', result.error, 'error', { type: 'SCAN_OUT_ERROR' });
      realtime.toUser(userId, RealtimeEvents.QR_ERROR, { error: result.error });
      return res.status(400).json(result);
    }
    res.json(result);
  }),

  //کارتن‌های خروج‌زده‌شده از انبار انباردار
  listShipped: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'انباری تعریف نشده' });
    const cartons = await scanOutService.listShippedCartons(warehouseId);
    res.json({ cartons });
  }),

  //کارتن‌های خروج‌زده‌شده برای یک سفارش — نمایش پیشرفت خروج در جزئیات سفارش انباردار
  listOrderCartons: asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params as { id: string };
    const warehouseId = req.user!.warehouseId ?? undefined;
    const cartons = await scanOutService.listOrderCartons(id, warehouseId);
    res.json({ cartons });
  }),
};