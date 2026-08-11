import { prisma } from './prisma';

// پاک‌سازی روزانهٔ رکوردهای منقضی (RefreshToken / IdempotencyKey / OutboxEvent)
// FAILEDهای Outbox پاک نمی‌شوند — آن‌ها برای بررسی لازم‌اند
export function startCleanup() {
    const run = async () => {
        const now = new Date();
        await prisma.refreshToken.deleteMany({
            where: { OR: [{ expiresAt: { lt: now } }, { revokedAt: { lt: new Date(Date.now() - 7 * 864e5) } }] },
        });
        await prisma.idempotencyKey.deleteMany({
            where: { createdAt: { lt: new Date(Date.now() - 7 * 864e5) } },
        });
        await prisma.outboxEvent.deleteMany({
            where: { status: 'DISPATCHED', dispatchedAt: { lt: new Date(Date.now() - 30 * 864e5) } },
        });
    };
    run();
    const t = setInterval(run, 24 * 3600 * 1000);
    t.unref?.();
}
