import { describe, it, expect, vi, beforeEach } from 'vitest';
import { transfersService } from './transfers.service';
import { AppError } from '../../common/exceptions/AppError';
import { prisma } from '../../utils/prisma';

const mocks = vi.hoisted(() => {
    const tx = {
        warehouse: { findUnique: vi.fn() },
        product: { findUnique: vi.fn() },
        productModel: { findUnique: vi.fn() },
        carton: { findFirst: vi.fn(), findMany: vi.fn(), updateMany: vi.fn().mockResolvedValue({ count: 1 }) },
        transaction: { create: vi.fn().mockResolvedValue({}) },
        transfer: { create: vi.fn().mockImplementation(async ({ data }: any) => ({ id: 't1', createdAt: new Date('2026-01-01'), ...data })) },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        $queryRaw: vi.fn(),
    };
    return {
        tx,
        transaction: vi.fn((fn: (t: unknown) => unknown) => fn(tx)),
        transferFindMany: vi.fn(),
    };
});

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: mocks.transaction,
        transfer: {
            findMany: mocks.transferFindMany,
            findUnique: vi.fn(),
            update: vi.fn().mockResolvedValue({}),
        },
        carton: { count: vi.fn().mockResolvedValue(0) },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
        $queryRaw: vi.fn().mockResolvedValue([]),
    },
}));

const wh1 = { id: 'wh1', name: 'انبار تهران', deletedAt: null };
const wh2 = { id: 'wh2', name: 'انبار کرج', deletedAt: null };
const product = { id: 'p1', name: 'کالای A', deletedAt: null };
const model1 = { id: 'm1', name: 'مدل ۱', productId: 'p1', deletedAt: null };
const model2 = { id: 'm2', name: 'مدل ۲', productId: 'p2', deletedAt: null };

function boxCarton(id: string, unitsPerBox = 10, overrides: any = {}) {
    return { id, productId: 'p1', modelId: 'm1', isIndividual: false, status: 'IN_STOCK', model: { id: 'm1', name: 'مدل ۱', unitsPerBox }, ...overrides };
}

function individualCarton(id: string, overrides: any = {}) {
    return { id, productId: 'p1', modelId: 'm1', isIndividual: true, status: 'IN_STOCK', model: { id: 'm1', name: 'مدل ۱', unitsPerBox: 10 }, ...overrides };
}

const baseInput = {
    fromWarehouseId: 'wh1',
    toWarehouseId: null,
    productId: 'p1',
    modelId: 'm1',
    quantity: 10,
    description: 'توضیح تست',
};

beforeEach(() => {
    vi.clearAllMocks();
    mocks.tx.warehouse.findUnique.mockImplementation(async ({ where }: { where: { id: string } }) => {
        if (where.id === 'wh1') return wh1;
        if (where.id === 'wh2') return wh2;
        return null;
    });
    mocks.tx.product.findUnique.mockResolvedValue(product);
    mocks.tx.productModel.findUnique.mockImplementation(async ({ where }: { where: { id: string } }) => {
        if (where.id === 'm1') return model1;
        if (where.id === 'm2') return model2;
        return null;
    });
    mocks.tx.carton.findFirst.mockResolvedValue({ id: 'c0' }); // کارتن‌دار
});

