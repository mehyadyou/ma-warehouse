import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { appUpdatesController } from './app-updates.controller';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { rateLimit } from '../middleware/rateLimit';
import { publishReleaseSchema } from './app-updates.schema';
import { appUpdatesService } from './app-updates.service';

// APK ها موقتاً در tmp آپلود و بعد از اعتبارسنجی به uploads/apk منتقل می‌شوند
const TMP_DIR = path.join(process.cwd(), 'uploads', 'tmp');
if (!fs.existsSync(TMP_DIR)) fs.mkdirSync(TMP_DIR, { recursive: true });

const uploadApk = multer({
    dest: TMP_DIR,
    limits: { fileSize: appUpdatesService.MAX_APK_MB * 1024 * 1024 },
    fileFilter: (_req, file, cb) => {
        // APK فایل zip است؛ mimetype ممکن است application/vnd.android.package-archive باشد یا octet-stream
        const ok = /android.*(package|archive)|octet-stream|application\/zip/i.test(file.mimetype) || file.originalname.toLowerCase().endsWith('.apk');
        if (!ok) {
            cb(new Error('فقط فایل APK مجاز است'));
            return;
        }
        cb(null, true);
    },
});

const router = Router();

// ─── عمومی (بدون احراز هویت) — چک بروزرسانی قبل از لاگین هم باید کار کند ───
router.get('/check',
    rateLimit({ windowMs: 60_000, max: 30, keyPrefix: 'upd:chk' }),
    appUpdatesController.check,
);

// ─── احراز هویت‌دار: دانلود APK (توکن موبایل خودش را می‌فرستد) ───
router.get('/apk/:versionCode',
    authenticate,
    rateLimit({ windowMs: 60_000, max: 10, keyPrefix: 'upd:apk' }),
    appUpdatesController.download,
);

// ─── فقط مدیر: انتشار/مدیریت نسخه‌ها ───
router.use(authenticate, authorize('MANAGER'));

router.get('/', appUpdatesController.list);
router.post('/',
    rateLimit({ windowMs: 60 * 60 * 1000, max: 20, keyPrefix: 'upd:pub' }),
    uploadApk.single('apk'),
    validate(publishReleaseSchema),
    appUpdatesController.publish,
);
router.delete('/:id', appUpdatesController.remove);

export const appUpdatesRoutes = router;
