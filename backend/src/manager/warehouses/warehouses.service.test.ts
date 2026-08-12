import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        $queryRaw: vi.fn(),
        warehouse: {
            findUnique: vi.fn(),
            findFirst: vi.fn(),
            findMany: vi.fn(),
            create: vi.fn(),
            update: vi.fn(),
        },
        user: {
            findUnique: vi.fn(),
            findFirst: vi.fn(),
            findMany: vi.fn(),
            create: vi.fn(),
            update: vi.fn(),
            updateMany: vi.fn(),
        },
        refreshToken: {
            updateMany: vi.fn(),
        },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
    },
}));

vi.mock('bcryptjs', () => ({
    default: {
        hash: vi.fn().mockResolvedValue('hashed-password'),
        compare: vi.fn(),
    },
}));

import { warehousesService } from './warehouses.service';
import { prisma } from '../../utils/prisma';

const archivedDate = new Date('2026-08-01T00:00:00Z');

beforeEach(() => {
    vi.clearAllMocks();
});

function mockWarehouseNameLookup(active: Record<string, any>, archived: Record<string, any>) {
    (prisma.warehouse.findFirst as any).mockImplementation((args: any) => {
        const name = args?.where?.name;
        const isArchivedQuery = args?.where?.deletedAt?.not !== undefined;
        const hit = isArchivedQuery ? archived[name] : active[name];
        return Promise.resolve(hit ?? null);
    });
}

describe('warehousesService.createWarehouse', () => {
    it('نام خالی → AppError 400', async () => {
        await expect(warehousesService.createWarehouse('   ')).rejects.toThrow('نام انبار الزامی است');
    });

    it('نام همنام فعال → 409', async () => {
        mockWarehouseNameLookup({ 'انبار مرکزی': { id: 'w1' } }, {});
        await expect(warehousesService.createWarehouse('انبار مرکزی')).rejects.toThrow('قبلاً ثبت شده است');
    });

    it('نام همنام بایگانیشده → 409 ARCHIVED_CONFLICT + payload دیالوگ', async () => {
        mockWarehouseNameLookup({}, { 'انبار مرکزی': { id: 'arch1', name: 'انبار مرکزی', deletedAt: archivedDate } });

        const err = await warehousesService.createWarehouse('انبار مرکزی', 'تهران').catch(e => e);

        expect(err).toMatchObject({
            statusCode: 409,
            code: 'ARCHIVED_CONFLICT',
            data: {
                id: 'arch1',
                name: 'انبار مرکزی',
                archivedAt: archivedDate,
                suggestedName: 'انبار مرکزی (۲)',
            },
        });
        expect(prisma.warehouse.create).not.toHaveBeenCalled();
    });

    it('پسوند تکراری: «(۲)» گرفته شده → پیشنهاد «(۳)»', async () => {
        mockWarehouseNameLookup(
            { 'انبار مرکزی (۲)': { id: 'a2' } },
            { 'انبار مرکزی': { id: 'arch1', name: 'انبار مرکزی', deletedAt: archivedDate } },
        );

        const err = await warehousesService.createWarehouse('انبار مرکزی').catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.data.suggestedName).toBe('انبار مرکزی (۳)');
    });

    it('P2002 (race) → 409 دوستانه «تازه کنید»', async () => {
        mockWarehouseNameLookup({}, {});
        (prisma.warehouse.create as any).mockRejectedValue({ code: 'P2002' });

        const err = await warehousesService.createWarehouse('انبار تست').catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.message).toContain('تازه کنید');
    });

    it('ساخت موفق: نام trim شده + آدرس', async () => {
        mockWarehouseNameLookup({}, {});
        (prisma.warehouse.create as any).mockResolvedValue({ id: 'w1', name: 'انبار تست' });

        const result = await warehousesService.createWarehouse('  انبار تست  ', 'تهران');

        expect(prisma.warehouse.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: { name: 'انبار تست', address: 'تهران' } })
        );
        expect(result).toEqual({ id: 'w1', name: 'انبار تست' });
    });
});

