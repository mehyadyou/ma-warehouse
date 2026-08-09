import { z } from 'zod';

export const orderItemSchema = z.object({
    productId:      z.string('شناسه محصول الزامی است').trim().min(1, 'شناسه محصول الزامی است'),
    quantity:       z.coerce.number().int().positive('تعداد باید عدد صحیح بزرگ‌تر از صفر باشد'),
    model:          z.string().trim().nullish(),
    modelId:        z.string().trim().nullish(),
    price:          z.coerce.number().nullish(),
    exchangeRate:   z.coerce.number().nullish(),
});

export const createOrderSchema = z.object({
    warehouseId:    z.string('شناسه انبار الزامی است').trim().min(1, 'شناسه انبار الزامی است'),
    items:          z.array(orderItemSchema).min(1, 'حداقل یک قلم کالا الزامی است'),
    shippingMethod: z.string().trim().min(1).default('باربری'),
    carrier:        z.string().trim().nullish(),
    city:           z.string().trim().nullish(),
    postalCode:     z.string().trim().nullish(),
    address:        z.string().trim().nullish(),
    customerPhone:  z.string().trim().nullish(),
    senderName:     z.string().trim().nullish(),
    receiverName:   z.string().trim().nullish(),
});

export const updateOrderSchema = z.object({
    items:          z.array(orderItemSchema).min(1, 'حداقل یک قلم کالا الزامی است').optional(),
    shippingMethod: z.string().trim().min(1).optional(),
    carrier:        z.string().trim().nullish(),
    city:           z.string().trim().nullish(),
    postalCode:     z.string().trim().nullish(),
    address:        z.string().trim().nullish(),
    customerPhone:  z.string().trim().nullish(),
    senderName:     z.string().trim().nullish(),
    receiverName:   z.string().trim().nullish(),
    // نسخه‌ی سفارش از لیست — برای قفل خوشبینانه (409 در صورت ویرایش همزمان)
    version:        z.coerce.number().int().min(0).optional(),
});

export const createCarrierSchema = z.object({
    name:     z.string('نام باربری الزامی است').trim().min(1, 'نام باربری الزامی است'),
    priority: z.coerce.number().int(),
    phone:    z.string().trim().nullish(),
    address:  z.string().trim().nullish(),
});

export type CreateOrderInput = z.infer<typeof createOrderSchema>;
export type UpdateOrderInput = z.infer<typeof updateOrderSchema>;
export type CreateCarrierInput = z.infer<typeof createCarrierSchema>;