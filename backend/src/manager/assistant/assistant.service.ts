import OpenAI from 'openai';
import { prisma } from '../../utils/prisma';
import { logger } from '../../utils/logger';
import { AppError } from '../../common/exceptions/AppError';
import { validateReadOnlySql, maskSensitiveColumns } from './sql-guard';
import { ASSISTANT_SYSTEM_PROMPT } from './schema-description';
import { assistantConfigService } from './assistant-config.service';
import { ChatHistoryItem } from './assistant.schema';

const MAX_TOOL_ROUNDS = 6;
const MAX_ROWS = 200;
const STATEMENT_TIMEOUT_MS = 15000;

interface ToolCallAcc {
    id: string;
    name: string;
    arguments: string;
}

/** نوع پیام دستیار Z.AI با فیلد reasoning_content (افزونهٔ Z.AI برای حالت فکرکردن) */
type ZAIAssistantMessage = OpenAI.ChatCompletionMessageParam & {
    reasoning_content?: string;
};

const READ_ONLY_TOOL: OpenAI.ChatCompletionTool = {
    type: 'function',
    function: {
        name: 'run_readonly_query',
        description:
            'اجرای یک کوئری فقط‌خواندنی (SELECT) روی دیتابیس انبار و برگرداندن ردیف‌ها به‌صورت JSON. تنها منبع داده برای پاسخ تو همین ابزار است — نتیجهٔ آن را دقیق بررسی کن. فقط SELECT — هر نوع نوشتن رد می‌شود.',
        parameters: {
            type: 'object',
            properties: {
                sql: {
                    type: 'string',
                    description: 'عبارت SQL فقط‌خواندنی (SELECT با یا بدون CTE/JOIN/GROUP BY)',
                },
            },
            required: ['sql'],
        },
    },
};

/**
 * اجبار ابزار در دور اول: مدل باید پیش از هر پاسخ آماری حداقل یک کوئری واقعی بزند.
 * بدون این، بعضی مدل‌ها (مثل GLM) از حفظ جواب می‌دهند و عدد جعل می‌کنند.
 * از دور دوم به بعد 'auto' است تا مدل با دادهٔ موجود مستقیماً پاسخ دهد.
 */
const FORCE_QUERY_TOOL: OpenAI.ChatCompletionToolChoiceOption = {
    type: 'function',
    function: { name: 'run_readonly_query' },
};

/**
 * اجرای امن و فقط‌خواندنی SQL:
 * - تراکنش READ ONLY در سطح دیتابیس (حتی تلاش برای نوشتن هم مسدود می‌شود)
 * - statement_timeout برای جلوگیری از کوئری سنگین
 * - سقف ۲۰۰ ردیف + ماسک ستون‌های حساس
 */
async function executeReadOnly(
    sql: string,
): Promise<{ ok: true; rows: Record<string, unknown>[] } | { ok: false; error: string }> {
    const guard = validateReadOnlySql(sql);
    if (guard.ok === false) return { ok: false, error: guard.error };
    try {
        const rows = await prisma.$transaction(async (tx) => {
            await tx.$executeRawUnsafe('SET TRANSACTION READ ONLY');
            await tx.$executeRawUnsafe(`SET LOCAL statement_timeout = ${STATEMENT_TIMEOUT_MS}`);
            return (await tx.$queryRawUnsafe(
                `SELECT * FROM (${guard.sql}) AS _assistant_result LIMIT ${MAX_ROWS}`,
            )) as Record<string, unknown>[];
        });
        return { ok: true, rows: maskSensitiveColumns(rows) };
    } catch (e) {
        return { ok: false, error: `خطای اجرای کوئری: ${(e as Error)?.message ?? 'نامشخص'}` };
    }
}

/**
 * سریال‌سازی امن نتایج کوئری برای مدل:
 * - BigInt (خروجی Prisma برای bigint/count) → عدد (یا رشته در صورت خروج از محدودهٔ ایمن)
 * - Buffer (bytea) → hex
 */
