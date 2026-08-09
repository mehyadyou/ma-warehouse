// لیست مبدأهای مجاز CORS — از متغیر محیطی ALLOWED_ORIGINS (با کاما جدا شده)
// (CORS_ORIGINS برای سازگاری با تنظیمات قدیمی خوانده می‌شود)
export function getAllowedOrigins(): string[] {
    return (process.env.ALLOWED_ORIGINS || process.env.CORS_ORIGINS || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);
}
