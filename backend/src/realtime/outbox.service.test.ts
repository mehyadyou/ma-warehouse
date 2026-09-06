import { describe, it, expect, vi, beforeEach } from 'vitest';

const mocks = vi.hoisted(() => {
    const user = { findMany: vi.fn() };
    const outboxEvent = { findMany: vi.fn(), updateMany: vi.fn() };
    const notification = { create: vi.fn(), upsert: vi.fn() };
    return {
        user,
        outboxEvent,
        notification,
        create: vi.fn(),
        toWarehouse: vi.fn(),
        toRole: vi.fn(),
        toUser: vi.fn(),
    };
});

vi.mock('../utils/prisma', () => ({
    prisma: {
        user: mocks.user,
        outboxEvent: mocks.outboxEvent,
    },
}));

vi.mock('../notification/notification.service', () => ({
    notificationService: { create: mocks.create, upsert: mocks.notification.upsert },
}));

vi.mock('./realtime', () => ({
    realtime: { toWarehouse: mocks.toWarehouse, toRole: mocks.toRole, toUser: mocks.toUser },
}));

import { dispatchOutbox } from './outbox';

const ORDER_CREATED_PAYLOAD = {
    orderId: 'o1',
    warehouseId: 'whA',
    senderName: 'فرستنده ۱',
    receiverName: 'گیرنده ۱',
    createdAt: new Date().toISOString(),
};

const ORDER_DELETED_PAYLOAD = {
    orderId: 'o1',
    warehouseId: 'whA',
    senderName: 'فرستنده ۱',
    receiverName: 'گیرنده ۱',
};

function makeEvent(type: string, payload: unknown, attempts = 0) {
    return {
        id: 'ev1',
        type,
        payload,
        status: 'PENDING',
        attempts,
        createdAt: new Date(),
    };
}

beforeEach(() => {
    vi.clearAllMocks();
    mocks.outboxEvent.findMany.mockResolvedValue([]);
    mocks.outboxEvent.updateMany.mockResolvedValue({ count: 1 });
    mocks.user.findMany.mockResolvedValue([{ id: 'k1' }]);
    mocks.create.mockResolvedValue({ id: 'n1' });
    mocks.notification.upsert.mockResolvedValue({ id: 'n1' });
});

