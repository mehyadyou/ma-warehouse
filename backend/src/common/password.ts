import { AppError } from './exceptions/AppError';

// سیاست رمز اصلی کل سیستم: دقیقاً ۶ رقم عددی (مثل پین)
export const PASSWORD_REGEX = /^\d{6}$/;

export function assertPasswordPolicy(password: string) {
    if (!PASSWORD_REGEX.test(password)) {
        throw new AppError('رمز عبور باید دقیقاً ۶ رقم باشد');
    }
}
