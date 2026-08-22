import { Request, Response } from 'express';
import { ordersService } from './orders.service';
import { asyncHandler } from '../../middleware/asyncHandler';
import { CreateOrderInput, UpdateOrderInput, CreateCarrierInput } from './orders.schema';

export const ordersController = {
  createOrder: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateOrderInput;
    const createdById = req.user!.id;
    const order = await ordersService.createOrder(
      body.warehouseId,
      createdById,
      body.items,
      body.shippingMethod,
      body.carrier ?? undefined,
      body.city ?? undefined,
      body.postalCode ?? undefined,
      body.address ?? undefined,
      body.customerPhone ?? undefined,
      body.senderName ?? undefined,
      body.receiverName ?? undefined
    );
    res.status(201).json({ message: 'سفارش با موفقیت ثبت شد', order });

  }),

  updateOrder: asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params as { id: string };
    const body = req.body as UpdateOrderInput;
    const order = await ordersService.updateOrder(id, {
      items: body.items,
      shippingMethod: body.shippingMethod,
      carrier: body.carrier ?? undefined,
      city: body.city ?? undefined,
      postalCode: body.postalCode ?? undefined,
      address: body.address ?? undefined,
      customerPhone: body.customerPhone ?? undefined,
      senderName: body.senderName ?? undefined,
      receiverName: body.receiverName ?? undefined,
      version: body.version,
    });
    res.json({ message: 'سفارش با موفقیت ویرایش شد', order });

  }),

  deleteOrder: asyncHandler(async (req: Request, res: Response) => {
    await ordersService.deleteOrder(req.params.id as string);
    res.json({ message: 'سفارش با موفقیت حذف شد' });

  }),

  listOrders: asyncHandler(async (req: Request, res: Response) => {
    const page = Number(req.query.page ?? 1);
    const pageSize = Number(req.query.pageSize ?? 100);
    const rawStatus = String(req.query.status ?? '').trim();
    const validStatuses = ['pending', 'in_transit', 'delivered', 'other'];
    const status = rawStatus && validStatuses.includes(rawStatus)
      ? (rawStatus as 'pending' | 'in_transit' | 'delivered' | 'other')
      : undefined;
    if (rawStatus && !status) {
      res.status(400).json({ error: 'فیلتر وضعیت نامعتبر است' });
      return;
    }
    const result = await ordersService.listOrders(page, pageSize, status);
    res.json(result);

  }),

  getOrderStock: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = String(req.query.warehouseId ?? '').trim();
    const productIds = String(req.query.productIds ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    if (!warehouseId || productIds.length === 0) {
      res.status(400).json({ error: 'انبار و شناسه‌های محصول الزامی است' });
      return;
    }
    const stock = await ordersService.getOrderStock(warehouseId, productIds);
    if (!stock) {
      res.status(404).json({ error: 'انبار یافت نشد' });
      return;
    }
    res.json({ stock });

  }),

  getCarriers: asyncHandler(async (req: Request, res: Response) => {
    const carriers = await ordersService.getCarriers();
    res.json({ carriers });

  }),

  createCarrier: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateCarrierInput;
    const carrier = await ordersService.createCarrier(body.name, body.priority, body.phone ?? undefined, body.address ?? undefined);
    res.status(201).json({ message: 'باربری ثبت شد', carrier });

  }),
};