describe('dispatchOutbox - نوتیفیکیشن سفارش برای انباردار', () => {
    it('سفارش جدید: نوتیفیکیشن فقط برای انباردارِ همان انبار ساخته میشود و به اتاق آن انبار ارسال میشود', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:created', ORDER_CREATED_PAYLOAD),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);

        // کوئری انباردار فقط با warehouseId داخل payload (انبار انتخاب‌شده) اجرا میشود
        const keeperQuery = mocks.user.findMany.mock.calls.find(
            ([args]) => (args as any)?.where?.role === 'WAREHOUSE_KEEPER',
        );
        expect(keeperQuery).toBeDefined();
        expect((keeperQuery![0] as any).where.warehouseId).toBe('whA');

        // نوتیفیکیشن فقط برای انباردارِ همان انبار
        expect(mocks.create).toHaveBeenCalledTimes(1);
        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            'سفارش جدید',
            expect.stringContaining('فرستنده ۱'),
            'info',
            expect.objectContaining({
                type: 'NEW_ORDER',
                orderId: 'o1',
                warehouseId: 'whA',
            }),
            'ev1:k1',
        );

        // ریل‌تایم به اتاق همان انبار (نه انبار دیگر)
        expect(mocks.toWarehouse).toHaveBeenCalledWith('whA', 'order:created', ORDER_CREATED_PAYLOAD);
        expect(mocks.toRole).toHaveBeenCalledWith('MANAGER', 'order:created', ORDER_CREATED_PAYLOAD);

        // رویداد تحویل‌شده علامت‌گذاری میشود (stuck-recovery + claim + dispatched)
        expect(mocks.outboxEvent.updateMany).toHaveBeenCalledTimes(3);
    });

    it('سفارش جدید: انباردارِ انبار دیگر هیچ نوتیفیکیشنی نمیگیرد', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:created', ORDER_CREATED_PAYLOAD),
        ]);
        // فقط انباردارِ انبار A وجود دارد؛ انبار B هیچ انبارداری ندارد
        mocks.user.findMany.mockResolvedValue([{ id: 'k1' }]);

        await dispatchOutbox();

        expect(mocks.create).toHaveBeenCalledTimes(1);
        expect(mocks.create.mock.calls[0][0]).toBe('k1');
    });

    it('حذف سفارش: نوتیفیکیشن حذف برای انباردار همان انبار ساخته میشود', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:deleted', ORDER_DELETED_PAYLOAD),
        ]);

        await dispatchOutbox();

        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            'حذف سفارش',
            expect.stringContaining('توسط مدیریت حذف شد'),
            'warning',
            expect.objectContaining({
                type: 'ORDER_DELETED',
                orderId: 'o1',
                warehouseId: 'whA',
            }),
            expect.any(String),
        );
        expect(mocks.toWarehouse).toHaveBeenCalledWith('whA', 'order:deleted', ORDER_DELETED_PAYLOAD);
    });

    it('خطا در ساخت نوتیفیکیشن: رویداد برای تلاش مجدد PENDING میماند و تلاشها شمارش میشود', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:created', ORDER_CREATED_PAYLOAD),
        ]);
        mocks.create.mockRejectedValueOnce(new Error('db down'));

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(0);
        expect(mocks.outboxEvent.updateMany).toHaveBeenLastCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({ attempts: 1, status: 'PENDING' }),
            }),
        );
    });

    it('انبار بدون انباردار: بدون کرش، فقط رویداد ریل‌تایم ارسال میشود', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:created', ORDER_CREATED_PAYLOAD),
        ]);
        mocks.user.findMany.mockResolvedValue([]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        expect(mocks.create).not.toHaveBeenCalled();
        expect(mocks.toWarehouse).toHaveBeenCalledTimes(1);
    });

    it('بازچینی صف باربری توسط انباردار: رویداد زنده به همهٔ راننده‌ها ارسال می‌شود', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('carriers:reordered', { ids: ['c2', 'c1'], count: 2 }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        // بدون نوتیفیکیشن — فقط ریل‌تایم به اتاق نقش راننده
        expect(mocks.create).not.toHaveBeenCalled();
        expect(mocks.toRole).toHaveBeenCalledWith(
            'DRIVER',
            'carriers:reordered',
            { ids: ['c2', 'c1'], count: 2 },
        );
        expect(mocks.toWarehouse).not.toHaveBeenCalled();
    });

    it('تحویل سفارش: نوتیفیکیشن به مدیر و انباردارِ همان انبار با نام باربری', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('delivery:completed', {
                orderId: 'o1',
                orderNumber: 42,
                driverId: 'd1',
                driverName: 'علی',
                receiverName: 'رضا',
                city: 'تهران',
                carrier: 'باربری آفتاب',
                warehouseId: 'whA',
                warehouseName: 'انبار مرکزی',
                receiptUrl: '/uploads/receipts/bijak.jpg',
                deliveredAt: new Date().toISOString(),
            }),
        ]);
        mocks.user.findMany.mockImplementation(({ where }: any) =>
            where?.role === 'MANAGER'
                ? Promise.resolve([{ id: 'm1' }])
                : Promise.resolve([{ id: 'k1' }]),
        );

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);

        // مدیر: چه سفارشی به چه باربری تحویل داده شد
        expect(mocks.create).toHaveBeenCalledWith(
            'm1',
            'تحویل سفارش',
            expect.stringContaining('باربری آفتاب'),
            'success',
            expect.objectContaining({
                type: 'DELIVERY_COMPLETED',
                orderId: 'o1',
                orderNumber: 42,
                carrier: 'باربری آفتاب',
                warehouseId: 'whA',
                receiptUrl: '/uploads/receipts/bijak.jpg',
            }),
            'ev1:m1',
        );

        // انباردارِ همان انبار هم مطلع می‌شود
        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            'تحویل سفارش',
            expect.stringContaining('سفارش 42'),
            'success',
            expect.objectContaining({ type: 'DELIVERY_COMPLETED' }),
            'ev1:k1',
        );

        expect(mocks.toRole).toHaveBeenCalledWith('MANAGER', 'delivery:completed', expect.any(Object));
        expect(mocks.toWarehouse).toHaveBeenCalledWith('whA', 'delivery:completed', expect.any(Object));
    });
});

describe('dispatchOutbox - ویرایش سفارش (مدیر → انبار)', () => {
    it('ویرایش سفارش: نوتیفیکیشن برای انباردارِ همان انبار + ریل‌تایم', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:updated', {
                orderId: 'o1',
                warehouseId: 'whA',
                senderName: 'فرستنده ۱',
                receiverName: 'گیرنده ۱',
                updatedAt: new Date().toISOString(),
            }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            'ویرایش سفارش',
            expect.stringContaining('گیرنده ۱'),
            'info',
            expect.objectContaining({ type: 'ORDER_UPDATED', orderId: 'o1', warehouseId: 'whA' }),
            expect.any(String),
        );
        expect(mocks.toWarehouse).toHaveBeenCalledWith('whA', 'order:updated', expect.any(Object));
    });
});

