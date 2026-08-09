import { Request, Response } from 'express';
import { z } from 'zod';
import { loadingPlanService } from './loadingplan.service';
import { asyncHandler } from '../../middleware/asyncHandler';

const dto = z.object({
  items: z.array(z.object({
    productId: z.string().uuid(),
    modelId:   z.string().uuid(),
    quantity:  z.number().int().positive(),
  })).min(1),
  strategy: z.enum(['FIFO', 'LIFO']).default('FIFO'),
});

export const loadingPlanController = {
  generate: asyncHandler(async (req: Request, res: Response) => {
    const parsed = dto.safeParse(req.body);
    if (!parsed.success) return res.status(422).json({ error: parsed.error.issues[0].message });

    const warehouseId = req.user!.warehouseId;
    if (!warehouseId) return res.status(403).json({ error: 'شما به هیچ انباری متصل نیستید' });

    const result = await loadingPlanService.generate(
      warehouseId, parsed.data.items, parsed.data.strategy,
    );
    res.json(result);

  }),
};