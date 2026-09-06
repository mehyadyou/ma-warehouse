import OpenAI from 'openai';
import { z } from 'zod';
import { env } from '../../config/env';
import { prisma } from '../../utils/prisma';
import { logger } from '../../utils/logger';
import { AppError } from '../../common/exceptions/AppError';

export const SINGLETON_ID = 'default';

/** سرویس‌دهندهٔ پیش‌فرض: Z.AI (Zhipu) — OpenAI-compatible — مدل‌های GLM */
export const DEFAULT_BASE_URL = 'https://api.z.ai/api/paas/v4';
export const DEFAULT_MODEL = 'glm-4.7-flash';
export const DEFAULT_MAX_TOKENS = 8000;
export const DEFAULT_THINKING = true;

export const assistantConfigSchema = z.object({
    name:     z.string('نام دلخواه').trim().max(100, 'نام حداکثر ۱۰۰ نویسه است').optional(),
    baseUrl:  z.string('آدرس پایه الزامی است').trim().min(1, 'آدرس پایه الزامی است').max(500, 'آدرس پایه بیش از حد طولانی است'),
    model:    z.string('نام مدل الزامی است').trim().min(1, 'نام مدل الزامی است').max(200, 'نام مدل بیش از حد طولانی است'),
    // apiKey اختیاری است: undefined = «تغییر نده»، '' = «حذف کن و از env استفاده کن»
    apiKey:   z.string('کلید API').trim().max(2000, 'کلید API بیش از حد طولانی است').optional(),
    maxTokens: z.number('سقف توکن باید عدد باشد').int('سقف توکن باید عدد صحیح باشد').min(256, 'حداقل ۲۵۶ توکن').max(100000, 'حداکثر ۱۰۰٬۰۰۰ توکن').optional(),
    thinking: z.boolean('حالت فکرکردن باید true/false باشد').optional(),
});

export type AssistantConfigInput = z.infer<typeof assistantConfigSchema>;

/** برای تست اتصال: همه اختیاری — مقادیرِ ناداده از پیکربندی فعلی خوانده می‌شود */
export const assistantConfigTestSchema = z.object({
    name:     assistantConfigSchema.shape.name,
    baseUrl:  assistantConfigSchema.shape.baseUrl.optional(),
    model:    assistantConfigSchema.shape.model.optional(),
    apiKey:   assistantConfigSchema.shape.apiKey,
    maxTokens: assistantConfigSchema.shape.maxTokens,
    thinking: assistantConfigSchema.shape.thinking,
});

export interface ResolvedAssistantConfig {
    name:      string | null;
    baseUrl:   string;
    model:     string;
    apiKey:    string; // کلید مؤثر (از ردیف دیتابیس یا env) — هرگز در GET برنمی‌گردد
    maxTokens: number;
    thinking:  boolean;
    /** ردیف اختصاصی دیتابیس هست یا از env/پیش‌فرض‌ها استفاده می‌شود؟ */
    fromDb:    boolean;
}

/** پیکربندیِ فعال دستیار — ردیف دیتابیس اگر هست، وگرنه fallback به env/پیش‌فرض */
export const assistantConfigService = {
    /** پیکربندی مؤثر برای اجرا (شامل کلید واقعی — فقط داخل سرور) */
    async resolve(): Promise<ResolvedAssistantConfig> {
        const row = await prisma.assistantConfig.findUnique({ where: { id: SINGLETON_ID } });
        if (row) {
            return {
                name:      row.name,
                baseUrl:   row.baseUrl,
                model:     row.model,
                // کلید ردیف اگر خالی باشد → fallback به env تا «خالی = همان کلید env» بماند
                apiKey:    row.apiKey && row.apiKey.trim() ? row.apiKey : env.ZAI_API_KEY,
                maxTokens: row.maxTokens,
                thinking:  row.thinking,
                fromDb:    true,
            };
        }
        return {
            name:      null,
            baseUrl:   env.ZAI_BASE_URL || DEFAULT_BASE_URL,
            model:     env.ZAI_MODEL || DEFAULT_MODEL,
            apiKey:    env.ZAI_API_KEY,
            maxTokens: env.ASSISTANT_MAX_TOKENS,
            thinking:  DEFAULT_THINKING,
            fromDb:    false,
        };
    },

    /** نمای عمومی برای GET — هرگز کلید کامل را برنمی‌گرداند */
    async getPublic() {
        const cfg = await this.resolve();
        return {
            name:      cfg.name,
            baseUrl:   cfg.baseUrl,
            model:     cfg.model,
            maxTokens: cfg.maxTokens,
            thinking:  cfg.thinking,
            fromDb:    cfg.fromDb,
            hasApiKey: cfg.apiKey.trim().length > 0,
            // فقط ۴ نویسهٔ آخر برای تشخیص کلید ذخیره‌شده
            apiKeyTail: cfg.apiKey.trim().length > 0 ? cfg.apiKey.trim().slice(-4) : null,
        };
    },

    /** ذخیره/به‌روزرسانی پیکربندی در دیتابیس */
    async save(input: AssistantConfigInput) {
        const existing = await prisma.assistantConfig.findUnique({ where: { id: SINGLETON_ID } });
        // apiKey خالی ('' یا undefined) یعنی «از کلید env استفاده کن» — resolve در همان حالت
        // به env.ZAI_API_KEY برمی‌گردد؛ پس کلید env در دیتابیس کپی نمی‌شود.
        const data = {
            name:      input.name ?? existing?.name ?? null,
            baseUrl:   input.baseUrl,
            model:     input.model,
            apiKey:    input.apiKey !== undefined ? input.apiKey : existing?.apiKey ?? '',
            maxTokens: input.maxTokens ?? existing?.maxTokens ?? env.ASSISTANT_MAX_TOKENS,
            thinking:  input.thinking ?? existing?.thinking ?? DEFAULT_THINKING,
        };
        const row = await prisma.assistantConfig.upsert({
            where: { id: SINGLETON_ID },
            create: { id: SINGLETON_ID, ...data },
            update: data,
        });
        logger.info({ model: row.model, baseUrl: row.baseUrl }, 'assistant config saved');
        return row;
    },

    /** حذف ردیف اختصاصی → بازگشت به env/پیش‌فرض‌ها */
    async reset() {
        await prisma.assistantConfig.deleteMany({ where: { id: SINGLETON_ID } });
    },
};

/** معتبرسازی و تست اتصال به مدل — بدون ذخیره */
export async function testAssistantConnection(input: AssistantConfigInput): Promise<{ ok: true; model: string; latencyMs: number }> {
    const current = await assistantConfigService.resolve();
    const baseUrl = (input.baseUrl || current.baseUrl).trim();
    const model = (input.model || current.model).trim();
    const apiKey = (input.apiKey !== undefined ? input.apiKey : current.apiKey).trim();
    if (!baseUrl || !model) {
        throw new AppError('آدرس پایه و نام مدل برای تست اتصال الزامی است', 400);
    }

    // OpenAI-compatible حداقلی — بدون ابزار، فقط یک پیام کوتاه
    const client = new OpenAI({ baseURL: baseUrl, apiKey: apiKey || 'no-key' });
    const started = Date.now();
    try {
        await client.chat.completions.create({
            model,
            messages: [{ role: 'user', content: 'ping' }],
            max_tokens: 5,
        });
        return { ok: true, model, latencyMs: Date.now() - started };
    } catch (e) {
        const message = (e as Error)?.message ?? 'نامشخص';
        logger.warn({ baseUrl, model, error: message }, 'assistant connection test failed');
        throw new AppError(`اتصال ناموفق بود: ${message}`, 502);
    }
}
