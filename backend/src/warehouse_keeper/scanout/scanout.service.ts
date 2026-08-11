import { prisma } from '../../utils/prisma';
import { verifyPayload, verifySerialPayload } from '../../utils/qr';
import type { CartonStatus } from '@prisma/client';

const cartonInclude = {
  product: { select: { id: true, name: true, unit: true } },
  model: { select: { id: true, name: true, unitsPerBox: true, packageType: true } },
  order: { select: { id: true, customerPhone: true, city: true, address: true } },
} as const;

interface CartonWithRefs {
  id: string;
  productId: string;
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

export const scanOutService = {
  scanOut: async (input: { qrPayload: string; serialNumber: string }, warehouseId: string, userId?: string) => {
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

    let conflicted = false;

    await prisma.$transaction(async (tx) => {
      // انتقال اتمی: فقط کارتنی که هنوز IN_STOCK است می‌تواند برنده‌ی مسابقه‌ی خروج باشد
      const updated = await tx.carton.updateMany({
        where: { id: carton.id, status: 'IN_STOCK', scannedOutAt: null },
        data: { status: 'SHIPPED', scannedOutAt: new Date(), version: { increment: 1 } },
      });
      if (updated.count !== 1) {
        conflicted = true;
        return;
      }

      if (carton.orderId) {
        const flipped = await tx.order.updateMany({
          where: { id: carton.orderId, status: 'PENDING' },
          data: { status: 'SHIPPED', updatedAt: new Date(), version: { increment: 1 } },
        });

        // ثبت در تاریخچه فقط برای اولین خروج از انبار سفارش
        if (flipped.count === 1 && userId) {
          await tx.activityLog.create({
            data: {
              type: 'order_shipped',
              label: `${carton.product.name} — سفارش ${carton.order?.city ?? ''} از انبار خارج شد`,
              orderId: carton.orderId,
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
          aggregate: carton.orderId ? 'order' : 'carton',
          type: carton.orderId ? 'order_shipped' : 'carton_shipped',
          payload: {
            orderId: carton.orderId ?? null,
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
        order: carton.orderId
          ? {
              id: carton.orderId,
              customerPhone: carton.order?.customerPhone,
              city: carton.order?.city,
              address: carton.order?.address,
            }
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
};