function toModelJson(rows: Record<string, unknown>[]): string {
    return JSON.stringify(rows, (_key, value) => {
        if (typeof value === 'bigint') {
            const n = Number(value);
            return Number.isSafeInteger(n) ? n : value.toString();
        }
        if (Buffer.isBuffer(value)) return value.toString('hex');
        return value;
    });
}

/**
 * اجرای فراخوانی‌های ابزار مدل و افزودن پیام‌های tool به گفتگو.
 * شامل: گارد SQL فقط‌خواندنی، جلوگیری از اجرای دوبارهٔ کوئری تکراری و ماسک ستون‌های حساس.
 */
async function runToolCalls(
    messages: ZAIAssistantMessage[],
    toolCalls: ToolCallAcc[],
    executedQueries: Set<string>,
): Promise<void> {
    for (const call of toolCalls) {
        if (!call.id) continue;
        let args: { sql?: string } = {};
        try {
            args = JSON.parse(call.arguments || '{}');
        } catch {
            args = {};
        }
        const sql = (args.sql ?? '').trim();
        if (!sql) {
            messages.push({
                role: 'tool',
                tool_call_id: call.id,
                content: 'SQL ارائه نشده است — آرگومان sql باید یک عبارت SELECT باشد.',
            });
            continue;
        }
        if (executedQueries.has(sql)) {
            // تکرار همان کوئری: داده از قبل در پیام‌های قبل هست
            messages.push({
                role: 'tool',
                tool_call_id: call.id,
                content:
                    'این کوئری قبلاً اجرا شده و نتیجهٔ آن در پیام‌های قبل موجود است؛ آن را دوباره اجرا نکن. بر اساس دادهٔ موجود گزارش نهایی را بده.',
            });
            continue;
        }
        executedQueries.add(sql);
        const result = await executeReadOnly(sql);
        messages.push({
            role: 'tool',
            tool_call_id: call.id,
            content:
            result.ok === true
                ? toModelJson(result.rows)
                : `${result.error} — نام جدول/ستون را با نقشهٔ جداول راهنمای سیستم دقیق بررسی کن.`,
        });
    }
}

/**
 * تبدیل خطاهای سرویس‌دهندهٔ هوش مصنوعی به پیام فارسیِ قابل‌نمایش.
 * پیام خام انگلیسیِ SDK/سرویس‌دهنده (مثل «The service may be temporarily overloaded… 429»)
 * هرگز به کلاینت نشت نمی‌کند؛ جزئیات فقط در لاگ سرور ثبت می‌شود.
 */
function toAssistantError(e: unknown): AppError {
    if (e instanceof AppError) return e;
    const err = e as { status?: unknown; name?: string } | null;
    if (err?.name === 'AbortError' || err?.name === 'APIUserAbortError') {
        return new AppError('درخواست لغو شد', 499);
    }
    const status = typeof err?.status === 'number' ? err.status : undefined;
    if (status === 429) {
        return new AppError('سرویس هوش مصنوعی شلوغ است؛ چند لحظه بعد دوباره تلاش کنید', 429);
    }
    if (status === 401 || status === 403) {
        return new AppError('کلید هوش مصنوعی نامعتبر است؛ از تنظیمات دستیار بررسی کنید', 502);
    }
    if (status === 404) {
        return new AppError('مدل یا آدرس پایهٔ هوش مصنوعی اشتباه است؛ از تنظیمات دستیار بررسی کنید', 502);
    }
    if (status !== undefined && status >= 400 && status < 500) {
        return new AppError('درخواست هوش مصنوعی رد شد؛ تنظیمات دستیار را بررسی کنید', 502);
    }
    if (status !== undefined && status >= 500) {
        return new AppError('سرور هوش مصنوعی موقتاً در دسترس نیست؛ کمی بعد دوباره تلاش کنید', 502);
    }
    // بدون status → خطای شبکه/DNS/timeout سمت سرور
    return new AppError('اتصال به سرویس هوش مصنوعی برقرار نشد؛ اتصال سرور را بررسی کنید', 502);
}

