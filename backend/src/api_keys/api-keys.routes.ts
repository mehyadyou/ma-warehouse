import { Router } from 'express';
import { z } from 'zod';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { rateLimit } from '../middleware/rateLimit';
import { asyncHandler } from '../middleware/asyncHandler';
import { apiKeysService, API_SCOPES } from './api-keys.service';

const createSchema = z.object({
    name: z.string().trim().min(2, 'نام کلید حداقل ۲ حرف است').max(80),
    scopes: z.array(z.string()).min(1, 'حداقل یک محدودهٔ دسترسی انتخاب کنید'),
    expiresAt: z.string().datetime({ offset: true }).nullish(),
});

const router = Router();
router.use(authenticate, authorize('MANAGER'));

router.get('/scopes', (_req, res) => {
    res.json({ scopes: API_SCOPES });
});

router.get('/', asyncHandler(async (_req, res) => {
    res.json({ keys: await apiKeysService.list() });
}));

router.post('/',
    rateLimit({ windowMs: 60 * 60 * 1000, max: 30, keyPrefix: 'apikey:create' }),
    validate(createSchema),
    asyncHandler(async (req, res) => {
        const { name, scopes, expiresAt } = req.body as { name: string; scopes: string[]; expiresAt?: string | null };
        const result = await apiKeysService.create(req.user!.id, {
            name,
            scopes,
            expiresAt: expiresAt ? new Date(expiresAt) : null,
        });
        res.status(201).json({ message: 'کلید API ساخته شد — همین یک بار نمایش داده می‌شود', ...result });
    }),
);

router.post('/:id/revoke', asyncHandler(async (req, res) => {
    res.json(await apiKeysService.revoke(String(req.params.id)));
}));

router.post('/:id/restore', asyncHandler(async (req, res) => {
    res.json(await apiKeysService.restore(String(req.params.id)));
}));

router.delete('/:id', asyncHandler(async (req, res) => {
    res.json(await apiKeysService.remove(String(req.params.id)));
}));

export const apiKeysRoutes = router;
