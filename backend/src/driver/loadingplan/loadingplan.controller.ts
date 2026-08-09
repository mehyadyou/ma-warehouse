import { Request, Response } from 'express';
import { loadingPlanService } from './loadingplan.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const loadingPlanController = {
  getLoadingPlan: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'راننده به انباری متصل نیست' });

    const plan = await loadingPlanService.getLoadingPlan(warehouseId);
    res.json(plan);

  }),
};