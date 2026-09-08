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
    // کلید ایدمپوتنسی سمت کلاینت: ریت‌رای/صف آفلاین با کلید یکسان، پاسخ قبلی را می‌گیرد
    clientKey:    z.string().trim().max(128).nullish(),
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
    // راننده‌ای که این بار برایش تعریف می‌شود (فقط برای خروج مطابق سفارش — نه دستور مدیر)
    driverId:   z.string().trim().nullish(),
    // انتخاب صریح هدف وقتی چند سفارش/دستور فعال برای این کالا/مدل وجود دارد
    orderId:    z.string().trim().nullish(),
    transferId: z.string().trim().nullish(),
    // کلید ایدمپوتنسی سمت کلاینت: ریت‌رای/صف آفلاین با کلید یکسان، پاسخ قبلی را می‌گیرد
    clientKey:  z.string().trim().max(128).nullish(),
}).refine(
    (v) => !(v.orderId && v.transferId),
    { message: 'فقط یکی از سفارش یا دستور جابه‌جایی/خروج را انتخاب کنید' },
);

export type ManualExitInput = z.infer<typeof manualExitSchema>;

/** تخصیص بار (سفارش) به راننده — بعد از اسکن خروج، انباردار راننده را انتخاب می‌کند */
export const assignDriverSchema = z.object({
    orderId:  z.string().trim().min(1, 'سفارش الزامی است'),
    driverId: z.string().trim().min(1, 'راننده الزامی است'),
});

export type AssignDriverInput = z.infer<typeof assignDriverSchema>;