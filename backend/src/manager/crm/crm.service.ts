import { prisma } from '../../utils/prisma';
import { cached } from '../../utils/cache';
import { jalaliDayKey } from '../../utils/jalali';
import { Prisma } from '@prisma/client';

// NOTE (L5 — سیاست دقت اعشاری): قیمت‌ها در DB با Decimal ذخیره می‌شوند و اینجا
// فقط برای نمایش به Number تبدیل می‌شوند — هیچ محاسبهٔ مالیِ حساس روی مقدار
// تبدیل‌شده انجام نمی‌شود (جمع‌ها نمایشی‌اند، نه سند حسابداری).

const toNumber = (v: Prisma.Decimal | null | undefined): number | null =>
    v == null ? null : Number(v);

const clampPage = (v: unknown, def = 1) => {
    const n = Math.floor(Number(v));
    return Number.isFinite(n) && n > 0 ? n : def;
};

const clampSize = (v: unknown, def = 20, max = 100) => {
    const n = Math.floor(Number(v));
    if (!Number.isFinite(n) || n < 1) return def;
    return Math.min(n, max);
};

const parseDate = (v: unknown): Date | undefined => {
    if (typeof v !== 'string' || !v.trim()) return undefined;
    const d = new Date(v.trim());
    return Number.isNaN(d.getTime()) ? undefined : d;
};

export interface CustomersQuery {
    q?: string;
    page?: number;
    pageSize?: number;
}

export interface AuditQuery {
    actorId?: string;
    entity?: string;
    action?: string;
    from?: string;
    to?: string;
    page?: number;
    pageSize?: number;
}

export interface UserActivityQuery {
    userId?: string;
    from?: string;
    to?: string;
    limit?: number;
}

export interface FinanceQuery {
    from?: string;
    to?: string;
    warehouseId?: string;
}

export interface ApiUsageQuery {
    from?: number;
    to?: number;
}

