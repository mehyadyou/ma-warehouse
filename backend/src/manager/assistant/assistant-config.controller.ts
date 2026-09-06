import { Request, Response } from 'express';
import { asyncHandler } from '../../middleware/asyncHandler';
import { AssistantConfigInput } from './assistant-config.service';
import { assistantConfigService, testAssistantConnection } from './assistant-config.service';

export const assistantConfigController = {
    /** پیکربندی فعلی — بدون کلید کامل، فقط tail آن */
    get: asyncHandler(async (_req: Request, res: Response) => {
        const config = await assistantConfigService.getPublic();
        res.json({ config });
    }),

    /** ذخیرهٔ پیکربندی مدل در دیتابیس */
    update: asyncHandler(async (req: Request, res: Response) => {
        const body = req.body as AssistantConfigInput;
        await assistantConfigService.save(body);
        const config = await assistantConfigService.getPublic();
        res.json({ config });
    }),

    /** حذف ردیف اختصاصی → بازگشت به env/پیش‌فرض */
    reset: asyncHandler(async (_req: Request, res: Response) => {
        await assistantConfigService.reset();
        const config = await assistantConfigService.getPublic();
        res.json({ config });
    }),

    /** تست اتصال به مدل با مقادیر داده‌شده (یا فعلی) — بدون ذخیره */
    test: asyncHandler(async (req: Request, res: Response) => {
        const body = (req.body ?? {}) as AssistantConfigInput;
        const result = await testAssistantConnection(body);
        res.json(result);
    }),
};
