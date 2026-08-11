import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Trend, Rate, Counter } from 'k6/metrics';

function buildStages() {
    const csv = __ENV.STAGES_CSV;
    if (csv) {
        return csv.split(',').map((pair) => {
            const [duration, target] = pair.split(':');
            return { duration, target: parseInt(target, 10) };
        });
    }
    const vus = parseInt(__ENV.VUS ?? '1', 10);
    const duration = __ENV.DURATION ?? '5m';
    const ramp = __ENV.RAMP ?? '30s';
    const hold = __ENV.HOLD ?? null;
    if (hold) {
        return [
            { duration: ramp, target: vus },
            { duration: hold, target: vus },
            { duration: '30s', target: 0 },
        ];
    }
    return [
        { duration: ramp, target: vus },
        { duration: duration, target: vus },
    ];
}

export const options = {
    scenarios: {
        load: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: buildStages(),
            gracefulStop: '30s',
        },
    },
    thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_duration: ['p(95)<500'],
    },
    discardResponseBodies: true,
    summaryTrendStats: ['min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
};

const BASE = __ENV.BASE_URL ?? 'http://localhost:3000';
const PASSWORD = __ENV.PASSWORD ?? 'Loadtest@1405';
const TOKEN_COUNT = parseInt(__ENV.TOKENS ?? '50', 10);

const socketConnections = new Counter('socket_connections');
const socketFailures = new Counter('socket_failures');
const txLatency = new Trend('tx_checkin_duration', true);
const txRate = new Rate('tx_checkin_ok');
const refreshCalls = new Counter('refresh_calls');
const refreshFailures = new Counter('refresh_failures');

const SEARCH_QUERIES = ['کالا', 'محصول', 'لوازم', 'قطعه', 'ابزار', 'P-', 'مواد', 'بهداشتی'];
const SERIALS = Array.from({ length: 30 }, (_, i) => `MA-1405-${String(rand(1, 100000)).padStart(6, '0')}`);

