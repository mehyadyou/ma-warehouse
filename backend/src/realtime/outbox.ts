import { prisma } from '../utils/prisma';
import { realtime } from './realtime';
import { RealtimeEvents } from './events';
import { notificationService } from '../notification/notification.service';
import { logger } from '../utils/logger';

const MAX_ATTEMPTS = 5;

type OutboxPayload = Record<string, any>;

const asPayload = (payload: unknown): OutboxPayload =>
  (payload ?? {}) as OutboxPayload;

async function findManagers() {
  return prisma.user.findMany({ where: { role: 'MANAGER' }, select: { id: true } });
}

// انباردارهای همان انبار — فقط انبارِ داخل payload (انتخاب‌شده هنگام ثبت سفارش)
async function findWarehouseKeepers(warehouseId?: string | null) {
  if (!warehouseId) return [];
  return prisma.user.findMany({
    where: {
      role: 'WAREHOUSE_KEEPER',
      warehouseId,
      isActive: true,
      deletedAt: null,
    },
    select: { id: true },
  });
}

async function deliver(type: string, rawPayload: unknown, eventId: string) {
  const payload = asPayload(rawPayload);

  switch (type) {
    case 'order_shipped':
    case 'carton_shipped': {
      const label = `${payload.productName ?? ''}${payload.modelName ? ` (${payload.modelName})` : ''}`;
      const managers = await findManagers();
      for (const mgr of managers) {
        await notificationService.create(
          mgr.id,
          'خروج کالا',
          `${label} از انبار ${payload.warehouseName ?? ''} خارج شد`,
          'info',
          {
            type: 'SCAN_OUT',
            warehouseId: payload.warehouseId,
            warehouseName: payload.warehouseName ?? null,
            cartonId: payload.cartonId ?? null,
            productName: payload.productName ?? null,
            modelName: payload.modelName ?? null,
          },
          `${eventId}:${mgr.id}`,
        );
      }
      realtime.toRole('MANAGER', RealtimeEvents.SCANOUT_DONE, payload);
      realtime.toWarehouse(payload.warehouseId, RealtimeEvents.SCANOUT_DONE, payload);
      break;
    }

    case 'checkin:completed': {
      const entries = Array.isArray(payload.entries) ? payload.entries : [];
      const managers = await findManagers();
      for (const mgr of managers) {
        for (const g of entries) {
          const modelPart = g.modelName ? ` (${g.modelName})` : '';
          const qtyParts: string[] = [];
          if (g.cartons > 0) qtyParts.push(`${g.cartons} کارتن`);
          if (g.individuals > 0) qtyParts.push(`${g.individuals} تکی`);
          const qtyPart = qtyParts.length ? ` — ${qtyParts.join(' + ')}` : '';
          if (g.entryType === 'RETURNED') {
            await notificationService.create(
              mgr.id,
              'ورود مرجوعی',
              `${g.productName}${modelPart}${qtyPart} به انبار ${payload.warehouseName ?? ''} بازگشت`,
              'info',
              {
                type: 'RETURN_ENTRY',
                warehouseId: payload.warehouseId,
                warehouseName: payload.warehouseName ?? null,
                productName: g.productName,
                modelName: g.modelName ?? null,
                entryType: 'RETURNED',
              },
              `${eventId}:${mgr.id}:return`,
            );
          } else {
            await notificationService.create(
              mgr.id,
              'ورود کالا',
              `${g.productName}${modelPart}${qtyPart} وارد انبار ${payload.warehouseName ?? ''} شد`,
              'info',
              {
                type: 'CARGO_ENTRY',
                warehouseId: payload.warehouseId,
                warehouseName: payload.warehouseName ?? null,
                productName: g.productName,
                modelName: g.modelName ?? null,
                entryType: 'NEW',
              },
              `${eventId}:${mgr.id}:entry`,
            );
          }
        }
      }
      realtime.toRole('MANAGER', RealtimeEvents.CARGO_ENTRY, {
        keeperName: 'انباردار',
        warehouseId: payload.warehouseId,
        totalUnits: payload.totalUnits ?? 0,
      });
      realtime.toRole('MANAGER', RealtimeEvents.CHECKIN_COMPLETED, {
        warehouseId: payload.warehouseId,
        totalUnits: payload.totalUnits ?? 0,
        cartonCount: payload.cartonCount ?? 0,
      });
      break;
    }

    case 'order:created': {
      const keepers = await findWarehouseKeepers(payload.warehouseId);
      const label = `${payload.senderName ?? 'فرستنده'} → ${payload.receiverName ?? 'گیرنده'}`;
      for (const keeper of keepers) {
        await notificationService.create(
          keeper.id,
          'سفارش جدید',
          `سفارش جدید ثبت شد: ${label}`,
          'info',
          {
            type: 'NEW_ORDER',
            orderId: payload.orderId ?? null,
            warehouseId: payload.warehouseId ?? null,
            senderName: payload.senderName ?? null,
            receiverName: payload.receiverName ?? null,
          },
          `${eventId}:${keeper.id}`,
        );
      }
      realtime.toWarehouse(payload.warehouseId, RealtimeEvents.ORDER_CREATED, payload);
      realtime.toRole('MANAGER', RealtimeEvents.ORDER_CREATED, payload);
      break;
    }

    case 'order:updated':
      realtime.toWarehouse(payload.warehouseId, RealtimeEvents.ORDER_UPDATED, payload);
      realtime.toRole('MANAGER', RealtimeEvents.ORDER_UPDATED, payload);
      break;

    case 'order:deleted': {
      const keepers = await findWarehouseKeepers(payload.warehouseId);
      const label = `${payload.senderName ?? 'فرستنده'} → ${payload.receiverName ?? 'گیرنده'}`;
      for (const keeper of keepers) {
        await notificationService.create(
          keeper.id,
          'حذف سفارش',
          `سفارش ${label} توسط مدیریت حذف شد`,
          'warning',
          {
            type: 'ORDER_DELETED',
            orderId: payload.orderId ?? null,
            warehouseId: payload.warehouseId ?? null,
            senderName: payload.senderName ?? null,
            receiverName: payload.receiverName ?? null,
          },
          `${eventId}:${keeper.id}`,
        );
      }
      realtime.toWarehouse(payload.warehouseId, RealtimeEvents.ORDER_DELETED, payload);
      realtime.toRole('MANAGER', RealtimeEvents.ORDER_DELETED, payload);
      break;
    }

    case 'delivery:completed':
      realtime.toRole('MANAGER', RealtimeEvents.DELIVERY_COMPLETED, payload);
      break;

    default:
      realtime.toRole('MANAGER', type, payload);
  }
}

