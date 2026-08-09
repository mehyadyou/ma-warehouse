import { z } from 'zod';

export const checkinItemSchema = z.object({
    productId:       z.string('شناسه محصول الزامی است').trim().min(1, 'شناسه محصول الزامی است'),
    modelId:         z.string().trim().nullish(),
    entryType:       z.string().trim().toUpperCase().pipe(
        z.enum(['NEW', 'RETURNED']).catch('NEW'),
    ).default('NEW'),
    serialNumber:    z.string().trim().nullish(),
    qrPayload:       z.string().trim().nullish(),
    cartonCount:     z.coerce.number().int().min(0).default(0),
    individualCount: z.coerce.number().int().min(0).default(0),
});

export const submitCheckinSchema = z.object({
    items: z.array(checkinItemSchema).min(1, 'حداقل یک محصول وارد کنید'),
    // کلید ایدمپوتنسی سمت کلاینت: با یک کلید تکراری، پاسخ قبلی برگردانده می‌شود و ورود کالا دوباره ثبت نمی‌شود
    clientKey: z.string().trim().max(128).optional(),
});

export type CheckinItemInput = z.infer<typeof checkinItemSchema>;
export type SubmitCheckinInput = z.infer<typeof submitCheckinSchema>;