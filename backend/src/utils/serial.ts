import type { Prisma } from '@prisma/client';
import { jalaliYear } from './jalali';

export const SERIAL_PREFIX = 'MA';

// سریال بعدی در همان تراکنش ورود کالا — upsert اتمی روی شمارنده سال شمسی
export const nextSerial = async (tx: Prisma.TransactionClient): Promise<string> => {
    const year = jalaliYear(new Date());
    const row = await tx.serialSequence.upsert({
        where: { year },
        update: { lastSeq: { increment: 1 } },
        create: { year, lastSeq: 1 },
    });
    return `${SERIAL_PREFIX}-${year}-${String(row.lastSeq).padStart(6, '0')}`;
};
