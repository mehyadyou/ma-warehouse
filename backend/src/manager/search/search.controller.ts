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
    const rawStatus = String(req.query.status ?? '').trim();
    const validStatuses = ['pending', 'in_transit', 'delivered', 'other'];
    if (rawStatus && !validStatuses.includes(rawStatus)) {
      res.status(400).json({ error: 'فیلتر وضعیت نامعتبر است' });
      return;
    }
    const filters = {
      sender:   String(req.query.sender ?? '').trim(),
      receiver: String(req.query.receiver ?? '').trim(),
      product:  String(req.query.product ?? '').trim(),
      model:    String(req.query.model ?? '').trim(),
      q:        String(req.query.q ?? '').trim(),
      status:   (rawStatus || undefined) as
        | 'pending'
        | 'in_transit'
        | 'delivered'
        | 'other'
        | undefined,
      page:     req.query.page !== undefined ? Number(req.query.page) : undefined,
      pageSize: req.query.pageSize !== undefined ? Number(req.query.pageSize) : undefined,
    };
    if (!filters.sender && !filters.receiver && !filters.product && !filters.model && !filters.q && !filters.status) {
      res.status(400).json({ error: 'حداقل یک فیلتر جستجو یا وضعیت لازم است' });
      return;
    }
    const result = await searchService.searchShipments(filters);
    res.json(result);

  }),
};