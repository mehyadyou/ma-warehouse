import { z } from 'zod';

// حداقل ۸ کاراکتر + حداقل یک عدد
const passwordPattern = /^(?=.*\d).{8,}$/;
const passwordMessage = 'رمز عبور باید حداقل ۸ کاراکتر و شامل یک عدد باشد';

export const loginSchema = z.object({
    phone:    z.string('شماره موبایل الزامی است').trim().min(10, 'شماره موبایل معتبر نیست').max(15, 'شماره موبایل معتبر نیست'),
    // اعتبارسنجی ورود سختگیرانه نیست — حساب‌های قدیمی با رمز ضعیف باید بتوانند وارد شوند؛
    // پالیسی قوی فقط موقع ساخت/تغییر رمز اعمال می‌شود
    password: z.string('رمز عبور الزامی است').min(1, 'رمز عبور الزامی است'),
});

export const refreshSchema = z.object({
    refreshToken: z.string('توکن رفرش الزامی است').min(1, 'توکن رفرش الزامی است'),
});

export const logoutSchema = z.object({
    refreshToken: z.string('توکن رفرش الزامی است').min(1, 'توکن رفرش الزامی است'),
});

export const createFirstManagerSchema = z.object({
    name:     z.string('نام الزامی است').trim().min(1, 'نام الزامی است'),
    phone:    z.string('شماره موبایل الزامی است').trim().min(10, 'شماره موبایل معتبر نیست').max(15, 'شماره موبایل معتبر نیست'),
    password: z.string('رمز عبور الزامی است').regex(passwordPattern, passwordMessage),
});

export const updateProfileSchema = z.object({
    name:     z.string('نام معتبر نیست').trim().min(1, 'نام نمی‌تواند خالی باشد').optional(),
    phone:    z.string('شماره موبایل معتبر نیست').trim().min(10, 'شماره موبایل معتبر نیست').max(15, 'شماره موبایل معتبر نیست').optional(),
    password: z.string('رمز عبور معتبر نیست').regex(passwordPattern, passwordMessage).optional(),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type CreateFirstManagerInput = z.infer<typeof createFirstManagerSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
export type LogoutInput = z.infer<typeof logoutSchema>;