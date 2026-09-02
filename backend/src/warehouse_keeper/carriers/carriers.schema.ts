import { z } from 'zod';

export const createCarrierSchema = z.object({
    name:     z.string('نام باربری الزامی است').trim().min(1, 'نام باربری الزامی است'),
    priority: z.coerce.number().int().min(0, 'اولویت باید عدد صحیح نامنفی باشد').default(0),
    phone:    z.string().trim().nullish(),
    address:  z.string().trim().nullish(),
});

export const updateCarrierSchema = z.object({
    name:     z.string('نام باربری الزامی است').trim().min(1, 'نام باربری الزامی است').optional(),
    priority: z.coerce.number().int().min(0, 'اولویت باید عدد صحیح نامنفی باشد').optional(),
    phone:    z.string().trim().nullish(),
    address:  z.string().trim().nullish(),
});

/// ترتیب صف بارگیری — آرایهٔ مرتب شناسهٔ باربری‌ها (بالا = نزدیک‌ترین)
/// سمت سرور اولویت‌ها (priority) بازچینی می‌شوند تا برنامهٔ بارگیری راننده همان ترتیب را بگیرد
export const reorderCarriersSchema = z.object({
    ids: z.array(z.string().min(1)).min(1, 'حداقل یک باربری لازم است'),
});

export type CreateCarrierInput = z.infer<typeof createCarrierSchema>;
export type UpdateCarrierInput = z.infer<typeof updateCarrierSchema>;
export type ReorderCarriersInput = z.infer<typeof reorderCarriersSchema>;