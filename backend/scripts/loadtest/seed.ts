import path from 'path';
import dotenv from 'dotenv';
import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

dotenv.config({ path: path.join(__dirname, '..', '..', '.env.staging') });

const url = new URL(process.env.MIGRATOR_URL ?? process.env.DATABASE_URL!);
const sslMode = url.searchParams.get('sslmode');
const acceptInvalid = url.searchParams.get('sslaccept') === 'accept_invalid_certs';
url.searchParams.delete('sslmode');
url.searchParams.delete('sslaccept');
const ssl = sslMode === 'disable' ? undefined : { rejectUnauthorized: false };
const pool = new Pool({ connectionString: url.toString(), ...(ssl ? { ssl } : {}) });
const prisma = new PrismaClient({ adapter: new PrismaPg(pool) });

const WAREHOUSES = 10;
const MANAGERS = 2;
const KEEPERS = 45;
const DRIVERS = 3;
const PRODUCTS = 20_000;
const CARTONS = 100_000;
const TRANSACTIONS = 50_000;
const ORDERS = 10_000;
const NOTIFICATIONS = 10_000;
const ACTIVITY_LOGS = 10_000;
const PASSWORD = 'Loadtest@1405';

const rand = (n: number) => Math.floor(Math.random() * n);
const pick = <T>(arr: T[]): T => arr[rand(arr.length)];
const spreadDate = (maxDays: number) => new Date(Date.now() - rand(maxDays * 86_400_000));
const randInt = (a: number, b: number) => a + rand(b - a + 1);

const TABLES = [
    'AuditLog', 'OutboxEvent', 'IdempotencyKey', 'Notification', 'RefreshToken', 'Delivery',
    'OrderItem', 'Badge', 'Order', 'ActivityLog', 'Carton', 'ProductModel', 'Transaction',
    'SerialSequence', 'Product', 'User', 'Warehouse',
];

const PERSIAN_PREFIXES = ['کالای', 'محصول', 'قطعه', 'لوازم', 'ابزار', 'مواد'];
const PERSIAN_SUFFIXES = ['خانگی', 'صنعتی', 'بهداشتی', 'الکترونیکی', 'ساختمانی', 'آزمایشگاهی'];

function productName(i: number): string {
    if (i < 200) return `${pick(PERSIAN_PREFIXES)} ${pick(PERSIAN_SUFFIXES)} آرشیو ${i}`;
    if (i % 500 === 0) return `P-${i}-${randInt(100, 999)}`;
    if (i % 1000 === 0) return `کالای بسیار بسیار طولانی با نام بلند و توصیفی برای تست جستجو و ایندکس ${'م'.repeat(120)} ${i}`;
    if (i % 2500 === 0) return 'م';
    if (i % 3000 === 0) return `کالا_${i}%بسته`;
    return `${pick(PERSIAN_PREFIXES)} ${pick(PERSIAN_SUFFIXES)} ${i}`;
}