describe('dispatchOutbox - دستورهای جابه‌جایی/خروج مدیر (مدیر → انبار)', () => {
    function usersByRoleWarehouse() {
        mocks.user.findMany.mockImplementation(({ where }: any) => {
            if (where?.role === 'MANAGER') return Promise.resolve([{ id: 'm1' }]);
            if (where?.role === 'WAREHOUSE_KEEPER') {
                if (where?.warehouseId === 'wh1') return Promise.resolve([{ id: 'k1' }]);
                if (where?.warehouseId === 'wh2') return Promise.resolve([{ id: 'k2' }]);
            }
            return Promise.resolve([]);
        });
    }

    it('دستور جابه‌جایی PENDING: نوتیف به انباردارهای مبدأ و مقصد + ریل‌تایم به هر دو انبار', async () => {
        usersByRoleWarehouse();
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('transfer:created', {
                transferId: 't1',
                kind: 'transfer',
                fromWarehouseId: 'wh1',
                fromWarehouseName: 'انبار تهران',
                toWarehouseId: 'wh2',
                toWarehouseName: 'انبار کرج',
                productId: 'p1',
                productName: 'کالای A',
                modelId: null,
                modelName: null,
                quantity: 20,
                status: 'PENDING',
                createdAt: new Date().toISOString(),
            }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        // انباردار مبدأ و مقصد هر دو باید دستور را ببینند
        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            'دستور جابه‌جایی جدید',
            expect.stringContaining('کالای A'),
            'warning',
            expect.objectContaining({ type: 'TRANSFER_CREATED', transferId: 't1', quantity: 20 }),
            expect.any(String),
        );
        expect(mocks.create).toHaveBeenCalledWith(
            'k2',
            expect.any(String),
            expect.stringContaining('در انتظار اجرا'),
            'warning',
            expect.objectContaining({ type: 'TRANSFER_CREATED' }),
            expect.any(String),
        );
        expect(mocks.toWarehouse).toHaveBeenCalledWith('wh1', 'transfer:created', expect.any(Object));
        expect(mocks.toWarehouse).toHaveBeenCalledWith('wh2', 'transfer:created', expect.any(Object));
        // مدیر صادرکننده نیازی به اعلان ندارد
        expect(mocks.toRole).not.toHaveBeenCalled();
    });

    it('دستور خروج لِگاسی که مستقیم اجرا شد (DONE): اعلان «اجرای خروج کالا» به انباردار مبدأ', async () => {
        usersByRoleWarehouse();
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('transfer:created', {
                transferId: 't2',
                kind: 'exit',
                fromWarehouseId: 'wh1',
                fromWarehouseName: 'انبار تهران',
                toWarehouseId: null,
                toWarehouseName: null,
                productId: 'p1',
                productName: 'کالای B',
                modelId: null,
                modelName: null,
                quantity: 5,
                status: 'DONE',
                createdAt: new Date().toISOString(),
            }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            'اجرای خروج کالا',
            expect.stringContaining('توسط مدیریت اجرا شد'),
            'info',
            expect.objectContaining({ type: 'TRANSFER_EXECUTED', quantity: 5 }),
            expect.any(String),
        );
        // انبار مقصدی وجود ندارد → فقط مبدأ
        expect(mocks.toWarehouse).toHaveBeenCalledTimes(1);
    });

    it('تکمیل دستور: یک اعلان تجمیعی به مدیر و انبارهای مبدأ/مقصد', async () => {
        usersByRoleWarehouse();
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('transfer:completed', {
                transferId: 't1',
                kind: 'transfer',
                fromWarehouseId: 'wh1',
                fromWarehouseName: 'انبار تهران',
                toWarehouseId: 'wh2',
                toWarehouseName: 'انبار کرج',
                productId: 'p1',
                productName: 'کالای A',
                modelName: null,
                quantity: 20,
                completedAt: new Date().toISOString(),
            }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        expect(mocks.create).toHaveBeenCalledWith(
            'm1',
            'تکمیل دستور جابه‌جایی',
            expect.stringContaining('به‌طور کامل اجرا شد'),
            'success',
            expect.objectContaining({ type: 'TRANSFER_COMPLETED' }),
            expect.any(String),
        );
        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            expect.any(String),
            expect.stringContaining('کالای A'),
            'success',
            expect.objectContaining({ type: 'TRANSFER_COMPLETED' }),
            expect.any(String),
        );
        expect(mocks.create).toHaveBeenCalledWith(
            'k2',
            expect.any(String),
            expect.stringContaining('به انبار کرج'),
            'success',
            expect.objectContaining({ type: 'TRANSFER_COMPLETED' }),
            expect.any(String),
        );
        expect(mocks.toWarehouse).toHaveBeenCalledWith('wh1', 'transfer:completed', expect.any(Object));
        expect(mocks.toWarehouse).toHaveBeenCalledWith('wh2', 'transfer:completed', expect.any(Object));
    });

    it('لغو دستور: هشدار به انباردار مبدأ که دیگر قابل اجرا نیست', async () => {
        usersByRoleWarehouse();
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('transfer:canceled', {
                transferId: 't1',
                kind: 'exit',
                fromWarehouseId: 'wh1',
                fromWarehouseName: 'انبار تهران',
                toWarehouseId: null,
                toWarehouseName: null,
                productId: 'p1',
                productName: 'کالای A',
                modelId: null,
                modelName: null,
                quantity: 20,
                canceledAt: new Date().toISOString(),
            }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        expect(mocks.create).toHaveBeenCalledWith(
            'k1',
            'لغو دستور خروج',
            expect.stringContaining('توسط مدیریت لغو شد'),
            'warning',
            expect.objectContaining({ type: 'TRANSFER_CANCELED' }),
            expect.any(String),
        );
        expect(mocks.toWarehouse).toHaveBeenCalledWith('wh1', 'transfer:canceled', expect.any(Object));
    });
});

describe('dispatchOutbox - تخصیص/حذف بار (انبار → راننده و مدیر)', () => {
    it('تخصیص بار: اعلان به رانندهٔ مقصد + مدیر (ردیابی حساس واگذاری بار)', async () => {
        mocks.user.findMany.mockImplementation(({ where }: any) =>
            where?.role === 'MANAGER'
                ? Promise.resolve([{ id: 'm1' }])
                : Promise.resolve([]),
        );
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:driver:assigned', {
                orderId: 'o1',
                orderNumber: 42,
                driverId: 'd1',
                driverName: 'علی',
                warehouseId: 'whA',
                warehouseName: 'انبار مرکزی',
                city: 'تهران',
                assignedAt: new Date().toISOString(),
            }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        // راننده: بار جدید برایش تعریف شد
        expect(mocks.create).toHaveBeenCalledWith(
            'd1',
            'بار جدید',
            expect.stringContaining('سفارش شماره 42'),
            'info',
            expect.objectContaining({ type: 'DRIVER_ORDER_ASSIGNED', driverId: 'd1' }),
            'ev1:d1',
        );
        // مدیر: چه باری به کدام راننده واگذار شد
        expect(mocks.create).toHaveBeenCalledWith(
            'm1',
            'تخصیص بار',
            expect.stringContaining('علی'),
            'info',
            expect.objectContaining({ type: 'DRIVER_ORDER_ASSIGNED', orderId: 'o1' }),
            'ev1:m1',
        );
        expect(mocks.toRole).toHaveBeenCalledWith('MANAGER', 'order:assigned', expect.any(Object));
    });

    it('تغییر راننده: رانندهٔ قبلی اعلان هشدار می‌گیرد و پنلش همان لحظه خالی می‌شود', async () => {
        mocks.outboxEvent.findMany.mockResolvedValue([
            makeEvent('order:driver:unassigned', {
                orderId: 'o1',
                orderNumber: 42,
                driverId: 'd-old',
                newDriverId: 'd2',
                newDriverName: 'رضا',
                warehouseId: 'whA',
                warehouseName: 'انبار مرکزی',
                reassignedAt: new Date().toISOString(),
            }),
        ]);

        const delivered = await dispatchOutbox();

        expect(delivered).toBe(1);
        expect(mocks.create).toHaveBeenCalledWith(
            'd-old',
            'حذف بار',
            expect.stringContaining('سفارش شماره 42'),
            'warning',
            expect.objectContaining({ type: 'DRIVER_ORDER_REMOVED', newDriverId: 'd2' }),
            'ev1:d-old',
        );
        expect(mocks.toUser).toHaveBeenCalledWith('d-old', 'order:unassigned', expect.any(Object));
    });
});
