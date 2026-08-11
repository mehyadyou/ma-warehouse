import { AppError } from './exceptions/AppError';

export const PASSWORD_MIN_LENGTH = 10;

// حداقل ۱۰ کاراکتر + حداقل یک حرف (فارسی/انگلیسی) + حداقل یک عدد
// رجکس حروف شامل \u0600-\u06FF است تا رمزهای فارسی (مثل «پارس۱۲۳۴۵») رد نشوند
export function assertPasswordPolicy(password: string) {
    if (password.length < PASSWORD_MIN_LENGTH) {
        throw new AppError(`رمز عبور باید حداقل ${PASSWORD_MIN_LENGTH} کاراکتر باشد`);
    }
    if (!/[a-zA-Z\u0600-\u06FF]/.test(password)) {
        throw new AppError('رمز عبور باید شامل حداقل یک حرف باشد');
    }
    if (!/\d/.test(password)) {
        throw new AppError('رمز عبور باید شامل حداقل یک عدد باشد');
    }
}
