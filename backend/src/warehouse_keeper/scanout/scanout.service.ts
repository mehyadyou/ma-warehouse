import { prisma } from '../../utils/prisma';
import { verifyPayload, verifySerialPayload } from '../../utils/qr';
import { runSerializable } from '../../utils/serializableTx';
import { AppError } from '../../common/exceptions/AppError';
import { transferExecutedUnits, completeTransferIfDone } from '../../manager/transfers/transfers.service';
import type { CartonStatus } from '@prisma/client';

const cartonInclude = {
  product: { select: { id: true, name: true, unit: true } },
  model: { select: { id: true, name: true, unitsPerBox: true, packageType: true } },
  order: { select: { id: true, customerPhone: true, city: true, address: true } },
} as const;

interface CartonWithRefs {
  id: string;
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

/**
 * پیدا کردن تنها هدف فعالِ منطبق (سفارش یا دستور جابه‌جایی/خروج) برای اتصال خودکار خروج.
 * ملاک تطابق فقط «محصول + مدل» است؛ سریال/QR در مجوز خروج هیچ نقشی ندارد.
 * برمی‌گرداند: {kind, id} یا 'none' (هیچ) یا 'multiple' (بیش از یکی — انتخاب صریح لازم است).
 */
async function findSingleMatchingTarget(
  carton: CartonWithRefs,
  warehouseId: string,
): Promise<{ kind: 'order' | 'transfer'; id: string } | 'none' | 'multiple'> {
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
        items: { select: { productId: true, modelId: true, quantity: true } },
      },
    })) ?? [];

  const orderIds: string[] = [];
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
    if (attached < item.quantity) orderIds.push(o.id);
  }

  if (orderIds.length === 1) return { kind: 'order', id: orderIds[0] };
  if (orderIds.length > 1) return 'multiple';

  // دستور جابه‌جایی/خروج مدیر (دوفازی) — فقط وقتی سفارشی منطبق نبود
  const transfers =
    (await prisma.transfer.findMany({
      where: {
        fromWarehouseId: warehouseId,
        status: 'PENDING',
        productId: carton.productId,
        modelId: carton.modelId ?? null,
      },
      select: { id: true, quantity: true },
    })) ?? [];

  const transferIds: string[] = [];
  for (const t of transfers) {
    const executed = await transferExecutedUnits(prisma, t.id);
    const unit = carton.isIndividual ? 1 : carton.model?.unitsPerBox ?? 1;
    if (executed + unit <= t.quantity) transferIds.push(t.id);
  }

  if (transferIds.length === 1) return { kind: 'transfer', id: transferIds[0] };
  if (transferIds.length > 1) return 'multiple';
  return 'none';
}

/**
 * پیدا کردن تنها هدف فعالِ منطبق برای خروج دستی (بدون QR): محصول + مدل + تعداد.
 * ملاک فقط «محصول + مدل» است؛ ظرفیتِ باقی‌مانده باید حداقل برابرِ تعدادِ درخواستی باشد.
 */
async function findSingleManualTarget(
  productId: string,
  modelId: string | null,
  quantity: number,
  warehouseId: string,
): Promise<{ kind: 'order' | 'transfer'; id: string } | 'none' | 'multiple'> {
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
        items: { select: { productId: true, modelId: true, quantity: true } },
      },
    })) ?? [];

  const orderIds: string[] = [];
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
    if (attached + quantity <= item.quantity) orderIds.push(o.id);
  }

  if (orderIds.length === 1) return { kind: 'order', id: orderIds[0] };
  if (orderIds.length > 1) return 'multiple';

  // دستور جابه‌جایی/خروج مدیر (دوفازی) — فقط وقتی سفارشی منطبق نبود
  const transfers =
    (await prisma.transfer.findMany({
      where: {
        fromWarehouseId: warehouseId,
        status: 'PENDING',
        productId,
        modelId: modelId ?? null,
      },
      select: { id: true, quantity: true },
    })) ?? [];

  const transferIds: string[] = [];
  for (const t of transfers) {
    const executed = await transferExecutedUnits(prisma, t.id);
    if (executed + quantity <= t.quantity) transferIds.push(t.id);
  }

  if (transferIds.length === 1) return { kind: 'transfer', id: transferIds[0] };
  if (transferIds.length > 1) return 'multiple';
  return 'none';
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
    input: { qrPayload: string; serialNumber: string; orderId?: string | null; transferId?: string | null },
    warehouseId: string,
    userId?: string,
  ) => {
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
      if (auto === 'multiple') {
        return { valid: false as const, error: 'چند سفارش/دستور فعال برای این کالا/مدل وجود دارد — از داخل سفارش یا دستور موردنظر اسکن کنید' };
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

    return {
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
        order: attachOrderId
          ? {
              id: attachOrderId,
              customerPhone: carton.order?.customerPhone,
              city: carton.order?.city,
              address: carton.order?.address,
            }
          : null,
        transfer: transferContext,
      },
    };
  },

  /**
   * خروج دستی (بدون QR) برای محصولاتی که برچسب/QR ندارند.
   * انتخاب محصول + مدل + تعداد → یافتن تنها هدف فعالِ منطبق (سفارش یا دستور خروج/جابه‌جایی
   * مدیر) با ملاک «محصول + مدل» → خروجِ همان تعداد از کارتن‌های IN_STOCKِ منطبق.
   */
  manualExit: async (
    input: { productId: string; modelId?: string | null; quantity: number },
    warehouseId: string,
    userId?: string,
  ) => {
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

    // پیدا کردن تنها هدف فعالِ منطبق (ملاک: محصول + مدل)
    const target = await findSingleManualTarget(product.id, modelId, quantity, warehouseId);
    if (target === 'none') {
      return { valid: false as const, error: 'این محصول اجازهٔ خروج ندارد — سفارش یا دستور خروج فعالی با همین کالا/مدل یافت نشد' };
    }
    if (target === 'multiple') {
      return { valid: false as const, error: 'چند سفارش/دستور فعال برای این کالا/مدل وجود دارد — از داخل سفارش یا دستور موردنظر اقدام کنید' };
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
        } else {
          // ── سفارش ──
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
        await tx.outboxEvent.create({
          data: {
            aggregate: target.kind === 'order' ? 'order' : 'carton',
            type: target.kind === 'order' ? 'order_shipped' : 'carton_exited',
            payload: {
              orderId: target.kind === 'order' ? target.id : null,
              transferId: target.kind === 'transfer' ? target.id : null,
              warehouseId,
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

    return {
      valid: true as const,
      quantity,
      carton: {
        id: 'manual',
        serialNumber: null,
        productName: product.name,
        modelName: model?.name ?? '',
        unit: product.unit ?? 'عدد',
        packageType: model?.packageType ?? 'کارتن',
        capacityPerBox: model?.unitsPerBox ?? 1,
        isIndividualUnit: true,
        order: target.kind === 'order'
          ? { id: target.id, customerPhone: null, city: null, address: null }
          : null,
        transfer: target.kind === 'transfer'
          ? { id: target.id, toWarehouseId: null, toWarehouseName: null }
          : null,
      },
    };
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