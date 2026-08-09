import 'dotenv/config'
import { PrismaClient } from '@prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'

const globalForPrisma = globalThis as unknown as {
    prisma: PrismaClient | undefined
}

// اولویت با استخر اتصال (PgBouncer)؛ در غیر این صورت اتصال مستقیم
const databaseUrl = process.env.DATABASE_POOL_URL ?? process.env.DATABASE_URL!

const adapter = new PrismaPg(databaseUrl)

export const prisma =
    globalForPrisma.prisma ??
    new PrismaClient({
        adapter,
        log: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
    })

if (process.env.NODE_ENV !== 'production') {
    globalForPrisma.prisma = prisma
}