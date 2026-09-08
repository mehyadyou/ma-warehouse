/**
 * سید فشار روی STAGING — دقیقاً حجم درخواستی:
 *   ۱۰٬۰۰۰ محصول (+مدل) · ۵ انبار · ۲ مدیر · ۲۰ انباردار · ۳۰ راننده
 *   ۵۰ سفارش (سرویس واقعی) · ۶۰ مرجوعی (سرویس واقعی) ·
 *   ۳۰ دستور جابه‌جایی/خروج (سرویس واقعی) · ۱۰ خروج اسکنی (سرویس واقعی)
 *
 * گارد ایمنی: اگر DATABASE_URL شامل staging نباشد، هیچ کاری نمی‌کند.
 * اجرا: node scripts/loadtest/run-staging.cjs scripts/loadtest/seed-pressure.ts
 */
import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import { Pool } from 'pg';
import { prisma } from '../../src/utils/prisma';
import { buildQrForSerial } from '../../src/utils/qr';
import { ordersService } from '../../src/manager/orders/orders.service';
import { checkinService } from '../../src/warehouse_keeper/checkin/checkin.service';
import { scanOutService } from '../../src/warehouse_keeper/scanout/scanout.service';
import { transfersService } from '../../src/manager/transfers/transfers.service';

const dbUrl = process.env.DATABASE_URL ?? '';
if (!dbUrl.includes('staging')) {
    throw new Error('REFUSING: DATABASE_URL is not a staging DB — aborting to protect real data');
}

const N_PRODUCTS = 10_000;
const N_WAREHOUSES = 5;
const N_MANAGERS = 2;
const N_KEEPERS = 20;
const N_DRIVERS = 30;
const N_ORDERS = 50;
const N_RETURNS = 60;
const N_TRANSFERS = 30;
const N_EXITS = 10;

const PIN = '123456';
const MANAGER_PW = 'Manager123';

const rand = (n: number) => Math.floor(Math.random() * n);
const pick = <T>(arr: T[]): T => arr[rand(arr.length)];
const randInt = (a: number, b: number) => a + rand(b - a + 1);

const TABLES = [
    'AuditLog', 'OutboxEvent', 'IdempotencyKey', 'Notification', 'RefreshToken', 'Delivery',
    'OrderItem', 'Badge', 'Order', 'ActivityLog', 'Carton', 'ProductModel', 'Transaction',
    'SerialSequence', 'OrderDaySequence', 'Product', 'User', 'Warehouse',
];

async function truncate() {
    // TRUNCATE نیازمند دسترسی بالاتر از ma_app است — با MIGRATOR_URL (رول DDL) انجام می‌شود
    const url = new URL(process.env.MIGRATOR_URL ?? '');
    url.searchParams.delete('sslmode');
    url.searchParams.delete('sslaccept');
    const pool = new Pool({ connectionString: url.toString(), ssl: { rejectUnauthorized: false } });
    try {
        for (const t of TABLES) {
            await pool.query(`TRUNCATE TABLE "${t}" CASCADE;`);
        }
    } finally {
        await pool.end();
    }
}

