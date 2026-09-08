import 'dotenv/config';

// متغیرهای محیطی الزامی — بدون fallback: اگر نباشند، برنامه با خطای روشن از بوت خارج می‌شود
const REQUIRED_KEYS = ['JWT_SECRET', 'QR_SECRET'] as const;

const missing = REQUIRED_KEYS.filter((key) => !process.env[key]);
if (missing.length > 0) {
    throw new Error(
        `متغیرهای محیطی الزامی در .env تعریف نشده‌اند: ${missing.join(', ')}\n` +
        'برای ساخت کلید: node -e "console.log(require(\'crypto\').randomBytes(32).toString(\'hex\'))"',
    );
}

// ── اعتبارسنجی قدرت سکرت (حداقل ۳۲ کاراکتر؛ توصیه ۶۴-hex) ──
// از بوتِ بی‌سروصدا با سکرت ضعیف جلوگیری می‌کند (یافته ممیزی: فقط presence چک می‌شد)
for (const key of REQUIRED_KEYS) {
    const value = process.env[key] || '';
    if (value.length < 32 || /CHANGE_ME/i.test(value)) {
        throw new Error(
            `متغیر ${key} ناامن است (کمتر از ۳۲ کاراکتر یا CHANGE_ME). ` +
            'با دستور بالا کلید ۶۴ کاراکتری بسازید و هر ۶ ماه بچرخانید (docs/db-ops.md).',
        );
    }
}

export const env = {
    JWT_SECRET: process.env.JWT_SECRET as string,
    QR_SECRET:  process.env.QR_SECRET as string,
    REDIS_URL:  process.env.REDIS_URL || 'redis://localhost:6379',
    ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS || process.env.CORS_ORIGINS || '',

    // ── دستیار هوش مصنوعی (اختیاری — بدون کلید، دستیار خطای روشن می‌دهد) ──
    // getter برای خواندن زندهٔ env در تست‌ها (vi.stubEnv)
    get ZAI_API_KEY() { return process.env.ZAI_API_KEY || ''; },
    get ZAI_MODEL() { return process.env.ZAI_MODEL || 'glm-4.7-flash'; },
    get ZAI_BASE_URL() { return process.env.ZAI_BASE_URL || 'https://api.z.ai/api/paas/v4'; },
    get ASSISTANT_MAX_TOKENS() { return Number(process.env.ASSISTANT_MAX_TOKENS) || 8000; },
};
