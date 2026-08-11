import { Request, Response } from 'express';
import path from 'path';
import fs from 'fs';
import multer from 'multer';
import { authService } from './auth.service';
import { asyncHandler } from '../middleware/asyncHandler';

// تنظیمات آپلود آواتار
const UPLOAD_DIR = path.join(process.cwd(), 'uploads', 'avatars');
if (!fs.existsSync(UPLOAD_DIR)) {
    fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
    filename: (_req, file, cb) => {
        const ext = path.extname(file.originalname) || '.jpg';
        const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
        cb(null, `${unique}${ext}`);
    },
});

const uploadAvatar = multer({
    storage,
    limits: { fileSize: 2 * 1024 * 1024 },
    fileFilter: (_req, file, cb) => {
        if (!/^image\/(jpeg|png|webp)$/.test(file.mimetype)) {
            cb(new Error('فقط تصاویر JPG, PNG و WEBP مجاز هستند'));
            return;
        }
        cb(null, true);
    },
});

// بررسی magic bytes — mimetype قابل جعل است، محتوای فایل نه
function sniffImage(filePath: string): 'jpg' | 'png' | 'webp' | null {
    const fd = fs.openSync(filePath, 'r');
    try {
        const buf = Buffer.alloc(12);
        fs.readSync(fd, buf, 0, 12, 0);
        if (buf[0] === 0xff && buf[1] === 0xd8) return 'jpg';
        if (buf[0] === 0x89 && buf[1] === 0x50 && buf[2] === 0x4e && buf[3] === 0x47) return 'png';
        if (buf.slice(0, 4).toString() === 'RIFF' && buf.slice(8, 12).toString() === 'WEBP') return 'webp';
        return null;
    } finally {
        fs.closeSync(fd);
    }
}

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