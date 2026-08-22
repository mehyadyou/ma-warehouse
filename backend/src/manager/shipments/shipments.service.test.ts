import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../utils/prisma', () => ({
    prisma: {
        order: { findMany: vi.fn() },
        warehouse: { findMany: vi.fn() },
    },
}));

import { shipmentsService } from './shipments.service';
import { prisma } from '../../utils/prisma';

beforeEach(() => {
    vi.clearAllMocks();
    (prisma.warehouse.findMany as any).mockResolvedValue([
        { id: 'w1', name: 'انبار مرکزی' },
        { id: 'w2', name: 'انبار غرب' },
    ]);
});

function makeOrder(overrides: Partial<any> & { id: string; warehouseId: string; createdAt: Date }) {
    return {
        status: 'PENDING',
        city: null,
        receiverName: null,
        senderName: null,
        carrier: null,
        createdBy: null,
        items: [],
        ...overrides,
    };
}

describe('shipmentsService.getShipmentsReport', () => {
    it('بدون ارسالی → آمار صفر و لیست خالی', async () => {
        (prisma.order.findMany as any).mockResolvedValue([]);
        const report = await shipmentsService.getShipmentsReport();
        expect(report).toMatchObject({ totalShipments: 0, totalUnits: 0, totalWarehouses: 0 });
        expect(report.lastShipment).toBeNull();
        expect(report.warehouses).toEqual([]);
    });

    it('شمارش ارسالی هر انبار + آخرین ارسالی + مرتب‌سازی روزها', async () => {
        // خروجی mock مثل دیتابیس: مرتب بر اساس createdAt نزولی
        (prisma.order.findMany as any).mockResolvedValue([
            makeOrder({
                id: 'o2',
                warehouseId: 'w1',
                createdAt: new Date('2026-08-18T12:00:00.000Z'),
                items: [{ quantity: 1, model: 'مدل A', product: { name: 'اسپیکر', unit: 'عدد' } }],
            }),
            makeOrder({
                id: 'o1',
                warehouseId: 'w1',
                createdAt: new Date('2026-08-18T10:00:00.000Z'),
                items: [{ quantity: 2, model: null, product: { name: 'اسپیکر', unit: 'عدد' } }],
            }),
            makeOrder({
                id: 'o3',
                warehouseId: 'w2',
                createdAt: new Date('2026-08-17T09:00:00.000Z'),
                items: [{ quantity: 5, model: null, product: { name: 'ماوس', unit: 'عدد' } }],
            }),
        ]);

        const report = await shipmentsService.getShipmentsReport();

        expect(report.totalShipments).toBe(3);
        expect(report.totalUnits).toBe(8);
        expect(report.totalWarehouses).toBe(2);

        // مرتب‌سازی انبارها بر اساس آخرین ارسالی (نزولی)
        expect(report.warehouses.map((w: any) => w.warehouseId)).toEqual(['w1', 'w2']);
        expect(report.warehouses[0]).toMatchObject({
            warehouseId: 'w1',
            warehouseName: 'انبار مرکزی',
            totalCount: 2,
            lastShipmentAt: '2026-08-18T12:00:00.000Z',
        });
        // تاریخچهٔ روزانه: یک روز با دو آیتم
        expect(report.warehouses[0].daily).toHaveLength(1);
        expect(report.warehouses[0].daily[0]).toMatchObject({ date: '2026-08-18', count: 2 });
        expect(report.warehouses[0].daily[0].items[0].orderId).toBe('o2');
        expect(report.warehouses[1].daily[0].items[0].items).toEqual([
            { productName: 'ماوس', quantity: 5, unit: 'عدد' },
        ]);
    });

    it('مدل به نام محصول اضافه می‌شود و واحد خالی به «عدد» برمی‌گردد', async () => {
        (prisma.order.findMany as any).mockResolvedValue([
            makeOrder({
                id: 'o1',
                warehouseId: 'w1',
                createdAt: new Date('2026-08-18T10:00:00.000Z'),
                items: [{ quantity: 3, model: 'مدل X', product: { name: 'هدفون', unit: ' ' } }],
            }),
        ]);

        const report = await shipmentsService.getShipmentsReport();
        expect(report.warehouses[0].daily[0].items[0].items).toEqual([
            { productName: 'هدفون (مدل X)', quantity: 3, unit: 'عدد' },
        ]);
    });

    it('lastShipment = جدیدترین ارسالی با نام انبار و مجموع واحدها', async () => {
        // خروجی mock مثل دیتابیس: مرتب بر اساس createdAt نزولی
        (prisma.order.findMany as any).mockResolvedValue([
            makeOrder({
                id: 'o2',
                warehouseId: 'w2',
                status: 'SHIPPED',
                receiverName: 'رضا',
                city: 'تهران',
                createdAt: new Date('2026-08-18T15:30:00.000Z'),
                createdBy: { name: 'علی' },
                items: [
                    { quantity: 2, model: null, product: { name: 'کالا', unit: 'عدد' } },
                    { quantity: 4, model: null, product: { name: 'کالا ۲', unit: 'بسته' } },
                ],
            }),
            makeOrder({
                id: 'o1',
                warehouseId: 'w1',
                createdAt: new Date('2026-08-17T09:00:00.000Z'),
                items: [{ quantity: 1, model: null, product: { name: 'کالا', unit: 'عدد' } }],
            }),
        ]);

        const report = await shipmentsService.getShipmentsReport();
        expect(report.lastShipment).toMatchObject({
            orderId: 'o2',
            warehouseId: 'w2',
            warehouseName: 'انبار غرب',
            status: 'SHIPPED',
            receiverName: 'رضا',
            city: 'تهران',
            createdByName: 'علی',
            totalUnits: 6,
        });
    });

    it('انبار ناشناخته → نامشخص و ارسالی بدون انبار نادیده گرفته می‌شود', async () => {
        (prisma.order.findMany as any).mockResolvedValue([
            makeOrder({ id: 'o1', warehouseId: 'wX', createdAt: new Date('2026-08-18T10:00:00.000Z'), items: [] }),
            makeOrder({ id: 'o2', warehouseId: null as any, createdAt: new Date('2026-08-18T11:00:00.000Z'), items: [] }),
        ]);

        const report = await shipmentsService.getShipmentsReport();
        expect(report.totalShipments).toBe(2);
        expect(report.warehouses[0].warehouseName).toBe('نامشخص');
    });
});