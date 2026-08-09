import { AppError } from './exceptions/AppError';

export const PASSWORD_MIN_LENGTH = 8;

// حداقل ۸ کاراکتر + حداقل یک عدد
export function assertPasswordPolicy(password: string) {
    if (password.length < PASSWORD_MIN_LENGTH) {
        throw new AppError(`رمز عبور باید حداقل ${PASSWORD_MIN_LENGTH} کاراکتر باشد`);
    }
    if (!/\d/.test(password)) {
        throw new AppError('رمز عبور باید شامل حداقل یک عدد باشد');
    }
}