export async function dispatchOutbox(batch = 50): Promise<number> {
  // بازیابی رویدادهای معلق: اگر سرور بین claim و deliver کرش کرده باشند
  const STUCK_MS = 60_000;
  await prisma.outboxEvent.updateMany({
    where: {
      status: 'DISPATCHING',
      claimedAt: { lt: new Date(Date.now() - STUCK_MS) },
      attempts: { lt: MAX_ATTEMPTS },
    },
    data: { status: 'PENDING' },
  });

  const events = await prisma.outboxEvent.findMany({
    where: { status: 'PENDING' },
    orderBy: { createdAt: 'asc' },
    take: batch,
  });

  let delivered = 0;
  for (const ev of events) {
    // ادعای اتمی: فقط یک مصرف‌کننده می‌تواند این رویداد را بردارد
    const claimed = await prisma.outboxEvent.updateMany({
      where: { id: ev.id, status: 'PENDING' },
      data: { status: 'DISPATCHING', attempts: { increment: 1 }, claimedAt: new Date() },
    });
    if (claimed.count !== 1) continue;

    try {
      await deliver(ev.type, ev.payload, ev.id);
      await prisma.outboxEvent.updateMany({
        where: { id: ev.id, status: 'DISPATCHING' },
        data: { status: 'DISPATCHED', dispatchedAt: new Date() },
      });
      delivered++;
    } catch (err: any) {
      const attempts = ev.attempts + 1;
      const failed = attempts >= MAX_ATTEMPTS;
      await prisma.outboxEvent.updateMany({
        where: { id: ev.id, status: 'DISPATCHING' },
        data: {
          attempts,
          lastError: String(err?.message ?? err),
          status: failed ? 'FAILED' : 'PENDING',
        },
      });
      if (failed) {
        // هشدار: رویداد دیگر دوباره تلاش نمی‌شود — اینجا باید در monitoring/گزارش دیده شود
        logger.error(
          { eventId: ev.id, type: ev.type, aggregate: ev.aggregate, attempts: MAX_ATTEMPTS, error: err?.message ?? err },
          'outbox: event FINAL failed',
        );
      }
    }
  }
  return delivered;
}

export function startOutboxDispatcher(intervalMs = 2000): () => void {
  const tick = () => {
    dispatchOutbox().catch((e) => logger.error({ err: e }, 'outbox: dispatcher error'));
  };
  tick();
  const timer = setInterval(tick, intervalMs);
  timer.unref?.();
  return () => clearInterval(timer);
}
