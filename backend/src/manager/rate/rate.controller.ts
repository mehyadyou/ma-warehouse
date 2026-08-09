import { Request, Response } from 'express';
import { rateService } from './rate.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const rateController = {
  getDollarRate: asyncHandler(async (req: Request, res: Response) => {
    const rate = await rateService.getDollarRate();
    res.json({ rate });

  }),
};