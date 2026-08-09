import { prisma } from '../../utils/prisma';

export const dashboardService = {
    //داشبورد مدیر
    getDashboard: async () => {
        const [usersCount, warehousesCount, driversCount, keepersCount] = await Promise.all([
            prisma.user.count({ where: { deletedAt: null } }),
            prisma.warehouse.count({ where: { deletedAt: null } }),
            prisma.user.count({ where: { role: 'DRIVER', deletedAt: null } }),
            prisma.user.count({ where: { role: 'WAREHOUSE_KEEPER', deletedAt: null } }),
        ]);

        return {
            usersCount,
            warehousesCount,
            driversCount,
            keepersCount,
        };
    },

    //همه تراکنش‌ها در یک روز
    getAllTransactionsByDate: async (date: string) => {
        const startOfDay = new Date(date);
        startOfDay.setHours(0, 0, 0, 0);
        const endOfDay = new Date(date);
        endOfDay.setHours(23, 59, 59, 999);

        const result = await prisma.$queryRaw`
            SELECT 
                t.id, t.type, t."productName", t.quantity, 
                t."warehouseId", w.name as "warehouseName",
                t."createdAt", u.name as "userName"
            FROM "Transaction" t
            JOIN "Warehouse" w ON t."warehouseId" = w.id
            JOIN "User" u ON t."userId" = u.id
            WHERE t."createdAt" >= ${startOfDay}
            AND t."createdAt" <= ${endOfDay}
            ORDER BY t."createdAt" DESC
        `;
        return result;
    },

    //فعالیت‌های اخیر
    getRecentActivities: async () => {
        const transactions = await prisma.$queryRaw`
            SELECT 
                t.id, t.type, t."productName" as title, t.quantity,
                t."createdAt", w.name as "warehouseName", u.name as "userName",
                'transaction' as "activityType"
            FROM "Transaction" t
            JOIN "Warehouse" w ON t."warehouseId" = w.id
            JOIN "User" u ON t."userId" = u.id
            ORDER BY t."createdAt" DESC
            LIMIT 10
        `;

        const orders = await prisma.$queryRaw`
            SELECT 
                o.id, o.status, o."createdAt", w.name as "warehouseName", u.name as "userName",
                'order' as "activityType"
            FROM "Order" o
            JOIN "Warehouse" w ON o."warehouseId" = w.id
            JOIN "User" u ON o."createdById" = u.id
            ORDER BY o."createdAt" DESC
            LIMIT 5
        `;

        const activityLog = await prisma.$queryRaw`
            SELECT 
                al.id, al.type, al.label, al."orderId", al."createdAt", u.name as "userName",
                'activityLog' as "activityType"
            FROM "ActivityLog" al
            JOIN "User" u ON al."userId" = u.id
            ORDER BY al."createdAt" DESC
            LIMIT 15
        `;

        return { transactions, orders, activityLog };
    },

    //تاریخچهٔ کامل سیستم — همهٔ وقایع ثبت‌شده با جزئیات دقیق
    getHistory: async () => {
        const entries = await prisma.$queryRaw`
            SELECT 
                al.id, al.type, al.label, al."orderId", al."createdAt", u.name as "userName"
            FROM "ActivityLog" al
            JOIN "User" u ON al."userId" = u.id
            ORDER BY al."createdAt" DESC
            LIMIT 500
        `;
        return entries;
    },
};