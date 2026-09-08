import { prisma } from '../../utils/prisma';
import { verifyPayload, verifySerialPayload } from '../../utils/qr';
import { runSerializable } from '../../utils/serializableTx';
import { AppError } from '../../common/exceptions/AppError';
import { writeAudit } from '../../utils/audit';
import { transferExecutedUnits, completeTransferIfDone } from '../../manager/transfers/transfers.service';
import type { CartonStatus, DeliveryStatus } from '@prisma/client';
import type { Prisma, PrismaClient } from '@prisma/client';

const cartonInclude = {
  product: { select: { id: true, name: true, unit: true } },
  model: { select: { id: true, name: true, unitsPerBox: true, packageType: true } },
  order: { select: { id: true, customerPhone: true, city: true, address: true } },
} as const;

// ── ایدمپوتنسی خروج: ریت‌رای/صف آفلاین با همان clientKey هرگز دوبار خروج نمی‌زند ──
// الگو مشابه checkin: پیش‌بررسی پاسخ ذخیره‌شده + ذخیره پاسخ موفق (فقط موفق‌ها کش می‌شوند
// تا تلاش ناموفق با همان کلید دوباره اجرا شود).
const IDEMPOTENCY_SCANOUT = 'scanout';
const IDEMPOTENCY_MANUAL = 'scanout-manual';

async function findStoredResponse(userId: string | undefined, operation: string, clientKey: string | undefined) {
  if (!userId || !clientKey) return null;
  const existing = await prisma.idempotencyKey.findUnique({
    where: { userId_operation_key: { userId, operation, key: clientKey } },
  });
  return (existing?.responseJson as unknown) ?? null;
}

async function storeResponse(userId: string | undefined, operation: string, clientKey: string | undefined, response: unknown) {
  if (!userId || !clientKey) return;
  try {
    await prisma.idempotencyKey.create({
      data: {
        userId,
        operation,
        key: clientKey,
        responseJson: response as unknown as Prisma.InputJsonValue,
      },
    });
  } catch {
    // مسابقه هم‌زمان با کلید یکسان: برنده قبلاً ذخیره کرده — نادیده بگیر
  }
}

// ── ذخیره پاسخ موفق + برگرداندن همان مقدار ──
// ژنریک است تا literal-بودن `valid: true as const` در استنتاج حفظ شود و
// باریک‌سازی `if (!result.valid)` در کنترلر (با strictNullChecks:false) نشکند.
async function storeAndReturn<T>(userId: string | undefined, operation: string, clientKey: string | undefined, response: T): Promise<T> {
  await storeResponse(userId, operation, clientKey, response);
  return response;
}

// ── ایدمپوتنسی خروج: replay دقیقاً همان شکل success را برمی‌گرداند (literal تایپ‌شده
// inline تا باریک‌سازی `if (!result.valid)` در کنترلر — با strictNullChecks:false — سالم بماند.

interface CartonWithRefs {  id: string;
  productId: string;
  modelId: string | null;
  warehouseId: string;
  status: CartonStatus;
  scannedOutAt: Date | null;
  isIndividual: boolean;
  serialNumber: string | null;
  orderId: string | null;
  createdById: string;
  product: { id: string; name: string; unit: string };
  model: { id: string; name: string; unitsPerBox: number | null; packageType: string | null } | null;
  order: { id: string; customerPhone: string | null; city: string | null; address: string | null } | null;
}

/** اطلاعات هر هدفِ منطبق برای نمایش در پیکر انتخاب (اسکن/خروج دستی) */
type TargetOrderInfo = {
  kind: 'order';
  id: string;
  orderNumber: number;
  city: string | null;
  receiverName: string | null;
  carrier: string | null;
  customerPhone: string | null;
};

type TargetTransferInfo = {
  kind: 'transfer';
  id: string;
  productName: string;
  modelName: string | null;
  quantity: number;
  toWarehouseName: string | null;
};

type TargetInfo = TargetOrderInfo | TargetTransferInfo;

type TargetMatch =
  | { kind: 'order' | 'transfer'; id: string }
  | 'none'
  | { multiple: TargetInfo[] };

/**
 * پیدا کردن هدف فعالِ منطبق (سفارش یا دستور جابه‌جایی/خروج) برای اتصال خروج.
 * ملاک تطابق فقط «محصول + مدل» است؛ سریال/QR در مجوز خروج هیچ نقشی ندارد.
 * سفارش‌ها و دستورهای مدیر با هم سنجیده می‌شوند؛ انباردار باید برای هر خروج مشخص کند
 * برای کدام هدف (سفارش/دستور) است — نه فقط وقتی سفارشی منطبق نبود.
 * برمی‌گرداند: {kind, id} (فقط یک هدف) یا 'none' یا {multiple: [اطلاعات هر هدف]} برای انتخاب صریح توسط انباردار.
 */
