import { Request, Response } from 'express';
import { asyncHandler } from '../../middleware/asyncHandler';
import { CreateTransferInput } from './transfers.schema';
import { transfersService } from './transfers.service';

export const transfersController = {
    createTransfer: asyncHandler(async (req: Request, res: Response) => {
        const body = req.body as CreateTransferInput;
        const transfer = await transfersService.createTransfer(
            {
                fromWarehouseId: body.fromWarehouseId,
                toWarehouseId: body.toWarehouseId ?? null,
                productId: body.productId,
                modelId: body.modelId ?? null,
                quantity: body.quantity,
                description: body.description ?? '',
            },
            req.user!.id,
        );
        res.status(201).json({
            message: transfer.toWarehouseId
                ? 'جابه‌جایی با موفقیت ثبت شد'
                : 'خروج کالا با موفقیت ثبت شد',
            transfer,
        });
    }),

    listTransfers: asyncHandler(async (req: Request, res: Response) => {
        const rawLimit = Number(req.query.limit ?? 20);
        const limit = Number.isFinite(rawLimit) ? rawLimit : 20;
        const transfers = await transfersService.listTransfers(limit);
        res.json({ transfers });
    }),

    cancelTransfer: asyncHandler(async (req: Request, res: Response) => {
        const { id } = req.params as { id: string };
        await transfersService.cancelTransfer(id, req.user!.id);
        res.json({ message: 'دستور با موفقیت لغو شد' });
    }),
};