import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { assistantService } from './assistant.service';
import { AppError } from '../../common/exceptions/AppError';

const mocks = vi.hoisted(() => {
    const tx = {
        $executeRawUnsafe: vi.fn().mockResolvedValue(undefined),
        $queryRawUnsafe: vi.fn().mockResolvedValue([{ id: '1', name: 'کالای A', hmac: 'secret' }]),
    };
    return {
        tx,
        transaction: vi.fn((fn: (t: unknown) => unknown) => fn(tx)),
        create: vi.fn(),
    };
});

vi.mock('openai', () => ({
    default: class {
        chat = { completions: { create: mocks.create } };
    },
}));

vi.mock('../../utils/prisma', () => ({
    prisma: {
        $transaction: mocks.transaction,
        assistantConfig: {
            findUnique: vi.fn().mockResolvedValue(null),
            upsert: vi.fn(),
            deleteMany: vi.fn(),
        },
    },
}));

function toolCallMessage(id: string, sql: string) {
    return {
        role: 'assistant',
        content: '',
        tool_calls: [
            {
                id,
                type: 'function',
                function: { name: 'run_readonly_query', arguments: JSON.stringify({ sql }) },
            },
        ],
    };
}

async function* streamGen(chunks: string[]) {
    for (const c of chunks) {
        yield { choices: [{ delta: { content: c } }] };
    }
}

beforeEach(() => {
    vi.clearAllMocks();
    vi.stubEnv('ZAI_API_KEY', 'test-key');
});

afterEach(() => {
    vi.unstubAllEnvs();
});