describe('transfersService.createTransfer - مسیر کارتنی', () => {
    it('ثبت دستور جابه‌جایی: فقط PENDING ثبت می‌شود — هیچ تغییری روی کارتن‌ها/تراکنش‌ها اعمال نمی‌شود', async () => {
        mocks.tx.carton.findMany.mockResolvedValue([
            boxCarton('c1'),
            boxCarton('c2'),
            individualCarton('c3'),
        ]);
        // موجودی کافی است ولی اجرا با اسکن انجام می‌شود
        mocks.tx.$queryRaw.mockResolvedValue([{ available: 21 }]);

        const result = await transfersService.createTransfer(
            { ...baseInput, toWarehouseId: 'wh2', quantity: 21 },
            'u1',
        );

        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
        expect(mocks.tx.transaction.create).not.toHaveBeenCalled();
        expect(mocks.tx.transfer.create).toHaveBeenCalledWith({
            data: expect.objectContaining({
                fromWarehouseId: 'wh1',
                toWarehouseId: 'wh2',
                productId: 'p1',
                modelId: 'm1',
                quantity: 21,
                description: 'توضیح تست',
                status: 'PENDING',
                completedAt: null,
                createdById: 'u1',
            }),
        });
        expect(mocks.tx.activityLog.create).toHaveBeenCalledWith({
            data: expect.objectContaining({ type: 'product_transfer' }),
        });
        expect(result.status).toBe('PENDING');
        expect(result.executedUnits).toBe(0);
        expect(result.toWarehouseId).toBe('wh2');
    });

    it('ثبت دستور خروج: فقط PENDING ثبت می‌شود — کارتن‌ها دست نمی‌خورند', async () => {
        mocks.tx.carton.findMany.mockResolvedValue([boxCarton('c1')]);
        mocks.tx.$queryRaw.mockResolvedValue([{ available: 10 }]);

        const result = await transfersService.createTransfer(baseInput, 'u1');

        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
        expect(mocks.tx.transaction.create).not.toHaveBeenCalled();
        expect(result.status).toBe('PENDING');
        expect(result.toWarehouseId).toBeNull();
        expect(mocks.tx.activityLog.create).toHaveBeenCalledWith({
            data: expect.objectContaining({ type: 'product_exit' }),
        });
    });

    it('موجودی ناکافی → خطای ۴۰۰ با موجودی', async () => {
        mocks.tx.carton.findMany.mockResolvedValue([boxCarton('c1')]);
        mocks.tx.$queryRaw.mockResolvedValue([{ available: 10 }]);

        await expect(
            transfersService.createTransfer({ ...baseInput, quantity: 15 }, 'u1'),
        ).rejects.toThrowError(new AppError('موجودی کافی نیست (موجودی: 10)', 400));
    });

    it('مقدار جزئی از ظرفیت کارتن مجاز است — اجرا با اسکن دقیق انجام می‌شود', async () => {
        mocks.tx.carton.findMany.mockResolvedValue([boxCarton('c1')]);
        mocks.tx.$queryRaw.mockResolvedValue([{ available: 10 }]);

        const result = await transfersService.createTransfer({ ...baseInput, quantity: 5 }, 'u1');

        expect(result.status).toBe('PENDING');
        expect(mocks.tx.transfer.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ quantity: 5 }) }),
        );
    });

    it('انبار مبدأ و مقصد یکی باشند → خطا', async () => {
        await expect(
            transfersService.createTransfer({ ...baseInput, toWarehouseId: 'wh1' }, 'u1'),
        ).rejects.toThrowError(new AppError('انبار مبدأ و مقصد نمی‌توانند یکی باشند', 400));
        expect(mocks.tx.transfer.create).not.toHaveBeenCalled();
    });

    it('مدل متعلق به محصول دیگری باشد → خطا', async () => {
        await expect(
            transfersService.createTransfer({ ...baseInput, modelId: 'm2' }, 'u1'),
        ).rejects.toThrowError(new AppError('مدل انتخابی متعلق به این محصول نیست', 400));
    });

    it('انبار مبدأ حذف‌شده → ۴۰۴', async () => {
        mocks.tx.warehouse.findUnique.mockResolvedValue({ ...wh1, deletedAt: new Date() });

        await expect(
            transfersService.createTransfer(baseInput, 'u1'),
        ).rejects.toThrowError(new AppError('انبار مبدأ یافت نشد', 404));
    });
});

describe('transfersService.createTransfer - مسیر لِگاسی (بدون کارتن)', () => {
    it('موجودی از دفتر تراکنش‌ها خوانده می‌شود و فقط تراکنش ثبت می‌شود', async () => {
        mocks.tx.carton.findFirst.mockResolvedValue(null);
        mocks.tx.$queryRaw.mockResolvedValue([{ balance: 50 }]);

        const result = await transfersService.createTransfer(
            { ...baseInput, toWarehouseId: 'wh2', quantity: 10 },
            'u1',
        );

        expect(mocks.tx.$queryRaw).toHaveBeenCalledOnce();
        expect(mocks.tx.carton.updateMany).not.toHaveBeenCalled();
        expect(mocks.tx.transaction.create).toHaveBeenCalledTimes(2);
        expect(result.toWarehouseId).toBe('wh2');
    });

    it('موجودی لِگاسی ناکافی → خطا', async () => {
        mocks.tx.carton.findFirst.mockResolvedValue(null);
        mocks.tx.$queryRaw.mockResolvedValue([{ balance: 3 }]);

        await expect(
            transfersService.createTransfer({ ...baseInput, quantity: 4 }, 'u1'),
        ).rejects.toThrowError(new AppError('موجودی کافی نیست (موجودی: 3)', 400));
    });
});

