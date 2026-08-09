import { prisma } from '../../utils/prisma';

export const loadingPlanService = {
  generate: async (
    warehouseId: string,
    items: Array<{ productId: string; modelId: string; quantity: number }>,
    strategy: 'FIFO' | 'LIFO',
  ) => {
    const plan: Array<{
      sequence:         number;
      cartonId:         string;
      qrPayload:        string;
      productName:      string;
      modelName:        string;
      isIndividualUnit: boolean;
      unit:             string;
      packageType:      string;
      capacityPerBox:   number;
    }> = [];

    for (const item of items) {
      const rows = await prisma.carton.findMany({
        where:   { warehouseId, productId: item.productId, modelId: item.modelId, status: 'IN_STOCK' },
        orderBy: { createdAt: strategy === 'FIFO' ? 'asc' : 'desc' },
        take:    item.quantity,
        include: {
          product: { select: { name: true, unit: true } },
          model:   { select: { name: true, unitsPerBox: true, packageType: true } },
        },
      });

      rows.forEach((c) =>
        plan.push({
          sequence:         plan.length + 1,
          cartonId:         c.id,
          qrPayload:        c.qrPayload,
          productName:      c.product.name,
          modelName:        c.model?.name ?? '',
          isIndividualUnit: c.isIndividual,
          unit:             c.product.unit ?? 'عدد',
          packageType:      c.model?.packageType ?? 'کارتن',
          capacityPerBox:   c.model?.unitsPerBox ?? 1,
        }),
      );
    }

    return { strategy, total: plan.length, plan };
  },
};