/** فراخوانی سرویس‌دهنده با نگاشت خطا — هر خطای خام به AppError فارسی تبدیل می‌شود */
async function createChatSafe<T>(fn: () => Promise<T>): Promise<T> {
    try {
        return await fn();
    } catch (e) {
        logger.warn(
            { err: (e as Error)?.message, name: (e as Error)?.name },
            'assistant provider error',
        );
        throw toAssistantError(e);
    }
}

/** پوشش استریم: خطای وسط استریم (قطع اتصال/خطای سرویس‌دهنده) هم به پیام فارسی نگاشت می‌شود */
async function* mapStreamErrors<T>(it: AsyncIterable<T>): AsyncGenerator<T> {
    try {
        yield* it;
    } catch (e) {
        logger.warn(
            { err: (e as Error)?.message, name: (e as Error)?.name },
            'assistant provider stream error',
        );
        throw toAssistantError(e);
    }
}

export const assistantService = {
    /**
     * گفتگوی مدیر با دستیار.
     * فاز ۱: حلقهٔ غیراستریمی با ابزارها (reasoning_content بین فراخوانی‌ها حفظ می‌شود —
     *        الگوی Z.AI برای ادامهٔ استدلال در حالت فکرکردن).
     * فاز ۲ (فقط وقتی onToken داده شده): پاسخ نهایی به‌صورت استریم توکن‌به‌توکن.
     */
    async chat(
        input: { message: string; history: ChatHistoryItem[] },
        onToken?: (text: string) => void,
    ): Promise<{ answer: string }> {
        const cfg = await assistantConfigService.resolve();
        const apiKey = cfg.apiKey;
        if (!apiKey) throw new AppError('کلید هوش مصنوعی تنظیم نشده است؛ از تنظیمات دستیار وارد کنید', 500);

        const client = new OpenAI({ baseURL: cfg.baseUrl, apiKey });
        const messages: ZAIAssistantMessage[] = [
            { role: 'system', content: ASSISTANT_SYSTEM_PROMPT },
            ...input.history.slice(-12).map((h) => ({ role: h.role, content: h.content })),
            { role: 'user', content: input.message },
        ];

        const baseOptions = {
            model: cfg.model,
            tools: [READ_ONLY_TOOL],
            max_tokens: cfg.maxTokens,
            // Z.AI — حالت فکرکردن (thinking)؛ فقط برای سرویس‌دهنده‌هایی که پشتیبانی می‌کنند فرستاده می‌شود
            ...(cfg.thinking ? { thinking: { type: 'enabled' } as const } : {}),
        };

        let finalText = '';
        let finished = false;
        // جلوگیری از حلقهٔ بی‌پایان: همان کوئری تکراری دوباره اجرا نمی‌شود
        const executedQueries = new Set<string>();
        // پاسخ خالی فقط یک بار با «نوشتن پاسخ نهایی» دوباره خواسته می‌شود
        let emptyRetries = 0;
        for (let round = 0; round <= MAX_TOOL_ROUNDS; round++) {
            const response = await createChatSafe(() =>
                client.chat.completions.create({
                    ...baseOptions,
                    // دور اول: ابزار اجباری — مدل نمی‌تواند بدون کوئری واقعی پاسخ دهد (جلوگیری از جعل داده)
                    tool_choice: round === 0 ? FORCE_QUERY_TOOL : 'auto',
                    messages,
                } as OpenAI.ChatCompletionCreateParamsNonStreaming),
            );

            const msg = response.choices[0]?.message;
            const finishReason = response.choices[0]?.finish_reason ?? null;
            logger.debug({ round, finishReason, usage: response.usage }, 'assistant round');
            if (!msg) throw new AppError('پاسخی از مدل دریافت نشد', 502);

            const toolCalls = msg.tool_calls ?? [];
            if (toolCalls.length === 0) {
                finalText = msg.content ?? '';
                if (finalText.trim()) {
                    finished = true;
                    break;
                }
                // content خالی (مثلاً finish_reason=length وسط reasoning)
                if (emptyRetries >= 1 || round === MAX_TOOL_ROUNDS) break;
                emptyRetries++;
                messages.push({
                    role: 'user',
                    content: 'پاسخ قبلی خالی بود؛ فقط متن گزارش/پاسخ نهایی را بنویس (بدون ابزار و بدون استدلال).',
                });
                continue;
            }
            if (round === MAX_TOOL_ROUNDS) {
                throw new AppError('دستیار نتوانست پاسخ را کامل کند؛ دوباره تلاش کنید', 502);
            }

            // حفظ reasoning_content طبق مستندات Z.AI — فقط وقتی حالت فکرکردن فعال است.
            // content برای پیام ابزار null است.
            messages.push({
                role: 'assistant',
                content: null,
                tool_calls: toolCalls,
                ...(cfg.thinking
                    ? { reasoning_content: (msg as ZAIAssistantMessage).reasoning_content }
                    : {}),
            });

            const accs: ToolCallAcc[] = toolCalls
                .filter(
                    (c): c is OpenAI.ChatCompletionMessageFunctionToolCall =>
                        c.type === 'function' && !!c.id,
                )
                .map((c) => ({
                    id: c.id,
                    name: c.function.name ?? '',
                    arguments: c.function.arguments ?? '',
                }));
            await runToolCalls(messages, accs, executedQueries);
        }

        if (!finished || !finalText.trim()) {
            throw new AppError('پاسخ مدل ناقص بود؛ دوباره تلاش کنید', 502);
        }

        // استریم: پاسخ نهایی با stream=true خواسته می‌شود تا توکن‌ها زنده برسند.
        // بدون ابزار تا مدل نتواند دوباره کوئری بخواهد؛ اگر استریم خطا داد، همان پاسخ کامل ارسال می‌شود.
        if (onToken) {
            try {
                const stream = await client.chat.completions.create({
                    model: baseOptions.model,
                    max_tokens: baseOptions.max_tokens,
                    messages,
                    stream: true,
                    ...(cfg.thinking ? { thinking: { type: 'enabled' } as const } : {}),
                } as OpenAI.ChatCompletionCreateParamsStreaming);
                for await (const chunk of mapStreamErrors(stream)) {
                    const delta = chunk.choices[0]?.delta?.content;
                    if (delta) onToken(delta);
                }
            } catch (e) {
                logger.warn({ error: (e as Error)?.message }, 'assistant stream failed; falling back');
                onToken(finalText);
            }
        }

        return { answer: finalText };
    },

    /**
     * گفتگوی کاملاً استریمی — همان حلقهٔ ابزار، ولی از همان درخواست اول stream=true:
     * - reasoning زنده از طریق onStatus و content کلمه‌به‌کلمه از طریق onToken می‌رسد
     * - فراخوانی ابزار وسط استریم جمع و اجرا می‌شود و استریم ادامه می‌یابد
     * - بدون درخواست دوم؛ پاسخ نهایی همان متنی است که استریم شده
     */
    async chatStream(
        input: { message: string; history: ChatHistoryItem[] },
        callbacks: {
            onToken: (text: string) => void;
            onStatus?: (text: string) => void;
            signal?: AbortSignal;
        },
    ): Promise<{ answer: string }> {
        const cfg = await assistantConfigService.resolve();
        const apiKey = cfg.apiKey;
        if (!apiKey) throw new AppError('کلید هوش مصنوعی تنظیم نشده است؛ از تنظیمات دستیار وارد کنید', 500);

        const client = new OpenAI({ baseURL: cfg.baseUrl, apiKey });
        const messages: ZAIAssistantMessage[] = [
            { role: 'system', content: ASSISTANT_SYSTEM_PROMPT },
            ...input.history.slice(-12).map((h) => ({ role: h.role, content: h.content })),
            { role: 'user', content: input.message },
        ];

        const baseOptions = {
            model: cfg.model,
            tools: [READ_ONLY_TOOL],
            max_tokens: cfg.maxTokens,
            // Z.AI — حالت فکرکردن (thinking)؛ فقط برای سرویس‌دهنده‌هایی که پشتیبانی می‌کنند فرستاده می‌شود
            ...(cfg.thinking ? { thinking: { type: 'enabled' } as const } : {}),
        };

        // پاسخ نهایی فقط از دورِ بدون-ابزار ساخته می‌شود؛ متن دورهای ابزار (مقدمهٔ
        // قبل از کوئری) زنده استریم می‌شود ولی نباید در پاسخ نهایی تکرار شود
        let answer = '';
        let emptyRetries = 0;
        const executedQueries = new Set<string>();
        let lastStatusAt = 0;
        const status = (text: string) => {
            if (!callbacks.onStatus) return;
            // throttle: وضعیت فکرکردن تقریباً هر ۸۰ms به‌روز می‌شود تا سوکت/UI سیل نشود
            const now = Date.now();
            if (now - lastStatusAt < 80) return;
            lastStatusAt = now;
            callbacks.onStatus(text);
        };

        for (let round = 0; round <= MAX_TOOL_ROUNDS; round++) {
            const stream = await createChatSafe(() =>
                client.chat.completions.create({
                    ...baseOptions,
                    // دور اول: ابزار اجباری — مدل نمی‌تواند بدون کوئری واقعی پاسخ دهد (جلوگیری از جعل داده)
                    tool_choice: round === 0 ? FORCE_QUERY_TOOL : 'auto',
                    messages,
                    stream: true,
                    signal: callbacks.signal,
                } as OpenAI.ChatCompletionCreateParamsStreaming),
            );

            let content = '';
            let reasoning = '';
            const toolCallIndex = new Map<number, ToolCallAcc>();

            for await (const chunk of mapStreamErrors(stream)) {
                const delta = chunk.choices?.[0]?.delta;
                if (!delta) continue;
                if (delta.content) {
                    content += delta.content;
                    callbacks.onToken(delta.content);
                }
                const reasoningFrag = (delta as unknown as { reasoning_content?: string }).reasoning_content;
                if (reasoningFrag) {
                    reasoning += reasoningFrag;
                    status(reasoning);
                }
                for (const tc of delta.tool_calls ?? []) {
                    if (tc.index === undefined) continue;
                    let acc = toolCallIndex.get(tc.index);
                    if (!acc) {
                        acc = { id: tc.id ?? '', name: '', arguments: '' };
                        toolCallIndex.set(tc.index, acc);
                    }
                    if (tc.id) acc.id = tc.id;
                    if (tc.function?.name) acc.name += tc.function.name;
                    if (tc.function?.arguments) acc.arguments += tc.function.arguments;
                }
            }

            const toolCalls = [...toolCallIndex.entries()]
                .sort((a, b) => a[0] - b[0])
                .map(([, v]) => v);

            if (toolCalls.length > 0) {
                if (round === MAX_TOOL_ROUNDS) {
                    throw new AppError('دستیار نتوانست پاسخ را کامل کند؛ دوباره تلاش کنید', 502);
                }
                messages.push({
                    role: 'assistant',
                    content: content || null,
                    tool_calls: toolCalls.map((c) => ({
                        id: c.id,
                        type: 'function' as const,
                        function: { name: c.name, arguments: c.arguments },
                    })),
                });
                status('در حال اجرای کوئری روی داده‌ها…');
                await runToolCalls(messages, toolCalls, executedQueries);
                status('در حال تحلیل نتایج…');
                continue;
            }

            if (content.trim()) {
                // فقط محتوای همین دور نهایی — بدون مقدمهٔ دورهای ابزار
                answer = content;
                return { answer };
            }
            if (emptyRetries >= 1 || round === MAX_TOOL_ROUNDS) {
                throw new AppError('پاسخ مدل ناقص بود؛ دوباره تلاش کنید', 502);
            }
            emptyRetries++;
            messages.push({
                role: 'user',
                content: 'پاسخ قبلی خالی بود؛ فقط متن گزارش/پاسخ نهایی را بنویس (بدون ابزار و بدون استدلال).',
            });
        }

        throw new AppError('پاسخ مدل ناقص بود؛ دوباره تلاش کنید', 502);
    },
};