import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { assistantConfigService, testAssistantConnection, assistantConfigSchema } from './assistant-config.service';

const mocks = vi.hoisted(() => {
    const row = {
        id: 'default',
        name: 'GLM تست',
        baseUrl: 'https://custom.example/v1',
        apiKey: 'db-key-1234',
        model: 'my-model',
        maxTokens: 4000,
        thinking: false,
    };
    return {
        row,
        findUnique: vi.fn(),
        upsert: vi.fn(),
        deleteMany: vi.fn(),
    };
});

vi.mock('openai', () => ({
    default: class {
        chat = {
            completions: {
                create: vi.fn().mockResolvedValue({ choices: [{ message: { content: 'pong' } }] }),
            },
        };
    },
}));

vi.mock('../../utils/prisma', () => ({
    prisma: {
        assistantConfig: {
            findUnique: mocks.findUnique,
            upsert: mocks.upsert,
            deleteMany: mocks.deleteMany,
        },
    },
}));

beforeEach(() => {
    vi.clearAllMocks();
    vi.stubEnv('ZAI_API_KEY', 'env-key');
    vi.stubEnv('ZAI_MODEL', 'env-model');
    vi.stubEnv('ZAI_BASE_URL', 'https://env.example/v1');
});

afterEach(() => {
    vi.unstubAllEnvs();
});

describe('assistantConfigService.resolve', () => {
    it('بدون ردیف دیتابیس → fallback به env/پیش‌فرض', async () => {
        mocks.findUnique.mockResolvedValueOnce(null);
        const cfg = await assistantConfigService.resolve();
        expect(cfg).toEqual({
            name: null,
            baseUrl: 'https://env.example/v1',
            model: 'env-model',
            apiKey: 'env-key',
            maxTokens: 8000,
            thinking: true,
            fromDb: false,
        });
    });

    it('با ردیف دیتابیس → مقادیر ردیف اولویت دارند و کلید خالی از env می‌آید', async () => {
        mocks.findUnique.mockResolvedValueOnce(mocks.row);
        const cfg = await assistantConfigService.resolve();
        expect(cfg).toEqual({
            name: 'GLM تست',
            baseUrl: 'https://custom.example/v1',
            model: 'my-model',
            apiKey: 'db-key-1234',
            maxTokens: 4000,
            thinking: false,
            fromDb: true,
        });
    });

    it('getPublic کلید کامل را برنمی‌گرداند — فقط tail', async () => {
        mocks.findUnique.mockResolvedValueOnce(mocks.row);
        const pub = await assistantConfigService.getPublic();
        expect(pub.apiKey).toBeUndefined();
        expect(pub.hasApiKey).toBe(true);
        expect(pub.apiKeyTail).toBe('1234');
    });
});

describe('assistantConfigService.save/reset', () => {
    it('upsert با مقادیر داده‌شده ذخیره می‌کند', async () => {
        mocks.findUnique.mockResolvedValueOnce(null);
        mocks.upsert.mockResolvedValueOnce({});
        await assistantConfigService.save({
            baseUrl: 'https://x/v1',
            model: 'm',
            apiKey: 'k',
            maxTokens: 3000,
            thinking: true,
        });
        expect(mocks.upsert).toHaveBeenCalledWith({
            where: { id: 'default' },
            create: expect.objectContaining({ id: 'default', baseUrl: 'https://x/v1', apiKey: 'k' }),
            update: expect.objectContaining({ baseUrl: 'https://x/v1', apiKey: 'k' }),
        });
    });

    it('apiKey نامشخص هنگام ویرایش، کلید قبلی را نگه می‌دارد', async () => {
        mocks.findUnique.mockResolvedValueOnce(mocks.row);
        mocks.upsert.mockResolvedValueOnce({});
        await assistantConfigService.save({ baseUrl: 'https://y/v1', model: 'm2' });
        expect(mocks.upsert).toHaveBeenCalledWith(
            expect.objectContaining({
                update: expect.objectContaining({ apiKey: 'db-key-1234' }),
            }),
        );
    });

    it('reset ردیف را حذف می‌کند', async () => {
        await assistantConfigService.reset();
        expect(mocks.deleteMany).toHaveBeenCalledWith({ where: { id: 'default' } });
    });
});

describe('testAssistantConnection', () => {
    it('اتصال موفق → ok با تأخیر', async () => {
        mocks.findUnique.mockResolvedValueOnce(null);
        const result = await testAssistantConnection({
            baseUrl: 'https://custom/v1',
            model: 'custom-model',
            apiKey: 'custom-key',
        });
        expect(result.ok).toBe(true);
        expect(result.model).toBe('custom-model');
        expect(typeof result.latencyMs).toBe('number');
    });
});

describe('assistantConfigSchema', () => {
    it('ورودی معتبر را می‌پذیرد', () => {
        const r = assistantConfigSchema.safeParse({
            baseUrl: 'https://x/v1',
            model: 'm',
            apiKey: 'k',
            maxTokens: 4000,
            thinking: false,
        });
        expect(r.success).toBe(true);
    });

    it('بدون baseUrl/model نامعتبر است', () => {
        expect(assistantConfigSchema.safeParse({}).success).toBe(false);
    });
});
