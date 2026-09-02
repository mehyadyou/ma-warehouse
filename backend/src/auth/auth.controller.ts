import { Request, Response } from 'express';
import path from 'path';
import fs from 'fs';
import { authService } from './auth.service';
import { asyncHandler } from '../middleware/asyncHandler';
import { createImageUpload, sniffImage } from '../utils/imageUpload';

// تنظیمات آپلود آواتار
const uploadAvatar = createImageUpload('avatars', 2);

export const authController = {
    // ساخت اولین مدیر
    createFirstManager: asyncHandler(async (req: Request, res: Response) => {
        const { name, phone, password } = req.body;
        const manager = await authService.createFirstManager(name, phone, password);
        res.status(201).json({ message: 'مدیر با موفقیت ساخته شد', manager });

    }),

    // ورود کاربر
    login: asyncHandler(async (req: Request, res: Response) => {
        const { phone, password } = req.body;
        const result = await authService.login(phone, password);
        res.json({ message: 'ورود موفق', ...result });

    }),

    // تازه‌سازی نشست (چرخش توکن رفرش)
    refresh: asyncHandler(async (req: Request, res: Response) => {
        const { refreshToken } = req.body;
        const result = await authService.refresh(refreshToken);
        res.json({ message: 'نشست تازه شد', ...result });

    }),

    // خروج — ابطال توکن رفرش
    logout: asyncHandler(async (req: Request, res: Response) => {
        const { refreshToken } = req.body;
        await authService.logout(refreshToken);
        res.json({ message: 'خروج موفق' });

    }),

    // پروفایل کاربر جاری
    getProfile: asyncHandler(async (req: Request, res: Response) => {
        const profile = await authService.getProfile(req.user!.id);
        res.json({ profile });

    }),

    // تأیید رمز اصلی برای قفل‌گشایی برنامه (نیازمند توکن)
    verifyPassword: asyncHandler(async (req: Request, res: Response) => {
        const { password } = req.body;
        const result = await authService.verifyPassword(req.user!.id, password);
        res.json(result);

    }),

    // ویرایش پروفایل
    updateProfile: asyncHandler(async (req: Request, res: Response) => {
        const { name, phone, password } = req.body;
        const profile = await authService.updateProfile(req.user!.id, { name, phone, password });
        res.json({ message: 'پروفایل با موفقیت ویرایش شد', profile });

    }),

    // آپلود آواتار
    uploadAvatar: (req: Request, res: Response) => {
        uploadAvatar.single('avatar')(req, res, async (err: any) => {
            if (err) {
                res.status(400).json({ error: err.message || 'خطا در آپلود تصویر' });
                return;
            }
            if (!req.file) {
                res.status(400).json({ error: 'فایلی ارسال نشده است' });
                return;
            }

            // اعتبارسنجی magic bytes — محتوای واقعی فایل باید تصویر باشد
            if (!sniffImage(req.file.path)) {
                fs.unlink(req.file.path, () => {});
                res.status(400).json({ error: 'فایل ارسالی تصویر معتبر نیست (JPG, PNG یا WEBP)' });
                return;
            }

            try {
                const avatarUrl = `/uploads/avatars/${req.file.filename}`;

                // حذف آواتار قبلی (اگر روی هارد ذخیره شده باشد)
                const prev = await authService.getProfile(req.user!.id);
                if (prev.avatarUrl?.startsWith('/uploads/')) {
                    const oldPath = path.join(process.cwd(), prev.avatarUrl);
                    fs.unlink(oldPath, () => {});
                }

                const profile = await authService.updateAvatar(req.user!.id, avatarUrl);
                res.json({ message: 'عکس پروفایل با موفقیت تغییر کرد', profile });
            } catch (error: any) {
                res.status(400).json({ error: error.message });
            }
        });
    },
};