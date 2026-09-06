// پیکربندی PM2 برای محیط production — سرور واقعی (dist/server.js)
// اجرا:  pm2 start ecosystem.production.config.cjs --env production
// نکته: .env را قبل از اجرا پر کنید (طبق .env.example)؛ این فایل مقادیر را از .env می‌خواند.
const path = require('path');
const fs = require('fs');

// خواندن .env بدون وابستگی (مثل dotenv ساده‌شده)
const env = {};
const envFile = path.join(__dirname, '.env');
if (fs.existsSync(envFile)) {
    for (const line of fs.readFileSync(envFile, 'utf8').split('\n')) {
        const m = line.match(/^\s*(?:export\s+)?([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$/);
        if (m) env[m[1]] = m[2].replace(/\r$/, '');
    }
}

module.exports = {
    apps: [
        {
            name: 'ma-warehouse-api',
            script: 'dist/server.js',
            cwd: __dirname,
            instances: 1, // Outbox/رقم‌گذاری روزانه باید تک‌نمونه بماند؛ افقی‌سازی فقط با قفل Redis
            exec_mode: 'fork',
            env: { ...env, NODE_ENV: 'production' },
            max_memory_restart: '1G',
            out_file: path.join(__dirname, 'logs', 'pm2-out.log'),
            error_file: path.join(__dirname, 'logs', 'pm2-err.log'),
            merge_logs: true,
            time: true,
            // راه‌اندازی مجدد خودکار با تأخیر کوتاه
            min_uptime: '10s',
            restart_delay: 2000,
        },
    ],
};