export const crmService = {
    //نمای کلی مالک: شمارنده‌ها + سفارش‌های امروز + عمق صف خروجی — کش ۳۰ ثانیه
    getOverview: async () =>
        cached('crm:overview', 30, async () => {
            const today = jalaliDayKey(new Date());
            const [
                usersCount,
                warehousesCount,
                ordersPending,
                transfersPending,
                outboxPending,
                outboxFailed,
                todayOrders,
            ] = await Promise.all([
                prisma.user.count({ where: { deletedAt: null } }),
                prisma.warehouse.count({ where: { deletedAt: null } }),
                prisma.order.count({ where: { status: 'PENDING' } }),
                prisma.transfer.count({ where: { status: 'PENDING' } }),
                prisma.outboxEvent.count({ where: { status: 'PENDING' } }),
                prisma.outboxEvent.count({ where: { status: 'FAILED' } }),
                prisma.order.count({ where: { orderDay: today } }),
            ]);
            return {
                usersCount,
                warehousesCount,
                ordersPending,
                transfersPending,
                outboxPending,
                outboxFailed,
                todayOrders,
                todayDayKey: today,
            };
        }),

    //مشتریان بر اساس شماره موبایل (بدون مدل جدید): تعداد سفارش + جمع خرید + آخرین سفارش
    getCustomers: async (opts: CustomersQuery = {}) => {
        const page = clampPage(opts.page);
        const pageSize = clampSize(opts.pageSize);
        const q = opts.q?.trim() || '';
        const phoneFilter = q ? { contains: q } : { not: null };
        const where = { customerPhone: phoneFilter };

        const totalRows: Array<{ n: number }> = await prisma.$queryRaw`
            SELECT COUNT(*)::int AS n FROM (
                SELECT DISTINCT "customerPhone" FROM "Order"
                WHERE "customerPhone" IS NOT NULL
                ${q ? Prisma.sql`AND "customerPhone" ILIKE ${'%' + q + '%'}` : Prisma.empty}
            ) t`;
        const total = totalRows[0]?.n ?? 0;

        const groups = await prisma.order.groupBy({
            by: ['customerPhone'],
            where: { customerPhone: q ? { contains: q } : { not: null } },
            _count: { _all: true },
            _max: { createdAt: true },
            orderBy: { _max: { createdAt: 'desc' } },
            skip: (page - 1) * pageSize,
            take: pageSize,
        });

        const phones = groups.map((g) => g.customerPhone as string);
        const withItems = phones.length
            ? await prisma.order.findMany({
                  where: { customerPhone: { in: phones } },
                  select: {
                      customerPhone: true,
                      city: true,
                      receiverName: true,
                      items: { select: { quantity: true, price: true } },
                  },
              })
            : [];

        const agg = new Map<string, { orders: number; spent: number; items: number; city: string | null; name: string | null; lastAt: string | null }>();
        for (const g of groups) {
            agg.set(g.customerPhone as string, {
                orders: g._count._all,
                spent: 0,
                items: 0,
                city: null,
                name: null,
                lastAt: g._max.createdAt ? (g._max.createdAt as Date).toISOString() : null,
            });
        }
        for (const o of withItems) {
            const a = agg.get(o.customerPhone as string);
            if (!a) continue;
            a.city = a.city ?? o.city ?? null;
            a.name = a.name ?? o.receiverName ?? null;
            for (const it of o.items) {
                a.items += it.quantity;
                a.spent += (toNumber(it.price) ?? 0) * it.quantity;
            }
        }

        return {
            customers: phones.map((phone) => ({ phone, ...agg.get(phone)! })),
            total,
            page,
            pageSize,
            where,
        };
    },

    //تایم‌لاین یک مشتری: سفارش‌ها (با اقلام/تحویل/انبار) + فعالیت‌های مرتبط
    getCustomerDetail: async (phone: string) => {
        const orders = await prisma.order.findMany({
            where: { customerPhone: phone },
            orderBy: { createdAt: 'desc' },
            take: 100,
            include: {
                items: { include: { product: { select: { name: true } } } },
                delivery: { select: { status: true, deliveredAt: true, driver: { select: { name: true } } } },
                warehouse: { select: { id: true, name: true } },
            },
        });
        let spent = 0;
        let items = 0;
        for (const o of orders) {
            for (const it of o.items) {
                items += it.quantity;
                spent += (toNumber(it.price) ?? 0) * it.quantity;
            }
        }
        const orderIds = orders.map((o) => o.id);
        const activity = orderIds.length
            ? await prisma.activityLog.findMany({
                  where: { orderId: { in: orderIds } },
                  orderBy: { createdAt: 'desc' },
                  take: 50,
              })
            : [];
        return {
            phone,
            totals: { orders: orders.length, spent, items },
            orders: orders.map((o) => ({
                ...o,
                items: o.items.map((it) => ({ ...it, price: toNumber(it.price), exchangeRate: toNumber(it.exchangeRate) })),
            })),
            activity,
        };
    },

    //خواندن AuditLog — دیتا بود و API نداشت؛ از ایندکس‌های موجود استفاده می‌شود
    getAudit: async (opts: AuditQuery = {}) => {
        const page = clampPage(opts.page);
        const pageSize = clampSize(opts.pageSize);
        const from = parseDate(opts.from);
        const to = parseDate(opts.to);
        const where: Prisma.AuditLogWhereInput = {
            ...(opts.actorId?.trim() ? { actorId: opts.actorId.trim() } : {}),
            ...(opts.entity?.trim() ? { entity: opts.entity.trim() } : {}),
            ...(opts.action?.trim() ? { action: { contains: opts.action.trim(), mode: 'insensitive' } } : {}),
            ...((from || to)
                ? { createdAt: { ...(from ? { gte: from } : {}), ...(to ? { lte: to } : {}) } }
                : {}),
        };
        const [rows, total] = await prisma.$transaction([
            prisma.auditLog.findMany({ where, orderBy: { createdAt: 'desc' }, skip: (page - 1) * pageSize, take: pageSize }),
            prisma.auditLog.count({ where }),
        ]);
        return { entries: rows, total, page, pageSize };
    },

    //تایم‌لاین یک کاربر (یا همه): Activity + Audit + تراکنش — ادغام‌شده و نزولی
    getUserActivity: async (opts: UserActivityQuery = {}) => {
        const limit = clampSize(opts.limit, 50, 200);
        const from = parseDate(opts.from);
        const to = parseDate(opts.to);
        const range = (from || to)
            ? { createdAt: { ...(from ? { gte: from } : {}), ...(to ? { lte: to } : {}) } }
            : {};
        const [activities, audits, transactions] = await Promise.all([
            prisma.activityLog.findMany({
                where: { ...(opts.userId?.trim() ? { userId: opts.userId.trim() } : {}), ...range },
                orderBy: { createdAt: 'desc' },
                take: limit,
            }),
            prisma.auditLog.findMany({
                where: { ...(opts.userId?.trim() ? { actorId: opts.userId.trim() } : {}), ...range },
                orderBy: { createdAt: 'desc' },
                take: limit,
            }),
            prisma.transaction.findMany({
                where: { ...(opts.userId?.trim() ? { userId: opts.userId.trim() } : {}), ...range },
                orderBy: { createdAt: 'desc' },
                take: limit,
            }),
        ]);
        const merged = [
            ...activities.map((a) => ({ kind: 'activity' as const, at: a.createdAt, data: a })),
            ...audits.map((a) => ({ kind: 'audit' as const, at: a.createdAt, data: a })),
            ...transactions.map((t) => ({ kind: 'transaction' as const, at: t.createdAt, data: t })),
        ]
            .sort((x, y) => y.at.getTime() - x.at.getTime())
            .slice(0, limit);
        return {
            entries: merged.map((e) => ({
                kind: e.kind,
                at: e.at.toISOString(),
                ...('type' in e.data ? { type: (e.data as { type: string }).type } : {}),
                ...('action' in e.data ? { action: (e.data as { action: string }).action } : {}),
                data: e.data,
            })),
            counts: { activities: activities.length, audits: audits.length, transactions: transactions.length },
            limit,
        };
    },

    //مالی نمایشی: جمع مبالغ/واحدها + تفکیک روز/انبار/شهر/باربری (سقف ۵۰۰۰ سفارش)
    getFinance: async (opts: FinanceQuery = {}) => {
        const from = parseDate(opts.from);
        const to = parseDate(opts.to);
        const orders = await prisma.order.findMany({
            where: {
                ...(opts.warehouseId?.trim() ? { warehouseId: opts.warehouseId.trim() } : {}),
                ...((from || to)
                    ? { createdAt: { ...(from ? { gte: from } : {}), ...(to ? { lte: to } : {}) } }
                    : {}),
            },
            orderBy: { createdAt: 'desc' },
            take: 5000,
            select: {
                id: true,
                createdAt: true,
                status: true,
                city: true,
                carrier: true,
                shippingMethod: true,
                warehouseId: true,
                warehouse: { select: { name: true } },
                items: { select: { quantity: true, price: true } },
            },
        });
        let revenue = 0;
        let units = 0;
        const byDay = new Map<string, { revenue: number; units: number; orders: number }>();
        const byWarehouse = new Map<string, { name: string; revenue: number; units: number; orders: number }>();
        const byCity = new Map<string, { revenue: number; units: number; orders: number }>();
        const byCarrier = new Map<string, { revenue: number; units: number; orders: number }>();
        const bump = (m: Map<string, { revenue: number; units: number; orders: number }>, key: string, extra: { name?: string }, rev: number, unit: number) => {
            const cur = m.get(key) ?? { revenue: 0, units: 0, orders: 0, ...extra };
            cur.revenue += rev;
            cur.units += unit;
            cur.orders += 1;
            m.set(key, cur);
        };
        for (const o of orders) {
            let rev = 0;
            let unit = 0;
            for (const it of o.items) {
                unit += it.quantity;
                rev += (toNumber(it.price) ?? 0) * it.quantity;
            }
            revenue += rev;
            units += unit;
            const day = o.createdAt.toISOString().slice(0, 10);
            bump(byDay, day, {}, rev, unit);
            bump(byWarehouse, o.warehouseId, { name: o.warehouse?.name ?? o.warehouseId }, rev, unit);
            bump(byCity, o.city?.trim() || 'نامشخص', {}, rev, unit);
            bump(byCarrier, o.carrier?.trim() || o.shippingMethod, {}, rev, unit);
        }
        const asList = (m: Map<string, Record<string, unknown>>) =>
            [...m.entries()].map(([key, v]) => ({ key, ...v }));
        return {
            totals: { revenue, units, orders: orders.length, capped: orders.length >= 5000 },
            byDay: asList(byDay).sort((a, b) => String(a.key) < String(b.key) ? 1 : -1),
            byWarehouse: asList(byWarehouse),
            byCity: asList(byCity),
            byCarrier: asList(byCarrier),
        };
    },

    //مصرف کلیدهای API به‌تفکیک روز (۱۴ روز اخیر پیش‌فرض)
    getApiUsage: async (opts: ApiUsageQuery = {}) => {
        const today = jalaliDayKey(new Date());
        const to = Number.isFinite(Number(opts.to)) && Number(opts.to) > 0 ? Math.floor(Number(opts.to)) : today;
        const from = Number.isFinite(Number(opts.from)) && Number(opts.from) > 0 ? Math.floor(Number(opts.from)) : to - 13;
        const rows = await prisma.apiKeyDailyUsage.findMany({
            where: { dayKey: { gte: Math.min(from, to), lte: Math.max(from, to) } },
            orderBy: [{ dayKey: 'desc' }, { hits: 'desc' }],
            take: 1000,
            include: { apiKey: { select: { id: true, name: true, prefix: true, isActive: true } } },
        });
        const perKey = new Map<string, { key: unknown; totalHits: number; totalErrors: number; days: Array<{ day: number; hits: number; errors: number }> }>();
        for (const r of rows) {
            const cur = perKey.get(r.apiKeyId) ?? { key: r.apiKey, totalHits: 0, totalErrors: 0, days: [] };
            cur.totalHits += r.hits;
            cur.totalErrors += r.errors;
            cur.days.push({ day: r.dayKey, hits: r.hits, errors: r.errors });
            perKey.set(r.apiKeyId, cur);
        }
        return { from: Math.min(from, to), to: Math.max(from, to), keys: [...perKey.values()] };
    },

    //سلامت سیستم برای مالک: شمارنده‌ها + عمق صف outbox + آپتایم + Redis
    getHealth: async () => {
        const [users, orders, cartons, products, transfers, outboxPending, outboxFailed, oldestPending] = await Promise.all([
            prisma.user.count({ where: { deletedAt: null } }),
            prisma.order.count(),
            prisma.carton.count(),
            prisma.product.count({ where: { deletedAt: null } }),
            prisma.transfer.count(),
            prisma.outboxEvent.count({ where: { status: 'PENDING' } }),
            prisma.outboxEvent.count({ where: { status: 'FAILED' } }),
            prisma.outboxEvent.findFirst({ where: { status: 'PENDING' }, orderBy: { createdAt: 'asc' }, select: { createdAt: true, type: true } }),
        ]);
        let redis: boolean | null = null;
        try {
            const { getRedis } = await import('../../utils/redis.js');
            redis = (await getRedis()) != null;
        } catch {
            redis = null;
        }
        return {
            counts: { users, orders, cartons, products, transfers },
            outbox: {
                pending: outboxPending,
                failed: outboxFailed,
                oldestPendingAt: oldestPending ? oldestPending.createdAt.toISOString() : null,
                oldestPendingType: oldestPending?.type ?? null,
            },
            redis,
            uptimeSec: Math.floor(process.uptime()),
            node: process.version,
            now: new Date().toISOString(),
        };
    },
};