describe('assistantService.chat', () => {
    it('پاسخ کامل با یک دور ابزار: SQL اجرا و نتیجه به مدل برمی‌گردد', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: toolCallMessage('call_1', 'SELECT id, name FROM "Product" LIMIT 5') }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش نهایی' } }],
            });

        const { answer } = await assistantService.chat({
            message: 'چند محصول داریم؟',
            history: [],
        });

        expect(answer).toBe('گزارش نهایی');
        expect(mocks.create).toHaveBeenCalledTimes(2);
        expect(mocks.tx.$executeRawUnsafe).toHaveBeenCalledWith('SET TRANSACTION READ ONLY');
        expect(mocks.tx.$executeRawUnsafe).toHaveBeenCalledWith('SET LOCAL statement_timeout = 15000');
        expect(mocks.tx.$queryRawUnsafe).toHaveBeenCalledWith(
            expect.stringContaining('SELECT * FROM (SELECT id, name FROM "Product" LIMIT 5)'),
        );
        expect(mocks.tx.$queryRawUnsafe).toHaveBeenCalledWith(expect.stringContaining('LIMIT 200'));
    });

    it('دور اول ابزار را اجباری می‌کند تا مدل نتواند از حفظ جواب بدهد', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: toolCallMessage('call_1', 'SELECT count(*) FROM "Product"') }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش نهایی' } }],
            });

        await assistantService.chat({ message: 'چند محصول داریم؟', history: [] });

        const first = mocks.create.mock.calls[0][0];
        expect(first.tool_choice).toEqual({
            type: 'function',
            function: { name: 'run_readonly_query' },
        });
        const second = mocks.create.mock.calls[1][0];
        expect(second.tool_choice).toBe('auto');
    });

    it('حتی سؤال احوالپرسی هم دور اول با ابزار می‌رود و کوئری واقعاً اجرا می‌شود', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: toolCallMessage('call_1', 'SELECT 1 AS ok') }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'سلام! چطور می‌توانم کمکت کنم؟' } }],
            });

        const { answer } = await assistantService.chat({ message: 'سلام', history: [] });

        expect(answer).toBe('سلام! چطور می‌توانم کمکت کنم؟');
        expect(mocks.tx.$queryRawUnsafe).toHaveBeenCalledWith(
            expect.stringContaining('SELECT 1 AS ok'),
        );
    });

    it('ستون حساس از نتیجه حذف می‌شود', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: toolCallMessage('call_1', 'SELECT * FROM "Carton" LIMIT 2') }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش' } }],
            });

        await assistantService.chat({ message: 'کارتن‌ها؟', history: [] });

        const toolMsg = mocks.create.mock.calls[0][0].messages.at(-1);
        expect(toolMsg.role).toBe('tool');
        expect(toolMsg.content).not.toContain('secret');
        expect(toolMsg.content).toContain('کالای A');
    });

    it('SQL مخرب رد می‌شود و خطای گارد به مدل برمی‌گردد (بدون اجرا)', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: toolCallMessage('call_1', 'DELETE FROM "Product"') }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'اجازه ندارم' } }],
            });

        const { answer } = await assistantService.chat({ message: 'حذف کن', history: [] });

        expect(answer).toBe('اجازه ندارم');
        expect(mocks.tx.$queryRawUnsafe).not.toHaveBeenCalled();
        const toolMsg = mocks.create.mock.calls[0][0].messages.at(-1);
        expect(toolMsg.content).toContain('SELECT');
    });

    it('خطای اجرای کوئری (مثلاً جدول ناموجود) به مدل برمی‌گردد', async () => {
        mocks.tx.$queryRawUnsafe.mockRejectedValueOnce(new Error('relation "Nope" does not exist'));
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: toolCallMessage('call_1', 'SELECT * FROM "Nope"') }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'جدول وجود ندارد' } }],
            });

        const { answer } = await assistantService.chat({ message: 'x', history: [] });

        expect(answer).toBe('جدول وجود ندارد');
        const toolMsg = mocks.create.mock.calls[0][0].messages.at(-1);
        expect(toolMsg.content).toContain('خطای اجرای کوئری');
    });

    it('استریم: توکن‌ها از طریق onToken ارسال می‌شوند', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'پاسخ استریمی' } }],
            })
            .mockResolvedValueOnce(streamGen(['سلام', ' دنیا', '!']));

        const tokens: string[] = [];
        const { answer } = await assistantService.chat(
            { message: 'سلام', history: [] },
            (t) => tokens.push(t),
        );

        expect(answer).toBe('پاسخ استریمی');
        expect(tokens).toEqual(['سلام', ' دنیا', '!']);
        expect(mocks.create).toHaveBeenCalledTimes(2);
        expect(mocks.create.mock.calls[1][0].stream).toBe(true);
    });

    it('نتیجهٔ حاوی BigInt بدون خطا سریال‌سازی می‌شود', async () => {
        mocks.tx.$queryRawUnsafe.mockResolvedValueOnce([
            { count: 12n, name: 'کالای A' },
            { count: 9007199254740993n, name: 'بزرگ' },
        ]);
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: toolCallMessage('call_1', 'SELECT count(*) FROM "Product"') }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش' } }],
            });

        const { answer } = await assistantService.chat({ message: 'چند محصول؟', history: [] });

        expect(answer).toBe('گزارش');
        const toolMsg = mocks.create.mock.calls[0][0].messages.at(-1);
        expect(toolMsg.content).toContain('"count":12');
        // خارج از محدودهٔ ایمن → رشتهٔ بدون از دست رفتن دقت
        expect(toolMsg.content).toContain('"count":"9007199254740993"');
    });

    it('کوئری تکراری دوباره اجرا نمی‌شود (جلوگیری از حلقه)', async () => {
        mocks.tx.$queryRawUnsafe.mockResolvedValue([{ n: 1n }]);
        mocks.create
            .mockResolvedValueOnce({
                choices: [
                    {
                        message: toolCallMessage('call_1', 'SELECT count(*) AS n FROM "Carton"'),
                    },
                ],
            })
            .mockResolvedValueOnce({
                choices: [
                    {
                        message: toolCallMessage('call_2', 'SELECT count(*) AS n FROM "Carton"'),
                    },
                ],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش' } }],
            });

        const { answer } = await assistantService.chat({ message: 'چند کارتن؟', history: [] });

        expect(answer).toBe('گزارش');
        // کوئری فقط یک بار اجرا شده
        expect(mocks.tx.$queryRawUnsafe).toHaveBeenCalledTimes(1);
        // پیام دوم همان کوئری، پاسخ «تکرار نکن» گرفته
        const msgs = mocks.create.mock.calls[0][0].messages;
        const toolMsgs = msgs.filter((m: { role: string }) => m.role === 'tool');
        expect(toolMsgs).toHaveLength(2);
        expect(toolMsgs[1].content).toContain('قبلاً اجرا شده');
    });

    it('پاسخ خالی (content null) → یک بار با پیام «پاسخ نهایی را بنویس» دوباره خواسته می‌شود', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: null }, finish_reason: 'length' }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش نهایی' } }],
            });

        const { answer } = await assistantService.chat({ message: 'موجودی؟', history: [] });

        expect(answer).toBe('گزارش نهایی');
        expect(mocks.create).toHaveBeenCalledTimes(2);
        // دور دوم با پیام راهنمای «فقط پاسخ نهایی» رفته
        const secondMsgs = mocks.create.mock.calls[1][0].messages;
        expect(secondMsgs.at(-1).role).toBe('user');
        expect(secondMsgs.at(-1).content).toContain('خالی بود');
    });

    it('پاسخ خالی دوبار → خطای دوستانه «پاسخ مدل ناقص بود»', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: null }, finish_reason: 'length' }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: null }, finish_reason: 'length' }],
            });

        await expect(
            assistantService.chat({ message: 'موجودی؟', history: [] }),
        ).rejects.toThrow('پاسخ مدل ناقص بود');
        expect(mocks.create).toHaveBeenCalledTimes(2);
    });

    it('خطای استریم → همان پاسخ کامل fallback ارسال می‌شود', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش کامل' } }],
            })
            .mockRejectedValueOnce(new Error('stream failed'));

        const tokens: string[] = [];
        const { answer } = await assistantService.chat(
            { message: 'سلام', history: [] },
            (t) => tokens.push(t),
        );

        expect(answer).toBe('گزارش کامل');
        expect(tokens).toEqual(['گزارش کامل']);
    });

    it('درخواست استریم بدون ابزار است (مدل نمی‌تواند دوباره کوئری بخواهد)', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش' } }],
            })
            .mockResolvedValueOnce(streamGen(['گ', 'زارش']));

        await assistantService.chat({ message: 'سلام', history: [] }, () => {});

        const streamOptions = mocks.create.mock.calls[1][0];
        expect(streamOptions.stream).toBe(true);
        expect(streamOptions.tools).toBeUndefined();
        expect(streamOptions.tool_choice).toBeUndefined();
    });

    it('بدون کلید هوش مصنوعی خطای روشن می‌دهد', async () => {
        vi.stubEnv('ZAI_API_KEY', '');
        await expect(
            assistantService.chat({ message: 'سلام', history: [] }),
        ).rejects.toThrow(new AppError('کلید هوش مصنوعی تنظیم نشده است؛ از تنظیمات دستیار وارد کنید', 500));
        expect(mocks.create).not.toHaveBeenCalled();
    });

    it('پاسخ خالی و بدون پیام راهنما → تلاش مجدد با «فقط پاسخ نهایی را بنویس» انجام می‌شود', async () => {
        mocks.create
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: '' } }],
            })
            .mockResolvedValueOnce({
                choices: [{ message: { role: 'assistant', content: 'گزارش' } }],
            });
        const { answer } = await assistantService.chat({ message: 'سلام', history: [] });
        expect(answer).toBe('گزارش');
        expect(mocks.create).toHaveBeenCalledTimes(2);
    });
});