async function main() {
    const t0 = Date.now();
    const time = (label: string, t: number) => console.log(`[seed] ${label}: ${((Date.now() - t) / 1000).toFixed(1)}s`);

    console.log('[seed] target:', dbUrl.replace(/:[^:@/]+@/, ':***@'));
    // گارد دوم (علاوه بر چک URL): از خودِ اتصال prisma بپرس به کدام DB وصلی —
    // اگر staging نبود، قبل از هر truncate متوقف شو
    const here = await prisma.$queryRawUnsafe<{ db: string }[]>(`SELECT current_database() AS db;`);
    console.log('[seed] connected database =', here[0].db);
    if (!here[0].db.includes('staging')) {
        throw new Error(`REFUSING: connected to "${here[0].db}" — aborting to protect real data`);
    }
    let t = Date.now();
    await truncate();
    time('truncate', t);

    // ── انبارها ──
    t = Date.now();
    await prisma.warehouse.createMany({
        data: Array.from({ length: N_WAREHOUSES }, (_, i) => ({
            name: `انبار فشاری ${i + 1}`,
            address: `تهران — خیابان فشار ${i + 1}`,
        })),
    });
    const warehouses = await prisma.warehouse.findMany({ select: { id: true } });
    const wIds = warehouses.map((w) => w.id);
    time('warehouses x5', t);

    // ── کاربران (هش یک‌بار، reuse) ──
    t = Date.now();
    const pinHash = await bcrypt.hash(PIN, 8);
    const mgrHash = await bcrypt.hash(MANAGER_PW, 8);
    const users: { name: string; phone: string; password: string; role: 'MANAGER' | 'WAREHOUSE_KEEPER' | 'DRIVER'; warehouseId: string | null; isActive: boolean; mustChangePassword: boolean }[] = [];
    for (let i = 0; i < N_MANAGERS; i++) {
        users.push({ name: `مدیر فشاری ${i + 1}`, phone: `0912000000${i}`, password: mgrHash, role: 'MANAGER', warehouseId: null, isActive: true, mustChangePassword: false });
    }
    for (let i = 0; i < N_KEEPERS; i++) {
        users.push({ name: `انباردار فشاری ${i + 1}`, phone: `091200010${String(i + 1).padStart(2, '0')}`, password: pinHash, role: 'WAREHOUSE_KEEPER', warehouseId: wIds[i % N_WAREHOUSES], isActive: true, mustChangePassword: false });
    }
    for (let i = 0; i < N_DRIVERS; i++) {
        users.push({ name: `راننده فشاری ${i + 1}`, phone: `091200020${String(i + 1).padStart(2, '0')}`, password: pinHash, role: 'DRIVER', warehouseId: null, isActive: true, mustChangePassword: false });
    }
    for (let i = 0; i < users.length; i += 50) {
        await prisma.user.createMany({ data: users.slice(i, i + 50) });
    }
    const userRows = await prisma.user.findMany({ select: { id: true, role: true, warehouseId: true } });
    const managers = userRows.filter((u) => u.role === 'MANAGER').map((u) => u.id);
    const keepers = userRows.filter((u) => u.role === 'WAREHOUSE_KEEPER' && u.warehouseId);
    const keeperIds = keepers.map((u) => u.id);
    time('users (2+20+30)', t);

    // ── ۱۰٬۰۰۰ محصول + مدل ──
    t = Date.now();
    const products: { name: string; unit: string }[] = [];
    for (let i = 0; i < N_PRODUCTS; i++) {
        products.push({ name: `کالای فشاری ${i + 1}`, unit: 'عدد' });
    }
    for (let i = 0; i < products.length; i += 2000) {
        await prisma.product.createMany({ data: products.slice(i, i + 2000) });
    }
    const pRows = await prisma.product.findMany({ select: { id: true } });
    const pIds = pRows.map((p) => p.id);
    const models = pIds.map((pid) => ({
        productId: pid, name: 'مدل استاندارد', price: 100000, packageType: 'کارتن', unitsPerBox: 10,
    }));
    for (let i = 0; i < models.length; i += 2000) {
        await prisma.productModel.createMany({ data: models.slice(i, i + 2000) });
    }
    const mRows = await prisma.productModel.findMany({ select: { id: true, productId: true } });
    const modelByProduct = new Map(mRows.map((m) => [m.productId, m.id]));
    time('products+models 10k', t);

    // ── کارتن‌ها (مستقیم — حجم): ۲۰۰ محصول اول ×۶ + بقیه ×۱ ≈ ۱۱٬۰۰۰ ──
    t = Date.now();
    const ORDER_POOL = 200; // محصولاتی که سفارش/انتقال رویشان می‌نشیند
    const cartonPlan: { pi: number; productId: string; count: number }[] = [];
    for (let i = 0; i < ORDER_POOL; i++) cartonPlan.push({ pi: i, productId: pIds[i], count: 6 });
    for (let i = ORDER_POOL; i < N_PRODUCTS; i++) cartonPlan.push({ pi: i, productId: pIds[i], count: 1 });
    const serialOf: string[] = [];
    // serial → {warehouseId, productId, modelId} برای اسکن‌های بعدی
    const cartonIndex: { serial: string; warehouseId: string; productId: string; modelId: string }[] = [];
    let serialN = 0;
    const batch: { id: string; productId: string; modelId: string | null; warehouseId: string; qrPayload: string; hmac: string; serialNumber: string; isIndividual: boolean; entryType: 'NEW'; status: 'IN_STOCK'; createdById: string }[] = [];
    const flush = async () => {
        if (batch.length === 0) return;
        const seen = new Set<string>();
        for (const b of batch) {
            if (seen.has(b.serialNumber)) throw new Error(`dup serial in batch: ${b.serialNumber}`);
            seen.add(b.serialNumber);
        }
        await prisma.carton.createMany({ data: batch.splice(0, batch.length) });
    };
    for (const { pi, productId, count } of cartonPlan) {
        const modelId = modelByProduct.get(productId)!;
        for (let k = 0; k < count; k++) {
            serialN++;
            const serial = `MA-1405-${String(serialN).padStart(6, '0')}`;
            const uuid = crypto.randomUUID();
            const { qrPayload, hmac } = buildQrForSerial({ serial, uuid });
            // ۲۰۰ محصول سفارشی: همهٔ کارتن‌های هر محصول در «یک» انبار تا چک
            // موجودیِ انبارِ سفارش/انتقال همیشه پاس شود؛ بقیه چرخشی
            const wid = pi < ORDER_POOL ? wIds[pi % N_WAREHOUSES] : wIds[serialN % N_WAREHOUSES];
            batch.push({
                id: uuid, productId, modelId, warehouseId: wid, qrPayload, hmac,
                serialNumber: serial, isIndividual: false, entryType: 'NEW',
                status: 'IN_STOCK', createdById: pick(keeperIds),
            });
            cartonIndex.push({ serial, warehouseId: wid, productId, modelId });
            serialOf.push(serial);
            if (batch.length >= 2000) await flush();
        }
    }
    await flush();
    await prisma.serialSequence.upsert({
        where: { year: 1405 }, update: { lastSeq: serialN }, create: { year: 1405, lastSeq: serialN },
    });
    time(`cartons x${serialN} (direct)`, t);

    // ── ۵۰ سفارش (سرویس واقعی → OrderDaySequence + موجودی) ──
    t = Date.now();
    const orderTargets: { orderId: string; warehouseId: string; productId: string; modelId: string; quotaLeft: number }[] = [];
    for (let i = 0; i < N_ORDERS; i++) {
        const pi = i % ORDER_POOL;
        const pid = pIds[pi];
        const wid = cartonIndex.find((c) => c.productId === pid)!.warehouseId;
        const qty = 2;
        const order = await ordersService.createOrder(
            wid, managers[i % managers.length],
            [{ productId: pid, modelId: modelByProduct.get(pid)!, quantity: qty, price: 100000 }],
            'باربری', undefined, 'تهران', undefined, `خیابان فشار ${i}`, '09120000001',
            `فرستنده ${i}`, `گیرنده ${i}`,
        );
        orderTargets.push({ orderId: (order as { id: string }).id, warehouseId: wid, productId: pid, modelId: modelByProduct.get(pid)!, quotaLeft: qty });
    }
    time('orders x50 (service)', t);

    // ── ۶۰ اسکن روی سفارش‌ها + ۶۰ مرجوعی (سرویس واقعی) ──
    t = Date.now();
    const scannedForReturn: { serial: string; warehouseId: string; userId: string }[] = [];
    const byProduct = new Map<string, { serial: string; warehouseId: string }[]>();
    for (const c of cartonIndex) {
        if (!byProduct.has(c.productId)) byProduct.set(c.productId, []);
        byProduct.get(c.productId)!.push({ serial: c.serial, warehouseId: c.warehouseId });
    }
    const usedSerials = new Set<string>();
    let need = N_RETURNS;
    for (const tgt of orderTargets) {
        if (need <= 0) break;
        const cands = (byProduct.get(tgt.productId) ?? []).filter(
            (c) => c.warehouseId === tgt.warehouseId && !usedSerials.has(c.serial),
        );
        const take = Math.min(tgt.quotaLeft, need, cands.length);
        for (let k = 0; k < take; k++) {
            const keeper = keepers.find((x) => x.warehouseId === tgt.warehouseId)!;
            const res = await scanOutService.scanOut(
                { qrPayload: '', serialNumber: cands[k].serial, orderId: tgt.orderId },
                tgt.warehouseId, keeper.id,
            );
            if ((res as { valid: boolean }).valid) {
                usedSerials.add(cands[k].serial);
                scannedForReturn.push({ serial: cands[k].serial, warehouseId: tgt.warehouseId, userId: keeper.id });
                tgt.quotaLeft--;
                need--;
            }
        }
    }
    if (need > 0) throw new Error(`not enough scannable stock for returns, short=${need}`);
    time('scan for returns x60 (service)', t);

    t = Date.now();
    for (let i = 0; i < scannedForReturn.length; i++) {
        const s = scannedForReturn[i];
        await checkinService.submitCheckin(s.warehouseId, s.userId, [{
            productId: cartonIndex.find((c) => c.serial === s.serial)!.productId,
            modelId: cartonIndex.find((c) => c.serial === s.serial)!.modelId,
            entryType: 'RETURNED', serialNumber: s.serial, cartonCount: 0, individualCount: 1,
        }], `pressure-return-${i}`);
    }
    time('returns x60 (service)', t);

    // ── ۳۰ دستور (۲۰ جابه‌جایی + ۱۰ خروج) + ۱۰ خروج اسکنی ──
    t = Date.now();
    const exitTransfers: { id: string; warehouseId: string; productId: string; modelId: string }[] = [];
    for (let i = 0; i < N_TRANSFERS; i++) {
        const pi = (i * 7) % ORDER_POOL;
        const pid = pIds[pi];
        // انبار مبدأ = انبارِ همان محصول (موجودی تضمینی)؛ مقصد متفاوت
        const from = wIds[pi % N_WAREHOUSES];
        const isExit = i >= N_TRANSFERS - N_EXITS; // ۱۰ تای آخر = خروج
        const tr = await transfersService.createTransfer({
            fromWarehouseId: from,
            toWarehouseId: isExit ? undefined : wIds[(pi + 1) % N_WAREHOUSES],
            productId: pid,
            modelId: modelByProduct.get(pid)!,
            quantity: 10, // یک کارتن کامل (unitsPerBox=۱۰) تا اسکن خروج سقف را پر کند
            description: `دستور فشاری ${i + 1}`,
        }, managers[i % managers.length]);
        if (isExit) {
            exitTransfers.push({ id: (tr as { id: string }).id, warehouseId: from, productId: pid, modelId: modelByProduct.get(pid)! });
        }
    }
    time('transfers x30 (service)', t);

    t = Date.now();
    for (const et of exitTransfers) {
        const cand = (byProduct.get(et.productId) ?? []).find(
            (c) => c.warehouseId === et.warehouseId && !usedSerials.has(c.serial),
        );
        if (!cand) throw new Error(`no stock for exit transfer ${et.id}`);
        const keeper = keepers.find((x) => x.warehouseId === et.warehouseId)!;
        const res = await scanOutService.scanOut(
            { qrPayload: '', serialNumber: cand.serial, transferId: et.id },
            et.warehouseId, keeper.id,
        );
        if (!(res as { valid: boolean }).valid) {
            throw new Error(`exit scan failed: ${JSON.stringify(res).slice(0, 200)}`);
        }
        usedSerials.add(cand.serial);
    }
    time('exits x10 (service)', t);

    const counts = await prisma.$queryRawUnsafe<{ t: string; c: bigint }[]>(
        `SELECT 'User' t, count(*)::int8 c FROM "User" UNION ALL SELECT 'Warehouse', count(*) FROM "Warehouse" UNION ALL SELECT 'Product', count(*) FROM "Product" UNION ALL SELECT 'ProductModel', count(*) FROM "ProductModel" UNION ALL SELECT 'Carton', count(*) FROM "Carton" UNION ALL SELECT 'Order', count(*) FROM "Order" UNION ALL SELECT 'Transfer', count(*) FROM "Transfer" UNION ALL SELECT 'Transaction', count(*) FROM "Transaction" UNION ALL SELECT 'OrderDaySequence', count(*) FROM "OrderDaySequence"`,
    );
    console.log('[seed] DONE:', counts.map((r) => `${r.t}=${Number(r.c)}`).join(' '));
    console.log(`[seed] TOTAL: ${((Date.now() - t0) / 1000).toFixed(1)}s`);
    await prisma.$disconnect();
    process.exit(0);
}

main().catch((e) => { console.error('[seed] FAIL:', e); process.exit(1); });
