import { Request, Response } from 'express';
import { searchService } from './search.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const searchController = {
  searchProducts: asyncHandler(async (req: Request, res: Response) => {
    const query = req.query.q as string;
    const results = await searchService.searchProducts(query);
    res.json({ results });

  }),

  searchBySerial: asyncHandler(async (req: Request, res: Response) => {
    const serial = String(req.query.serial ?? '').trim();
    if (!serial) {
      res.status(400).json({ error: 'سریال کالا را وارد کنید' });
      return;
    }
    const carton = await searchService.searchBySerial(serial);
    if (!carton) {
      res.status(404).json({ error: 'کارتنی با این سریال یافت نشد' });
      return;
    }
    res.json({ carton });

  }),

  searchShipments: asyncHandler(async (req: Request, res: Response) => {
    const filters = {
      sender:   String(req.query.sender ?? '').trim(),
      receiver: String(req.query.receiver ?? '').trim(),
      product:  String(req.query.product ?? '').trim(),
      model:    String(req.query.model ?? '').trim(),
    };
    if (!filters.sender && !filters.receiver && !filters.product && !filters.model) {
      res.status(400).json({ error: 'حداقل یکی از فیلدها را وارد کنید' });
      return;
    }
    const orders = await searchService.searchShipments(filters);
    res.json({ orders });

  }),
};