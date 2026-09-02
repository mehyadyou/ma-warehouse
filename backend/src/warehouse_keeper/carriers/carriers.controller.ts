import { Request, Response } from 'express';
import { carriersService } from './carriers.service';
import { asyncHandler } from '../../middleware/asyncHandler';
import { CreateCarrierInput, UpdateCarrierInput, ReorderCarriersInput } from './carriers.schema';

export const carriersController = {
    list: asyncHandler(async (_req: Request, res: Response) => {
        const carriers = await carriersService.list();
        res.json({ carriers });
    }),

    create: asyncHandler(async (req: Request, res: Response) => {
        const body = req.body as CreateCarrierInput;
        const carrier = await carriersService.create(
            body.name,
            body.phone ?? undefined,
            body.address ?? undefined,
        );
        res.status(201).json({ message: 'باربری با موفقیت ثبت شد', carrier });
    }),

    /// بازچینی صف بارگیری — آرایهٔ مرتب شناسه‌ها از سمت کلاینت (درگ‌انددراپ)
    reorder: asyncHandler(async (req: Request, res: Response) => {
        const body = req.body as ReorderCarriersInput;
        const carriers = await carriersService.reorder(body.ids);
        res.json({ message: 'ترتیب بارگیری به‌روزرسانی شد', carriers });
    }),

    update: asyncHandler(async (req: Request, res: Response) => {
        const body = req.body as UpdateCarrierInput;
        const carrier = await carriersService.update(req.params.id as string, body);
        res.json({ message: 'باربری با موفقیت ویرایش شد', carrier });
    }),

    remove: asyncHandler(async (req: Request, res: Response) => {
        const result = await carriersService.remove(req.params.id as string);
        res.json({ message: 'باربری حذف شد', ...result });
    }),
};