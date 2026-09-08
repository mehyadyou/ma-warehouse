/**
 * لانچر اجرای اسکریپت‌های TS روی staging — اول .env.staging را (با override) لود
 * می‌کند، بعد ts-node را رجیستر و فایل هدف را اجرا می‌کند.
 * استفاده: node scripts/loadtest/run-staging.cjs scripts/loadtest/seed-pressure.ts
 */
const fs = require('fs');
const path = require('path');

const envFile = path.join(__dirname, '..', '..', '.env.staging');
for (const line of fs.readFileSync(envFile, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$/);
    if (m) process.env[m[1]] = m[2].replace(/\r$/, '');
}
// اتصال مستقیم به staging (نه PgBouncer — userlist آن فقط رمز live را دارد).
// نکتهٔ آموخته‌شدهٔ سخت: `import 'dotenv/config'` در ماژول‌های src، متغیرهای
// «حذف‌شده» را از .env واقعی برمی‌گرداند؛ پس به‌جای delete، صریح override می‌کنیم
// (dotenv هرگز روی مقدار موجود بازنویسی نمی‌کند).
const direct = process.env.DATABASE_URL;
if (!direct || !direct.includes('staging')) {
    console.error('REFUSING: .env.staging DATABASE_URL is not a staging DB');
    process.exit(1);
}
process.env.DATABASE_POOL_URL = direct;

const target = process.argv[2];
if (!target) {
    console.error('Usage: node run-staging.cjs <script.ts>');
    process.exit(1);
}

require('ts-node').register({ transpileOnly: true, compilerOptions: { module: 'commonjs', moduleResolution: 'node' } });
require(path.resolve(target));
