import { Request, Response } from 'express';
import { labelsService } from './labels.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const labelsController = {
  getLabels: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'انباری تعریف نشده' });
    const cartons = await labelsService.getLabels(warehouseId);
    res.json({ cartons });

  }),
};