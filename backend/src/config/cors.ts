// لیست مبدأهای مجاز CORS — از متغیر محیطی ALLOWED_ORIGINS (با کاما جدا شده)
// (CORS_ORIGINS برای سازگاری با تنظیمات قدیمی خوانده می‌شود)
export function getAllowedOrigins(): string[] {
    return (process.env.ALLOWED_ORIGINS || process.env.CORS_ORIGINS || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);
}

// `*` در پیکربندی به معنای «همهٔ مبدأها مجاز» است (مثل رفتار لیست خالی).
// مقدار literalِ "*" در آرایه، توسط پکیج cors به‌عنوان وایلدکارت شناخته نمی‌شود.
export function isCorsAllowAll(): boolean {
    const origins = getAllowedOrigins();
    // در production هرگز fail-open نباش — نبودِ ALLOWED_ORIGINS یعنی «بسته»، نه «همه مجاز»
    if (process.env.NODE_ENV === 'production') return false;
    return origins.length === 0 || origins.includes('*');
}