describe('assistantService.chatStream', () => {
    it('استریم کامل: reasoning و سپس پاسخ، از همان درخواست اول (بدون درخواست دوم)', async () => {
        async function* reasoningThenAnswer() {
            yield { choices: [{ delta: { reasoning_content: 'بذار حساب کنم' } }] };
            yield { choices: [{ delta: { content: 'گزارش ' } }] };
            yield { choices: [{ delta: { content: 'کامل' } }] };
        }
        mocks.create.mockResolvedValueOnce(reasoningThenAnswer());

        const tokens: string[] = [];
        const statuses: string[] = [];
        const { answer } = await assistantService.chatStream(
            { message: 'سلام', history: [] },
            { onToken: (t) => tokens.push(t), onStatus: (s) => statuses.push(s) },
        );

        expect(answer).toBe('گزارش کامل');
        expect(tokens).toEqual(['گزارش ', 'کامل']);
        expect(statuses.length).toBeGreaterThanOrEqual(1);
        expect(mocks.create).toHaveBeenCalledTimes(1);
        expect(mocks.create.mock.calls[0][0].stream).toBe(true);
    });

    it('استریم با ابزار: فراخوانی کوئری وسط استریم اجرا و ادامهٔ استریم پاسخ می‌دهد', async () => {
        async function* toolRound() {
            yield {
                choices: [
                    {
                        delta: {
                            tool_calls: [
                                {
                                    index: 0,
                                    id: 'call_s1',
                                    type: 'function',
                                    function: {
                                        name: 'run_readonly_query',
                                        arguments: JSON.stringify({
                                            sql: 'SELECT id, name FROM "Product" LIMIT 5',
                                        }),
                                    },
                                },
                            ],
                        },
                    },
                ],
            };
        }
        async function* answerRound() {
            yield { choices: [{ delta: { content: 'پاسخ استریمی' } }] };
        }
        mocks.create
            .mockResolvedValueOnce(toolRound())
            .mockResolvedValueOnce(answerRound());

        const tokens: string[] = [];
        const { answer } = await assistantService.chatStream(
            { message: 'چند محصول؟', history: [] },
            { onToken: (t) => tokens.push(t) },
        );

        expect(answer).toBe('پاسخ استریمی');
        expect(tokens).toEqual(['پاسخ استریمی']);
        expect(mocks.create).toHaveBeenCalledTimes(2);
        expect(mocks.tx.$queryRawUnsafe).toHaveBeenCalledWith(
            expect.stringContaining('SELECT * FROM (SELECT id, name FROM "Product" LIMIT 5)'),
        );
        // استریم در هر دو دور active است
        expect(mocks.create.mock.calls[0][0].stream).toBe(true);
        expect(mocks.create.mock.calls[1][0].stream).toBe(true);
    });

    it('استریم: دور اول ابزار را اجباری می‌کند، دور دوم auto', async () => {
        async function* toolRound() {
            yield {
                choices: [
                    {
                        delta: {
                            tool_calls: [
                                {
                                    index: 0,
                                    id: 'call_s1',
                                    type: 'function',
                                    function: {
                                        name: 'run_readonly_query',
                                        arguments: JSON.stringify({
                                            sql: 'SELECT count(*) FROM "Product"',
                                        }),
                                    },
                                },
                            ],
                        },
                    },
                ],
            };
        }
        async function* answerRound() {
            yield { choices: [{ delta: { content: 'گزارش' } }] };
        }
        mocks.create
            .mockResolvedValueOnce(toolRound())
            .mockResolvedValueOnce(answerRound());

        await assistantService.chatStream(
            { message: 'چند محصول؟', history: [] },
            { onToken: () => {} },
        );

        expect(mocks.create.mock.calls[0][0].tool_choice).toEqual({
            type: 'function',
            function: { name: 'run_readonly_query' },
        });
        expect(mocks.create.mock.calls[1][0].tool_choice).toBe('auto');
    });

    it('بدون کلید هوش مصنوعی خطای روشن می‌دهد', async () => {
        vi.stubEnv('ZAI_API_KEY', '');
        await expect(
            assistantService.chatStream({ message: 'سلام', history: [] }, { onToken: () => {} }),
        ).rejects.toThrow(new AppError('کلید هوش مصنوعی تنظیم نشده است؛ از تنظیمات دستیار وارد کنید', 500));
        expect(mocks.create).not.toHaveBeenCalled();
    });
});

