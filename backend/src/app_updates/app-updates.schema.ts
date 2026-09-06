import { z } from 'zod';

// انتشار نسخهٔ جدید — فیلدهای متنی؛ خود APK جداگانه multipart می‌آید
export const publishReleaseSchema = z.object({
    versionName: z.string().regex(/^\d+\.\d+(\.\d+)?$/, 'versionName باید مثل 1.2.0 باشد'),
    versionCode: z.coerce.number().int().positive('versionCode باید عدد صحیح مثبت باشد'),
    changelog: z.string().trim().min(1, 'توضیحات نسخه الزامی است').max(2000),
    isForce: z
        .union([z.boolean(), z.enum(['true', 'false'])])
        .transform((v) => v === true || v === 'true')
        .optional()
        .default(false),
    minAndroidSdk: z.coerce.number().int().nonnegative().optional().default(0),
});

export type PublishReleaseInput = z.infer<typeof publishReleaseSchema>;
