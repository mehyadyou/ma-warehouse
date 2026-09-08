import 'dotenv/config'
import { PrismaClient } from '@prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'
import { Pool } from 'pg'

const globalForPrisma = globalThis as unknown as {
    prisma: PrismaClient | undefined
}

// اولویت با استخر اتصال (PgBouncer)؛ در غیر این صورت اتصال مستقیم
const databaseUrl = process.env.DATABASE_POOL_URL ?? process.env.DATABASE_URL!

/**
 * ساخت استخر اتصال با مدیریت درست SSL.
 *
 * `sslaccept=accept_invalid_certs` پارامتر مخصوص libpq است که درایور pg آن را
 * نادیده می‌گیرد؛ علاوه بر آن، در نسخه‌های جدید pg هر `sslmode` داخل خودِ
 * connection string گزینه‌ی صریح `ssl` را override می‌کند. برای همین پارامترهای
 * ssl را از URL حذف و گزینه‌ی `ssl` را خودمان ست می‌کنیم:
 * - `sslaccept=accept_invalid_certs` → گواهی self-signed پذیرفته می‌شود
 *   (رمزنگاری فعال می‌ماند؛ فقط تأیید گواهی خاموش است — دقیقاً قصد پارامتر libpq)
 * - بدون آن → تأیید کامل گواهی (پیش‌فرض امن)
 */
function buildDatabasePool(): Pool {
    const url = new URL(databaseUrl)
    const sslMode = url.searchParams.get('sslmode')
    const acceptInvalidCerts = url.searchParams.get('sslaccept') === 'accept_invalid_certs'
    url.searchParams.delete('sslmode')
    url.searchParams.delete('sslaccept')

    const ssl =
        sslMode === 'disable'
            ? undefined
            : acceptInvalidCerts
              ? { rejectUnauthorized: false }
              : true

    return new Pool({
        connectionString: url.toString(),
        ...(ssl ? { ssl } : {}),
        // سقف صریح هم‌خوان با PgBouncer (default_pool_size=30): پولِ بی‌سقفِ pg
        // در پیک ۱۰۰ انباردار، اتصال‌های سرور را قفل می‌کرد
        max: Number(process.env.PG_POOL_MAX) || 20,
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 10000,
    })
}

const adapter = new PrismaPg(buildDatabasePool())

export const prisma =
    globalForPrisma.prisma ??
    new PrismaClient({
        adapter,
        log: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
    })

if (process.env.NODE_ENV !== 'production') {
    globalForPrisma.prisma = prisma
}