function rand(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
function pick(arr) {
    return arr[rand(0, arr.length - 1)];
}

let session = null;

export function setup() {
    const tokens = [];
    for (let i = 0; i < TOKEN_COUNT; i++) {
        const phone = i < 2
            ? `0912000000${i}`
            : i < 47
                ? `091200000${10 + (i - 2)}`
                : `091200000${60 + (i - 47)}`;
        const res = http.post(`${BASE}/api/auth/login`, JSON.stringify({ phone, password: PASSWORD }), {
            headers: { 'Content-Type': 'application/json' },
            responseType: 'text',
        });
        if (res.status === 200) {
            const body = res.json();
            tokens.push({ token: body.token, refreshToken: body.refreshToken, role: body.user.role, warehouseId: body.user.warehouseId, productId: null });
        }
    }
    if (tokens.length === 0) throw new Error('setup: no login tokens obtained');
    const keeper = tokens.find((t) => t.role === 'WAREHOUSE_KEEPER');
    if (keeper) {
        const r = http.get(`${BASE}/api/warehouse-keeper/products`, {
            headers: { Authorization: `Bearer ${keeper.token}` },
            responseType: 'text',
        });
        if (r.status === 200) {
            const arr = JSON.parse(r.body);
            if (arr && arr.length) {
                const pid = arr[0].id;
                for (const t of tokens) t.productId = pid;
            }
        }
    }
    console.log(`setup: ${tokens.length} tokens`);
    return { tokens };
}

export default function (data) {
    if (!session) {
        const idx = __VU % data.tokens.length;
        session = { idx, loggedAt: Date.now(), ...data.tokens[idx] };
    }
    const headers = { Authorization: `Bearer ${session.token}`, 'Content-Type': 'application/json' };

    if (session.role === 'MANAGER') {
        managerFlow(headers);
    } else if (session.role === 'WAREHOUSE_KEEPER') {
        keeperFlow(headers);
    } else {
        driverFlow(headers);
    }

    if (__ITER % 5 === 0) socketFlow();

    if (__ITER % 20 === 0 && Date.now() - session.loggedAt > 9 * 60 * 1000) maybeRefresh();
}

function managerFlow(headers) {
    group('manager', function () {
        check(http.get(`${BASE}/api/manager/dashboard`, { headers }), { 'dashboard 200': (r) => r.status === 200 });
        sleep(rand(1, 3));

        check(http.get(`${BASE}/api/manager/products?page=1&pageSize=100`, { headers }), { 'products 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        const q = pick(SEARCH_QUERIES);
        check(http.get(`${BASE}/api/manager/search-products?q=${encodeURIComponent(q)}`, { headers }), { 'search-products 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/manager/search/serial?serial=${pick(SERIALS)}`, { headers }), { 'search-serial 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/manager/orders?page=1&pageSize=20`, { headers }), { 'orders 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/manager/inventory-summary`, { headers }), { 'inventory-summary 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/notifications?limit=20`, { headers }), { 'notifications 200': (r) => r.status === 200 });
        sleep(rand(1, 3));
    });
}

function keeperFlow(headers) {
    group('keeper', function () {
        check(http.get(`${BASE}/api/warehouse-keeper/my-warehouse`, { headers }), { 'my-warehouse 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/warehouse-keeper/orders?limit=50`, { headers }), { 'keeper-orders 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/warehouse-keeper/inventory-summary`, { headers }), { 'keeper-inventory 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/warehouse-keeper/checkin/recent`, { headers }), { 'checkin-recent 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        check(http.get(`${BASE}/api/warehouse-keeper/products`, { headers }), { 'keeper-products 200': (r) => r.status === 200 });
        sleep(rand(1, 2));

        if (__ITER % 3 === 0 && session.productId) {
            const r = http.post(`${BASE}/api/warehouse-keeper/checkin`, JSON.stringify({
                items: [{
                    productId: session.productId,
                    entryType: 'CARTON',
                    serialNumber: `MA-1405-${String(rand(1, 100000)).padStart(6, '0')}`,
                    cartonCount: 1,
                    individualCount: 0,
                }],
            }), { headers });
            txRate.add(r.status === 201 || r.status === 200);
            txLatency.add(r.timings.duration);
            sleep(rand(1, 2));
        }

        check(http.get(`${BASE}/api/warehouse-keeper/cartons/shipped`, { headers }), { 'shipped 200': (r) => r.status === 200 });
        sleep(rand(1, 3));
    });
}

function driverFlow(headers) {
    group('driver', function () {
        check(http.get(`${BASE}/api/driver/orders`, { headers }), { 'driver-orders 200': (r) => r.status === 200 });
        sleep(rand(1, 3));
    });
}

function socketFlow() {
    try {
        const auth = encodeURIComponent(JSON.stringify({ token: session.token }));
        const url = `${BASE}/socket.io/?EIO=4&transport=polling&auth=${auth}`;
        const hs = http.get(url, { timeout: '10s', responseType: 'text' });
        if (hs.status !== 200 || !hs.body.startsWith('0{')) { socketFailures.add(1); return; }
        const sid = hs.body.match(/"sid":"([^"]+)"/)[1];
        const postUrl = `${BASE}/socket.io/?EIO=4&transport=polling&sid=${sid}`;
        const open = http.post(postUrl, '40', { timeout: '10s', responseType: 'text' });
        if (open.status !== 200) { socketFailures.add(1); return; }
        const poll = http.get(postUrl, { timeout: '10s', responseType: 'text' });
        if (poll.status === 200) {
            socketConnections.add(1);
            http.post(postUrl, '41', { timeout: '10s' });
        } else {
            socketFailures.add(1);
        }
    } catch (e) {
        socketFailures.add(1);
    }
}

function maybeRefresh() {
    const res = http.post(`${BASE}/api/auth/refresh`, JSON.stringify({ refreshToken: session.refreshToken }), {
        headers: { 'Content-Type': 'application/json' },
    });
    refreshCalls.add(1);
    if (res.status === 200) {
        const body = res.json();
        session.token = body.token;
        session.refreshToken = body.refreshToken;
        session.loggedAt = Date.now();
    } else {
        refreshFailures.add(1);
    }
}
