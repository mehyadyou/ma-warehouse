import { Request, Response } from 'express';
import path from 'path';
import { appUpdatesService } from './app-updates.service';
import { asyncHandler } from '../middleware/asyncHandler';

export const appUpdatesController = {
    /// GET /api/app/updates/check?currentVersionCode=12&deviceSdkInt=34
    check: asyncHandler(async (req: Request, res: Response) => {
        const current = Number(req.query.currentVersionCode) || 0;
        const deviceSdkInt = req.query.deviceSdkInt ? Number(req.query.deviceSdkInt) : undefined;
        const result = await appUpdatesService.check(current, deviceSdkInt);
        res.json(result);
    }),

    /// GET /api/app/updates/apk/:versionCode — دانلود با توکن (اپ این را با dio می‌گیرد)
    download: asyncHandler(async (req: Request, res: Response) => {
        const versionCode = Number(req.params.versionCode);
        const release = await req.app.locals.prisma.appRelease.findUnique({
            where: { versionCode },
        });
        if (!release || !release.isActive) {
            return res.status(404).json({ error: 'نسخهٔ مورد نظر یافت نشد' });
        }
        // فقط از پوشهٔ مجاز سرو کن — جلوگیری از path traversal
        const safe = path.basename(release.apkUrl);
        const filePath = path.join(process.cwd(), 'uploads', 'apk', safe);
        res.download(filePath, `ma-${release.versionCode}.apk`);
    }),

    list: asyncHandler(async (_req: Request, res: Response) => {
        res.json(await appUpdatesService.list());
    }),

    publish: asyncHandler(async (req: Request, res: Response) => {
        const publisherId = req.user!.id;
        const result = await appUpdatesService.publish(publisherId, {
            ...(req.body as { versionName: string; versionCode: number; changelog: string; isForce?: boolean; minAndroidSdk?: number }),
            tmpPath: (req as any).file.path,
            originalName: (req as any).file.originalname,
        });
        res.status(201).json({ message: 'نسخهٔ جدید منتشر شد', release: result });
    }),

    remove: asyncHandler(async (req: Request, res: Response) => {
        const { id } = req.params as { id: string };
        res.json(await appUpdatesService.delete(id));
    }),
};
