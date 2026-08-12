import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../utils/prisma', () => ({
    prisma: {
        warehouse: { findUnique: vi.fn() },
    },
}));

import { requireActiveWarehouse } from './requireActiveWarehouse';
import { prisma } from '../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
});

function makeRes() {
    const res = {
        statusCode: 0,
        body: undefined as unknown,
        status(code: number) {
            res.statusCode = code;
            return this;
        },
        json(payload: unknown) {
            res.body = payload;
            return this;
        },
    };
    return res;
}

describe('requireActiveWarehouse (فریز انبار بایگانیشده)', () => {
    it('انبار فعال → next صدا زده میشود؛ هیچ پاسخ 403 ارسال نمیشود', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ deletedAt: null });
        const res = makeRes();
        const next = vi.fn();

        await requireActiveWarehouse({ user: { warehouseId: 'wh1' } } as any, res as any, next);

        expect(next).toHaveBeenCalledTimes(1);
        expect(res.statusCode).toBe(0);
    });

    it('انبار بایگانیشده → 403 با پیام واضح؛ next صدا زده نمیشود', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue({ deletedAt: new Date() });
        const res = makeRes();
        const next = vi.fn();

        await requireActiveWarehouse({ user: { warehouseId: 'wh1' } } as any, res as any, next);

        expect(res.statusCode).toBe(403);
        expect((res.body as any).error).toContain('بایگانیشده');
        expect(next).not.toHaveBeenCalled();
    });

    it('انبار یافت نشد → 403 (همان فریز)', async () => {
        (prisma.warehouse.findUnique as any).mockResolvedValue(null);
        const res = makeRes();
        const next = vi.fn();

        await requireActiveWarehouse({ user: { warehouseId: 'wh1' } } as any, res as any, next);

        expect(res.statusCode).toBe(403);
        expect(next).not.toHaveBeenCalled();
    });

    it('کاربر بدون انبار → 403', async () => {
        const res = makeRes();
        const next = vi.fn();

        await requireActiveWarehouse({ user: {} } as any, res as any, next);

        expect(res.statusCode).toBe(403);
        expect((res.body as any).error).toContain('انباری به این کاربر متصل نیست');
        expect(prisma.warehouse.findUnique).not.toHaveBeenCalled();
    });
});