describe('warehousesService.createWarehouseWithKeeper', () => {
    it('نام همنام بایگانیشده → 409 ARCHIVED_CONFLICT (بدون اجرای تراکنش)', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(null);
        mockWarehouseNameLookup({}, { 'انبار مرکزی': { id: 'arch1', name: 'انبار مرکزی', deletedAt: archivedDate } });

        const err = await warehousesService
            .createWarehouseWithKeeper('انبار مرکزی', 'علی', '09120000000', 'password123')
            .catch(e => e);

        expect(err).toMatchObject({
            statusCode: 409,
            code: 'ARCHIVED_CONFLICT',
            data: expect.objectContaining({ id: 'arch1', suggestedName: 'انبار مرکزی (۲)' }),
        });
        expect(prisma.$transaction).not.toHaveBeenCalled();
    });

    it('P2002 در تراکنش (race) → 409 دوستانه', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(null);
        mockWarehouseNameLookup({}, {});
        (prisma.$transaction as any).mockRejectedValue({ code: 'P2002' });

        const err = await warehousesService
            .createWarehouseWithKeeper('انبار جدید', 'علی', '09120000000', 'password123')
            .catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.message).toContain('تازه کنید');
    });

    it('ساخت موفق: انبار + انباردار (نقش WAREHOUSE_KEEPER وصل به انبار)', async () => {
        (prisma.user.findUnique as any).mockResolvedValue(null);
        mockWarehouseNameLookup({}, {});
        const tx = {
            warehouse: { create: vi.fn().mockResolvedValue({ id: 'w1', name: 'انبار جدید' }) },
            user: { create: vi.fn().mockResolvedValue({ id: 'k1', name: 'علی' }) },
        };
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        const result = await warehousesService
            .createWarehouseWithKeeper('انبار جدید', 'علی', '09120000000', 'password123');

        expect(tx.user.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({
                    role: 'WAREHOUSE_KEEPER',
                    warehouseId: 'w1',
                    password: 'hashed-password',
                }),
            })
        );
        expect(result).toEqual({ warehouse: { id: 'w1', name: 'انبار جدید' }, keeper: { id: 'k1', name: 'علی' } });
    });
});

describe('warehousesService.updateWarehouse', () => {
    it('تغییر نام به نامِ انبار بایگانیشده → 409 متنی ساده', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'w1', name: 'انبار', deletedAt: null });
        (prisma.warehouse.findFirst as any).mockImplementation((args: any) => {
            const isArchivedQuery = args?.where?.deletedAt?.not !== undefined;
            return Promise.resolve(isArchivedQuery ? { id: 'arch1' } : null);
        });

        const err = await warehousesService.updateWarehouse('w1', { name: 'نام بایگانیشده' }).catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.message).toContain('در بایگانی است');
        expect(prisma.warehouse.update).not.toHaveBeenCalled();
    });

    it('انبار بایگانیشده قابل ویرایش نیست → 400', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'w1', deletedAt: archivedDate });
        await expect(warehousesService.updateWarehouse('w1', { name: 'X' })).rejects.toThrow('بایگانی‌شده');
    });
});

describe('warehousesService.restoreWarehouse', () => {
    it('بازیابی موفق: رفع deletedAt + لاگ warehouse_restored + بازگشت جزئیات', async () => {
        (prisma.warehouse.findUnique as any)
            .mockResolvedValueOnce({ id: 'w1', name: 'انبار مرکزی', deletedAt: archivedDate })
            .mockResolvedValueOnce({ id: 'w1', users: [], _count: { users: 0, cartons: 0, orders: 0 } });
        (prisma.warehouse.update as any).mockResolvedValue({});

        const result = await warehousesService.restoreWarehouse('w1', 'mgr1');

        expect(prisma.warehouse.update).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 'w1' }, data: { deletedAt: null } })
        );
        expect(prisma.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'warehouse_restored', userId: 'mgr1' }) })
        );
        expect(result).toEqual({ id: 'w1', users: [], _count: { users: 0, cartons: 0, orders: 0 } });
    });

    it('انبار فعال → 400 (فقط موارد بایگانیشده قابل بازیابی)', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ id: 'w1', deletedAt: null });
        await expect(warehousesService.restoreWarehouse('w1')).rejects.toThrow('بایگانی نشده است');
    });
});