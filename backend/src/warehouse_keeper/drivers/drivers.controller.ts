import { Request, Response } from 'express';
import { driversService } from './drivers.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const driversController = {
  listDrivers: asyncHandler(async (req: Request, res: Response) => {
    const drivers = await driversService.listDrivers(req.user!.warehouseId);
    res.json({ drivers });

  }),

  assignDriver: asyncHandler(async (req: Request, res: Response) => {
    const driverId = req.params.id as string;
    const { assigned } = req.body as { assigned: boolean };
    const myWarehouseId = req.user!.warehouseId!;

    const result = await driversService.assignDriver(
      driverId,
      myWarehouseId,
      assigned,
      req.user!.id,
    );
    res.json({
      message: assigned ? 'راننده به انبار شما متصل شد' : 'راننده از انبار شما جدا شد',
      ...result,
    });
  }),
};