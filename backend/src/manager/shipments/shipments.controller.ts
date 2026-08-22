import { Request, Response } from 'express';
import { shipmentsService } from './shipments.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const shipmentsController = {
    getShipmentsReport: asyncHandler(async (_req: Request, res: Response) => {
        const report = await shipmentsService.getShipmentsReport();
        res.json(report);
    }),
};