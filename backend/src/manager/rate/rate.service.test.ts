import { describe, it, expect, vi, beforeEach } from 'vitest';
import { extractPrice, __resetCache } from './rate.service';
import { rateService } from './rate.service';

const mockFn = vi.fn();

vi.mock('https', () => ({
    default: {
        get: (...args: any[]) => mockFn(...args),
        Agent: class Agent {
            constructor(_opts?: any) {}
        },
    },
}));

function fakeResponse(json: object) {
    const { PassThrough } = require('stream');
    const res = new PassThrough();
    res.statusCode = 200;
    process.nextTick(() => {
        res.write(JSON.stringify(json));
        res.end();
    });
    return res;
}

function fakeReq() {
    const { EventEmitter } = require('events');
    const req = new EventEmitter();
    req.destroy = vi.fn();
    req.setTimeout = vi.fn();
    return req;
}

beforeEach(() => {
    mockFn.mockReset();
    __resetCache();
});

describe('extractPrice', () => {
    it('market.price_dollar_rl.p', () => {
        expect(extractPrice({ market: { price_dollar_rl: { p: '52,300' } } })).toBe(52300);
    });

    it('data.price_dollar_rl.price', () => {
        expect(extractPrice({ data: { price_dollar_rl: { price: 51000 } } })).toBe(51000);
    });

    it('مستقیم price_dollar_rl.value', () => {
        expect(extractPrice({ price_dollar_rl: { value: '48,500.5' } })).toBe(48500.5);
    });

    it('last key fallback', () => {
        expect(extractPrice({ price_dollar_rl: { last: '50000' } })).toBe(50000);
    });

    it('null وقتی فرمت ناشناخته باشد', () => {
        expect(extractPrice({ something: { else: 123 } })).toBeNull();
    });

    it('null وقتی قیمت 0 باشد', () => {
        expect(extractPrice({ market: { price_dollar_rl: { p: '0' } } })).toBeNull();
    });

    it('حذف کاراکترهای غیرعددی از قیمت', () => {
        expect(extractPrice({ market: { price_dollar_rl: { p: '$52300' } } })).toBe(52300);
    });
});

describe('rateService.getDollarRate', () => {
    it('نرخ طبیعی از TGJU با موفقیت', async () => {
        mockFn.mockImplementation((_url: any, _opts: any, cb: any) => {
            cb(fakeResponse({ market: { price_dollar_rl: { p: '52300' } } }));
            return fakeReq();
        });

        const result = await rateService.getDollarRate();
        expect(result.price).toBe(52300);
        expect(result.source).toBe('tgju');
    });

    it('فقط یکبار HTTP میزند', async () => {
        mockFn.mockImplementation((_url: any, _opts: any, cb: any) => {
            cb(fakeResponse({ market: { price_dollar_rl: { p: '52300' } } }));
            return fakeReq();
        });

        await rateService.getDollarRate();
        await rateService.getDollarRate();
        expect(mockFn).toHaveBeenCalledTimes(1);
    });

    it('fallback به last-known وقتی TGJU خطا بدهد', async () => {
        mockFn.mockImplementation((_url: any, _opts: any, cb: any) => {
            cb(fakeResponse({ market: { price_dollar_rl: { p: '52300' } } }));
            return fakeReq();
        });
        await rateService.getDollarRate();

        vi.useFakeTimers();
        vi.advanceTimersByTime(6 * 60 * 1000); // پشت سر 5 دقیقه TTL

        const req = fakeReq();
        mockFn.mockImplementation((_url: any, _opts: any, cb: any) => {
            process.nextTick(() => req.emit('error', new Error('network fail')));
            return req;
        });

        const result = await rateService.getDollarRate();
        vi.useRealTimers();
        expect(result.price).toBe(52300);
        expect(result.source).toBe('last-known');
    });

    it('AppError 502 وقتی نه کش باشد نه TGJU', async () => {
        mockFn.mockImplementation((_url: any, _opts: any, cb: any) => {
            const req = fakeReq();
            process.nextTick(() => req.emit('error', new Error('fail')));
            return req;
        });

        await expect(rateService.getDollarRate()).rejects.toThrow('دریافت نرخ دلار ممکن نشد');
    });

    it('خطا وقتی TGJU پاسخ بده ولی قیمت نباشد', async () => {
        mockFn.mockImplementation((_url: any, _opts: any, cb: any) => {
            cb(fakeResponse({ market: {} }));
            return fakeReq();
        });

        // سرویس خطای داخلی fetchFromTgju را catch و پیام عمومی برمیگرداند
        await expect(rateService.getDollarRate()).rejects.toThrow('دریافت نرخ دلار ممکن نشد');
    });
});
