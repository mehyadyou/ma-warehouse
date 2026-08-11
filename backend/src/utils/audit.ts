import { Prisma } from '@prisma/client';
import { prisma } from './prisma';

// ثبت ممیزی تغییرات حساس — چه کسی، چه چیزی، قبل/بعد، از کدام IP
export async function writeAudit(tx: Prisma.TransactionClient, e: {
    actorId?: string; action: string; entity: string; entityId?: string;
    before?: unknown; after?: unknown; ip?: string;
}) {
    await tx.auditLog.create({
        data: {
            actorId: e.actorId, action: e.action, entity: e.entity, entityId: e.entityId,
            before: e.before as Prisma.InputJsonValue, after: e.after as Prisma.InputJsonValue, ip: e.ip,
        },
    });
}

// نسخهٔ غیرتراکنشی (برای مواردی که تراکنش ندارند)
export async function writeAuditStandalone(e: {
    actorId?: string; action: string; entity: string; entityId?: string;
    before?: unknown; after?: unknown; ip?: string;
}) {
    await prisma.auditLog.create({
        data: {
            actorId: e.actorId, action: e.action, entity: e.entity, entityId: e.entityId,
            before: e.before as Prisma.InputJsonValue, after: e.after as Prisma.InputJsonValue, ip: e.ip,
        },
    });
}
