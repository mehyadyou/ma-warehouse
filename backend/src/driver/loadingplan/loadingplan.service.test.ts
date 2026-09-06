import { describe, it, expect, vi, beforeEach } from 'vitest';
import { loadingPlanService } from './loadingplan.service';

const mocks = vi.hoisted(() => {
    const carrierFindMany = vi.fn();
    const orderFindMany = vi.fn();
    return { carrierFindMany, orderFindMany };
});

vi.mock('../../utils/prisma', () => ({
    prisma: {
        carrier: { findMany: mocks.carrierFindMany },
        order: { findMany: mocks.orderFindMany },
    },
}));

beforeEach(() => {
    vi.clearAllMocks();
});

const carrierRow = (name: string, priority: number) => ({ name, priority });

const basePlanRow = {
    city: null,
    postalCode: null,
    address: null,
    customerPhone: null,
    senderName: null,
    receiverName: null,
    items: [],
    cartons: [],
};

const planOrderRow = (id: string, carrier: string, createdAt: string) => ({
    id,
    carrier,
    createdAt: new Date(createdAt),
    ...basePlanRow,
});

describe('loadingPlanService.getLoadingPlan — صف بارگیری طبق چیدمان باربری انباردار', () => {
    it('سفارش‌ها دقیقاً بر اساس اولویتِ باربری (۰ = بالای صف) چیده می‌شوند', async () => {
        // چیدمان انباردار: قدس اول (اولویت ۰)، فارس دوم (۱)، جاوید سوم (۲)
        mocks.carrierFindMany.mockResolvedValue([
            carrierRow('باربری فارس', 1),
            carrierRow('باربری قدس', 0),
            carrierRow('باربری جاوید ترابر', 2),
        ]);
        // خروجی دیتابیس به‌هم‌ریخته است — صف باید آن را اصلاح کند
        mocks.orderFindMany
            .mockResolvedValueOnce([
                planOrderRow('o-javid', 'باربری جاوید ترابر', '2026-01-03'),
                planOrderRow('o-fars', 'باربری فارس', '2026-01-02'),
                planOrderRow('o-ghods', 'باربری قدس', '2026-01-01'),
            ])
            .mockResolvedValueOnce([]);

        const result = await loadingPlanService.getLoadingPlan('d1', 'w1');

        expect(result.plan.map((o) => o.carrier)).toEqual([
            'باربری قدس',
            'باربری فارس',
            'باربری جاوید ترابر',
        ]);
        expect(result.plan.map((o) => o.priority)).toEqual([0, 1, 2]);
        // شماره‌گذاری صف از ۱
        expect(result.plan.map((o) => o.sequence)).toEqual([1, 2, 3]);
    });

    it('فقط سفارش‌های SHIPPEDِ تخصیص‌داده‌شده به همین راننده صف را می‌سازند', async () => {
        mocks.carrierFindMany.mockResolvedValue([carrierRow('باربری فارس', 0)]);
        mocks.orderFindMany.mockResolvedValueOnce([]).mockResolvedValueOnce([]);

        await loadingPlanService.getLoadingPlan('d1', 'w1');

        const planWhere = mocks.orderFindMany.mock.calls[0][0].where;
        expect(planWhere.warehouseId).toBe('w1');
        expect(planWhere.status).toBe('SHIPPED');
        expect(planWhere.delivery).toEqual({ is: { driverId: 'd1' } });

        const pendingWhere = mocks.orderFindMany.mock.calls[1][0].where;
        expect(pendingWhere.status).toBe('PENDING');
    });

    it('سفارش با باربریِ خارج از لیست (حذف/تغییرنام‌شده) به انتهای صف می‌رود', async () => {
        mocks.carrierFindMany.mockResolvedValue([carrierRow('باربری قدس', 0)]);
        mocks.orderFindMany
            .mockResolvedValueOnce([
                planOrderRow('o-tipax', 'تیپاکس', '2026-01-02'),
                planOrderRow('o-ghods', 'باربری قدس', '2026-01-01'),
            ])
            .mockResolvedValueOnce([]);

        const result = await loadingPlanService.getLoadingPlan('d1', 'w1');

        expect(result.plan.map((o) => o.carrier)).toEqual(['باربری قدس', 'تیپاکس']);
        expect(result.plan[1].priority).toBe(99);
    });

    it('باربری تغییرنام‌داده‌شده: سفارش قدیمی «باربری فارس» با باربری «فارس» تطبیق می‌یابد', async () => {
        // انباردار «باربری فارس» را به «فارس» تغییرنام داده — سفارش‌های قدیمی نام کهنه دارند
        mocks.carrierFindMany.mockResolvedValue([
            carrierRow('باربری قدس', 0),
            carrierRow('فارس', 1),
        ]);
        mocks.orderFindMany
            .mockResolvedValueOnce([
                planOrderRow('o-fars-old', 'باربری فارس', '2026-01-02'),
                planOrderRow('o-ghods', 'باربری قدس', '2026-01-01'),
            ])
            .mockResolvedValueOnce([]);

        const result = await loadingPlanService.getLoadingPlan('d1', 'w1');

        // سفارش قدیمی به‌جای ته صف (۹۹)، با جایگاه واقعی باربری صف می‌شود
        expect(result.plan.map((o) => o.carrier)).toEqual(['باربری قدس', 'باربری فارس']);
        expect(result.plan.map((o) => o.priority)).toEqual([0, 1]);
    });

    it('اختلاف نامرئی (نیم‌فاصله/فاصلهٔ اضافه) صف را نمی‌شکند', async () => {
        // کاربر در فرم باربری نیم‌فاصله تایپ کرده ولی سفارش با فاصلهٔ معمولی ثبت شده
        mocks.carrierFindMany.mockResolvedValue([carrierRow('باربری قدس', 0)]);
        mocks.orderFindMany
            .mockResolvedValueOnce([
                planOrderRow('o-zwnj', 'باربری قدس ', '2026-01-01'),
            ])
            .mockResolvedValueOnce([]);

        const result = await loadingPlanService.getLoadingPlan('d1', 'w1');

        expect(result.plan[0].priority).toBe(0);
        expect(result.plan[0].sequence).toBe(1);
    });

    it('دو سفارشِ یک باربری: کهنه‌ترین اول — دیتابیس با createdAt صعودی می‌آید و sort پایدار آن را حفظ می‌کند', async () => {
        mocks.carrierFindMany.mockResolvedValue([carrierRow('باربری قدس', 0)]);
        // خروجی پرزیما با orderBy createdAt صعودی — ترتیبِ داخلِ یک باربری نباید به‌هم بخورد
        mocks.orderFindMany
            .mockResolvedValueOnce([
                planOrderRow('o-old', 'باربری قدس', '2026-01-01'),
                planOrderRow('o-new', 'باربری قدس', '2026-02-02'),
            ])
            .mockResolvedValueOnce([]);

        const result = await loadingPlanService.getLoadingPlan('d1', 'w1');

        // همان ترتیب قطعی حفظ می‌شود
        expect(result.plan.map((o) => o.orderId)).toEqual(['o-old', 'o-new']);
        // و از پرزیما هم همین ترتیب خواسته شده تا خروجیِ صفِ هم‌اولویت قابل پیش‌بینی باشد
        const orderBy = mocks.orderFindMany.mock.calls[0][0].orderBy;
        expect(orderBy).toEqual({ createdAt: 'asc' });
    });

    it('سفارش‌های در انتظار خروج جدا از صف برمی‌گردند و شماره نمی‌گیرند', async () => {
        mocks.carrierFindMany.mockResolvedValue([carrierRow('باربری قدس', 0)]);
        mocks.orderFindMany
            .mockResolvedValueOnce([planOrderRow('o-shipped', 'باربری قدس', '2026-01-01')])
            .mockResolvedValueOnce([
                {
                    id: 'o-pending',
                    orderNumber: 7,
                    carrier: 'باربری قدس',
                    city: 'تهران',
                    address: null,
                    customerPhone: null,
                    senderName: null,
                    receiverName: null,
                    createdAt: new Date('2026-02-01'),
                    items: [],
                },
            ]);

        const result = await loadingPlanService.getLoadingPlan('d1', 'w1');

        expect(result.totalOrders).toBe(1);
        expect(result.plan).toHaveLength(1);
        expect(result.pendingOrders).toHaveLength(1);
        expect(result.pendingOrders[0].orderNumber).toBe(7);
    });

    it('سفارش‌های در انتظار هم به ترتیب صف باربری چیده می‌شوند؛ داخل هر باربری جدیدترین اول', async () => {
        // چیدمان انباردار: فارس بالا (اولویت ۰)، قدس دوم (۱) — تیپاکس در لیست نیست
        mocks.carrierFindMany.mockResolvedValue([
            carrierRow('باربری فارس', 0),
            carrierRow('باربری قدس', 1),
        ]);
        const pendingRow = (id: string, orderNumber: number, carrier: string, createdAt: string) => ({
            id,
            orderNumber,
            carrier,
            city: null,
            address: null,
            customerPhone: null,
            senderName: null,
            receiverName: null,
            createdAt: new Date(createdAt),
            items: [],
        });
        // خروجی پرزیما createdAt نزولی — مرتب‌سازی پایدار باید هم‌اولویت‌ها را همین‌طور نگه دارد
        mocks.orderFindMany
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([
                pendingRow('p-tipax', 3, 'تیپاکس', '2026-01-07'),
                pendingRow('p-fars', 2, 'باربری فارس', '2026-01-06'),
                pendingRow('p-ghods-new', 1, 'باربری قدس', '2026-01-05'),
                pendingRow('p-ghods-old', 0, 'باربری قدس', '2026-01-04'),
            ]);

        const result = await loadingPlanService.getLoadingPlan('d1', 'w1');

        // صف: فارس اول، بعد قدس (جدیدترین اول)، تیپاکسِ خارج از لیست آخر
        expect(result.pendingOrders.map((o) => o.carrier)).toEqual([
            'باربری فارس',
            'باربری قدس',
            'باربری قدس',
            'تیپاکس',
        ]);
        expect(result.pendingOrders.map((o) => o.orderNumber)).toEqual([2, 1, 0, 3]);
    });
});
