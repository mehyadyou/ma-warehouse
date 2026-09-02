import { describe, it, expect, vi, beforeEach } from 'vitest';
import { carriersService } from './carriers.service';

const mocks = vi.hoisted(() => {
    const findMany = vi.fn();
    const findUnique = vi.fn();
    const create = vi.fn();
    const update = vi.fn();
    const deleteFn = vi.fn();
    const aggregate = vi.fn();
    const transaction = vi.fn(async (ops: any[]) => {
        for (const op of ops) await op;
    });
    return { findMany, findUnique, create, update, deleteFn, aggregate, transaction };
});

vi.mock('../../utils/prisma', () => ({
    prisma: {
        carrier: {
            findMany: mocks.findMany,
            findUnique: mocks.findUnique,
            create: mocks.create,
            update: mocks.update,
            delete: mocks.deleteFn,
            aggregate: mocks.aggregate,
        },
        $transaction: mocks.transaction,
    },
}));

beforeEach(() => {
    vi.clearAllMocks();
    // mockRejectedValue از تست قبلی روی update می‌ماند — حذف پیاده‌سازی تا mockResolvedValueOnce ها بدون تداخل کار کنند
    mocks.update.mockReset();
});

const carrierRow = (overrides: Record<string, any> = {}) => ({
    id: 'c1',
    name: 'باربری فارس',
    priority: 1,
    phone: '071-12345678',
    address: 'شیراز',
    createdAt: new Date('2026-09-02'),
    updatedAt: new Date('2026-09-02'),
    ...overrides,
});

describe('carriersService.list', () => {
    it('همهٔ باربری‌ها را مرتب بر اساس اولویت سپس نام برمی‌گرداند', async () => {
        mocks.findMany.mockResolvedValue([carrierRow(), carrierRow({ id: 'c2', name: 'باربری قدس', priority: 3 })]);

        const carriers = await carriersService.list();

        expect(carriers).toHaveLength(2);
        expect(carriers[0].name).toBe('باربری فارس');
        expect(mocks.findMany).toHaveBeenCalledWith({
            orderBy: [{ priority: 'asc' }, { name: 'asc' }],
        });
    });

    it('وقتی باربری‌ای ثبت نشده باشد لیست خالی برمی‌گردد', async () => {
        mocks.findMany.mockResolvedValue([]);
        const carriers = await carriersService.list();
        expect(carriers).toEqual([]);
    });
});

describe('carriersService.create', () => {
    it('باربری جدید به انتهای صف اضافه می‌شود (اولویت = ماکسیمم + ۱)', async () => {
        mocks.aggregate.mockResolvedValue({ _max: { priority: 4 } });
        mocks.create.mockResolvedValue(carrierRow({ id: 'c9', name: 'باربری جدید', priority: 5, phone: '021-111', address: 'تهران' }));

        const result = await carriersService.create('باربری جدید', '021-111', 'تهران');

        expect(mocks.aggregate).toHaveBeenCalledWith({ _max: { priority: true } });
        expect(mocks.create).toHaveBeenCalledWith({
            data: { name: 'باربری جدید', priority: 5, phone: '021-111', address: 'تهران' },
        });
        expect(result.name).toBe('باربری جدید');
    });

    it('بدون باربری قبلی → اولین باربری با اولویت صفر (بالای صف)', async () => {
        mocks.aggregate.mockResolvedValue({ _max: { priority: null } });
        mocks.create.mockResolvedValue(carrierRow({ id: 'c9', name: 'باربری اول', priority: 0 }));

        await carriersService.create('باربری اول');

        expect(mocks.create).toHaveBeenCalledWith({
            data: { name: 'باربری اول', priority: 0, phone: null, address: null },
        });
    });

    it('فیلدهای اختیاری خالی → null ذخیره می‌شوند', async () => {
        mocks.aggregate.mockResolvedValue({ _max: { priority: 2 } });
        mocks.create.mockResolvedValue(carrierRow({ phone: null, address: null }));

        await carriersService.create('باربری ساده', '', '  ');

        expect(mocks.create).toHaveBeenCalledWith({
            data: { name: 'باربری ساده', priority: 3, phone: null, address: null },
        });
    });

    it('نام تکراری (P2002) → AppError 409 دوستانه', async () => {
        mocks.aggregate.mockResolvedValue({ _max: { priority: 1 } });
        mocks.create.mockRejectedValue({ code: 'P2002' });

        await expect(carriersService.create('باربری فارس')).rejects.toThrow('این باربری قبلاً ثبت شده است');
    });
});

