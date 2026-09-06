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

    case 'carton_transferred':
    case 'carton_exited': {
      const label = `${payload.productName ?? ''}${payload.modelName ? ` (${payload.modelName})` : ''}`;
      const isTransfer = type === 'carton_transferred';
      const managers = await findManagers();
      for (const mgr of managers) {
        await notificationService.create(
          mgr.id,
          isTransfer ? 'جابه‌جایی کالا' : 'خروج کالا',
          isTransfer
            ? `${label} از انبار ${payload.warehouseName ?? ''} به ${payload.destinationWarehouseName ?? ''} منتقل شد`
            : `${label} از انبار ${payload.warehouseName ?? ''} خارج شد (دستور خروج)`,
          'info',
          {
            type: isTransfer ? 'TRANSFER_EXECUTED' : 'EXIT_EXECUTED',
            transferId: payload.transferId ?? null,
            cartonId: payload.cartonId ?? null,
            warehouseId: payload.warehouseId ?? null,
            destinationWarehouseId: payload.destinationWarehouseId ?? null,
            productName: payload.productName ?? null,
            modelName: payload.modelName ?? null,
          },
          `${eventId}:${mgr.id}`,
        );
      }
      realtime.toRole('MANAGER', RealtimeEvents.SCANOUT_DONE, payload);
      realtime.toWarehouse(payload.warehouseId, RealtimeEvents.SCANOUT_DONE, payload);
      if (payload.destinationWarehouseId) {
        realtime.toWarehouse(payload.destinationWarehouseId, RealtimeEvents.SCANOUT_DONE, payload);
      }
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

    case 'order:updated': {
      // مدیر سفارش را ویرایش کرد — انباردار همان انبار باید مطلع شود (اطلاعات ارسال/اقلام ممکن است
      // عوض شده باشد) تا بر اساس نسخهٔ تازه آماده‌سازی کند
      const keepers = await findWarehouseKeepers(payload.warehouseId);
      const label = `${payload.senderName ?? 'فرستنده'} → ${payload.receiverName ?? 'گیرنده'}`;
      for (const keeper of keepers) {
        await notificationService.create(
          keeper.id,
          'ویرایش سفارش',
          `سفارش «${label}» توسط مدیریت ویرایش شد — جزئیات را بررسی کنید`,
          'info',
          {
            type: 'ORDER_UPDATED',
            orderId: payload.orderId ?? null,
            warehouseId: payload.warehouseId ?? null,
            senderName: payload.senderName ?? null,
            receiverName: payload.receiverName ?? null,
          },
          `${eventId}:${keeper.id}`,
        );
      }
      realtime.toWarehouse(payload.warehouseId, RealtimeEvents.ORDER_UPDATED, payload);
      realtime.toRole('MANAGER', RealtimeEvents.ORDER_UPDATED, payload);
      break;
    }

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

    // تعریف بار برای راننده توسط انباردار (بعد از اسکن خروج) — اعلان به راننده + مدیر + رفرش زنده
    case 'order:driver:assigned': {
      const warehouseName = payload.warehouseName ?? '';
      const orderLabel = payload.orderNumber
        ? `سفارش شماره ${payload.orderNumber}`
        : 'یک سفارش';
      await notificationService.create(
        payload.driverId,
        'بار جدید',
        `${orderLabel} برای شما تعریف شد${warehouseName ? ` (${warehouseName})` : ''}`,
        'info',
        {
          type: 'DRIVER_ORDER_ASSIGNED',
          orderId: payload.orderId ?? null,
          driverId: payload.driverId ?? null,
          driverName: payload.driverName ?? null,
          warehouseId: payload.warehouseId ?? null,
          warehouseName,
        },
        `${eventId}:${payload.driverId}`,
      );
      // مدیر هم مطلع می‌شود چه بار و به کدام راننده واگذار شد (ردیابی حساس خروج کالا)
      const managers = await findManagers();
      const orderRef = payload.orderNumber
        ? `سفارش #${payload.orderNumber}${payload.city ? ` (${payload.city})` : ''}`
        : 'یک سفارش';
      for (const mgr of managers) {
        await notificationService.create(
          mgr.id,
          'تخصیص بار',
          `${orderRef} به راننده «${payload.driverName ?? '—'}»${warehouseName ? ` در انبار ${warehouseName}` : ''} واگذار شد`,
          'info',
          {
            type: 'DRIVER_ORDER_ASSIGNED',
            orderId: payload.orderId ?? null,
            driverId: payload.driverId ?? null,
            driverName: payload.driverName ?? null,
            warehouseId: payload.warehouseId ?? null,
            warehouseName,
          },
          `${eventId}:${mgr.id}`,
        );
      }
      // پنل راننده همان‌لحظه بار را نشان می‌دهد + مدیر لیست زندهٔ سفارش‌ها را رفرش می‌کند
      realtime.toUser(payload.driverId, RealtimeEvents.ORDER_ASSIGNED, payload);
      realtime.toRole('MANAGER', RealtimeEvents.ORDER_ASSIGNED, payload);
      break;
    }

    // انباردار پیش از تحویل راننده را عوض کرد — رانندهٔ قبلی باید همان لحظه بداند بار از او گرفته شده
    case 'order:driver:unassigned': {
      const orderRef = payload.orderNumber
        ? `سفارش شماره ${payload.orderNumber}`
        : 'یک سفارش';
      await notificationService.create(
        payload.driverId,
        'حذف بار',
        `${orderRef} از لیست بارهای شما حذف شد و به رانندهٔ دیگری واگذار گردید`,
        'warning',
        {
          type: 'DRIVER_ORDER_REMOVED',
          orderId: payload.orderId ?? null,
          driverId: payload.driverId ?? null,
          newDriverId: payload.newDriverId ?? null,
          warehouseId: payload.warehouseId ?? null,
          warehouseName: payload.warehouseName ?? null,
        },
        `${eventId}:${payload.driverId}`,
      );
      // پنل رانندهٔ قبلی همان لحظه سفارش را از لیستش پاک می‌کند (بار دیگر برایش نیست)
      realtime.toUser(payload.driverId, RealtimeEvents.ORDER_UNASSIGNED, payload);
      break;
    }

    // ── دستور جابه‌جایی/خروج مدیر (دوفازی) ──
    // صادر شدن دستور (PENDING → انباردار باید اجرا کند) یا اجرای مستقیم مسیر لِگاسی (DONE)
    case 'transfer:created': {
      const isTransfer = payload.kind === 'transfer';
      const productLabel = `${payload.productName ?? ''}${payload.modelName ? ` (${payload.modelName})` : ''}`;
      const unit = payload.quantity ?? 0;
      const done = payload.status === 'DONE';
      const fromName = payload.fromWarehouseName ?? '';
      const toName = payload.toWarehouseName ?? null;
      const scope = toName ? `از ${fromName} به ${toName}` : `از ${fromName}`;
      const verb = isTransfer ? 'جابه‌جایی' : 'خروج';
      const data = {
        type: done ? 'TRANSFER_EXECUTED' : isTransfer ? 'TRANSFER_CREATED' : 'EXIT_CREATED',
        transferId: payload.transferId ?? null,
        fromWarehouseId: payload.fromWarehouseId ?? null,
        fromWarehouseName: fromName || null,
        toWarehouseId: payload.toWarehouseId ?? null,
        toWarehouseName: toName,
        productName: payload.productName ?? null,
        modelName: payload.modelName ?? null,
        quantity: unit,
        status: payload.status ?? 'PENDING',
      };

      // انباردارِ مبدأ (و مقصد در جابه‌جایی) باید از دستور تازه باخبر شوند — چه در انتظار اجرا
      // باشد و چه (مسیر لِگاسی) مستقیم توسط مدیریت اجرا شده باشد
      const targetIds = new Set<string>();
      const fromKeepers = await findWarehouseKeepers(payload.fromWarehouseId);
      for (const k of fromKeepers) targetIds.add(k.id);
      if (payload.toWarehouseId) {
        const toKeepers = await findWarehouseKeepers(payload.toWarehouseId);
        for (const k of toKeepers) targetIds.add(k.id);
      }
      for (const keeperId of targetIds) {
        await notificationService.create(
          keeperId,
          done ? `اجرای ${verb} کالا` : `دستور ${verb} جدید`,
          done
            ? `${productLabel} — ${unit} واحد ${scope} توسط مدیریت اجرا شد`
            : `${productLabel} — ${unit} واحد ${scope} — در انتظار اجرا`,
          done ? 'info' : 'warning',
          data,
          `${eventId}:${keeperId}`,
        );
      }
      realtime.toWarehouse(payload.fromWarehouseId, RealtimeEvents.TRANSFER_CREATED, payload);
      if (payload.toWarehouseId) {
        realtime.toWarehouse(payload.toWarehouseId, RealtimeEvents.TRANSFER_CREATED, payload);
      }
      break;
    }

    // دستور با اسکن انباردار کامل اجرا شد — یک اعلانِ تجمیعی به مدیر + انبارهای مبدأ/مقصد
    case 'transfer:completed': {
      const isTransfer = payload.kind === 'transfer';
      const productLabel = `${payload.productName ?? ''}${payload.modelName ? ` (${payload.modelName})` : ''}`;
      const unit = payload.quantity ?? 0;
      const fromName = payload.fromWarehouseName ?? '';
      const toName = payload.toWarehouseName ?? null;
      const scope = toName ? `از ${fromName} به ${toName}` : `از ${fromName}`;
      const verb = isTransfer ? 'جابه‌جایی' : 'خروج';
      const data = {
        type: 'TRANSFER_COMPLETED',
        transferId: payload.transferId ?? null,
        fromWarehouseId: payload.fromWarehouseId ?? null,
        fromWarehouseName: fromName || null,
        toWarehouseId: payload.toWarehouseId ?? null,
        toWarehouseName: toName,
        productName: payload.productName ?? null,
        modelName: payload.modelName ?? null,
        quantity: unit,
      };
      const managers = await findManagers();
      for (const mgr of managers) {
        await notificationService.create(
          mgr.id,
          `تکمیل دستور ${verb}`,
          `${productLabel} — ${unit} واحد ${scope} به‌طور کامل اجرا شد`,
          'success',
          data,
          `${eventId}:${mgr.id}`,
        );
      }
      const targetIds = new Set<string>();
      const fromKeepers = await findWarehouseKeepers(payload.fromWarehouseId);
      for (const k of fromKeepers) targetIds.add(k.id);
      if (payload.toWarehouseId) {
        const toKeepers = await findWarehouseKeepers(payload.toWarehouseId);
        for (const k of toKeepers) targetIds.add(k.id);
      }
      for (const keeperId of targetIds) {
        await notificationService.create(
          keeperId,
          `تکمیل دستور ${verb}`,
          `${productLabel} — ${unit} واحد ${scope} به‌طور کامل اجرا شد`,
          'success',
          data,
          `${eventId}:${keeperId}`,
        );
      }
      realtime.toWarehouse(payload.fromWarehouseId, RealtimeEvents.TRANSFER_COMPLETED, payload);
      if (payload.toWarehouseId) {
        realtime.toWarehouse(payload.toWarehouseId, RealtimeEvents.TRANSFER_COMPLETED, payload);
      }
      break;
    }

    // مدیر دستورِ در انتظار را لغو کرد — انباردار نباید دیگر برایش اسکن کند
    case 'transfer:canceled': {
      const isTransfer = payload.kind === 'transfer';
      const productLabel = `${payload.productName ?? ''}${payload.modelName ? ` (${payload.modelName})` : ''}`;
      const unit = payload.quantity ?? 0;
      const fromName = payload.fromWarehouseName ?? '';
      const toName = payload.toWarehouseName ?? null;
      const scope = toName ? `از ${fromName} به ${toName}` : `از ${fromName}`;
      const verb = isTransfer ? 'جابه‌جایی' : 'خروج';
      const data = {
        type: 'TRANSFER_CANCELED',
        transferId: payload.transferId ?? null,
        fromWarehouseId: payload.fromWarehouseId ?? null,
        fromWarehouseName: fromName || null,
        toWarehouseId: payload.toWarehouseId ?? null,
        toWarehouseName: toName,
        productName: payload.productName ?? null,
        modelName: payload.modelName ?? null,
        quantity: unit,
      };
      const targetIds = new Set<string>();
      const fromKeepers = await findWarehouseKeepers(payload.fromWarehouseId);
      for (const k of fromKeepers) targetIds.add(k.id);
      if (payload.toWarehouseId) {
        const toKeepers = await findWarehouseKeepers(payload.toWarehouseId);
        for (const k of toKeepers) targetIds.add(k.id);
      }
      for (const keeperId of targetIds) {
        await notificationService.create(
          keeperId,
          `لغو دستور ${verb}`,
          `${productLabel} — ${unit} واحد ${scope} توسط مدیریت لغو شد — دیگر قابل اجرا نیست`,
          'warning',
          data,
          `${eventId}:${keeperId}`,
        );
      }
      realtime.toWarehouse(payload.fromWarehouseId, RealtimeEvents.TRANSFER_CANCELED, payload);
      if (payload.toWarehouseId) {
        realtime.toWarehouse(payload.toWarehouseId, RealtimeEvents.TRANSFER_CANCELED, payload);
      }
      break;
    }

    // تحویل سفارش توسط راننده — اطلاع به مدیر و انباردارِ همان انبار:
    // چه سفارشی تحویل داده شد و به چه باربری
    case 'delivery:completed': {
      const orderRef = payload.orderNumber ? `سفارش ${payload.orderNumber}` : 'یک سفارش';
      const label = `${orderRef}${payload.receiverName ? ` (${payload.receiverName})` : ''} با باربری ${payload.carrier ?? 'نامشخص'} تحویل داده شد`;
      const data = {
        type: 'DELIVERY_COMPLETED',
        orderId: payload.orderId ?? null,
        orderNumber: payload.orderNumber ?? null,
        receiverName: payload.receiverName ?? null,
        city: payload.city ?? null,
        carrier: payload.carrier ?? null,
        warehouseId: payload.warehouseId ?? null,
        warehouseName: payload.warehouseName ?? null,
        driverName: payload.driverName ?? null,
        receiptUrl: payload.receiptUrl ?? null,
      };
      const managers = await findManagers();
      for (const mgr of managers) {
        await notificationService.create(
          mgr.id,
          'تحویل سفارش',
          label,
          'success',
          data,
          `${eventId}:${mgr.id}`,
        );
      }
      const keepers = await findWarehouseKeepers(payload.warehouseId);
      for (const keeper of keepers) {
        await notificationService.create(
          keeper.id,
          'تحویل سفارش',
          label,
          'success',
          data,
          `${eventId}:${keeper.id}`,
        );
      }
      realtime.toRole('MANAGER', RealtimeEvents.DELIVERY_COMPLETED, payload);
      realtime.toWarehouse(payload.warehouseId, RealtimeEvents.DELIVERY_COMPLETED, payload);
      break;
    }

    // بازچینی صف بارگیری توسط انباردار — پنل راننده همان لحظه صفِ تازه را می‌گیرد
    case 'carriers:reordered': {
      realtime.toRole('DRIVER', RealtimeEvents.CARRIERS_REORDERED, payload);
      break;
    }

    // اتصال/قطع راننده به انبار توسط انباردار — نوتیفیکیشن به راننده + تازه‌سازی زندهٔ همهٔ انباردارها
    case 'driver:assigned':
    case 'driver:unassigned': {
      const assigned = type === 'driver:assigned';
      const warehouseName = payload.warehouseName ?? '';
      await notificationService.create(
        payload.driverId,
        assigned ? 'اتصال به انبار' : 'قطع اتصال از انبار',
        assigned
          ? `شما به انبار ${warehouseName} متصل شدید`
          : `اتصال شما به انبار ${warehouseName} قطع شد`,
        assigned ? 'info' : 'warning',
        {
          type: assigned ? 'DRIVER_ASSIGNED' : 'DRIVER_UNASSIGNED',
          driverId: payload.driverId ?? null,
          driverName: payload.driverName ?? null,
          warehouseId: payload.warehouseId ?? null,
          warehouseName,
        },
        `${eventId}:${payload.driverId}`,
      );
      // پنل راننده همان‌لحظه خالی/پر می‌شود + لیست انباردارها زنده رفرش می‌شود
      realtime.toUser(payload.driverId, RealtimeEvents.DRIVER_ASSIGNED, payload);
      realtime.toRole('WAREHOUSE_KEEPER', RealtimeEvents.DRIVER_ASSIGNED, payload);
      break;
    }

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
