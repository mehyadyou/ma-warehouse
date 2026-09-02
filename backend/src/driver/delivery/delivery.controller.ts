import { Request, Response } from 'express';
import fs from 'fs';
import { deliveryService } from './delivery.service';
import { asyncHandler } from '../../middleware/asyncHandler';
import { createImageUpload, sniffImage } from '../../utils/imageUpload';

// تنظیمات آپلود عکس بیجک باربری — عکسِ برگه‌ای که باربری هنگام تحویل بار به راننده داده
const uploadReceipt = createImageUpload('receipts', 5);

export const deliveryController = {
  // تحویل سفارش — عکس بیجک باربری الزامی است؛ بعد از آپلود، سفارش تحویل می‌شود
  deliverOrder: (req: Request, res: Response) => {
    uploadReceipt.single('receipt')(req, res, async (err: any) => {
      if (err) {
        const msg = err.code === 'LIMIT_FILE_SIZE'
          ? 'حجم عکس نباید بیشتر از ۵ مگابایت باشد'
          : err.message || 'خطا در آپلود تصویر';
        res.status(400).json({ error: msg });
        return;
      }
      if (!req.file) {
        res.status(400).json({ error: 'عکس بیجک باربری الزامی است' });
        return;
      }
      // اعتبارسنجی magic bytes — محتوای واقعی فایل باید تصویر باشد
      if (!sniffImage(req.file.path)) {
        fs.unlink(req.file.path, () => {});
        res.status(400).json({ error: 'فایل ارسالی تصویر معتبر نیست (JPG, PNG یا WEBP)' });
        return;
      }

      const orderId = req.params.orderId as string;
      const notes = typeof req.body?.notes === 'string' ? req.body.notes : undefined;
      const driverId = req.user!.id;
      try {
        const receiptUrl = `/uploads/receipts/${req.file.filename}`;
        const result = await deliveryService.deliverOrder(orderId, driverId, notes, receiptUrl);
        res.json({ message: 'تحویل با موفقیت ثبت شد', ...result });
      } catch (error: any) {
        // در صورت ناموفق بودن تحویل (مثلاً سفارش در وضعیت ارسال نیست) فایل آپلودشده پاک می‌شود
        fs.unlink(req.file.path, () => {});
        const status = error?.statusCode ?? 400;
        res.status(status).json({ error: error?.message ?? 'خطا در ثبت تحویل' });
      }
    });
  },

  getMyDeliveries: asyncHandler(async (req: Request, res: Response) => {
    const driverId = req.user!.id;
    const dateParam = req.query.date;
    const date = typeof dateParam === 'string' ? dateParam : undefined;
    const deliveries = await deliveryService.getMyDeliveries(driverId, date);
    res.json({ deliveries });
  }),
};