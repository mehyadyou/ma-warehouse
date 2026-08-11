const path = require('path');
const fs = require('fs');

const envFile = path.join(__dirname, '.env.staging');
const env = {};
for (const line of fs.readFileSync(envFile, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$/);
    if (m) env[m[1]] = m[2].replace(/\r$/, '');
}

module.exports = {
    apps: [
        {
            name: 'ma-warehouse-staging',
            script: 'scripts/loadtest/staging-run.js',
            cwd: __dirname,
            env,
            max_memory_restart: '1G',
            out_file: path.join(__dirname, 'logs', 'pm2-out.log'),
            error_file: path.join(__dirname, 'logs', 'pm2-err.log'),
            merge_logs: true,
            time: true,
        },
    ],
};
