import { z } from 'zod';

export const scanOutSchema = z.object({
    qrPayload:    z.string().trim().default(''),
    serialNumber: z.string().trim().default(''),
}).refine(
    (v) => v.qrPayload.length > 0 || v.serialNumber.length > 0,
    { message: 'qrPayload یا serialNumber الزامی است' },
);

export type ScanOutInput = z.infer<typeof scanOutSchema>;