async function findSingleMatchingTarget(
  carton: CartonWithRefs,
  warehouseId: string,
): Promise<TargetMatch> {
  // اگر کارتن از قبل به سفارشی متصل است، همان را استفاده کن
  if (carton.orderId) return { kind: 'order', id: carton.orderId };

  // سفارش‌های فعال (PENDING/SHIPPED) همان انبار با قلمِ منطبق
  const orders =
    (await prisma.order.findMany({
      where: {
        warehouseId,
        status: { in: ['PENDING', 'SHIPPED'] },
        items: {
          some: {
            productId: carton.productId,
            modelId: carton.modelId ?? null,
          },
        },
      },
      select: {
        id: true,
        orderNumber: true,
        city: true,
        receiverName: true,
        carrier: true,
        customerPhone: true,
        items: { select: { productId: true, modelId: true, quantity: true } },
      },
    })) ?? [];

  const orderCandidates: TargetOrderInfo[] = [];
  for (const o of orders) {
    const item = o.items.find(
      (i) =>
        i.productId === carton.productId &&
        (i.modelId ?? null) === (carton.modelId ?? null),
    );
    if (!item) continue;
    const attached = await prisma.carton.count({
      where: {
        orderId: o.id,
        productId: carton.productId,
        modelId: carton.modelId,
        scannedOutAt: { not: null },
      },
    });
    if (attached < item.quantity) {
      orderCandidates.push({
        kind: 'order' as const,
        id: o.id,
        orderNumber: o.orderNumber ?? 0,
        city: o.city ?? null,
        receiverName: o.receiverName ?? null,
        carrier: o.carrier ?? null,
        customerPhone: o.customerPhone ?? null,
      });
    }
  }

  // دستور جابه‌جایی/خروج مدیر (دوفازی) — همیشه همراه سفارش‌ها سنجیده می‌شود تا انباردار
  // بتواند خروج را صریحاً به یک دستور متصل کند حتی وقتی سفارشِ منطبق هم وجود دارد
  const transfers =
    (await prisma.transfer.findMany({
      where: {
        fromWarehouseId: warehouseId,
        status: 'PENDING',
        productId: carton.productId,
        modelId: carton.modelId ?? null,
      },
      select: {
        id: true,
        quantity: true,
        product: { select: { name: true } },
        model: { select: { name: true } },
        toWarehouse: { select: { name: true } },
      },
    })) ?? [];

  const transferCandidates: TargetTransferInfo[] = [];
  for (const t of transfers) {
    const executed = await transferExecutedUnits(prisma, t.id);
    const unit = carton.isIndividual ? 1 : carton.model?.unitsPerBox ?? 1;
    if (executed + unit <= t.quantity) {
      transferCandidates.push({
        kind: 'transfer' as const,
        id: t.id,
        productName: t.product?.name ?? '',
        modelName: t.model?.name ?? null,
        quantity: t.quantity,
        toWarehouseName: t.toWarehouse?.name ?? null,
      });
    }
  }

  // سفارش‌ها و دستورها را با هم در نظر بگیر: یک هدف → اتصال خودکار؛ بیش از یک هدف →
  // انتخاب صریح انباردار (پیکر «کدام هدف؟» هر دو گروه را نمایش می‌دهد)
  const targets: TargetInfo[] = [...orderCandidates, ...transferCandidates];
  if (targets.length === 1) {
    const only = targets[0];
    return { kind: only.kind, id: only.id };
  }
  if (targets.length > 1) return { multiple: targets };
  return 'none';
}

/**
 * پیدا کردن هدف فعالِ منطبق برای خروج دستی (بدون QR): محصول + مدل + تعداد.
 * ملاک فقط «محصول + مدل» است؛ ظرفیتِ باقی‌مانده باید حداقل برابرِ تعدادِ درخواستی باشد.
 * سفارش‌ها و دستورهای مدیر با هم سنجیده می‌شوند — انباردار هدف (سفارش/دستور) را انتخاب می‌کند.
 */
async function findSingleManualTarget(
  productId: string,
  modelId: string | null,
  quantity: number,
  warehouseId: string,
): Promise<TargetMatch> {
  // سفارش‌های فعال (PENDING/SHIPPED) همان انبار با قلمِ منطبق
  const orders =
    (await prisma.order.findMany({
      where: {
        warehouseId,
        status: { in: ['PENDING', 'SHIPPED'] },
        items: {
          some: { productId, modelId: modelId ?? null },
        },
      },
      select: {
        id: true,
        orderNumber: true,
        city: true,
        receiverName: true,
        carrier: true,
        customerPhone: true,
        items: { select: { productId: true, modelId: true, quantity: true } },
      },
    })) ?? [];

  const orderCandidates: TargetOrderInfo[] = [];
  for (const o of orders) {
    const item = o.items.find(
      (i) => i.productId === productId && (i.modelId ?? null) === (modelId ?? null),
    );
    if (!item) continue;
    const attached = await prisma.carton.count({
      where: {
        orderId: o.id,
        productId,
        modelId,
        scannedOutAt: { not: null },
      },
    });
    if (attached + quantity <= item.quantity) {
      orderCandidates.push({
        kind: 'order' as const,
        id: o.id,
        orderNumber: o.orderNumber ?? 0,
        city: o.city ?? null,
        receiverName: o.receiverName ?? null,
        carrier: o.carrier ?? null,
        customerPhone: o.customerPhone ?? null,
      });
    }
  }

  // دستور جابه‌جایی/خروج مدیر (دوفازی) — همیشه همراه سفارش‌ها سنجیده می‌شود تا انباردار
  // بتواند خروج را صریحاً به یک دستور متصل کند حتی وقتی سفارشِ منطبق هم وجود دارد
  const transfers =
    (await prisma.transfer.findMany({
      where: {
        fromWarehouseId: warehouseId,
        status: 'PENDING',
        productId,
        modelId: modelId ?? null,
      },
      select: {
        id: true,
        quantity: true,
        product: { select: { name: true } },
        model: { select: { name: true } },
        toWarehouse: { select: { name: true } },
      },
    })) ?? [];

  const transferCandidates: TargetTransferInfo[] = [];
  for (const t of transfers) {
    const executed = await transferExecutedUnits(prisma, t.id);
    if (executed + quantity <= t.quantity) {
      transferCandidates.push({
        kind: 'transfer' as const,
        id: t.id,
        productName: t.product?.name ?? '',
        modelName: t.model?.name ?? null,
        quantity: t.quantity,
        toWarehouseName: t.toWarehouse?.name ?? null,
      });
    }
  }

  // سفارش‌ها و دستورها را با هم در نظر بگیر: یک هدف → اتصال خودکار؛ بیش از یک هدف →
  // انتخاب صریح انباردار (پیکر «کدام هدف؟» هر دو گروه را نمایش می‌دهد)
  const targets: TargetInfo[] = [...orderCandidates, ...transferCandidates];
  if (targets.length === 1) {
    const only = targets[0];
    return { kind: only.kind, id: only.id };
  }
  if (targets.length > 1) return { multiple: targets };
  return 'none';
}

/**
 * راننده‌ای که انباردار برایش تیک زده (به همین انبار متصل است) — مبنای لیست انتخاب راننده.
 */
async function findTickedDriver(
    client: Prisma.TransactionClient | PrismaClient,
    driverId: string,
    warehouseId: string,
) {
    const driver = await client.user.findUnique({
        where: { id: driverId },
        select: { id: true, name: true, phone: true, role: true, isActive: true, deletedAt: true, warehouseId: true },
    });
    if (!driver || driver.role !== 'DRIVER' || !driver.isActive || driver.deletedAt) {
        throw new AppError('راننده یافت نشد', 404);
    }
    if (driver.warehouseId !== warehouseId) {
        throw new AppError('این راننده برای انبار شما تیک نخورده است', 400);
    }
    return driver;
}

/**
 * تعریف «بار» برای راننده: ساخت/به‌روزرسانی رکورد تحویل سفارش با وضعیت IN_TRANSIT.
 * تا قبل از تحویل، انباردار می‌تواند راننده را عوض کند (re-assign).
 */
