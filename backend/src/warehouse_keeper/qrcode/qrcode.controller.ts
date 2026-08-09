import { Request, Response } from 'express';
import { labelsService } from '../labels/labels.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const qrcodeController = {
  getTemplate: asyncHandler(async (req: Request, res: Response) => {
    const template = await labelsService.getTemplate();
    res.json(template);

  }),
};