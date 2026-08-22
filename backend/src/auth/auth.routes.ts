import { Router } from 'express';
import { authController } from './auth.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { rateLimit } from '../middleware/rateLimit';
import { loginSchema, createFirstManagerSchema, updateProfileSchema, refreshSchema, logoutSchema, verifyPasswordSchema } from './auth.schema';

const router = Router();

// محدودیت‌ها با env قابل تنظیم (فقط برای تست/staging؛ پیش‌فرض‌ها رفتار production هستند)
const loginRateMax = Number(process.env.LOGIN_RATE_MAX) || 10;
const refreshRateMax = Number(process.env.REFRESH_RATE_MAX) || 30;

// POST /api/auth/create-first-manager — محدودیت: حداکثر ۵ بار در ساعت
router.post('/create-first-manager',
    rateLimit({ windowMs: 60 * 60 * 1000, max: 5, keyPrefix: 'first-manager' }),
    validate(createFirstManagerSchema),
    authController.createFirstManager);

// POST /api/auth/login — محدودیت تلاش: حداکثر ۱۰ بار در ۱۵ دقیقه به ازای هر IP
router.post('/login',
    rateLimit({ windowMs: 15 * 60 * 1000, max: loginRateMax, keyPrefix: 'login' }),
    validate(loginSchema),
    authController.login,
);

// POST /api/auth/refresh — تازه‌سازی نشست با چرخش توکن رفرش
router.post('/refresh',
    rateLimit({ windowMs: 15 * 60 * 1000, max: refreshRateMax, keyPrefix: 'refresh' }),
    validate(refreshSchema),
    authController.refresh,
);

// POST /api/auth/logout — ابطال توکن رفرش
router.post('/logout', authenticate, validate(logoutSchema), authController.logout);

// تأیید رمز اصلی برای قفل‌گشایی برنامه (نیازمند توکن)
router.post('/verify-password', authenticate, validate(verifyPasswordSchema), authController.verifyPassword);

// پروفایل (نیازمند توکن)
router.get('/profile', authenticate, authController.getProfile);
router.put('/profile', authenticate, validate(updateProfileSchema), authController.updateProfile);
router.post('/profile/avatar', authenticate, authController.uploadAvatar);

export const authRoutes = router;