async function assignDriverToOrder(
    tx: Prisma.TransactionClient,
    orderId: string,
    driverId: string,
    warehouseId: string,
    actorId: string,
): Promise<{ orderId: string; orderNumber: number; driverId: string; driverName: string }> {
    const order = await tx.order.findUnique({
        where: { id: orderId },
        select: {
            id: true, orderNumber: true, warehouseId: true, status: true,
            city: true, receiverName: true,
            delivery: { select: { status: true, driverId: true } },
        },
    });
    if (!order) throw new AppError('سفارش یافت نشد', 404);
    if (order.warehouseId !== warehouseId)
        throw new AppError('این سفارش متعلق به انبار شما نیست', 400);
    if (order.status === 'DELIVERED' || order.status === 'CANCELED')
        throw new AppError('این سفارش وارد مرحلهٔ تحویل شده و قابل تخصیص نیست', 400);
    if (order.delivery?.status === 'DELIVERED')
        throw new AppError('این بار قبلاً تحویل شده و قابل تغییر نیست', 400);

    const driver = await findTickedDriver(tx, driverId, warehouseId);

    // ساخت/به‌روزرسانی رکورد تحویل — وضعیت IN_TRANSIT تا زمان تحویل توسط راننده
    await tx.delivery.upsert({
        where: { orderId },
        create: { orderId, driverId, status: 'IN_TRANSIT' as DeliveryStatus },
        update: { driverId, status: 'IN_TRANSIT' as DeliveryStatus },
    });

    const prevDriverId = order.delivery?.driverId ?? null;
    const isChange = prevDriverId !== null && prevDriverId !== driverId;
    await tx.activityLog.create({
        data: {
            type: 'order_updated',
            label: `سفارش #${order.orderNumber} به راننده «${driver.name}» ${isChange ? 'منتقل' : 'تخصیص'} یافت`,
            orderId,
            userId: actorId,
        },
    });
    await writeAudit(tx, {
        actorId, action: 'order.assign_driver', entity: 'Order', entityId: orderId,
        before: { driverId: prevDriverId }, after: { driverId, status: 'IN_TRANSIT' },
    });

    const warehouse = await tx.warehouse.findUnique({
        where: { id: warehouseId },
        select: { name: true },
    });

    // اگر بار قبلاً به رانندهٔ دیگری تخصیص یافته بود و حالا عوض می‌شود، رانندهٔ قبلی باید
    // همان لحظه بداند بار از او گرفته شده (پنلش پاک می‌شود + اعلان هشدار)
    if (isChange && prevDriverId) {
        await tx.outboxEvent.create({
            data: {
                aggregate: 'order',
                type: 'order:driver:unassigned',
                payload: {
                    orderId,
                    orderNumber: order.orderNumber,
                    driverId: prevDriverId,
                    newDriverId: driver.id,
                    newDriverName: driver.name,
                    warehouseId,
                    warehouseName: warehouse?.name ?? '',
                    city: order.city ?? null,
                    receiverName: order.receiverName ?? null,
                    reassignedAt: new Date().toISOString(),
                },
            },
        });
    }

    await tx.outboxEvent.create({
        data: {
            aggregate: 'order',
            type: 'order:driver:assigned',
            payload: {
                orderId,
                orderNumber: order.orderNumber,
                driverId,
                driverName: driver.name,
                warehouseId,
                warehouseName: warehouse?.name ?? '',
                city: order.city ?? null,
                receiverName: order.receiverName ?? null,
                assignedAt: new Date().toISOString(),
            },
        },
    });

    return { orderId, orderNumber: order.orderNumber, driverId, driverName: driver.name };
}

