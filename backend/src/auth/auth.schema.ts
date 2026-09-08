import { z } from 'zod';
import { ANY_PASSWORD_REGEX, MANAGER_PASSWORD_REGEX } from '../common/password';

const managerPasswordMessage = 'رمز مدیر باید حداقل ۸ کاراکتر شامل حرف و عدد باشد';

export const loginSchema = z.object({
    phone:    z.string('شماره موبایل الزامی است').trim().min(10, 'شماره موبایل معتبر نیست').max(15, 'شماره موبایل معتبر نیست'),
    // ورود: هم PIN شش‌رقمی انباردار/راننده و هم رمز قوی مدیر پذیرفته می‌شود (نقش بعد از یافتن کاربر معلوم است)
    password: z.string('رمز عبور الزامی است').regex(ANY_PASSWORD_REGEX, 'رمز عبور معتبر نیست'),
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
    password: z.string('رمز عبور الزامی است').regex(MANAGER_PASSWORD_REGEX, managerPasswordMessage),
});

export const updateProfileSchema = z.object({
    name:     z.string('نام معتبر نیست').trim().min(1, 'نام نمی‌تواند خالی باشد').optional(),
    phone:    z.string('شماره موبایل معتبر نیست').trim().min(10, 'شماره موبایل معتبر نیست').max(15, 'شماره موبایل معتبر نیست').optional(),
    password: z.string('رمز عبور معتبر نیست').regex(ANY_PASSWORD_REGEX, 'رمز عبور معتبر نیست').optional(),
});

// تأیید رمز برای قفل‌گشایی برنامه — همان رمز ورود (PIN یا رمز مدیر)
export const verifyPasswordSchema = z.object({
    password: z.string('رمز عبور الزامی است').regex(ANY_PASSWORD_REGEX, 'رمز عبور معتبر نیست'),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type CreateFirstManagerInput = z.infer<typeof createFirstManagerSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
export type LogoutInput = z.infer<typeof logoutSchema>;
export type VerifyPasswordInput = z.infer<typeof verifyPasswordSchema>;
