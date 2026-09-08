import { AppError } from './exceptions/AppError';

// سیاست رمز کل سیستم:
// - انباردار/راننده: دقیقاً ۶ رقم عددی (PIN — کار با دستکش در انبار)
// - مدیر (MANAGER): حداقل ۸ کاراکتر شامل حرف و عدد (دسترسی به کل سیستم)
// دلیل: PIN شش‌رقمی فقط ~۱M ترکیب دارد؛ برای نقش مدیر با دسترسی کامل کافی نیست.
export const PASSWORD_REGEX = /^\d{6}$/;
export const MANAGER_PASSWORD_REGEX = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$%^&*()_+\-=]{8,64}$/;

// رمز ورودی ممکن است PIN انباردار یا رمز قوی مدیر باشد (لاگین/verify باید هر دو را بپذیرند)
export const ANY_PASSWORD_REGEX = /^(?:\d{6}|(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$%^&*()_+\-=]{8,64})$/;

export function assertPasswordPolicy(password: string, role?: string) {
    if (role === 'MANAGER') {
        if (!MANAGER_PASSWORD_REGEX.test(password)) {
            throw new AppError('رمز مدیر باید حداقل ۸ کاراکتر شامل حرف و عدد باشد');
        }
        return;
    }
    if (!PASSWORD_REGEX.test(password)) {
        throw new AppError('رمز عبور باید دقیقاً ۶ رقم باشد');
    }
}
