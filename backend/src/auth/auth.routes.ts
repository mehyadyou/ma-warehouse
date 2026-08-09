import { Router } from 'express';
import { authController } from './auth.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { rateLimit } from '../middleware/rateLimit';
import { loginSchema, createFirstManagerSchema, updateProfileSchema, refreshSchema, logoutSchema } from './auth.schema';

const router = Router();

// POST /api/auth/create-first-manager — محدودیت: حداکثر ۵ بار در ساعت
router.post('/create-first-manager',
    rateLimit({ windowMs: 60 * 60 * 1000, max: 5, keyPrefix: 'first-manager' }),
    validate(createFirstManagerSchema),
    authController.createFirstManager);

// POST /api/auth/login — محدودیت تلاش: حداکثر ۱۰ بار در ۱۵ دقیقه به ازای هر IP
router.post('/login',
    rateLimit({ windowMs: 15 * 60 * 1000, max: 10, keyPrefix: 'login' }),
    validate(loginSchema),
    authController.login,
);

// POST /api/auth/refresh — تازه‌سازی نشست با چرخش توکن رفرش
router.post('/refresh',
    rateLimit({ windowMs: 15 * 60 * 1000, max: 30, keyPrefix: 'refresh' }),
    validate(refreshSchema),
    authController.refresh,
);

// POST /api/auth/logout — ابطال توکن رفرش
router.post('/logout', authenticate, validate(logoutSchema), authController.logout);

// پروفایل (نیازمند توکن)
router.get('/profile', authenticate, authController.getProfile);
router.put('/profile', authenticate, validate(updateProfileSchema), authController.updateProfile);
router.post('/profile/avatar', authenticate, authController.uploadAvatar);

export const authRoutes = router;