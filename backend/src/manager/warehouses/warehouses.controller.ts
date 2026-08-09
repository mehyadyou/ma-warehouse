import { Request, Response } from 'express';
import { warehousesService } from './warehouses.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const warehousesController = {
  getAllWarehouses: asyncHandler(async (req: Request, res: Response) => {
    const warehouses = await warehousesService.getAllWarehouses();
    const result = warehouses.map((w: any) => ({
      ...w,
      keeperId: w.users?.[0]?.id || null,
      keeperName: w.users?.[0]?.name || null,
    }));
    res.json({ warehouses: result });

  }),

  createWarehouse: asyncHandler(async (req: Request, res: Response) => {
    const { name, address } = req.body;
    const warehouse = await warehousesService.createWarehouse(name, address);
    res.status(201).json({ message: 'انبار با موفقیت ساخته شد', warehouse });

  }),

  updateWarehouse: asyncHandler(async (req: Request, res: Response) => {
    const { name, address, keeperId } = req.body;
    const warehouse = await warehousesService.updateWarehouse(req.params.id as string, { name, address, keeperId });
    res.json({ message: 'انبار ویرایش شد', warehouse });

  }),

  deleteWarehouse: asyncHandler(async (req: Request, res: Response) => {
    const warehouse = await warehousesService.deleteWarehouse(req.params.id as string, req.user!.id);
    res.json({ message: 'انبار بایگانی شد — سوابق حفظ شد؛ با بازگردانی برمی‌گردد', mode: 'archived', warehouse });

  }),

  restoreWarehouse: asyncHandler(async (req: Request, res: Response) => {
    const warehouse = await warehousesService.restoreWarehouse(req.params.id as string, req.user!.id);
    res.json({ message: 'انبار بازگردانده شد', warehouse });

  }),

  getArchivedWarehouses: asyncHandler(async (req: Request, res: Response) => {
    const warehouses = await warehousesService.getArchivedWarehouses();
    res.json({ warehouses });

  }),

  createWarehouseWithKeeper: asyncHandler(async (req: Request, res: Response) => {
    const { warehouseName, keeperName, keeperPhone, keeperPassword } = req.body;
    const result = await warehousesService.createWarehouseWithKeeper(
      warehouseName, keeperName, keeperPhone, keeperPassword
    );
    res.status(201).json({
      message: 'انبار و انباردار با موفقیت ساخته شدند',
      warehouse: result.warehouse,
      keeper: result.keeper,
    });

  }),

  getTransactionsByDate: asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const date = req.query.date as string;
    const transactions = await warehousesService.getTransactionsByDate(id as string, date);
    res.json({ transactions });

  }),

  getWarehouseDetail: asyncHandler(async (req: Request, res: Response) => {
    const data = await warehousesService.getWarehouseDetail(req.params.id as string);
    res.json(data);

  }),
};