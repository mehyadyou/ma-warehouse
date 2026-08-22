import { z } from 'zod';

export const orderItemSchema = z.object({
    productId:      z.string('شناسهٔ محصول الزامی است').trim().min(1, 'شناسهٔ محصول الزامی است'),
    quantity:       z.coerce.number().int().positive('تعداد باید عددی مثبت باشد').max(10000, 'تعداد هر قلم حداکثر ۱۰,۰۰۰ است'),
    model:          z.string().trim().nullish(),
    modelId:        z.string().trim().nullish(),
    price:          z.coerce.number().nonnegative('قیمت نمی‌تواند منفی باشد').nullish(),
    exchangeRate:   z.coerce.number().nonnegative('نرخ ارز نمی‌تواند منفی باشد').nullish(),
});

export const createOrderSchema = z.object({
    warehouseId:    z.string('شناسهٔ انبار الزامی است').trim().min(1, 'شناسهٔ انبار الزامی است'),
    items:          z.array(orderItemSchema)
        .min(1, 'سفارش باید حداقل یک قلم کالا داشته باشد')
        .max(200, 'تعداد اقلام حداکثر ۲۰۰ مورد است'),
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
    items:          z.array(orderItemSchema)
        .min(1, 'سفارش باید حداقل یک قلم کالا داشته باشد')
        .max(200, 'تعداد اقلام حداکثر ۲۰۰ مورد است')
        .optional(),
    shippingMethod: z.string().trim().min(1).optional(),
    carrier:        z.string().trim().nullish(),
    city:           z.string().trim().nullish(),
    postalCode:     z.string().trim().nullish(),
    address:        z.string().trim().nullish(),
    customerPhone:  z.string().trim().nullish(),
    senderName:     z.string().trim().nullish(),
    receiverName:   z.string().trim().nullish(),
    // برای ویرایش هم‌زمان — با شمارهٔ نسخهٔ سفارش (409 اگر ناهماهنگ باشد)
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