describe('assistantService error mapping', () => {
    it('خطای ۴۲۹ سرویس‌دهنده به پیام فارسی نگاشت می‌شود — پیام خام انگلیسی نشت نمی‌کند', async () => {
        mocks.create.mockRejectedValueOnce(
            Object.assign(
                new Error('The service may be temporarily overloaded, please try again later'),
                { status: 429, name: 'RateLimitError' },
            ),
        );
        await expect(
            assistantService.chat({ message: 'سلام', history: [] }),
        ).rejects.toMatchObject({
            message: 'سرویس هوش مصنوعی شلوغ است؛ چند لحظه بعد دوباره تلاش کنید',
            statusCode: 429,
        });
    });

    it('خطای ۴۰۱ سرویس‌دهنده → پیام کلید نامعتبر (۵۰۲)', async () => {
        mocks.create.mockRejectedValueOnce(
            Object.assign(new Error('Incorrect API key provided'), { status: 401, name: 'AuthenticationError' }),
        );
        await expect(
            assistantService.chat({ message: 'سلام', history: [] }),
        ).rejects.toMatchObject({
            message: 'کلید هوش مصنوعی نامعتبر است؛ از تنظیمات دستیار بررسی کنید',
            statusCode: 502,
        });
    });

    it('خطای وسط استریم هم به پیام فارسی نگاشت می‌شود', async () => {
        async function* brokenStream() {
            yield { choices: [{ delta: { content: 'پاسخ ناق' } }] };
            throw Object.assign(new Error('upstream disconnected'), {
                status: 502,
                name: 'APIError',
            });
        }
        mocks.create.mockResolvedValueOnce(brokenStream());
        await expect(
            assistantService.chatStream(
                { message: 'سلام', history: [] },
                { onToken: () => {} },
            ),
        ).rejects.toMatchObject({
            message: 'سرور هوش مصنوعی موقتاً در دسترس نیست؛ کمی بعد دوباره تلاش کنید',
            statusCode: 502,
        });
    });

    it('خطای شبکه بدون status → پیام اتصال (۵۰۲)', async () => {
        mocks.create.mockRejectedValueOnce(new Error('getaddrinfo ENOTFOUND api.z.ai'));
        await expect(
            assistantService.chat({ message: 'سلام', history: [] }),
        ).rejects.toMatchObject({
            message: 'اتصال به سرویس هوش مصنوعی برقرار نشد؛ اتصال سرور را بررسی کنید',
            statusCode: 502,
        });
    });
});