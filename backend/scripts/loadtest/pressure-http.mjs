/**
 * تست فشار HTTP روی سرور staging (پورت جدا) — mix واقعی عملیات با همزمانی بالا.
 * استفاده: node scripts/loadtest/pressure-http.mjs [base] [workers] [totalOps]
 * پیش‌نیاز: سید فشاری + سرور staging بالا (scripts/loadtest/serve-staging.cjs).
 */
const BASE = process.argv[2] ?? 'http://127.0.0.1:3100';
const WORKERS = Number(process.argv[3] ?? 15);
const TOTAL_OPS = Number(process.argv[4] ?? 300);

const stats = new Map(); // name -> {times: [], ok2xx, c4xx, c429, c5xx, timeout, other}
function rec(name, ms, status) {
    let s = stats.get(name);
    if (!s) { s = { times: [], ok2xx: 0, c4xx: 0, c429: 0, c5xx: 0, timeout: 0, other: 0 }; stats.set(name, s); }
    if (ms !== null) s.times.push(ms);
    if (status === 'timeout') s.timeout++;
    else if (status >= 200 && status < 300) s.ok2xx++;
    else if (status === 429) s.c429++;
    else if (status >= 400 && status < 500) s.c4xx++;
    else if (status >= 500) s.c5xx++;
    else s.other++;
}

async function call(name, method, path, token, body) {
    const ctrl = new AbortController();
    const to = setTimeout(() => ctrl.abort(), 30000);
    const t0 = performance.now();
    try {
        const res = await fetch(BASE + path, {
            method,
            headers: {
                'Content-Type': 'application/json',
                ...(token ? { Authorization: `Bearer ${token}` } : {}),
            },
            body: body ? JSON.stringify(body) : undefined,
            signal: ctrl.signal,
        });
        await res.text().catch(() => '');
        rec(name, performance.now() - t0, res.status);
        return res.status;
    } catch {
        rec(name, performance.now() - t0, 'timeout');
        return 0;
    } finally {
        clearTimeout(to);
    }
}

function pct(arr, p) {
    if (!arr.length) return 0;
    const a = [...arr].sort((x, y) => x - y);
    return a[Math.min(a.length - 1, Math.floor((p / 100) * a.length))];
}

async function login(phone, password) {
    const res = await fetch(BASE + '/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone, password }),
    });
    const data = await res.json();
    if (!data.token) throw new Error(`login failed for ${phone}: ${JSON.stringify(data).slice(0, 150)}`);
    return { token: data.token, user: data.user };
}

let serialPool = [];
async function refillSerials(keeperToken) {
    try {
        const res = await fetch(BASE + '/api/warehouse-keeper/checkin/recent', {
            headers: { Authorization: `Bearer ${keeperToken}` },
        });
        const data = await res.json();
        const list = data.cartons ?? data ?? [];
        serialPool = list.map((c) => c.serialNumber).filter(Boolean);
    } catch { /* خالی می‌ماند — اسکن‌ها 404 می‌گیرند ولی بار حساب می‌شود */ }
}

const rnd = (n) => Math.floor(Math.random() * n);
const key = () => `${Date.now().toString(36)}-${rnd(1e9).toString(36)}-${rnd(1e9).toString(36)}`;

async function worker(id, ctx, perWorker) {
    for (let i = 0; i < perWorker; i++) {
        const r = Math.random();
        try {
            if (r < 0.22) {
                await call('GET m:dashboard', 'GET', '/api/manager/dashboard', ctx.mgr);
            } else if (r < 0.40) {
                await call('GET m:products-p50', 'GET', '/api/manager/products?page=1&pageSize=50', ctx.mgr);
            } else if (r < 0.55) {
                await call('GET w:inv-summary', 'GET', '/api/warehouse-keeper/inventory-summary', ctx.keeper);
            } else if (r < 0.68) {
                await call('GET w:products-p50', 'GET', '/api/warehouse-keeper/products?page=1&pageSize=50', ctx.keeper);
            } else if (r < 0.80) {
                await call('POST w:checkin', 'POST', '/api/warehouse-keeper/checkin', ctx.keeper, {
                    items: [{ productId: ctx.productId, modelId: ctx.modelId, cartonCount: 1, individualCount: 0 }],
                    clientKey: key(),
                });
            } else if (r < 0.92) {
                if (!serialPool.length && i % 7 === 0) await refillSerials(ctx.keeper);
                const serial = serialPool.length ? serialPool[rnd(serialPool.length)] : 'MA-1405-000001';
                await call('POST w:scanout', 'POST', '/api/warehouse-keeper/scan-out', ctx.keeper, {
                    serialNumber: serial, clientKey: key(),
                });
            } else if (r < 0.97) {
                const s = serialPool.length ? serialPool[rnd(serialPool.length)] : 'MA-1405-000001';
                await call('GET w:search-serial', 'GET', `/api/warehouse-keeper/search/serial?serial=${encodeURIComponent(s)}`, ctx.keeper);
            } else {
                await call('GET healthz', 'GET', '/healthz', null);
            }
        } catch (e) {
            rec('worker-crash', null, 'other');
        }
    }
}

async function main() {
    console.log(`[pressure] ${BASE} workers=${WORKERS} total=${TOTAL_OPS}`);
    const t0 = Date.now();
    const mgr = await login('09120000000', 'Manager123');
    const keeper = await login('09120001001', '123456');
    console.log('[pressure] login ok, keeper warehouse =', keeper.user.warehouseId ?? '?');

    // یک محصول+مدل معتبر برای checkin
    const pr = await fetch(BASE + '/api/manager/products?page=1&pageSize=1', {
        headers: { Authorization: `Bearer ${mgr.token}` },
    }).then((r) => r.json());
    const productId = pr.products[0].id;
    const modelId = (pr.products[0].models ?? [])[0]?.id ?? null;
    await refillSerials(keeper.token);
    console.log('[pressure] serial pool =', serialPool.length);

    const ctx = { mgr: mgr.token, keeper: keeper.token, productId, modelId };
    const perWorker = Math.ceil(TOTAL_OPS / WORKERS);
    await Promise.all(Array.from({ length: WORKERS }, (_, i) => worker(i, ctx, perWorker)));
    const secs = (Date.now() - t0) / 1000;

    console.log(`\n[pressure] done in ${secs.toFixed(1)}s`);
    console.log('endpoint                |  n  | 2xx | 4xx | 429 | 5xx | t/o |  avg  |  p50  |  p95  |  max');
    console.log('------------------------|-----|-----|-----|-----|-----|-----|-------|-------|-------|-------');
    for (const [name, s] of stats) {
        const n = s.times.length;
        const avg = n ? s.times.reduce((a, b) => a + b, 0) / n : 0;
        console.log(
            `${name.padEnd(23)} | ${String(n).padStart(3)} | ${String(s.ok2xx).padStart(3)} | ${String(s.c4xx).padStart(3)} | ${String(s.c429).padStart(3)} | ${String(s.c5xx).padStart(3)} | ${String(s.timeout).padStart(3)} | ${String(Math.round(avg)).padStart(5)} | ${String(Math.round(pct(s.times, 50))).padStart(5)} | ${String(Math.round(pct(s.times, 95))).padStart(5)} | ${String(Math.round(Math.max(0, ...s.times))).padStart(5)}`,
        );
    }
}
main().catch((e) => { console.error('[pressure] FAIL:', e); process.exit(1); });
