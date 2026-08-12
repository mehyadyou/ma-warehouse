import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: vi.fn(),
        product: {
            findFirst: vi.fn(),
            findUnique: vi.fn(),
            findMany: vi.fn(),
            create: vi.fn(),
            update: vi.fn(),
            count: vi.fn(),
        },
        productModel: {
            findUnique: vi.fn(),
            findFirst: vi.fn(),
            findMany: vi.fn(),
            create: vi.fn(),
            update: vi.fn(),
            updateMany: vi.fn(),
        },
        activityLog: { create: vi.fn().mockResolvedValue({}) },
    },
}));

vi.mock('../../utils/audit', () => ({
    writeAuditStandalone: vi.fn(),
}));

import { productsService } from './products.service';
import { prisma } from '../../utils/prisma';

const archivedDate = new Date('2026-08-01T00:00:00Z');

beforeEach(() => {
    vi.clearAllMocks();
});

// راهنما: محصول بایگانیشدهٔ همنام + نتیجهٔ جستجو بر اساس نام
function mockNameLookup(active: Record<string, any>, archived: Record<string, any>) {
    (prisma.product.findFirst as any).mockImplementation((args: any) => {
        const name = args?.where?.name;
        const isArchivedQuery = args?.where?.deletedAt?.not !== undefined;
        const hit = isArchivedQuery ? archived[name] : active[name];
        return Promise.resolve(hit ?? null);
    });
}

const baseModels = [
    { name: 'مدل A', price: '1000', packageType: 'کارتن', unitsPerBox: '10' },
];