async function main() {
    console.log('[seed] truncate all tables...');
    for (const t of TABLES) {
        await pool.query(`TRUNCATE TABLE "${t}" CASCADE;`);
    }

    console.log('[seed] warehouses...');
    const warehouses = Array.from({ length: WAREHOUSES }, (_, i) => ({
        name: `انبار مرکزی ${i + 1}`,
        address: `آدرس انبار شماره ${i + 1} — تهران`,
    }));
    await prisma.warehouse.createMany({ data: warehouses });
    const wIds = (await prisma.warehouse.findMany({ select: { id: true } })).map((w) => w.id);

    console.log('[seed] users...');
    const users: { name: string; phone: string; password: string; role: 'MANAGER' | 'WAREHOUSE_KEEPER' | 'DRIVER'; warehouseId?: string; isActive: boolean; deletedAt?: Date | null }[] = [];
    for (let i = 0; i < MANAGERS; i++) users.push({ name: `مدیر تست ${i + 1}`, phone: `0912000000${i}`, password: PASSWORD, role: 'MANAGER', isActive: true });
    for (let i = 0; i < KEEPERS; i++) users.push({ name: `انباردار تست ${i + 1}`, phone: `091200000${i + 10}`, password: PASSWORD, role: 'WAREHOUSE_KEEPER', warehouseId: wIds[i % WAREHOUSES], isActive: true });
    for (let i = 0; i < DRIVERS; i++) users.push({ name: `راننده تست ${i + 1}`, phone: `091200000${i + 60}`, password: PASSWORD, role: 'DRIVER', isActive: true });
    for (let i = 0; i < 10; i++) users.push({ name: `کاربر غیرفعال ${i}`, phone: `091200000${i + 70}`, password: PASSWORD, role: 'WAREHOUSE_KEEPER', warehouseId: wIds[i % WAREHOUSES], isActive: false, deletedAt: new Date() });
    for (const u of users) u.password = await bcrypt.hash(u.password, 8);
    await prisma.user.createMany({ data: users });
    const userRows = await prisma.user.findMany({ select: { id: true, role: true, warehouseId: true } });
    const managers = userRows.filter((u) => u.role === 'MANAGER').map((u) => u.id);
    const keepers = userRows.filter((u) => u.role === 'WAREHOUSE_KEEPER' && u.warehouseId).map((u) => u.id);
    const drivers = userRows.filter((u) => u.role === 'DRIVER').map((u) => u.id);
    const allUsers = userRows.map((u) => u.id);

    console.log('[seed] products + models...');
    const products: { name: string; unit: string; deletedAt: Date | null }[] = [];
    for (let i = 0; i < PRODUCTS; i++) {
        products.push({ name: productName(i), unit: ['عدد', 'بسته', 'کیلوگرم', 'متر'][rand(4)], deletedAt: i < 200 ? new Date() : null });
    }
    for (let i = 0; i < products.length; i += 5000) {
        await prisma.product.createMany({ data: products.slice(i, i + 5000), skipDuplicates: true });
    }
    const pRows = await prisma.product.findMany({ select: { id: true } });
    const models: { productId: string; name: string; price: number; packageType: string; unitsPerBox: number }[] = [];
    for (const p of pRows) {
        models.push({ productId: p.id, name: ['مدل استاندارد', 'مدل ویژه', 'مدل اقتصادی'][rand(3)], price: randInt(10_000, 5_000_000), packageType: 'کارتن', unitsPerBox: randInt(1, 50) });
    }
    for (let i = 0; i < models.length; i += 5000) {
        await prisma.productModel.createMany({ data: models.slice(i, i + 5000), skipDuplicates: true });
    }
    const mRows = await prisma.productModel.findMany({ select: { id: true, productId: true } });
    const modelByProduct = new Map(mRows.map((m) => [m.productId, m.id]));

    const { buildQrForSerial } = require('../../src/utils/qr') as { buildQrForSerial: (p: { serial: string; uuid: string }) => { qrPayload: string; hmac: string } };

    console.log('[seed] orders...');
    const SHIPPED = Math.floor(ORDERS * 0.25);
    const orders: { warehouseId: string; status: 'PENDING' | 'SHIPPED' | 'DELIVERED' | 'CANCELED'; createdById: string; shippingMethod: string; carrier: string | null; city: string | null; postalCode: string | null; receiverName: string | null; customerPhone: string | null; address: string | null; createdAt: Date }[] = [];
    for (let i = 0; i < ORDERS; i++) {
        const r = rand(100);
        const status = r < 55 ? 'PENDING' : r < 80 ? 'SHIPPED' : r < 95 ? 'DELIVERED' : 'CANCELED';
        const hasCity = rand(100) < 70;
        orders.push({
            warehouseId: pick(wIds), status, createdById: pick(managers),
            shippingMethod: pick(['باربری', 'پست', 'تیپاکس']), carrier: ['باربری مهر', 'پست پیشتاز', null][rand(3)],
            city: hasCity ? pick(['تهران', 'اصفهان', 'شیراز', 'مشهد', 'تبریز']) : null,
            postalCode: hasCity ? String(1000000000 + rand(8999999999)) : null,
            receiverName: `گیرنده ${i}`,
            customerPhone: `0913${String(1000000 + rand(8999999))}`, address: `خیابان تست ${i}`,
            createdAt: spreadDate(180),
        });
    }
    for (let i = 0; i < orders.length; i += 2000) {
        await prisma.order.createMany({ data: orders.slice(i, i + 2000) });
    }
    const orderRows = await prisma.order.findMany({ select: { id: true, status: true } });
    const orderIds = orderRows.map((o) => o.id);
    const shippedOrderIds = orderRows.filter((o) => o.status === 'SHIPPED').map((o) => o.id);
    const shippedOrderIdsU = shippedOrderIds.length > 0 ? shippedOrderIds : orderIds.slice(0, 1000);

    console.log('[seed] order items...');
    const orderItems: { orderId: string; productId: string; quantity: number; model: string | null; modelId: string | null; price: number }[] = [];
    for (let i = 0; i < ORDERS; i++) {
        const itemCount = randInt(1, 5);
        const used = new Set<number>();
        for (let k = 0; k < itemCount; k++) {
            const pi = rand(PRODUCTS);
            if (used.has(pi)) continue;
            used.add(pi);
            const pid = pRows[pi].id;
            orderItems.push({ orderId: orderIds[i], productId: pid, quantity: randInt(1, 100), model: 'مدل استاندارد', modelId: modelByProduct.get(pid) ?? null, price: randInt(10_000, 5_000_000) });
        }
    }
    for (let i = 0; i < orderItems.length; i += 5000) {
        await prisma.orderItem.createMany({ data: orderItems.slice(i, i + 5000), skipDuplicates: true });
    }

    console.log('[seed] cartons (100k)...');
    const cartons: { productId: string; modelId: string | null; warehouseId: string; orderId: string | null; qrPayload: string; hmac: string; serialNumber: string; isIndividual: boolean; entryType: 'NEW' | 'RETURNED'; status: 'IN_STOCK' | 'SHIPPED' | 'RETURNED'; scannedOutAt: Date | null; createdById: string; createdAt: Date }[] = [];
    const keeperByWarehouse = new Map<string, string>();
    for (const k of keepers) keeperByWarehouse.set(k, k);
    for (let i = 0; i < CARTONS; i++) {
        const pi = rand(PRODUCTS);
        const wi = i % WAREHOUSES;
        const pid = pRows[pi].id;
        const r = rand(100);
        const status = r < 88 ? 'IN_STOCK' : r < 95 ? 'SHIPPED' : 'RETURNED';
        const serial = `MA-1405-${String(i + 1).padStart(6, '0')}`;
        const uuid = crypto.randomUUID();
        const { qrPayload, hmac } = buildQrForSerial({ serial, uuid });
        cartons.push({
            productId: pid, modelId: modelByProduct.get(pid) ?? null, warehouseId: wIds[wi],
            orderId: status === 'SHIPPED' ? shippedOrderIdsU[i % shippedOrderIdsU.length] : null,
            qrPayload, hmac, serialNumber: serial,
            isIndividual: i % 10 === 0, entryType: 'NEW', status,
            scannedOutAt: status === 'SHIPPED' ? spreadDate(90) : null,
            createdById: pick(keepers), createdAt: spreadDate(180),
        });
    }
    for (let i = 0; i < cartons.length; i += 5000) {
        await prisma.carton.createMany({ data: cartons.slice(i, i + 5000), skipDuplicates: true });
    }

    console.log('[seed] transactions...');
    const tx: { type: 'IN' | 'OUT' | 'RETURN'; productName: string; productId: string; quantity: number; warehouseId: string; userId: string; createdAt: Date }[] = [];
    for (let i = 0; i < TRANSACTIONS; i++) {
        const pi = rand(PRODUCTS);
        const r = rand(100);
        tx.push({
            type: r < 70 ? 'IN' : r < 90 ? 'OUT' : 'RETURN',
            productName: productName(pi), productId: pRows[pi].id,
            quantity: randInt(1, 50), warehouseId: pick(wIds), userId: pick(allUsers), createdAt: spreadDate(180),
        });
    }
    for (let i = 0; i < tx.length; i += 5000) {
        await prisma.transaction.createMany({ data: tx.slice(i, i + 5000) });
    }

    console.log('[seed] notifications...');
    const notifs: { userId: string; title: string; body: string; type: string; isRead: boolean; createdAt: Date }[] = [];
    for (let i = 0; i < NOTIFICATIONS; i++) {
        notifs.push({ userId: pick(allUsers), title: 'اعلان تست', body: `بدنه اعلان شماره ${i}`, type: pick(['info', 'order', 'alert']), isRead: rand(100) < 40, createdAt: spreadDate(90) });
    }
    for (let i = 0; i < notifs.length; i += 5000) {
        await prisma.notification.createMany({ data: notifs.slice(i, i + 5000) });
    }

    console.log('[seed] activity logs...');
    const TYPES = ['order_created', 'order_updated', 'product_checkin', 'order_shipped', 'product_created', 'user_created'] as const;
    const acts: { type: (typeof TYPES)[number]; label: string; orderId: string | null; userId: string; createdAt: Date }[] = [];
    for (let i = 0; i < ACTIVITY_LOGS; i++) {
        acts.push({ type: pick([...TYPES]), label: `فعالیت تست ${i}`, orderId: rand(100) < 30 ? orderIds[rand(ORDERS)] : null, userId: pick(allUsers), createdAt: spreadDate(90) });
    }
    for (let i = 0; i < acts.length; i += 5000) {
        await prisma.activityLog.createMany({ data: acts.slice(i, i + 5000) });
    }

    console.log('[seed] serial sequence + refresh tokens...');
    await prisma.serialSequence.upsert({ where: { year: 1405 }, update: { lastSeq: CARTONS }, create: { year: 1405, lastSeq: CARTONS } });

    const counts = await prisma.$queryRawUnsafe<{ t: string; c: bigint }[]>(
        `SELECT 'User' t, count(*)::int8 c FROM "User" UNION ALL SELECT 'Warehouse', count(*) FROM "Warehouse" UNION ALL SELECT 'Product', count(*) FROM "Product" UNION ALL SELECT 'ProductModel', count(*) FROM "ProductModel" UNION ALL SELECT 'Carton', count(*) FROM "Carton" UNION ALL SELECT 'Transaction', count(*) FROM "Transaction" UNION ALL SELECT 'Order', count(*) FROM "Order" UNION ALL SELECT 'OrderItem', count(*) FROM "OrderItem" UNION ALL SELECT 'Notification', count(*) FROM "Notification" UNION ALL SELECT 'ActivityLog', count(*) FROM "ActivityLog"`,
    );
    console.log('[seed] DONE:', counts.map((r) => `${r.t}=${Number(r.c)}`).join(' '));
    await prisma.$disconnect();
}

main().catch((e) => { console.error('[seed] FAIL:', e); process.exit(1); });
