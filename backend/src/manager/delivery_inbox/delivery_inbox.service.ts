import { prisma } from '../../utils/prisma';
import { jalaliToGregorian } from '../../utils/jalali';
import type { Prisma } from '@prisma/client';

const DAY_MS = 24 * 60 * 60 * 1000;

/// بازهٔ میلادی [gte, lt) برای فیلتر شمسی:
/// فقط سال → کل سال | سال+ماه → همان ماه | سال+ماه+روز → همان روز
function shamsiDateRange(year?: number, month?: number, day?: number):
    { gte: Date; lt: Date } | undefined {
    if (!year) return undefined;
    const gte = jalaliToGregorian(year, month ?? 1, day ?? 1);
    let lt: Date;
    if (day) {
        lt = new Date(gte.getTime() + DAY_MS);
    } else if (month) {
        const [ny, nm] = month === 12 ? [year + 1, 1] : [year, month + 1];
        lt = jalaliToGregorian(ny, nm, 1);
    } else {
        lt = jalaliToGregorian(year + 1, 1, 1);
    }
    return { gte, lt };
}

export const deliveryInboxService = {
    /// صندوق تحویل: همهٔ عکس‌های بیجک ثبت‌شده با فیلتر راننده و روز/ماه/سال شمسی
    list: async ({
        driverId,
        year,
        month,
        day,
    }: {
        driverId?: string;
        year?: number;
        month?: number;
        day?: number;
    }) => {
        const where: Prisma.DeliveryWhereInput = {
            status: 'DELIVERED',
            // فقط تحویل‌هایی که عکس بیجک دارند وارد صندوق می‌شوند
            receiptUrl: { not: null },
            ...(driverId ? { driverId } : {}),
        };
        const dateRange = shamsiDateRange(year, month, day);
        if (dateRange) {
            where.deliveredAt = dateRange;
        }

        return prisma.delivery.findMany({
            where,
            include: {
                driver: { select: { id: true, name: true, phone: true } },
                order: {
                    select: {
                        id: true,
                        orderNumber: true,
                        warehouseId: true,
                        carrier: true,
                        city: true,
                        receiverName: true,
                        address: true,
                        customerPhone: true,
                    },
                },
            },
            orderBy: { deliveredAt: 'desc' },
            take: 500,
        });
    },

    /// برای فیلتر راننده: همهٔ راننده‌های فعال + راننده‌هایی که بیجک در صندوق دارند
    /// (حتی اگر بعداً غیرفعال شده باشند تا تحویل‌های قدیمی قابل فیلتر بمانند)
    listDrivers: async () => {
        const drivers = await prisma.user.findMany({
            where: {
                OR: [
                    { role: 'DRIVER', isActive: true },
                    {
                        deliveries: {
                            some: { status: 'DELIVERED', receiptUrl: { not: null } },
                        },
                    },
                ],
            },
            select: { id: true, name: true, phone: true },
        });
        return drivers.sort((a, b) => (a.name ?? '').localeCompare(b.name ?? '', 'fa'));
    },
};