describe('productsService.createProduct', () => {
    it('بدون مدل → AppError 400', async () => {
        await expect(productsService.createProduct('X', [])).rejects.toThrow('حداقل یک مدل');
    });

    it('نام همنام با محصول بایگانیشده → 409 ARCHIVED_CONFLICT + payload کامل (دیالوگ)', async () => {
        mockNameLookup({}, { X: { id: 'arch1', name: 'X', deletedAt: archivedDate } });

        const err = await productsService.createProduct('X', baseModels).catch(e => e);

        expect(err).toMatchObject({
            statusCode: 409,
            code: 'ARCHIVED_CONFLICT',
            message: expect.stringContaining('در بایگانی است'),
            data: {
                id: 'arch1',
                name: 'X',
                archivedAt: archivedDate,
                suggestedName: 'X (۲)',
            },
        });
        expect(prisma.product.create).not.toHaveBeenCalled();
    });

    it('پسوند تکراری: «X (۲)» فعال است → پیشنهاد «X (۳)»', async () => {
        mockNameLookup(
            { 'X (۲)': { id: 'a2' } },
            { X: { id: 'arch1', name: 'X', deletedAt: archivedDate } },
        );

        const err = await productsService.createProduct('X', baseModels).catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.data.suggestedName).toBe('X (۳)');
    });

    it('P2002 (race ساخت همزمان) → 409 دوستانه «تازه کنید»', async () => {
        mockNameLookup({}, {});
        (prisma.product.create as any).mockRejectedValue({ code: 'P2002' });

        const err = await productsService.createProduct('X', baseModels).catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.message).toContain('تازه کنید');
    });

    it('ساخت موفق: محصول + مدلها + لاگ history', async () => {
        mockNameLookup({}, {});
        (prisma.product.create as any).mockResolvedValue({ id: 'p1', name: 'X' });

        const result = await productsService.createProduct('X', baseModels, 'mgr1', 'عدد');

        expect(prisma.product.create).toHaveBeenCalledWith(
            expect.objectContaining({
                data: expect.objectContaining({
                    name: 'X',
                    unit: 'عدد',
                    models: { create: [expect.objectContaining({ name: 'مدل A', price: 1000, unitsPerBox: 10 })] },
                }),
            })
        );
        expect(result).toEqual({ id: 'p1', name: 'X' });
        expect(prisma.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'product_created', userId: 'mgr1' }) })
        );
    });

    it('ادغام با محصول فعال: بازیابی مدل بایگانیشده + ساخت مدل جدید — همه داخل $transaction', async () => {
        mockNameLookup({ X: { id: 'p1', unit: 'عدد' } }, {});
        const tx = {
            productModel: {
                findUnique: vi.fn((args: any) => {
                    const name = args.where.productId_name.name;
                    return Promise.resolve(
                        name === 'مدل A' ? { id: 'm1', name, deletedAt: archivedDate } : null
                    );
                }),
                update: vi.fn().mockResolvedValue({}),
                create: vi.fn().mockResolvedValue({}),
            },
            product: { update: vi.fn().mockResolvedValue({}) },
            activityLog: { create: vi.fn().mockResolvedValue({}) },
        };
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));
        (prisma.product.findUnique as any).mockResolvedValue({ id: 'p1', name: 'X' });

        await productsService.createProduct('X', [
            { name: 'مدل A', price: '2000' },
            { name: 'مدل B', price: '3000' },
        ], 'mgr1', 'عدد');

        // مدل بایگانیشدهٔ همنام → بازیابی با دادهٔ ارسالشده
        expect(tx.productModel.update).toHaveBeenCalledWith({
            where: { id: 'm1' },
            data: { name: 'مدل A', price: 2000, packageType: null, unitsPerBox: null, deletedAt: null },
        });
        // مدل جدید → ساخته میشود
        expect(tx.productModel.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ productId: 'p1', name: 'مدل B', price: 3000 }) })
        );
        // تاریخچه داخل تراکنش
        expect(tx.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'product_updated', userId: 'mgr1' }) })
        );
        // ساخت محصول جدید هرگز اتفاق نمیافتد
        expect(prisma.product.create).not.toHaveBeenCalled();
        expect(prisma.$transaction).toHaveBeenCalledTimes(1);
    });

    it('مدل فعالِ همنام برای محصول موجود → 409 (و کل تراکنش رد میشود)', async () => {
        mockNameLookup({ X: { id: 'p1', unit: 'عدد' } }, {});
        const tx = {
            productModel: {
                findUnique: vi.fn().mockResolvedValue({ id: 'm1', name: 'مدل A', deletedAt: null }),
                update: vi.fn(),
                create: vi.fn(),
            },
            product: { update: vi.fn() },
            activityLog: { create: vi.fn().mockResolvedValue({}) },
        };
        (prisma.$transaction as any).mockImplementation(async (cb: any) => cb(tx));

        await expect(
            productsService.createProduct('X', [{ name: 'مدل A' }])
        ).rejects.toThrow('قبلاً برای این محصول ثبت شده است');

        expect(tx.productModel.create).not.toHaveBeenCalled();
    });
});

describe('productsService.restoreProduct', () => {
    it('محصول فعال → idempotent: بدون خطا و بدون هیچ آپدیتی برمیگردد', async () => {
        (prisma.product.findUnique as any).mockResolvedValue({ id: 'p1', deletedAt: null });
        (prisma.product.findUnique as any).mockResolvedValueOnce({ id: 'p1', deletedAt: null })
            .mockResolvedValueOnce({ id: 'p1', deletedAt: null, models: [] });

        const result = await productsService.restoreProduct('p1', 'mgr1');

        expect(result).toEqual({ id: 'p1', deletedAt: null, models: [] });
        expect(prisma.product.update).not.toHaveBeenCalled();
        expect(prisma.$transaction).not.toHaveBeenCalled();
    });

    it('برخورد نام مدل با مدلِ فعالِ همنام → 409 بامعنی (بهجای 500)', async () => {
        (prisma.product.findUnique as any).mockResolvedValue({ id: 'p1', deletedAt: archivedDate, name: 'X' });
        (prisma.productModel.findMany as any).mockResolvedValue([{ name: 'مدل A' }]);
        (prisma.productModel.findFirst as any).mockResolvedValue({ name: 'مدل A' });

        const err = await productsService.restoreProduct('p1', 'mgr1').catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.message).toContain('فعال است');
        expect(prisma.product.update).not.toHaveBeenCalled();
    });

    it('بازیابی موفق: رفع deletedAt + لاگ product_restored', async () => {
        (prisma.product.findUnique as any).mockResolvedValueOnce({ id: 'p1', deletedAt: archivedDate, name: 'X' })
            .mockResolvedValueOnce({ id: 'p1', deletedAt: null, models: [] });
        (prisma.productModel.findMany as any).mockResolvedValue([]);
        (prisma.productModel.findFirst as any).mockResolvedValue(null);
        (prisma.$transaction as any).mockResolvedValue([]);

        const result = await productsService.restoreProduct('p1', 'mgr1');

        expect(prisma.product.update).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 'p1' }, data: { deletedAt: null } })
        );
        expect(prisma.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'product_restored' }) })
        );
        expect(result).toEqual({ id: 'p1', deletedAt: null, models: [] });
    });

    it('محصول ناموجود → 404', async () => {
        (prisma.product.findUnique as any).mockResolvedValue(null);
        await expect(productsService.restoreProduct('nope')).rejects.toThrow('محصول یافت نشد');
    });
});