describe('carriersService.update', () => {
    it('فقط فیلدهای ارسالی تغییر می‌کنند و بقیه حفظ می‌شوند', async () => {
        mocks.findUnique.mockResolvedValue(carrierRow());
        mocks.update.mockResolvedValue(carrierRow({ name: 'باربری نوین', priority: 10 }));

        const result = await carriersService.update('c1', { name: 'باربری نوین', priority: 10 });

        expect(mocks.update).toHaveBeenCalledWith({
            where: { id: 'c1' },
            data: {
                name: 'باربری نوین',
                priority: 10,
                phone: '071-12345678',
                address: 'شیراز',
            },
        });
        expect(result.priority).toBe(10);
    });

    it('ویرایش با phone: null صریح → تلفن پاک می‌شود', async () => {
        mocks.findUnique.mockResolvedValue(carrierRow());
        mocks.update.mockResolvedValue(carrierRow({ phone: null }));

        await carriersService.update('c1', { phone: null });

        expect(mocks.update).toHaveBeenCalledWith({
            where: { id: 'c1' },
            data: { name: 'باربری فارس', priority: 1, phone: null, address: 'شیراز' },
        });
    });

    it('باربری یافت نشد → AppError 404 (بدون عملیات update)', async () => {
        mocks.findUnique.mockResolvedValue(null);

        await expect(carriersService.update('nope', { name: 'x' })).rejects.toThrow('باربری یافت نشد');
        expect(mocks.update).not.toHaveBeenCalled();
    });

    it('تغییر نام به نام تکراری (P2002) → AppError 409', async () => {
        mocks.findUnique.mockResolvedValue(carrierRow());
        mocks.update.mockRejectedValue({ code: 'P2002' });

        await expect(carriersService.update('c1', { name: 'باربری قدس' })).rejects.toThrow('این باربری قبلاً ثبت شده است');
    });
});

describe('carriersService.reorder', () => {
    it('ترتیب جدید را به اولویت‌های ۰..n تبدیل و لیست مرتب برمی‌گرداند', async () => {
        mocks.findMany
            .mockResolvedValueOnce([{ id: 'c1' }, { id: 'c2' }])
            .mockResolvedValueOnce([
                carrierRow({ id: 'c2', name: 'باربری قدس', priority: 0 }),
                carrierRow({ id: 'c1', name: 'باربری فارس', priority: 1 }),
            ]);

        const carriers = await carriersService.reorder(['c2', 'c1']);

        expect(mocks.update).toHaveBeenNthCalledWith(1, { where: { id: 'c2' }, data: { priority: 0 } });
        expect(mocks.update).toHaveBeenNthCalledWith(2, { where: { id: 'c1' }, data: { priority: 1 } });
        expect(mocks.transaction).toHaveBeenCalledTimes(1);
        expect(carriers[0].name).toBe('باربری قدس');
        expect(carriers[1].name).toBe('باربری فارس');
    });

    it('ترتیب ناقص → AppError 400 بدون تراکنش', async () => {
        mocks.findMany.mockResolvedValueOnce([{ id: 'c1' }, { id: 'c2' }]);

        await expect(carriersService.reorder(['c1'])).rejects.toThrow(
            'ترتیب ارسالی با لیست باربری‌ها همخوانی ندارد',
        );
        expect(mocks.transaction).not.toHaveBeenCalled();
    });

    it('شناسهٔ ناشناخته در ترتیب → AppError 400 بدون تراکنش', async () => {
        mocks.findMany.mockResolvedValueOnce([{ id: 'c1' }, { id: 'c2' }]);

        await expect(carriersService.reorder(['c1', 'nope'])).rejects.toThrow(
            'ترتیب ارسالی با لیست باربری‌ها همخوانی ندارد',
        );
        expect(mocks.transaction).not.toHaveBeenCalled();
    });
});

describe('carriersService.remove', () => {
    it('حذف موفق → شناسهٔ باربری برمی‌گردد', async () => {
        mocks.findUnique.mockResolvedValue(carrierRow());

        const result = await carriersService.remove('c1');

        expect(mocks.deleteFn).toHaveBeenCalledWith({ where: { id: 'c1' } });
        expect(result).toEqual({ id: 'c1' });
    });

    it('باربری یافت نشد → AppError 404', async () => {
        mocks.findUnique.mockResolvedValue(null);

        await expect(carriersService.remove('nope')).rejects.toThrow('باربری یافت نشد');
        expect(mocks.deleteFn).not.toHaveBeenCalled();
    });
});