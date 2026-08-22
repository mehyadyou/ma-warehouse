import { Prisma } from '@prisma/client';
import { prisma } from './prisma';

// تراکنش با ایزولیشن Serializable + تلاش مجدد خودکار روی P2034 (تعارض تراکنش همزمان).
// برای عملیاتی که «چک + نوشتن» اتمی می‌خواهند (چک موجودی در ثبت/ویرایش سفارش،
// خروج کارتن، حذف سفارش) تا oversell و race رخ ندهد: دو تراکنش هم‌زمان که روی
// ردیف‌های مشترک می‌خوانند/می‌نویسند، یکی با P2034 رد می‌شود و بعد از retry
// وضعیت تازه را می‌بیند و تصمیم درست می‌گیرد.
export const runSerializable = async <T>(
    fn: (tx: Prisma.TransactionClient) => Promise<T>,
    attempts = 4,
): Promise<T> => {
    for (let attempt = 1; ; attempt++) {
        try {
            return await prisma.$transaction(fn, {
                isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
                maxWait: 5000,
                timeout: 20000,
            });
        } catch (e) {
            const serializationConflict =
                e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2034';
            if (serializationConflict && attempt < attempts) continue;
            throw e;
        }
    }
};