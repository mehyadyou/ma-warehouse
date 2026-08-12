import { prisma } from '../../utils/prisma';
import { cached } from '../../utils/cache';
import { Prisma } from '@prisma/client';

const HISTORY_MAX_PAGE_SIZE = 500;

const HISTORY_CATEGORIES: Record<string, string[]> = {
    products: ['product_created', 'product_updated', 'product_checkin', 'product_archived', 'product_restored', 'model_archived', 'model_restored'],
    warehouses: ['warehouse_archived', 'warehouse_restored'],
    users: ['user_created', 'user_role_changed', 'user_warehouse_changed', 'user_deleted'],
    shipments: ['order_created', 'order_updated', 'order_deleted', 'order_shipped', 'order_completed'],
    returns: ['return_received'],
};

export interface HistoryQuery {
    page?: number;
    pageSize?: number;
    category?: string;
    q?: string;
}

export const dashboardService = {
    //داشبورد مدیر
    getDashboard: async () => cached('dash:manager', 45, async () => {
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
    }),

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

    //تاریخچهٔ کامل سیستم — صفحه‌بندی + فیلتر دسته + جستجو (بدون پارامتر = رفتار قبلی: ۵۰۰ ردیف اول)
    getHistory: async (opts: HistoryQuery = {}) => {
        const pageSize = Math.min(HISTORY_MAX_PAGE_SIZE, Math.max(1, Number.isFinite(opts.pageSize) ? Math.floor(opts.pageSize as number) : HISTORY_MAX_PAGE_SIZE));
        const page = Math.max(1, Number.isFinite(opts.page) ? Math.floor(opts.page as number) : 1);
        const types = opts.category && opts.category !== 'all' ? HISTORY_CATEGORIES[opts.category] : undefined;
        const search = opts.q?.trim();

        const conds: Prisma.Sql[] = [];
        if (types) conds.push(Prisma.sql`al."type" IN (${Prisma.join(types, ',')})`);
        if (search) conds.push(Prisma.sql`(al."label" ILIKE ${`%${search}%`} OR u."name" ILIKE ${`%${search}%`})`);
        const whereSql = conds.length ? Prisma.sql`WHERE ${Prisma.join(conds, ' AND ')}` : Prisma.empty;

        const fromSql = Prisma.sql`
            FROM "ActivityLog" al
            JOIN "User" u ON al."userId" = u.id
            ${whereSql}
        `;

        const [countRows, entries] = await Promise.all([
            prisma.$queryRaw<{ count: number }[]>`
                SELECT COUNT(*)::int AS count
                ${fromSql}
            `,
            prisma.$queryRaw<Array<Record<string, unknown>>>`
                SELECT al.id, al.type, al.label, al."orderId", al."createdAt", u.name as "userName"
                ${fromSql}
                ORDER BY al."createdAt" DESC
                LIMIT ${pageSize} OFFSET ${(page - 1) * pageSize}
            `,
        ]);

        const total = countRows[0]?.count ?? 0;
        return { entries, total, page, pageSize };
    },
};