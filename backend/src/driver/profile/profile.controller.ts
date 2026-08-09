import { Request, Response } from 'express';

export const profileController = {
  me: async (req: Request, res: Response) => {
    res.json({
      id: req.user!.id,
      role: req.user!.role,
      warehouseId: req.user!.warehouseId,
      hasWarehouse: !!req.user!.warehouseId,
    });
  },
};