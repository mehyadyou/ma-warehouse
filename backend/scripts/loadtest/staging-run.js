const fs = require('fs');
const path = require('path');

const envFile = path.join(__dirname, '..', '..', '.env.staging');
const env = {};
for (const line of fs.readFileSync(envFile, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*"?([^"]*)"?\s*$/);
    if (m) env[m[1]] = m[2].replace(/\r$/, '');
}
Object.assign(process.env, env);

require(path.join(__dirname, '..', '..', 'dist', 'server.js'));
