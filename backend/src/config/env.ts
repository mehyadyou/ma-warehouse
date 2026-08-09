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

export const env = {
    JWT_SECRET: process.env.JWT_SECRET as string,
    QR_SECRET:  process.env.QR_SECRET as string,
    REDIS_URL:  process.env.REDIS_URL || 'redis://localhost:6379',
    ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS || process.env.CORS_ORIGINS || '',
};
