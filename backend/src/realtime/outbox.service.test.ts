import { describe, it, expect, vi, beforeEach } from 'vitest';

const mocks = vi.hoisted(() => {
    const user = { findMany: vi.fn() };
    const outboxEvent = { findMany: vi.fn(), updateMany: vi.fn() };
    return {
        user,
        outboxEvent,
        create: vi.fn(),
        toWarehouse: vi.fn(),
        toRole: vi.fn(),
    };
});

vi.mock('../utils/prisma', () => ({
    prisma: {
        user: mocks.user,
        outboxEvent: mocks.outboxEvent,
    },
}));

vi.mock('../notification/notification.service', () => ({
    notificationService: { create: mocks.create },
}));

vi.mock('./realtime', () => ({
    realtime: { toWarehouse: mocks.toWarehouse, toRole: mocks.toRole },
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
        );

        // ریل‌تایم به اتاق همان انبار (نه انبار دیگر)
        expect(mocks.toWarehouse).toHaveBeenCalledWith('whA', 'order:created', ORDER_CREATED_PAYLOAD);
        expect(mocks.toRole).toHaveBeenCalledWith('MANAGER', 'order:created', ORDER_CREATED_PAYLOAD);

        // رویداد تحویل‌شده علامت‌گذاری میشود (claim + dispatched)
        expect(mocks.outboxEvent.updateMany).toHaveBeenCalledTimes(2);
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
});
