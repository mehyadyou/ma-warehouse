import { prisma } from '../../utils/prisma';
import fs from 'fs';
import path from 'path';

export const loadingPlanService = {
  getLoadingPlan: async (warehouseId: string) => {
    const carriers: any[] = JSON.parse(
      fs.readFileSync(path.join(__dirname, '..', '..', 'config', 'carriers.json'), 'utf-8')
    );

    const orders = await prisma.order.findMany({
      where: { warehouseId, status: 'SHIPPED' },
      include: {
        items: {
          include: { product: { select: { name: true } } },
        },
        cartons: {
          where: { status: 'SHIPPED' },
          include: {
            product: { select: { name: true, unit: true } },
            model: { select: { name: true, unitsPerBox: true, packageType: true } },
          },
        },
      },
    });

    const getPriority = (carrierName: string) => {
      const found = carriers.find(c => c.name === carrierName);
      return found ? found.priority : 99;
    };

    const sorted = orders.sort((a, b) => getPriority(a.carrier || '') - getPriority(b.carrier || ''));

    let sequence = 0;
    const plan = sorted.map(order => ({
      sequence: ++sequence,
      orderId: order.id,
      carrier: order.carrier || 'نامشخص',
      priority: getPriority(order.carrier || ''),
      city: order.city,
      postalCode: order.postalCode,
      address: order.address,
      customerPhone: order.customerPhone,
      senderName: order.senderName,
      receiverName: order.receiverName,
      totalCartons: order.cartons.length,
      cartons: order.cartons.map(c => ({
        id: c.id,
        qrUuid: c.qrUuid,
        productName: c.product.name,
        modelName: c.model?.name || '',
        unit: c.product.unit || 'عدد',
        packageType: c.model?.packageType || 'کارتن',
        capacityPerBox: c.model?.unitsPerBox || 1,
        isIndividual: c.isIndividual,
      })),
      items: order.items.map(i => ({
        productName: i.product.name,
        quantity: i.quantity,
        model: i.model,
      })),
    }));

    return { totalOrders: plan.length, plan };
  },
};