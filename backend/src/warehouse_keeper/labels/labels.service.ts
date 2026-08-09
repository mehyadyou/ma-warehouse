import fs from 'fs';
import path from 'path';
import { prisma } from '../../utils/prisma';

export const labelsService = {
  getLabels: async (warehouseId: string) => {
    const rows = await prisma.carton.findMany({
      where:   { warehouseId },
      orderBy: { createdAt: 'desc' },
      include: {
        product: { select: { name: true, unit: true } },
        model:   { select: { name: true, unitsPerBox: true, packageType: true } },
        order:   { select: { customerPhone: true, city: true, address: true } },
      },
    });
    return rows.map((c) => ({
      id:               c.id,
      qrPayload:        c.qrPayload,
      qrUuid:           c.qrUuid,
      productName:      c.product.name,
      modelName:        c.model?.name ?? '',
      entryType:        c.entryType,
      serialNumber:     c.serialNumber,
      unit:             c.product.unit ?? 'عدد',
      packageType:      c.model?.packageType ?? 'کارتن',
      capacityPerBox:   c.model?.unitsPerBox ?? 1,
      isIndividualUnit: c.isIndividual,
      status:           c.status,
      scannedOutAt:     c.scannedOutAt,
      createdAt:        c.createdAt,
      order:            c.order ?? null,
    }));
  },

  getTemplate: async () => {
    const templatePath = path.join(__dirname, '..', '..', 'config', 'qr-template.json');
    return JSON.parse(fs.readFileSync(templatePath, 'utf-8'));
  },
};