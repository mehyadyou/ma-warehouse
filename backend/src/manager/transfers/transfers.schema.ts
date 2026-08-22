import { z } from 'zod';

export const createTransferSchema = z.object({
    fromWarehouseId: z.string('انبار مبدأ الزامی است').trim().min(1, 'انبار مبدأ الزامی است'),
    toWarehouseId:   z.string().trim().min(1, 'انبار مقصد الزامی است').nullish(),
    productId:       z.string('محصول الزامی است').trim().min(1, 'محصول الزامی است'),
    modelId:         z.string().trim().nullish(),
    quantity:        z.coerce
        .number('تعداد باید عدد باشد')
        .int('تعداد باید عدد صحیح باشد')
        .positive('تعداد باید عددی مثبت باشد')
        .max(1_000_000, 'تعداد حداکثر ۱,۰۰۰,۰۰۰ است'),
    description:     z.string().trim().max(500, 'توضیحات حداکثر ۵۰۰ نویسه است').default(''),
});

export type CreateTransferInput = z.infer<typeof createTransferSchema>;