import OpenAI from 'openai';
import { env } from '../../config/env';
import { prisma } from '../../utils/prisma';
import { logger } from '../../utils/logger';
import { AppError } from '../../common/exceptions/AppError';
import { validateReadOnlySql, maskSensitiveColumns } from './sql-guard';
import { ASSISTANT_SYSTEM_PROMPT } from './schema-description';
import { ChatHistoryItem } from './assistant.schema';

const OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1';
const MAX_TOOL_ROUNDS = 6;
const MAX_ROWS = 200;
const STATEMENT_TIMEOUT_MS = 15000;

interface ToolCallAcc {
    id: string;
    name: string;
    arguments: string;
}

/** نوع پیام دستیار OpenRouter با فیلد reasoning_details (افزونهٔ OpenRouter) */
type ORAssistantMessage = OpenAI.ChatCompletionMessageParam & {
    reasoning_details?: unknown;
};

const READ_ONLY_TOOL: OpenAI.ChatCompletionTool = {
    type: 'function',
    function: {
        name: 'run_readonly_query',
        description:
            'اجرای یک کوئری فقط‌خواندنی (SELECT) روی دیتابیس انبار و برگرداندن ردیف‌ها به‌صورت JSON. فقط SELECT — هر نوع نوشتن رد می‌شود.',
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
    messages: ORAssistantMessage[],
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

export const assistantService = {
    /**
     * گفتگوی مدیر با دستیار.
     * فاز ۱: حلقهٔ غیراستریمی با ابزارها (reasoning_details بین فراخوانی‌ها حفظ می‌شود —
     *        الگوی رسمی OpenRouter برای ادامهٔ استدلال).
     * فاز ۲ (فقط وقتی onToken داده شده): پاسخ نهایی به‌صورت استریم توکن‌به‌توکن.
     */
    async chat(
        input: { message: string; history: ChatHistoryItem[] },
        onToken?: (text: string) => void,
    ): Promise<{ answer: string }> {
        const apiKey = env.OPENROUTER_API_KEY;
        if (!apiKey) throw new AppError('کلید OpenRouter در سرور تنظیم نشده است', 500);

        const client = new OpenAI({ baseURL: OPENROUTER_BASE_URL, apiKey });
        const messages: ORAssistantMessage[] = [
            { role: 'system', content: ASSISTANT_SYSTEM_PROMPT },
            ...input.history.slice(-12).map((h) => ({ role: h.role, content: h.content })),
            { role: 'user', content: input.message },
        ];

        const baseOptions = {
            model: env.OPENROUTER_MODEL,
            tools: [READ_ONLY_TOOL],
            tool_choice: 'auto' as const,
            max_tokens: env.ASSISTANT_MAX_TOKENS,
            // افزونهٔ OpenRouter — reasoning داخلی فعال است ولی به کاربر نمایش داده نمی‌شود
            reasoning: { enabled: true },
        };

        let finalText = '';
        let finished = false;
        // جلوگیری از حلقهٔ بی‌پایان: همان کوئری تکراری دوباره اجرا نمی‌شود
        const executedQueries = new Set<string>();
        // پاسخ خالی فقط یک بار با «نوشتن پاسخ نهایی» دوباره خواسته می‌شود
        let emptyRetries = 0;
        for (let round = 0; round <= MAX_TOOL_ROUNDS; round++) {
            const response = await client.chat.completions.create({
                ...baseOptions,
                messages,
            } as OpenAI.ChatCompletionCreateParamsNonStreaming);

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

            // حفظ reasoning_details طبق مستندات OpenRouter — content برای پیام ابزار null است
            messages.push({
                role: 'assistant',
                content: null,
                tool_calls: toolCalls,
                reasoning_details: (msg as ORAssistantMessage).reasoning_details,
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
                    reasoning: baseOptions.reasoning,
                    messages,
                    stream: true,
                } as OpenAI.ChatCompletionCreateParamsStreaming);
                for await (const chunk of stream) {
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
        const apiKey = env.OPENROUTER_API_KEY;
        if (!apiKey) throw new AppError('کلید OpenRouter در سرور تنظیم نشده است', 500);

        const client = new OpenAI({ baseURL: OPENROUTER_BASE_URL, apiKey });
        const messages: ORAssistantMessage[] = [
            { role: 'system', content: ASSISTANT_SYSTEM_PROMPT },
            ...input.history.slice(-12).map((h) => ({ role: h.role, content: h.content })),
            { role: 'user', content: input.message },
        ];

        const baseOptions = {
            model: env.OPENROUTER_MODEL,
            tools: [READ_ONLY_TOOL],
            tool_choice: 'auto' as const,
            max_tokens: env.ASSISTANT_MAX_TOKENS,
            // افزونهٔ OpenRouter — reasoning داخلی به‌صورت زنده استریم می‌شود
            reasoning: { enabled: true },
        };

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
            const stream = await client.chat.completions.create({
                ...baseOptions,
                messages,
                stream: true,
                signal: callbacks.signal,
            } as OpenAI.ChatCompletionCreateParamsStreaming);

            let content = '';
            let reasoning = '';
            const toolCallIndex = new Map<number, ToolCallAcc>();

            for await (const chunk of stream) {
                const delta = chunk.choices?.[0]?.delta;
                if (!delta) continue;
                if (delta.content) {
                    content += delta.content;
                    callbacks.onToken(delta.content);
                }
                const reasoningFrag = (delta as unknown as { reasoning?: string }).reasoning;
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

            // هر متنی که در این دور استریم شده (مثل مقدمهٔ قبل از ابزار) در پاسخ نهایی حفظ می‌شود
            answer += content;

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