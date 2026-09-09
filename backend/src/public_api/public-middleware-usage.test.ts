import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../utils/prisma', () => ({
    prisma: {
        apiKey: {
            findUnique: vi.fn(),
            update: vi.fn(),
        },
        apiKeyDailyUsage: {
            upsert: vi.fn(),
            updateMany: vi.fn(),
        },
    },
}));

import { authenticateApiKey } from './public.middleware';
import { prisma } from '../utils/prisma';

function makeRes() {
    const listeners: Record<string, Array<() => void>> = {};
    return {
        statusCode: 200,
        status(c: number) {
            this.statusCode = c;
            return this;
        },
        json() {
            return this;
        },
        on(ev: string, fn: () => void) {
            (listeners[ev] ||= []).push(fn);
            return this;
        },
        emit(ev: string) {
            for (const fn of listeners[ev] ?? []) fn();
        },
    } as any;
}

const keyRow = {
    id: 'k1',
    scopes: ['orders'],
    revokedAt: null,
    isActive: true,
    expiresAt: null,
};

beforeEach(() => {
    vi.clearAllMocks();
    (prisma.apiKeyDailyUsage.upsert as any).mockResolvedValue({});
    (prisma.apiKeyDailyUsage.updateMany as any).mockResolvedValue({ count: 1 });
});

describe('authenticateApiKey — هوک مصرف روزانه (CRM)', () => {
    it('کلید معتبر → hits همان روز +1 (و lastUsedAt/useCount مثل قبل)', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow);
        (prisma.apiKey.update as any).mockResolvedValue({});
        const req = { headers: { authorization: 'Bearer ma_live_abcdef1234567890' } } as any;
        const res = makeRes();
        let nexted = false;

        await authenticateApiKey(req, res, () => {
            nexted = true;
        });
        await new Promise((r) => setTimeout(r, 20));

        expect(nexted).toBe(true);
        expect(req.apiKey).toEqual({ id: 'k1', scopes: ['orders'] });
        expect(prisma.apiKeyDailyUsage.upsert).toHaveBeenCalledWith(
            expect.objectContaining({
                where: { apiKeyId_dayKey: { apiKeyId: 'k1', dayKey: expect.any(Number) } },
                update: { hits: { increment: 1 } },
            }),
        );
    });

    it('پاسخ 4xx → errors همان روز +1', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow);
        (prisma.apiKey.update as any).mockResolvedValue({});
        const req = { headers: { authorization: 'Bearer ma_live_abcdef1234567890' } } as any;
        const res = makeRes();

        await authenticateApiKey(req, res, () => {});
        res.statusCode = 403;
        res.emit('finish');
        await new Promise((r) => setTimeout(r, 20));

        const calls = (prisma.apiKeyDailyUsage.upsert as any).mock.calls;
        expect(calls.some((c: any) => c[0]?.update?.errors)).toBe(true);
    });

    it('تعارض هم‌زمان ساخت ردیف (P2002) → fallback به updateMany', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(keyRow);
        (prisma.apiKey.update as any).mockResolvedValue({});
        const err: any = new Error('unique');
        err.code = 'P2002';
        (prisma.apiKeyDailyUsage.upsert as any).mockRejectedValueOnce(err);
        const req = { headers: { authorization: 'Bearer ma_live_abcdef1234567890' } } as any;

        await authenticateApiKey(req, makeRes(), () => {});
        await new Promise((r) => setTimeout(r, 20));

        expect(prisma.apiKeyDailyUsage.updateMany).toHaveBeenCalledWith(
            expect.objectContaining({
                where: expect.objectContaining({ apiKeyId: 'k1' }),
                data: { hits: { increment: 1 } },
            }),
        );
    });

    it('کلید نامعتبر → بدون ثبت مصرف و بدون next', async () => {
        (prisma.apiKey.findUnique as any).mockResolvedValue(null);
        const req = { headers: { authorization: 'Bearer ma_live_xxxx' } } as any;
        const res = makeRes();
        let nexted = false;

        await authenticateApiKey(req, res, () => {
            nexted = true;
        });

        expect(nexted).toBe(false);
        expect(res.statusCode).toBe(401);
        expect(prisma.apiKeyDailyUsage.upsert).not.toHaveBeenCalled();
    });
});
