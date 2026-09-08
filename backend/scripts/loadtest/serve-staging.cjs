/**
 * اجرای سرور staging روی پورت جدا (پیش‌فرض 3100) از dist بیلدشده.
 * استفاده: node scripts/loadtest/serve-staging.cjs [port]
 * توقف: Ctrl+C
 */
const fs = require('fs');
const path = require('path');

const envFile = path.join(__dirname, '..', '..', '.env.staging');
for (const line of fs.readFileSync(envFile, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$/);
    if (m) process.env[m[1]] = m[2].replace(/\r$/, '');
}
process.env.PORT = process.argv[2] ?? '3100';
// اتصال مستقیم (نه PgBouncer) — دلیل در run-staging.cjs
process.env.DATABASE_POOL_URL = process.env.DATABASE_URL;

console.log('[serve-staging] port =', process.env.PORT);
require(path.join(__dirname, '..', '..', 'dist', 'server.js'));
