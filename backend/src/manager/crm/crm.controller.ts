import { Request, Response } from 'express';
import { crmService } from './crm.service';
import { asyncHandler } from '../../middleware/asyncHandler';

const num = (v: unknown): number | undefined => {
    if (v === undefined || v === null || v === '') return undefined;
    const n = Number(v);
    return Number.isFinite(n) ? n : undefined;
};

const str = (v: unknown): string | undefined => {
    if (typeof v !== 'string' || !v.trim()) return undefined;
    return v.trim();
};

export const crmController = {
    overview: asyncHandler(async (_req: Request, res: Response) => {
        res.json(await crmService.getOverview());
    }),

    customers: asyncHandler(async (req: Request, res: Response) => {
        res.json(
            await crmService.getCustomers({
                q: str(req.query.q),
                page: num(req.query.page),
                pageSize: num(req.query.pageSize),
            }),
        );
    }),

    customerDetail: asyncHandler(async (req: Request, res: Response) => {
        const phone = String(req.params.phone ?? '').trim();
        if (!phone) {
            res.status(400).json({ error: 'شماره موبایل الزامی است' });
            return;
        }
        res.json(await crmService.getCustomerDetail(decodeURIComponent(phone)));
    }),

    audit: asyncHandler(async (req: Request, res: Response) => {
        res.json(
            await crmService.getAudit({
                actorId: str(req.query.actorId),
                entity: str(req.query.entity),
                action: str(req.query.action),
                from: str(req.query.from),
                to: str(req.query.to),
                page: num(req.query.page),
                pageSize: num(req.query.pageSize),
            }),
        );
    }),

    userActivity: asyncHandler(async (req: Request, res: Response) => {
        res.json(
            await crmService.getUserActivity({
                userId: str(req.query.userId),
                from: str(req.query.from),
                to: str(req.query.to),
                limit: num(req.query.limit),
            }),
        );
    }),

    finance: asyncHandler(async (req: Request, res: Response) => {
        res.json(
            await crmService.getFinance({
                from: str(req.query.from),
                to: str(req.query.to),
                warehouseId: str(req.query.warehouseId),
            }),
        );
    }),

    apiUsage: asyncHandler(async (req: Request, res: Response) => {
        res.json(
            await crmService.getApiUsage({ from: num(req.query.from), to: num(req.query.to) }),
        );
    }),

    health: asyncHandler(async (_req: Request, res: Response) => {
        res.json(await crmService.getHealth());
    }),
};
