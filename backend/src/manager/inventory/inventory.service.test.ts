import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/cache', () => ({
    cached: (_key: string, _ttl: number, fn: () => Promise<unknown>) => fn(),
}));

vi.mock('../../utils/prisma', () => ({
    prisma: {
        warehouse: { findMany: vi.fn(), findFirst: vi.fn() },
        $queryRaw: vi.fn(),
    },
}));

import { inventoryService } from './inventory.service';
import { prisma } from '../../utils/prisma';

const findMany = vi.mocked(prisma.warehouse.findMany);
const findFirst = vi.mocked(prisma.warehouse.findFirst);
const queryRaw = vi.mocked(prisma.$queryRaw);

beforeEach(() => {
    vi.clearAllMocks();
    findMany.mockResolvedValue([
        { id: 'wh1', name: 'انبار مرکزی' },
        { id: 'wh2', name: 'انبار غرب' },
    ]);
    findFirst.mockResolvedValue({ id: 'wh1', name: 'انبار مرکزی' });
});

describe('inventoryService.getProductInventory', () => {
    const baseRows = () => {
        // ۱) کارتن‌ها ۲) محصولات دارای کارتن ۳) تراکنش‌های لِگاسی ۴) مدل‌های محصولات
        queryRaw
            .mockResolvedValueOnce([
                { productId: 'p1', productName: 'کالای اول', unit: 'عدد', warehouseId: 'wh1', count: 30 },
                { productId: 'p2', productName: 'کالای دوم', unit: 'عدد', warehouseId: 'wh1', count: 20 },
            ])
            .mockResolvedValueOnce([
                { productId: 'p1', cartonRows: 1 },
                { productId: 'p2', cartonRows: 1 },
            ])
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);
    };

    it('بدون پارامتر — رفتار قبلی: همهٔ محصولات و آیتم‌های کامل هر انبار', async () => {
        baseRows();

        const res = await inventoryService.getProductInventory();

        expect(res.total).toBe(2);
        expect(res.products).toHaveLength(2);
        expect(res.warehouses[0].items).toHaveLength(2);
        expect(res.warehouses[0].totalItems).toBe(2);
    });

    it('با page/pageSize — فقط صفحهٔ درخواستی + hasMore', async () => {
        // ۳۰ محصول برای دو صفحهٔ ۲۰تایی
        queryRaw
            .mockResolvedValueOnce(
                Array.from({ length: 30 }, (_, i) => ({
                    productId: `p${i}`,
                    productName: `کالای ${i}`,
                    unit: 'عدد',
                    warehouseId: 'wh1',
                    count: i + 1,
                })),
            )
            .mockResolvedValueOnce(
                Array.from({ length: 30 }, (_, i) => ({
                    productId: `p${i}`,
                    cartonRows: 1,
                })),
            )
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);

        const res = await inventoryService.getProductInventory({ page: 2, pageSize: 20 });

        expect(res.total).toBe(30);
        expect(res.page).toBe(2);
        expect(res.pageSize).toBe(20);
        expect(res.hasMore).toBe(false);
        // صفحهٔ ۲ = ۱۰ محصول بعدی در مرتب‌سازی نزولی بر موجودی (پرجمعیت‌ترین‌ها در صفحهٔ ۱)
        expect(res.products).toHaveLength(10);
        expect(res.products[0].productId).toBe('p9');
        expect(res.products[0].totalCount).toBe(10);
        expect(res.products[9].productId).toBe('p0');
        expect(res.products[9].totalCount).toBe(1);
    });

    it('pageSize بیشتر از سقف → به ۵۰۰ محدود می‌شود', async () => {
        baseRows();

        const res = await inventoryService.getProductInventory({ page: 1, pageSize: 9999 });

        expect(res.pageSize).toBe(500);
    });

    it('آیتم‌های هر انبار به ۵۰ مورد برتر محدود می‌شوند + totalItems کامل', async () => {
        queryRaw
            .mockResolvedValueOnce(
                Array.from({ length: 60 }, (_, i) => ({
                    productId: `p${i}`,
                    productName: `کالای ${i}`,
                    unit: 'عدد',
                    warehouseId: 'wh1',
                    count: i + 1,
                })),
            )
            .mockResolvedValueOnce(
                Array.from({ length: 60 }, (_, i) => ({
                    productId: `p${i}`,
                    cartonRows: 1,
                })),
            )
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);

        const res = await inventoryService.getProductInventory({ page: 1, pageSize: 500 });

        expect(res.warehouses[0].totalItems).toBe(60);
        expect(res.warehouses[0].items).toHaveLength(50);
        // مرتب نزولی → ۵۰ تای برتر
        expect(res.warehouses[0].items[0].count).toBe(60);
    });

    it('با q — فقط محصولات منطبق + آیتم‌های انبار هماهنگ با فیلتر', async () => {
        queryRaw
            .mockResolvedValueOnce([
                { productId: 'p1', productName: 'کالای اول', unit: 'عدد', warehouseId: 'wh1', count: 30 },
                { productId: 'p2', productName: 'کالای دوم', unit: 'عدد', warehouseId: 'wh1', count: 20 },
                { productId: 'p3', productName: 'کالای دیگر', unit: 'عدد', warehouseId: 'wh1', count: 10 },
            ])
            .mockResolvedValueOnce([
                { productId: 'p1', cartonRows: 1 },
                { productId: 'p2', cartonRows: 1 },
                { productId: 'p3', cartonRows: 1 },
            ])
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);

        const res = await inventoryService.getProductInventory({ q: 'دوم' });

        expect(res.total).toBe(1);
        expect(res.products[0].productId).toBe('p2');
        expect(res.products[0].totalCount).toBe(20);
        // آیتم‌های انبار فقط محصول منطبق
        expect(res.warehouses[0].items).toHaveLength(1);
        expect(res.warehouses[0].items[0].productId).toBe('p2');
        expect(res.warehouses[0].totalItems).toBe(1);
    });

    it('با onlyInStock — فقط محصولات دارای موجودی (با فیلتر بعد از صفحه‌بندی)', async () => {
        queryRaw
            .mockResolvedValueOnce([
                { productId: 'p1', productName: 'کالای اول', unit: 'عدد', warehouseId: 'wh1', count: 30 },
                { productId: 'p2', productName: 'کالای دوم', unit: 'عدد', warehouseId: 'wh1', count: 0 },
            ])
            .mockResolvedValueOnce([
                { productId: 'p1', cartonRows: 1 },
                { productId: 'p2', cartonRows: 1 },
            ])
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);

        const res = await inventoryService.getProductInventory({ onlyInStock: true });

        expect(res.total).toBe(1);
        expect(res.products[0].productId).toBe('p1');
        expect(res.warehouses[0].items).toHaveLength(1);
    });

    it('q + صفحه‌بندی — total از فیلتر شده محاسبه می‌شود', async () => {
        queryRaw
            .mockResolvedValueOnce(
                Array.from({ length: 30 }, (_, i) => ({
                    productId: `p${i}`,
                    productName: i % 2 === 0 ? `کالای ویژه ${i}` : `کالای معمولی ${i}`,
                    unit: 'عدد',
                    warehouseId: 'wh1',
                    count: i + 1,
                })),
            )
            .mockResolvedValueOnce(
                Array.from({ length: 30 }, (_, i) => ({
                    productId: `p${i}`,
                    cartonRows: 1,
                })),
            )
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);

        const res = await inventoryService.getProductInventory({ q: 'ویژه', page: 1, pageSize: 20 });

        expect(res.total).toBe(15);
        expect(res.products).toHaveLength(15);
        expect(res.hasMore).toBe(false);
    });

    it('مدل‌های هر محصول (تعداد + نام) در پاسخ می‌آید', async () => {
        queryRaw
            .mockResolvedValueOnce([
                { productId: 'p1', productName: 'کالای اول', unit: 'عدد', warehouseId: 'wh1', count: 30 },
                { productId: 'p2', productName: 'کالای دوم', unit: 'عدد', warehouseId: 'wh1', count: 20 },
            ])
            .mockResolvedValueOnce([
                { productId: 'p1', cartonRows: 1 },
                { productId: 'p2', cartonRows: 1 },
            ])
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([
                { productId: 'p1', modelCount: 2, modelNames: ['SL116', 'SL120'] },
            ]);

        const res = await inventoryService.getProductInventory();

        const p1 = res.products.find(p => p.productId === 'p1')!;
        const p2 = res.products.find(p => p.productId === 'p2')!;
        expect(p1.modelCount).toBe(2);
        expect(p1.modelNames).toEqual(['SL116', 'SL120']);
        // محصول بدون مدل → صفر و خالی
        expect(p2.modelCount).toBe(0);
        expect(p2.modelNames).toEqual([]);
    });

    it('با warehouseId — فقط محصولات همان انبار + یک ورودی انبار با آیتمهای صفحهٔ جاری', async () => {
        // ۱) کارتن انبار ۲) محصولات دارای کارتن همان انبار ۳) لگاسی همان انبار ۴) مدلها
        queryRaw
            .mockResolvedValueOnce([
                { productId: 'p1', productName: 'کالای اول', unit: 'عدد', count: 30 },
                { productId: 'p2', productName: 'کالای دوم', unit: 'عدد', count: 20 },
                { productId: 'p3', productName: 'کالای سوم', unit: 'عدد', count: 0 },
            ])
            .mockResolvedValueOnce([
                { productId: 'p1', cartonRows: 1 },
                { productId: 'p2', cartonRows: 1 },
            ])
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);

        const res = await inventoryService.getProductInventory({ warehouseId: 'wh1' });

        expect(res.warehouses).toHaveLength(1);
        expect(res.warehouses[0].warehouseId).toBe('wh1');
        expect(res.warehouses[0].warehouseName).toBe('انبار مرکزی');
        expect(res.total).toBe(3);
        expect(res.products).toHaveLength(3);
        expect(res.products[0].productId).toBe('p1');
        expect(res.products[0].totalCount).toBe(30);
        // آیتمهای انبار = صفحهٔ جاری با موجودی غیرصفر
        expect(res.warehouses[0].totalCount).toBe(50);
        expect(res.warehouses[0].totalItems).toBe(3);
        expect(res.warehouses[0].items).toHaveLength(2);
        expect(res.warehouses[0].items[0].productId).toBe('p1');
        expect(res.warehouses[0].items[0].count).toBe(30);
    });

    it('با warehouseId ناموجود → null (کنترلر ۴۰۴ میدهد)', async () => {
        findFirst.mockResolvedValueOnce(null);

        const res = await inventoryService.getProductInventory({ warehouseId: 'nope' });

        expect(res).toBeNull();
        expect(queryRaw).not.toHaveBeenCalled();
    });

    it('با warehouseId + onlyInStock/q — فیلترها روی همان انبار اعمال میشوند', async () => {
        queryRaw
            .mockResolvedValueOnce([
                { productId: 'p1', productName: 'کالای اول', unit: 'عدد', count: 30 },
                { productId: 'p2', productName: 'کالای دوم', unit: 'عدد', count: 0 },
            ])
            .mockResolvedValueOnce([
                { productId: 'p1', cartonRows: 1 },
                { productId: 'p2', cartonRows: 1 },
            ])
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([]);

        const res = await inventoryService.getProductInventory({
            warehouseId: 'wh1',
            onlyInStock: true,
            q: 'اول',
        });

        expect(res.total).toBe(1);
        expect(res.products[0].productId).toBe('p1');
        expect(res.warehouses[0].items).toHaveLength(1);
    });

    it('با warehouseId + صفحهبندی — صفحهبندی و مدلها کار میکند', async () => {
        queryRaw
            .mockResolvedValueOnce(
                Array.from({ length: 30 }, (_, i) => ({
                    productId: `p${i}`,
                    productName: `کالای ${i}`,
                    unit: 'عدد',
                    count: i + 1,
                })),
            )
            .mockResolvedValueOnce(
                Array.from({ length: 30 }, (_, i) => ({
                    productId: `p${i}`,
                    cartonRows: 1,
                })),
            )
            .mockResolvedValueOnce([])
            .mockResolvedValueOnce([
                { productId: 'p9', modelCount: 2, modelNames: ['SL116', 'SL120'] },
            ]);

        const res = await inventoryService.getProductInventory({ warehouseId: 'wh1', page: 2, pageSize: 20 });

        expect(res.total).toBe(30);
        expect(res.products).toHaveLength(10);
        expect(res.hasMore).toBe(false);
        const p9 = res.products.find(p => p.productId === 'p9')!;
        expect(p9.modelCount).toBe(2);
        expect(p9.modelNames).toEqual(['SL116', 'SL120']);
        // آیتمهای انبار فقط صفحهٔ جاری
        expect(res.warehouses[0].items).toHaveLength(10);
    });
});
