import type { Prisma } from '@prisma/client';
import { jalaliYear } from './jalali';

export const SERIAL_PREFIX = 'MA';

// سریال بعدی در همان تراکنش ورود کالا — upsert اتمی روی شمارنده سال شمسی
export const nextSerial = async (tx: Prisma.TransactionClient): Promise<string> => {
    return (await nextSerials(tx, 1))[0];
};

// تخصیص دسته‌ای N سریال با «یک» upsert اتمی (به‌جای N بار تک‌تک) —
// ورود ۵۰تایی، تراکنش را ۵۰ قفل متوالی روی ردیف شمارنده نگه نمی‌دارد.
// ترتیب آزادسازی با ترتیب مصرف در حلقه‌های checkin یکی است (صف‌بندی، نه deadlock).
export const nextSerials = async (tx: Prisma.TransactionClient, count: number): Promise<string[]> => {
    if (count <= 0) return [];
    const year = jalaliYear(new Date());
    const row = await tx.serialSequence.upsert({
        where: { year },
        update: { lastSeq: { increment: count } },
        create: { year, lastSeq: count },
    });
    const end = row.lastSeq;
    const start = end - count + 1;
    return Array.from(
        { length: count },
        (_, i) => `${SERIAL_PREFIX}-${year}-${String(start + i).padStart(6, '0')}`,
    );
};