describe('productsService.restoreProductModel', () => {
    it('مدل فعال → idempotent', async () => {
        (prisma.productModel.findUnique as any).mockResolvedValue({ id: 'm1', deletedAt: null });
        const result = await productsService.restoreProductModel('m1', 'mgr1');
        expect(result).toEqual({ id: 'm1', deletedAt: null });
        expect(prisma.productModel.update).not.toHaveBeenCalled();
    });

    it('مدلِ فعالِ همنام در همین محصول → 409 (بهجای 500)', async () => {
        (prisma.productModel.findUnique as any).mockResolvedValue({ id: 'm1', productId: 'p1', name: 'مدل A', deletedAt: archivedDate });
        (prisma.productModel.findFirst as any).mockResolvedValue({ id: 'm2' });

        const err = await productsService.restoreProductModel('m1', 'mgr1').catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.message).toContain('فعال است');
        expect(prisma.productModel.update).not.toHaveBeenCalled();
    });

    it('بازیابی موفق + لاگ model_restored', async () => {
        (prisma.productModel.findUnique as any).mockResolvedValue({ id: 'm1', productId: 'p1', name: 'مدل A', deletedAt: archivedDate });
        (prisma.productModel.findFirst as any).mockResolvedValue(null);
        (prisma.productModel.update as any).mockResolvedValue({ id: 'm1', deletedAt: null });

        const result = await productsService.restoreProductModel('m1', 'mgr1');

        expect(prisma.productModel.update).toHaveBeenCalledWith(
            expect.objectContaining({ where: { id: 'm1' }, data: { deletedAt: null } })
        );
        expect(prisma.activityLog.create).toHaveBeenCalledWith(
            expect.objectContaining({ data: expect.objectContaining({ type: 'model_restored' }) })
        );
        expect(result).toEqual({ id: 'm1', productId: 'p1', name: 'مدل A', deletedAt: archivedDate });
    });
});

describe('productsService.updateProduct', () => {
    it('تغییر نام به نامِ محصول بایگانیشده → 409 متنی ساده', async () => {
        (prisma.product.findFirst as any).mockImplementation((args: any) => {
            const isArchivedQuery = args?.where?.deletedAt?.not !== undefined;
            return Promise.resolve(isArchivedQuery ? { id: 'arch1' } : null);
        });

        const err = await productsService.updateProduct('p1', 'نام بایگانیشده').catch(e => e);

        expect(err.statusCode).toBe(409);
        expect(err.message).toContain('در بایگانی است');
        expect(prisma.product.update).not.toHaveBeenCalled();
    });

    it('ویرایش موفق با نام یکتا', async () => {
        (prisma.product.findFirst as any).mockResolvedValue(null);
        (prisma.product.update as any).mockResolvedValue({ id: 'p1', name: 'جدید' });

        const result = await productsService.updateProduct('p1', 'جدید', 'عدد');

        expect(prisma.product.update).toHaveBeenCalledWith({
            where: { id: 'p1' },
            data: { name: 'جدید', unit: 'عدد' },
        });
        expect(result).toEqual({ id: 'p1', name: 'جدید' });
    });
});