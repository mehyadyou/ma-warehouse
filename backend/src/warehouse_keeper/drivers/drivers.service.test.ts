import { describe, it, expect, vi, beforeEach } from 'vitest';
import { driversService } from './drivers.service';

const mocks = vi.hoisted(() => {
    const findMany = vi.fn();
    const findFirst = vi.fn();
    const updateMany = vi.fn();
    const warehouseFindUnique = vi.fn();
    const activityLogCreate = vi.fn();
    const outboxCreate = vi.fn();
    const auditCreate = vi.fn();
    return { findMany, findFirst, updateMany, warehouseFindUnique, activityLogCreate, outboxCreate, auditCreate };
});

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        user: { findMany: mocks.findMany, findFirst: mocks.findFirst, updateMany: mocks.updateMany },
        warehouse: { findUnique: mocks.warehouseFindUnique },
        activityLog: { create: mocks.activityLogCreate },
        outboxEvent: { create: mocks.outboxCreate },
        auditLog: { create: mocks.auditCreate },
    },
}));

vi.mock('../../utils/audit', () => ({
    writeAuditStandalone: vi.fn().mockResolvedValue(undefined),
}));

import { prisma } from '../../utils/prisma';
import { writeAuditStandalone } from '../../utils/audit';

function makeTx(overrides: Record<string, any> = {}) {
    return {
        user: { updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
        outboxEvent: { create: vi.fn().mockResolvedValue({}) },
        ...overrides,
    };
}

beforeEach(() => {
    vi.clearAllMocks();
});

describe('driversService.listDrivers', () => {
    it('فقط کاربران فعال با نقش راننده را برمی‌گرداند و به‌همراه فیلدهای پایه مرتب می‌کند', async () => {
        mocks.findMany.mockResolvedValue([
            { id: 'd1', name: 'علی', phone: '09120000001', avatarUrl: null, warehouseId: null, warehouse: null, createdAt: new Date('2026-08-01') },
            { id: 'd2', name: 'رضا', phone: '09120000002', avatarUrl: '/uploads/a.png', warehouseId: 'w1', warehouse: { id: 'w1', name: 'انبار مرکزی' }, createdAt: new Date('2026-08-02') },
        ]);

        const drivers = await driversService.listDrivers('w1');

        expect(drivers).toHaveLength(2);
        expect(drivers[0].name).toBe('علی');
        expect(drivers[1].avatarUrl).toBe('/uploads/a.png');

        // شرط فقط نقش راننده و فعال — مدیر/انباردار و کاربران حذف‌شده نباید بیایند
        const where = mocks.findMany.mock.calls[0][0].where;
        expect(where.role).toBe('DRIVER');
        expect(where.isActive).toBe(true);
        expect(where.deletedAt).toBeNull();
        expect(mocks.findMany).toHaveBeenCalledTimes(1);
    });

    it('فلگ‌های تیک را بر اساس انبارِ خودِ انباردار محاسبه می‌کند', async () => {
        mocks.findMany.mockResolvedValue([
            { id: 'd1', name: 'علی', phone: '09120000001', avatarUrl: null, warehouseId: 'w1', warehouse: { id: 'w1', name: 'انبار مرکزی' }, createdAt: new Date('2026-08-01') },
            { id: 'd2', name: 'رضا', phone: '09120000002', avatarUrl: null, warehouseId: 'w2', warehouse: { id: 'w2', name: 'انبار غرب' }, createdAt: new Date('2026-08-02') },
            { id: 'd3', name: 'سعید', phone: '09120000003', avatarUrl: null, warehouseId: null, warehouse: null, createdAt: new Date('2026-08-03') },
        ]);

        const drivers = await driversService.listDrivers('w1');

        expect(drivers[0]).toMatchObject({ assignedToMe: true, assignedToOther: false, warehouseName: 'انبار مرکزی' });
        expect(drivers[1]).toMatchObject({ assignedToMe: false, assignedToOther: true, warehouseName: 'انبار غرب' });
        expect(drivers[2]).toMatchObject({ assignedToMe: false, assignedToOther: false, warehouseName: null });
    });

    it('وقتی راننده‌ای تعریف نشده باشد لیست خالی برمی‌گردد', async () => {
        mocks.findMany.mockResolvedValue([]);

        const drivers = await driversService.listDrivers('w1');

        expect(drivers).toEqual([]);
    });
});

describe('driversService.assignDriver', () => {
    const driverRow = { id: 'd1', name: 'علی', phone: '09120000001', warehouseId: null };

    it('تیک زدن موفق: اتصال به انبار خودم + outbox با نوع driver:assigned + تاریخچه و ممیزی', async () => {
        mocks.findFirst.mockResolvedValue(driverRow);
        mocks.warehouseFindUnique.mockResolvedValue({ name: 'انبار مرکزی' });
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        mocks.activityLogCreate.mockResolvedValue({});

        const result = await driversService.assignDriver('d1', 'w1', true, 'k1');

        expect(tx.user.updateMany).toHaveBeenCalledWith({
            where: { id: 'd1', role: 'DRIVER', OR: [{ warehouseId: null }, { warehouseId: 'w1' }] },
            data: { warehouseId: 'w1' },
        });
        expect(tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({
                    aggregate: 'driver',
                    type: 'driver:assigned',
                    payload: expect.objectContaining({ driverId: 'd1', warehouseId: 'w1', warehouseName: 'انبار مرکزی', assigned: true }),
                }),
            })
        );
        expect(mocks.activityLogCreate).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'user_warehouse_changed', userId: 'k1' }) })
        );
        expect(writeAuditStandalone).toHaveBeenCalledWith(
            expect.objectContaining({ actorId: 'k1', before: { warehouseId: null }, after: { warehouseId: 'w1' } })
        );
        expect(result).toEqual({ id: 'd1', name: 'علی', warehouseId: 'w1' });
    });

    it('برداشتن تیک موفق: راننده از انبار جدا می‌شود و outbox نوع driver:unassigned می‌سازد', async () => {
        mocks.findFirst.mockResolvedValue({ ...driverRow, warehouseId: 'w1' });
        mocks.warehouseFindUnique.mockResolvedValue({ name: 'انبار مرکزی' });
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        mocks.activityLogCreate.mockResolvedValue({});

        const result = await driversService.assignDriver('d1', 'w1', false, 'k1');

        expect(tx.user.updateMany).toHaveBeenCalledWith({
            where: { id: 'd1', warehouseId: 'w1' },
            data: { warehouseId: null },
        });
        expect(tx.outboxEvent.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({
                    type: 'driver:unassigned',
                    payload: expect.objectContaining({ assigned: false }),
                }),
            })
        );
        expect(result).toEqual({ id: 'd1', name: 'علی', warehouseId: null });
    });

    it('تیک زدن راننده‌ای که به انبار دیگری متصل است → AppError 409 بدون هیچ تغییری', async () => {
        mocks.findFirst.mockResolvedValue({ ...driverRow, warehouseId: 'w2' });
        mocks.warehouseFindUnique.mockResolvedValue({ name: 'انبار مرکزی' });
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(driversService.assignDriver('d1', 'w1', true, 'k1')).rejects.toThrow('به انبار دیگری متصل است');
        expect(tx.user.updateMany).not.toHaveBeenCalled();
        expect(tx.outboxEvent.create).not.toHaveBeenCalled();
        expect(mocks.activityLogCreate).not.toHaveBeenCalled();
    });

    it('برداشتن تیک راننده‌ای که به انبار من متصل نیست → AppError 409', async () => {
        mocks.findFirst.mockResolvedValue({ ...driverRow, warehouseId: 'w2' });
        mocks.warehouseFindUnique.mockResolvedValue({ name: 'انبار مرکزی' });
        const tx = makeTx();
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(driversService.assignDriver('d1', 'w1', false, 'k1')).rejects.toThrow('به انبار شما متصل نیست');
        expect(tx.user.updateMany).not.toHaveBeenCalled();
    });

    it('راننده یافت نشد → AppError 404', async () => {
        mocks.findFirst.mockResolvedValue(null);

        await expect(driversService.assignDriver('nope', 'w1', true)).rejects.toThrow('راننده یافت نشد');
        expect(mocks.warehouseFindUnique).not.toHaveBeenCalled();
    });

    it('مسابقه هم‌زمان دو انباردار: وقتی updateMany صفر برگرداند → AppError 409 و outbox ساخته نمی‌شود', async () => {
        mocks.findFirst.mockResolvedValue(driverRow);
        mocks.warehouseFindUnique.mockResolvedValue({ name: 'انبار مرکزی' });
        const tx = makeTx();
        tx.user.updateMany = vi.fn().mockResolvedValue({ count: 0 });
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(driversService.assignDriver('d1', 'w1', true, 'k1')).rejects.toThrow('به انبار دیگری متصل است');
        expect(tx.outboxEvent.create).not.toHaveBeenCalled();
        expect(mocks.activityLogCreate).not.toHaveBeenCalled();
    });
});