import { Request, Response } from 'express';
import { loadingPlanService } from './loadingplan.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const loadingPlanController = {
  getLoadingPlan: asyncHandler(async (req: Request, res: Response) => {
    const warehouseId = req.user!.warehouseId;
    // راننده‌ای که تیکش توسط انباردار برداشته شده → پنل خالی است، نه خطا
    if (!warehouseId) return res.json({ plan: [], hasWarehouse: false });

    const plan = await loadingPlanService.getLoadingPlan(req.user!.id, warehouseId);
    res.json({ ...plan, hasWarehouse: true });

  }),
};