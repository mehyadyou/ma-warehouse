import { z } from 'zod';

export const checkinItemSchema = z.object({
    productId:       z.string('شناسه محصول الزامی است').trim().min(1, 'شناسه محصول الزامی است'),
    modelId:         z.string().trim().nullish(),
    entryType:       z.string().trim().toUpperCase().pipe(
        z.enum(['NEW', 'RETURNED']).catch('NEW'),
    ).default('NEW'),
    serialNumber:    z.string().trim().nullish(),
    withoutQr:       z.boolean().optional(),
    qrPayload:       z.string().trim().nullish(),
    cartonCount:     z.coerce.number().int().min(0).default(0),
    individualCount: z.coerce.number().int().min(0).default(0),
});

export const submitCheckinSchema = z.object({
    items: z.array(checkinItemSchema).min(1, 'حداقل یک محصول وارد کنید').max(200, 'حداکثر ۲۰۰ ردیف در هر ورود'),
    // کلید ایدمپوتنسی سمت کلاینت: با یک کلید تکراری، پاسخ قبلی برگردانده می‌شود و ورود کالا دوباره ثبت نمی‌شود
    clientKey: z.string().trim().max(128).optional(),
});

/** ثبت چاپ لیبل‌ها از پنل دسکتاپ — کارتن‌ها به تب «چاپ شده‌ها» منتقل می‌شوند */
export const markPrintedSchema = z.object({
    cartonIds: z.array(z.string().trim().min(1)).min(1, 'حداقل یک کارتن انتخاب کنید'),
});

export type CheckinItemInput = z.infer<typeof checkinItemSchema>;
export type SubmitCheckinInput = z.infer<typeof submitCheckinSchema>;
export type MarkPrintedInput = z.infer<typeof markPrintedSchema>;