export const scanOutService = {
  /**
   * خروج کارتن از انبار — به‌صورت اتمی:
   * - کارتن IN_STOCK → SHIPPED (فقط برندهٔ مسابقهٔ هم‌زمان)
   * - اگر orderId داده شود، کارتن به همان سفارش متصل می‌شود (اعتبارسنجی: انبار، وضعیت،
   *   تطابق محصول/مدل با اقلام، سقف تعداد هر قلم) و اولین خروج، سفارش را PENDING → SHIPPED می‌کند
   * - تراکنش OUT + رویداد outbox (تراکنشی)
   * کل عملیات داخل تراکنش Serializable است؛ تعارض با حذف/ویرایش هم‌زمان سفارش → retry خودکار
   */
  scanOut: async (
    input: { qrPayload: string; serialNumber: string; orderId?: string | null; transferId?: string | null; clientKey?: string | null },
    warehouseId: string,
    userId?: string,
  ) => {
    // پاسخ قبلی برای کلید یکسان — ریت‌رای بعد از تایم‌اوت یا فلاش صف آفلاین.
    // نکته تایپی: پاسخ ذخیره‌شده در literal تازه پیچیده می‌شود (به‌جای `as` مستقیم)
    // تا باریک‌سازی `if (!result.valid)` در کنترلر سالم بماند.
    const stored = await findStoredResponse(userId, IDEMPOTENCY_SCANOUT, input.clientKey?.trim() || undefined);
    if (stored) {
      const s = stored as { carton: unknown };
      return {
        valid: true as const,
        carton: s.carton as {
          id: string;
          serialNumber: string | null;
          productName: string;
          modelName: string;
          unit: string;
          packageType: string;
          capacityPerBox: number;
          isIndividualUnit: boolean;
          order: {
            id: string;
            orderNumber: number;
            customerPhone: string | null;
            city: string | null;
            address: string | null;
          } | null;
          transfer: { id: string; toWarehouseId: string | null; toWarehouseName: string | null } | null;
        },
      };
    }

    let carton: CartonWithRefs | null = null;

    if (input.qrPayload) {
      let serialMatch: string | null = null;
      try {
        // فرمت جدید: MA|SN|<serial>|<uuid>|<hmac> — محتوای QR همان سریال است
        serialMatch = verifySerialPayload(input.qrPayload).serial;
      } catch {
        // فرمت قدیمی: MA|<product>|<model>|<capacity>|<uuid>|<hmac>
        try {
          const parsed = verifyPayload(input.qrPayload);
          carton = await prisma.carton.findUnique({
            where: { id: parsed.uuid },
            include: cartonInclude,
          });
        } catch {
          // QR نه با فرمت جدید قابل پارس است نه با فرمت قدیمی — پیام تلاش اول (فرمت جدید)
          // گمراه‌کننده است؛ پیام ثابت بده
          return { valid: false as const, error: 'کد QR معتبر نیست' };
        }
      }
      if (serialMatch !== null) {
        carton = await prisma.carton.findUnique({
          where: { serialNumber: serialMatch },
          include: cartonInclude,
        });
      }
    } else if (input.serialNumber) {
      const q = input.serialNumber.trim();
      carton = await prisma.carton.findFirst({
        where: {
          OR: [{ serialNumber: q }, { qrUuid: q }, { qrUuid: { startsWith: q } }],
        },
        include: cartonInclude,
      });
    }

    if (!carton) return { valid: false as const, error: 'کارتن در سیستم ثبت نشده' };
    if (carton.warehouseId !== warehouseId)
      return { valid: false as const, error: 'این کارتن متعلق به انبار دیگری است' };
    if (carton.scannedOutAt)
      return { valid: false as const, error: 'این کارتن قبلاً خروج داده شده' };
    if (carton.status !== 'IN_STOCK')
      return { valid: false as const, error: `وضعیت کارتن: ${carton.status}` };

    // ── انتخاب صریح: بدون سفارش یا دستور، کارتن اجازهٔ خروج ندارد ──
    let explicitOrderId = input.orderId?.trim() || null;
    let explicitTransferId = input.transferId?.trim() || null;
    if (explicitOrderId && explicitTransferId) {
      return { valid: false as const, error: 'فقط یکی از سفارش یا دستور جابه‌جایی/خروج را انتخاب کنید' };
    }

    // بدون انتخاب صریح: اتصال خودکار. ملاک مجوز خروج فقط تطابق «محصول + مدل» با
    // سفارش/دستور فعال است — سریال/QR فقط کارتن را شناسایی می‌کند و نقشی در مجوز ندارد.
    if (!explicitOrderId && !explicitTransferId) {
      const auto = await findSingleMatchingTarget(carton, warehouseId);
      if (auto === 'none') {
        return { valid: false as const, error: 'این محصول اجازهٔ خروج ندارد — سفارش یا دستور فعالی با همین کالا/مدل یافت نشد' };
      }
      if ('multiple' in auto) {
        // چند هدف فعال — لیست هدف‌های ممکن برای انتخاب صریح انباردار
        return {
          valid: false as const,
          error: 'چند سفارش/دستور فعال برای این کالا/مدل وجود دارد — هدف موردنظر را انتخاب کنید',
          candidates: auto.multiple,
        };
      }
      if (auto.kind === 'order') explicitOrderId = auto.id;
      else explicitTransferId = auto.id;
    }

    const attachOrderId = explicitOrderId;
    let transferContext: { id: string; toWarehouseId: string | null; toWarehouseName: string | null } | null = null;
    let conflicted = false;

    try {
      await runSerializable(async (tx) => {
        // ── شاخهٔ دستور جابه‌جایی/خروج مدیر (دوفازی) ──
        if (explicitTransferId) {
          const transfer = await tx.transfer.findUnique({
            where: { id: explicitTransferId },
            select: {
              id: true, fromWarehouseId: true, toWarehouseId: true,
              productId: true, modelId: true, quantity: true, status: true,
            },
          });
          if (!transfer) throw new AppError('دستور جابه‌جایی/خروج یافت نشد', 404);
          if (transfer.status !== 'PENDING') throw new AppError('این دستور دیگر فعال نیست', 400);
          if (transfer.fromWarehouseId !== warehouseId)
            throw new AppError('این دستور متعلق به انبار شما نیست', 400);
          if (transfer.productId !== carton.productId || (transfer.modelId ?? null) !== (carton.modelId ?? null))
            throw new AppError('این کارتن با کالای دستور همخوانی ندارد', 400);

          const executed = await transferExecutedUnits(tx, transfer.id);
          const unit = carton.isIndividual ? 1 : carton.model?.unitsPerBox ?? 1;
          if (executed + unit > transfer.quantity)
            throw new AppError('سقف مقدار این دستور تکمیل شده است', 400);

          // اجرای اتمی: جابه‌جایی → انتقال به انبار مقصد؛ خروج → EXITED
          const updated = await tx.carton.updateMany({
            where: { id: carton.id, status: 'IN_STOCK', scannedOutAt: null },
            data: transfer.toWarehouseId
              ? {
                  warehouseId: transfer.toWarehouseId,
                  scannedOutAt: new Date(),
                  transferId: transfer.id,
                  orderId: null,
                  version: { increment: 1 },
                }
              : {
                  status: 'EXITED',
                  scannedOutAt: new Date(),
                  transferId: transfer.id,
                  orderId: null,
                  version: { increment: 1 },
                },
          });
          if (updated.count !== 1) {
            conflicted = true;
            return;
          }

          // دفتر تراکنش: OUT از انبار مبدأ (+ IN در مقصد برای جابه‌جایی)
          const productLabel = carton.product.name + (carton.model?.name ? ` (${carton.model.name})` : '');
          await tx.transaction.create({
            data: {
              type: 'OUT',
              productName: productLabel,
              productId: carton.productId,
              quantity: unit,
              warehouseId,
              userId: userId ?? carton.createdById,
            },
          });
          if (transfer.toWarehouseId) {
            await tx.transaction.create({
              data: {
                type: 'IN',
                productName: productLabel,
                productId: carton.productId,
                quantity: unit,
                warehouseId: transfer.toWarehouseId,
                userId: userId ?? carton.createdById,
              },
            });
          }

          const completed = await completeTransferIfDone(tx, transfer.id, executed + unit);
          if (completed && userId) {
            await tx.activityLog.create({
              data: {
                type: transfer.toWarehouseId ? 'product_transfer' : 'product_exit',
                label: `دستور ${transfer.toWarehouseId ? 'جابه‌جایی' : 'خروج'} ${productLabel} تکمیل شد (${transfer.quantity} واحد)`,
                userId,
              },
            });
          }

          const warehouse = await tx.warehouse.findUnique({
            where: { id: warehouseId },
            select: { name: true },
          });
          const dest = transfer.toWarehouseId
            ? await tx.warehouse.findUnique({ where: { id: transfer.toWarehouseId }, select: { name: true } })
            : null;
          transferContext = {
            id: transfer.id,
            toWarehouseId: transfer.toWarehouseId ?? null,
            toWarehouseName: dest?.name ?? null,
          };
          await tx.outboxEvent.create({
            data: {
              aggregate: 'carton',
              type: transfer.toWarehouseId ? 'carton_transferred' : 'carton_exited',
              payload: {
                transferId: transfer.id,
                cartonId: carton.id,
                warehouseId,
                warehouseName: warehouse?.name ?? '',
                destinationWarehouseId: transfer.toWarehouseId ?? null,
                destinationWarehouseName: dest?.name ?? null,
                productName: carton.product.name,
                modelName: carton.model?.name ?? null,
                movedAt: new Date().toISOString(),
                completed,
              },
            },
          });

          // تکمیل کامل سهمیهٔ دستور — یک اعلان تجمیعی برای مدیر و انبارهای مبدأ/مقصد
          if (completed) {
            await tx.outboxEvent.create({
              data: {
                aggregate: 'transfer',
                type: 'transfer:completed',
                payload: {
                  transferId: transfer.id,
                  kind: transfer.toWarehouseId ? 'transfer' : 'exit',
                  fromWarehouseId: warehouseId,
                  fromWarehouseName: warehouse?.name ?? '',
                  toWarehouseId: transfer.toWarehouseId ?? null,
                  toWarehouseName: dest?.name ?? null,
                  productName: carton.product.name,
                  modelName: carton.model?.name ?? null,
                  quantity: transfer.quantity,
                  completedAt: new Date().toISOString(),
                },
              },
            });
          }
          return;
        }

        // اعتبارسنجی اتصال به سفارش — انباردار صریحاً سفارش را انتخاب کرده
        if (explicitOrderId) {
          const order = await tx.order.findUnique({
            where: { id: explicitOrderId },
            select: {
              id: true, warehouseId: true, status: true,
              customerPhone: true, city: true, address: true,
              items: { select: { productId: true, modelId: true, quantity: true } },
            },
          });
          if (!order) throw new AppError('سفارش یافت نشد', 404);
          if (order.warehouseId !== warehouseId)
            throw new AppError('این سفارش متعلق به انبار دیگری است', 400);
          if (order.status === 'DELIVERED' || order.status === 'CANCELED')
            throw new AppError('این سفارش وارد مرحلهٔ تحویل شده و قابل خروج نیست', 400);
          if (carton.orderId && carton.orderId !== order.id)
            throw new AppError('این کارتن به سفارش دیگری اختصاص دارد', 400);

          const item = order.items.find(
            (i) =>
              i.productId === carton.productId &&
              (i.modelId ?? null) === (carton.modelId ?? null),
          );
          if (!item)
            throw new AppError('این کارتن با اقلام سفارش همخوانی ندارد (کالا یا مدل متفاوت است)', 400);

          const attached = await tx.carton.count({
            where: {
              orderId: order.id,
              productId: carton.productId,
              modelId: carton.modelId,
              scannedOutAt: { not: null },
            },
          });
          if (attached >= item.quantity)
            throw new AppError('تعداد کارتن‌های این قلم سفارش تکمیل شده است', 400);
        }

        // انتقال اتمی: فقط کارتنی که هنوز IN_STOCK است می‌تواند برنده‌ی مسابقه‌ی خروج باشد
        const updated = await tx.carton.updateMany({
          where: { id: carton.id, status: 'IN_STOCK', scannedOutAt: null },
          data: {
            status: 'SHIPPED',
            scannedOutAt: new Date(),
            orderId: attachOrderId,
            version: { increment: 1 },
          },
        });
        if (updated.count !== 1) {
          conflicted = true;
          return;
        }

        if (attachOrderId) {
          const flipped = await tx.order.updateMany({
            where: { id: attachOrderId, status: 'PENDING' },
            data: { status: 'SHIPPED', updatedAt: new Date(), version: { increment: 1 } },
          });

          // ثبت در تاریخچه فقط برای اولین خروج از انبار سفارش
          if (flipped.count === 1 && userId) {
            await tx.activityLog.create({
              data: {
                type: 'order_shipped',
                label: `${carton.product.name} — سفارش ${carton.order?.city ?? ''} از انبار خارج شد`,
                orderId: attachOrderId,
                userId,
              },
            });
          }
        }

        // ثبت تراکنش خروج — تاریخچه/آمار OUT و موجودی لِگاسی به این رکورد وابسته است
        await tx.transaction.create({
          data: {
            type: 'OUT',
            productName: carton.product.name + (carton.model?.name ? ` (${carton.model.name})` : ''),
            productId: carton.productId,
            quantity: carton.isIndividual ? 1 : carton.model?.unitsPerBox ?? 1,
            warehouseId,
            userId: userId ?? carton.createdById,
          },
        });

        // رویداد خروجی تراکنشی — دیسپچر به مدیران اطلاع می‌دهد و رویداد ریل‌تایم را می‌فرستد
        const warehouse = await tx.warehouse.findUnique({
          where: { id: warehouseId },
          select: { name: true },
        });
        await tx.outboxEvent.create({
          data: {
            aggregate: attachOrderId ? 'order' : 'carton',
            type: attachOrderId ? 'order_shipped' : 'carton_shipped',
            payload: {
              orderId: attachOrderId,
              cartonId: carton.id,
              warehouseId,
              warehouseName: warehouse?.name ?? '',
              productName: carton.product.name,
              modelName: carton.model?.name ?? null,
              shippedAt: new Date().toISOString(),
            },
          },
        });
      });
    } catch (e) {
      if (e instanceof AppError) {
        return { valid: false as const, error: e.message };
      }
      throw e;
    }

    if (conflicted) {
      return { valid: false as const, error: 'این کارتن قبلاً خروج داده شده' };
    }

    // اطلاعات تازهٔ سفارش برای نمایش در کارت موفقیت موبایل (شمارهٔ سفارش و ...)
    let orderSnapshot: { id: string; orderNumber: number; customerPhone: string | null; city: string | null; address: string | null } | null = null;
    if (attachOrderId) {
      orderSnapshot = await prisma.order.findUnique({
        where: { id: attachOrderId },
        select: { id: true, orderNumber: true, customerPhone: true, city: true, address: true },
      });
    }

    return storeAndReturn(userId, IDEMPOTENCY_SCANOUT, input.clientKey?.trim() || undefined, {
      valid: true as const,
      carton: {
        id: carton.id,
        serialNumber: carton.serialNumber,
        productName: carton.product.name,
        modelName: carton.model?.name ?? '',
        unit: carton.product.unit ?? 'عدد',
        packageType: carton.model?.packageType ?? 'کارتن',
        capacityPerBox: carton.model?.unitsPerBox ?? 1,
        isIndividualUnit: carton.isIndividual,
        order: orderSnapshot
          ? {
              id: orderSnapshot.id,
              orderNumber: orderSnapshot.orderNumber,
              customerPhone: orderSnapshot.customerPhone,
              city: orderSnapshot.city,
              address: orderSnapshot.address,
            }
          : null,
        transfer: transferContext,
      },
    });
  },

  /**
   * تخصیص بار (سفارش) به رانندهٔ تیک‌خورده — بعد از اسکن خروج، انباردار راننده را انتخاب می‌کند.
   * کل عملیات داخل تراکنش Serializable است (تعارض هم‌زمان با تحویل → retry خودکار).
   */
  assignDriver: async (
    input: { orderId: string; driverId: string },
    warehouseId: string,
    actorId: string,
  ): Promise<{ valid: boolean; error?: string; assignment?: { orderId: string; orderNumber: number; driverId: string; driverName: string } }> => {
    try {
      let assignment: { orderId: string; orderNumber: number; driverId: string; driverName: string } | undefined;
      await runSerializable(async (tx) => {
        assignment = await assignDriverToOrder(tx, input.orderId.trim(), input.driverId.trim(), warehouseId, actorId);
      });
      return { valid: true, assignment };
    } catch (e) {
      if (e instanceof AppError) {
        return { valid: false, error: e.message };
      }
      throw e;
    }
  },

  /**
   * خروج دستی (بدون QR) برای محصولاتی که برچسب/QR ندارند.
   * انتخاب محصول + مدل + تعداد → یافتن تنها هدف فعالِ منطبق (سفارش یا دستور خروج/جابه‌جایی
   * مدیر) با ملاک «محصول + مدل» → خروجِ همان تعداد از کارتن‌های IN_STOCKِ منطبق.
   */
  manualExit: async (
    input: {
      productId: string;
      modelId?: string | null;
      quantity: number;
      driverId?: string | null;
      // انتخاب صریح هدف (از پیکر وقتی چند هدف فعال است) — سفارش یا دستور خروج/جابه‌جایی
      orderId?: string | null;
      transferId?: string | null;
      clientKey?: string | null;
    },
    warehouseId: string,
    userId?: string,
  ) => {
    // پاسخ قبلی برای کلید یکسان — ریت‌رای بعد از تایم‌اوت یا فلاش صف آفلاین.
    // (literal تازه برای حفظ باریک‌سازی کنترلر — توضیح بالا)
    const storedManual = await findStoredResponse(userId, IDEMPOTENCY_MANUAL, input.clientKey?.trim() || undefined);
    if (storedManual) {
      const sm = storedManual as { quantity: unknown; carton: unknown };
      return {
        valid: true as const,
        quantity: sm.quantity as number,
        carton: sm.carton as {
          id: string;
          serialNumber: string | null;
          productName: string;
          modelName: string;
          unit: string;
          packageType: string;
          capacityPerBox: number;
          isIndividualUnit: boolean;
          order: {
            id: string;
            orderNumber: number;
            customerPhone: string | null;
            city: string | null;
            address: string | null;
          } | null;
          transfer: { id: string; toWarehouseId: string | null; toWarehouseName: string | null } | null;
          driver: { id: string; name: string } | null;
        },
      };
    }

    const product = await prisma.product.findUnique({
      where: { id: input.productId.trim() },
      select: { id: true, name: true, unit: true, deletedAt: true },
    });
    if (!product || product.deletedAt) {
      return { valid: false as const, error: 'محصول یافت نشد' };
    }

    const modelId = input.modelId?.trim() || null;
    let model: { id: string; name: string; productId: string; deletedAt: Date | null; unitsPerBox: number | null; packageType: string | null } | null = null;
    if (modelId) {
      model = await prisma.productModel.findUnique({ where: { id: modelId } });
      if (!model || model.deletedAt) {
        return { valid: false as const, error: 'مدل یافت نشد' };
      }
      if (model.productId !== product.id) {
        return { valid: false as const, error: 'مدل انتخابی متعلق به این محصول نیست' };
      }
    }

    const quantity = Math.floor(input.quantity);
    if (quantity < 1) {
      return { valid: false as const, error: 'تعداد باید عددی مثبت باشد' };
    }

    const driverId = input.driverId?.trim() || null;
    const explicitOrderId = input.orderId?.trim() || null;
    const explicitTransferId = input.transferId?.trim() || null;
    if (explicitOrderId && explicitTransferId) {
      return { valid: false as const, error: 'فقط یکی از سفارش یا دستور جابه‌جایی/خروج را انتخاب کنید' };
    }
    let driverName: string | null = null;

    // هدف صریحِ انتخاب‌شده توسط انباردار (پیکر) یا پیدا کردن تنها هدف فعالِ منطبق
    let target: TargetMatch;
    if (explicitOrderId || explicitTransferId) {
      target = { kind: explicitOrderId ? 'order' : 'transfer', id: (explicitOrderId ?? explicitTransferId) as string };
    } else {
      target = await findSingleManualTarget(product.id, modelId, quantity, warehouseId);
    }
    if (target === 'none') {
      return { valid: false as const, error: 'این محصول اجازهٔ خروج ندارد — سفارش یا دستور خروج فعالی با همین کالا/مدل یافت نشد' };
    }
    if ('multiple' in target) {
      // چند هدف فعال — لیست هدف‌های ممکن برای انتخاب صریح انباردار
      return {
        valid: false as const,
        error: 'چند سفارش/دستور فعال برای این کالا/مدل وجود دارد — هدف موردنظر را انتخاب کنید',
        candidates: target.multiple,
      };
    }

    // راننده فقط برای خروجِ مطابق سفارش انتخاب می‌شود — نه برای دستور جابه‌جایی/خروج مدیر
    if (driverId && target.kind === 'transfer') {
      return { valid: false as const, error: 'خروج موردنظر دستور جابه‌جایی/خروج مدیر است — راننده فقط برای سفارش انتخاب می‌شود' };
    }

    // اگر راننده انتخاب شده، بررسی شود که تیک‌خوردهٔ همین انبار است (خطای نامعتبر → پاسخ ۴۰۰، نه پرتاب)
    if (driverId) {
      try {
        const driver = await findTickedDriver(prisma, driverId, warehouseId);
        driverName = driver.name;
      } catch (e) {
        if (e instanceof AppError) {
          return { valid: false as const, error: e.message };
        }
        throw e;
      }
    }

    let conflicted = false;
    let completedTransfer = false;
    const productLabel = product.name + (model ? ` (${model.name})` : '');

    try {
      await runSerializable(async (tx) => {
        // موجودی: کارتن‌های IN_STOCKِ منطبق به ترتیب ورود
        const stock = await tx.carton.findMany({
          where: {
            warehouseId,
            productId: product.id,
            modelId: modelId ?? null,
            status: 'IN_STOCK',
            scannedOutAt: null,
          },
          orderBy: { createdAt: 'asc' },
          select: {
            id: true,
            isIndividual: true,
            model: { select: { unitsPerBox: true } },
          },
        });

        // برداشت دقیقِ quantity واحد (تقسیم‌ناپذیر بودن کارتن رعایت می‌شود)
        const picked: string[] = [];
        let taken = 0;
        for (const c of stock) {
          const unit = c.isIndividual ? 1 : (c.model?.unitsPerBox ?? 1);
          if (taken + unit > quantity) {
            throw new AppError('تعداد واردشده با واحد بسته‌بندی کارتن‌ها همخوانی ندارد', 400);
          }
          picked.push(c.id);
          taken += unit;
          if (taken === quantity) break;
        }
        if (taken < quantity) {
          throw new AppError(`موجودی کافی نیست (موجودی: ${taken} از ${quantity})`, 400);
        }

        if (target.kind === 'transfer') {
          const transfer = await tx.transfer.findUnique({
            where: { id: target.id },
            select: {
              id: true, fromWarehouseId: true, toWarehouseId: true,
              productId: true, modelId: true, quantity: true, status: true,
            },
          });
          if (!transfer) throw new AppError('دستور جابه‌جایی/خروج یافت نشد', 404);
          if (transfer.status !== 'PENDING') throw new AppError('این دستور دیگر فعال نیست', 400);
          if (transfer.fromWarehouseId !== warehouseId)
            throw new AppError('این دستور متعلق به انبار شما نیست', 400);
          if (transfer.productId !== product.id || (transfer.modelId ?? null) !== (modelId ?? null))
            throw new AppError('این کالا/مدل با دستور همخوانی ندارد', 400);
          const executed = await transferExecutedUnits(tx, transfer.id);
          if (executed + quantity > transfer.quantity)
            throw new AppError('سقف مقدار این دستور تکمیل شده است', 400);

          const updated = await tx.carton.updateMany({
            where: { id: { in: picked }, status: 'IN_STOCK', scannedOutAt: null },
            data: transfer.toWarehouseId
              ? {
                  warehouseId: transfer.toWarehouseId,
                  scannedOutAt: new Date(),
                  transferId: transfer.id,
                  orderId: null,
                  version: { increment: 1 },
                }
              : {
                  status: 'EXITED',
                  scannedOutAt: new Date(),
                  transferId: transfer.id,
                  orderId: null,
                  version: { increment: 1 },
                },
          });
          if (updated.count !== picked.length) {
            conflicted = true;
            return;
          }

          if (transfer.toWarehouseId) {
            await tx.transaction.create({
              data: { type: 'IN', productName: productLabel, productId: product.id, quantity, warehouseId: transfer.toWarehouseId, userId: userId ?? 'system' },
            });
          }
          completedTransfer = await completeTransferIfDone(tx, transfer.id, executed + quantity);

          // تکمیل کامل سهمیهٔ دستور — یک اعلان تجمیعی برای مدیر و انبارهای مبدأ/مقصد
          if (completedTransfer) {
            const srcName = (await tx.warehouse.findUnique({
              where: { id: warehouseId },
              select: { name: true },
            }))?.name ?? '';
            const dstName = transfer.toWarehouseId
              ? (await tx.warehouse.findUnique({
                  where: { id: transfer.toWarehouseId },
                  select: { name: true },
                }))?.name ?? null
              : null;
            await tx.outboxEvent.create({
              data: {
                aggregate: 'transfer',
                type: 'transfer:completed',
                payload: {
                  transferId: transfer.id,
                  kind: transfer.toWarehouseId ? 'transfer' : 'exit',
                  fromWarehouseId: warehouseId,
                  fromWarehouseName: srcName,
                  toWarehouseId: transfer.toWarehouseId ?? null,
                  toWarehouseName: dstName,
                  productName: product.name,
                  modelName: model?.name ?? null,
                  quantity: transfer.quantity,
                  completedAt: new Date().toISOString(),
                },
              },
            });
          }
        } else if (driverId) {
          // ── سفارش + رانندهٔ انتخاب‌شده: این بار برای همان راننده تعریف می‌شود ──
          const order = await tx.order.findUnique({
            where: { id: target.id },
            select: {
              id: true, warehouseId: true, status: true,
              customerPhone: true, city: true, address: true,
              items: { select: { productId: true, modelId: true, quantity: true } },
            },
          });
          if (!order) throw new AppError('سفارش یافت نشد', 404);
          if (order.warehouseId !== warehouseId)
            throw new AppError('این سفارش متعلق به انبار دیگری است', 400);
          if (order.status === 'DELIVERED' || order.status === 'CANCELED')
            throw new AppError('این سفارش وارد مرحلهٔ تحویل شده و قابل خروج نیست', 400);
          const item = order.items.find(
            (i) => i.productId === product.id && (i.modelId ?? null) === (modelId ?? null),
          );
          if (!item) throw new AppError('این کالا/مدل با اقلام سفارش همخوانی ندارد', 400);
          const attached = await tx.carton.count({
            where: { orderId: order.id, productId: product.id, modelId: modelId ?? null, scannedOutAt: { not: null } },
          });
          if (attached + quantity > item.quantity)
            throw new AppError('تعداد این قلم سفارش تکمیل شده است', 400);

          const updated = await tx.carton.updateMany({
            where: { id: { in: picked }, status: 'IN_STOCK', scannedOutAt: null },
            data: {
              status: 'SHIPPED',
              scannedOutAt: new Date(),
              orderId: order.id,
              version: { increment: 1 },
            },
          });
          if (updated.count !== picked.length) {
            conflicted = true;
            return;
          }

          const flipped = await tx.order.updateMany({
            where: { id: order.id, status: 'PENDING' },
            data: { status: 'SHIPPED', updatedAt: new Date(), version: { increment: 1 } },
          });
          if (flipped.count === 1 && userId) {
            await tx.activityLog.create({
              data: {
                type: 'order_shipped',
                label: `${productLabel} — سفارش ${order.city ?? ''} از انبار خارج شد`,
                orderId: order.id,
                userId,
              },
            });
          }

          // تعریف بار برای راننده — همان upsert تراکنشی (ساخت/تغییر راننده)
          await assignDriverToOrder(tx, order.id, driverId, warehouseId, userId ?? 'system');
        } else {
          // ── سفارش بدون راننده ──
          const order = await tx.order.findUnique({
            where: { id: target.id },
            select: {
              id: true, warehouseId: true, status: true,
              customerPhone: true, city: true, address: true,
              items: { select: { productId: true, modelId: true, quantity: true } },
            },
          });
          if (!order) throw new AppError('سفارش یافت نشد', 404);
          if (order.warehouseId !== warehouseId)
            throw new AppError('این سفارش متعلق به انبار دیگری است', 400);
          if (order.status === 'DELIVERED' || order.status === 'CANCELED')
            throw new AppError('این سفارش وارد مرحلهٔ تحویل شده و قابل خروج نیست', 400);
          const item = order.items.find(
            (i) => i.productId === product.id && (i.modelId ?? null) === (modelId ?? null),
          );
          if (!item) throw new AppError('این کالا/مدل با اقلام سفارش همخوانی ندارد', 400);
          const attached = await tx.carton.count({
            where: { orderId: order.id, productId: product.id, modelId: modelId ?? null, scannedOutAt: { not: null } },
          });
          if (attached + quantity > item.quantity)
            throw new AppError('تعداد این قلم سفارش تکمیل شده است', 400);

          const updated = await tx.carton.updateMany({
            where: { id: { in: picked }, status: 'IN_STOCK', scannedOutAt: null },
            data: {
              status: 'SHIPPED',
              scannedOutAt: new Date(),
              orderId: order.id,
              version: { increment: 1 },
            },
          });
          if (updated.count !== picked.length) {
            conflicted = true;
            return;
          }

          const flipped = await tx.order.updateMany({
            where: { id: order.id, status: 'PENDING' },
            data: { status: 'SHIPPED', updatedAt: new Date(), version: { increment: 1 } },
          });
          if (flipped.count === 1 && userId) {
            await tx.activityLog.create({
              data: {
                type: 'order_shipped',
                label: `${productLabel} — سفارش ${order.city ?? ''} از انبار خارج شد`,
                orderId: order.id,
                userId,
              },
            });
          }
        }

        await tx.transaction.create({
          data: { type: 'OUT', productName: productLabel, productId: product.id, quantity, warehouseId, userId: userId ?? 'system' },
        });
        if (target.kind === 'transfer' && completedTransfer && userId) {
          const tDest = await tx.transfer.findUnique({
            where: { id: target.id },
            select: { toWarehouseId: true },
          });
          await tx.activityLog.create({
            data: {
              type: tDest?.toWarehouseId ? 'product_transfer' : 'product_exit',
              label: `دستور ${tDest?.toWarehouseId ? 'جابه‌جایی' : 'خروج'} ${productLabel} تکمیل شد`,
              userId,
            },
          });
        }
        // نام انبار برای اعلان‌های دقیق به مدیر (پیام خروج دستی)
        const manualWarehouseName = (await tx.warehouse.findUnique({
          where: { id: warehouseId },
          select: { name: true },
        }))?.name ?? '';
        await tx.outboxEvent.create({
          data: {
            aggregate: target.kind === 'order' ? 'order' : 'carton',
            type: target.kind === 'order' ? 'order_shipped' : 'carton_exited',
            payload: {
              orderId: target.kind === 'order' ? target.id : null,
              transferId: target.kind === 'transfer' ? target.id : null,
              warehouseId,
              warehouseName: manualWarehouseName,
              productName: product.name,
              modelName: model?.name ?? null,
              quantity,
              exitedAt: new Date().toISOString(),
              manual: true,
            },
          },
        });
      });
    } catch (e) {
      if (e instanceof AppError) {
        return { valid: false as const, error: e.message };
      }
      throw e;
    }

    if (conflicted) {
      return { valid: false as const, error: 'برخی از واحدها قبلاً خروج داده شده‌اند — دوباره تلاش کنید' };
    }

    // اطلاعات تازهٔ سفارش (شمارهٔ سفارش و ...) برای نمایش در دیالوگ موفقیت موبایل
    let orderSnapshot: { id: string; orderNumber: number; customerPhone: string | null; city: string | null; address: string | null } | null = null;
    if (target.kind === 'order') {
      orderSnapshot = await prisma.order.findUnique({
        where: { id: target.id },
        select: { id: true, orderNumber: true, customerPhone: true, city: true, address: true },
      });
    }

    return storeAndReturn(userId, IDEMPOTENCY_MANUAL, input.clientKey?.trim() || undefined, {
      valid: true as const,
      quantity,
      carton: {
        id: 'manual',
        // تایپ صریح nullها: با strictNullChecks:false استنتاج `null` به any می‌رسد و
        // anyِ تودرتو باریک‌سازی union در کنترلر را می‌شکند
        serialNumber: null as string | null,
        productName: product.name,
        modelName: model?.name ?? '',
        unit: product.unit ?? 'عدد',
        packageType: model?.packageType ?? 'کارتن',
        capacityPerBox: model?.unitsPerBox ?? 1,
        isIndividualUnit: true,
        order: orderSnapshot
          ? {
              id: orderSnapshot.id,
              orderNumber: orderSnapshot.orderNumber,
              customerPhone: orderSnapshot.customerPhone,
              city: orderSnapshot.city,
              address: orderSnapshot.address,
            }
          : null,
        transfer: target.kind === 'transfer'
          ? { id: target.id, toWarehouseId: null as string | null, toWarehouseName: null as string | null }
          : null,
        // راننده‌ای که این بار برایش تعریف شد
        driver: driverId
          ? { id: driverId, name: driverName ?? '' }
          : null,
      },
    });
  },

  //کارتن‌های خروج‌زده‌شده از این انبار
  listShippedCartons: async (warehouseId: string) => {
    return await prisma.carton.findMany({
      where: { warehouseId, status: 'SHIPPED' },
      include: {
        product: { select: { id: true, name: true, unit: true } },
        model: { select: { id: true, name: true, price: true, packageType: true, unitsPerBox: true } },
        order: { select: { id: true, customerPhone: true, city: true } },
      },
      orderBy: { scannedOutAt: 'desc' },
      take: 100,
    });
  },

  //کارتن‌های خروج‌زده‌شده برای یک سفارش خاص (نمایش پیشرفت خروج)
  listOrderCartons: async (orderId: string, warehouseId?: string) => {
    return await prisma.carton.findMany({
      where: {
        orderId,
        status: 'SHIPPED',
        ...(warehouseId ? { warehouseId } : {}),
      },
      include: {
        product: { select: { id: true, name: true, unit: true } },
        model: { select: { id: true, name: true, packageType: true, unitsPerBox: true } },
      },
      orderBy: { scannedOutAt: 'desc' },
      take: 500,
    });
  },
};