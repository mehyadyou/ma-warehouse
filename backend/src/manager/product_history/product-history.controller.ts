import { Request, Response } from 'express';
import { productHistoryService, ExitTypeFilter } from './product-history.service';
import { asyncHandler } from '../../middleware/asyncHandler';

const str = (v: unknown): string | undefined => {
    const s = typeof v === 'string' ? v.trim() : '';
    return s.length > 0 ? s : undefined;
};
const dateStr = (v: unknown): string | undefined => {
    const s = str(v);
    return s && /^\d{4}-\d{2}-\d{2}$/.test(s) ? s : undefined;
};
const EXIT_TYPES: ExitTypeFilter[] = ['any', 'carton', 'individual', 'none'];

export const productHistoryController = {
    list: asyncHandler(async (req: Request, res: Response) => {
        const exitTypeRaw = str(req.query.exitType) as ExitTypeFilter | undefined;
        const exitType = exitTypeRaw && EXIT_TYPES.includes(exitTypeRaw) ? exitTypeRaw : 'any';
        const result = await productHistoryService.list({
            q: str(req.query.q),
            warehouseId: str(req.query.warehouseId),
            activityDate: dateStr(req.query.activityDate),
            exitType,
            serial: str(req.query.serial),
            customerPhone: str(req.query.customerPhone),
            from: dateStr(req.query.from),
            to: dateStr(req.query.to),
            page: req.query.page !== undefined ? Number(req.query.page) : undefined,
            pageSize: req.query.pageSize !== undefined ? Number(req.query.pageSize) : undefined,
        });
        res.json(result);
    }),

    detail: asyncHandler(async (req: Request, res: Response) => {
        const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
        const result = await productHistoryService.detail(String(id ?? ''), {
            warehouseId: str(req.query.warehouseId),
            modelId: str(req.query.modelId),
            activityDate: dateStr(req.query.activityDate),
        });
        if (!result) {
            res.status(404).json({ error: 'محصول یافت نشد' });
            return;
        }
        res.json(result);
    }),
};