describe('transfersService.listTransfers', () => {
    it('آخرین جابه‌جایی‌ها با نام‌ها نگاشت می‌شوند', async () => {
        mocks.transferFindMany.mockResolvedValue([
            {
                id: 't1',
                fromWarehouseId: 'wh1',
                toWarehouseId: 'wh2',
                productId: 'p1',
                modelId: 'm1',
                quantity: 5,
                description: '',
                status: 'PENDING',
                completedAt: null,
                createdAt: new Date('2026-01-02'),
                fromWarehouse: { name: 'انبار تهران' },
                toWarehouse: { name: 'انبار کرج' },
                product: { name: 'کالای A' },
                model: { name: 'مدل ۱' },
            },
            {
                id: 't2',
                fromWarehouseId: 'wh1',
                toWarehouseId: null,
                productId: 'p2',
                modelId: null,
                quantity: 2,
                description: '',
                status: 'DONE',
                completedAt: new Date('2026-01-01'),
                createdAt: new Date('2026-01-01'),
                fromWarehouse: { name: 'انبار تهران' },
                toWarehouse: null,
                product: { name: 'کالای B' },
                model: null,
            },
        ]);

        const rows = await transfersService.listTransfers(20);

        expect(mocks.transferFindMany).toHaveBeenCalledWith(
            expect.objectContaining({ orderBy: { createdAt: 'desc' }, take: 20 }),
        );
        expect(rows).toHaveLength(2);
        expect(rows[0]).toEqual(expect.objectContaining({
            fromWarehouseName: 'انبار تهران',
            toWarehouseName: 'انبار کرج',
            productName: 'کالای A',
            modelName: 'مدل ۱',
            status: 'PENDING',
            completedAt: null,
            executedUnits: 0,
            remainingUnits: 5,
        }));
        expect(rows[1].toWarehouseName).toBeNull();
        expect(rows[1].modelName).toBeNull();
        expect(rows[1].status).toBe('DONE');
    });

    it('با fromWarehouseId فقط دستورهای همان انبار (غیر لغوشده) برمی‌گردد', async () => {
        mocks.transferFindMany.mockResolvedValue([]);

        await transfersService.listTransfers(20, 'wh1');

        expect(mocks.transferFindMany).toHaveBeenCalledWith(
            expect.objectContaining({ where: { fromWarehouseId: 'wh1', status: { not: 'CANCELED' } } }),
        );
    });
});

describe('transfersService.cancelTransfer', () => {
    beforeEach(() => {
        vi.mocked(prisma.transfer.findUnique).mockReset();
        vi.mocked(prisma.carton.count).mockReset();
        vi.mocked(prisma.carton.count).mockResolvedValue(0);
        vi.mocked(prisma.transfer.update).mockReset();
        vi.mocked(prisma.transfer.update).mockResolvedValue({} as any);
    });

    it('لغو دستور PENDING بدون اسکن → CANCELED + لاگ', async () => {
        vi.mocked(prisma.transfer.findUnique).mockResolvedValue({
            id: 't1', status: 'PENDING', toWarehouseId: null, quantity: 10,
        } as any);

        await transfersService.cancelTransfer('t1', 'u1');

        expect(prisma.transfer.update).toHaveBeenCalledWith({
            where: { id: 't1' },
            data: { status: 'CANCELED' },
        });
        expect(prisma.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'product_exit' }) }),
        );
    });

    it('لغو دستور DONE → رد', async () => {
        vi.mocked(prisma.transfer.findUnique).mockResolvedValue({
            id: 't1', status: 'DONE', toWarehouseId: null, quantity: 10,
        } as any);

        await expect(
            transfersService.cancelTransfer('t1', 'u1'),
        ).rejects.toThrowError(new AppError('فقط دستورهای «در انتظار» قابل لغو هستند', 400));
        expect(prisma.transfer.update).not.toHaveBeenCalled();
    });

    it('لغو دستور شروع‌شده (با کارتن اسکن‌شده) → رد', async () => {
        vi.mocked(prisma.transfer.findUnique).mockResolvedValue({
            id: 't1', status: 'PENDING', toWarehouseId: 'wh2', quantity: 10,
        } as any);
        vi.mocked(prisma.carton.count).mockResolvedValue(1);

        await expect(
            transfersService.cancelTransfer('t1', 'u1'),
        ).rejects.toThrowError(new AppError('این دستور شروع به اجرا شده و قابل لغو نیست', 400));
        expect(prisma.transfer.update).not.toHaveBeenCalled();
    });

    it('دستور یافت نشد → ۴۰۴', async () => {
        vi.mocked(prisma.transfer.findUnique).mockResolvedValue(null);

        await expect(
            transfersService.cancelTransfer('t1', 'u1'),
        ).rejects.toThrowError(new AppError('دستور یافت نشد', 404));
    });
});