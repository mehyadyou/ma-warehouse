import { z } from 'zod';

export const scanOutSchema = z.object({
    qrPayload:    z.string().trim().default(''),
    serialNumber: z.string().trim().default(''),
    // وقتی انباردار کارتن را برای یک سفارش خاص اسکن می‌کند، کارتن به همان سفارش
    // متصل و خروج داده می‌شود (اولین خروج → سفارش SHIPPED)
    orderId:      z.string().trim().nullish(),
    // وقتی انباردار کارتن را برای یک دستور جابه‌جایی/خروج مدیر اسکن می‌کند، کارتن
    // به همان دستور متصل شده و اجرا می‌شود (تا تکمیل سهمیه → دستور DONE)
    transferId:   z.string().trim().nullish(),
}).refine(
    (v) => v.qrPayload.length > 0 || v.serialNumber.length > 0,
    { message: 'qrPayload یا serialNumber الزامی است' },
);

export type ScanOutInput = z.infer<typeof scanOutSchema>;

/** خروج دستی (بدون QR) برای محصولاتی که برچسب/QR ندارند — انتخاب محصول + مدل + تعداد */
export const manualExitSchema = z.object({
    productId: z.string().trim().min(1, 'محصول الزامی است'),
    modelId:    z.string().trim().nullish(),
    quantity:   z.number().int().positive('تعداد باید عددی مثبت باشد'),
});

export type ManualExitInput = z.infer<typeof manualExitSchema>;