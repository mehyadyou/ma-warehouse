import { parse } from 'pgsql-ast-parser';

// ── گارد فقط‌خواندنی SQL ──
// لایهٔ اعتماد: خالص و بدون I/O — کاملاً تست‌شده در sql-guard.test.ts.
// این گارد تنها خط دفاعی نیست؛ اجراکننده (assistant.service) کوئری را داخل
// تراکنش READ ONLY با statement_timeout و سقف ردیف اجرا می‌کند (دفاع در عمق).

const MAX_SQL_LENGTH = 8000;

/** ستون‌های حساسی که هرگز نباید به مدل برسند (نام ستون — حساس به حروف بزرگ نیست) */
const SENSITIVE_COLUMNS = new Set([
    'hmac',
    'qrpayload',
    'password',
    'passwordhash',
    'refreshtoken',
    'accesstoken',
    'jwtsecret',
]);

export type GuardResult =
    | { ok: true; sql: string }
    | { ok: false; error: string };

/**
 * اعتبارسنجی: فقط یک عبارت SELECT (یا WITH…SELECT) مجاز است.
 * هر نوع نوشتن (INSERT/UPDATE/DELETE/DDL/…)، چندعبارتی، SELECT INTO و کوئری نامعتبر رد می‌شود.
 */
export function validateReadOnlySql(raw: string): GuardResult {
    const sql = raw.trim().replace(/;+\s*$/, '');
    if (!sql) return { ok: false, error: 'SQL خالی است' };
    if (sql.length > MAX_SQL_LENGTH) return { ok: false, error: 'SQL بیش از حد طولانی است' };

    let stmts: unknown[];
    try {
        stmts = parse(sql);
    } catch {
        return { ok: false, error: 'SQL نامعتبر است' };
    }

    if (stmts.length !== 1) {
        return { ok: false, error: 'فقط یک عبارت SELECT مجاز است' };
    }

    const stmt = stmts[0] as { type: string; into?: unknown };
    if (stmt.type !== 'select' && stmt.type !== 'with') {
        return { ok: false, error: `فقط SELECT مجاز است (دریافت: ${stmt.type})` };
    }
    if (stmt.type === 'select' && stmt.into) {
        return { ok: false, error: 'SELECT INTO مجاز نیست' };
    }

    return { ok: true, sql };
}

/** حذف ستون‌های حساس + کوتاه‌کردن مقادیر طولانی (برای ورود به context مدل) */
export function maskSensitiveColumns(rows: Record<string, unknown>[]): Record<string, unknown>[] {
    return rows.map((row) => {
        const out: Record<string, unknown> = {};
        for (const [key, value] of Object.entries(row)) {
            if (SENSITIVE_COLUMNS.has(key.toLowerCase())) continue;
            out[key] =
                typeof value === 'string' && value.length > 500
                    ? `${value.slice(0, 500)}…`
                    : value;
        }
        return out;
    });
}