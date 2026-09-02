import path from 'path';
import fs from 'fs';
import multer from 'multer';

/// بررسی magic bytes — mimetype قابل جعل است، محتوای فایل نه
export function sniffImage(filePath: string): 'jpg' | 'png' | 'webp' | null {
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

/// ساخت middleware آپلود عکس (آواتار، بیجک و...) — ذخیره روی دیسک با نام یکتا
export function createImageUpload(uploadDirName: string, maxMb = 2) {
    const UPLOAD_DIR = path.join(process.cwd(), 'uploads', uploadDirName);
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

    return multer({
        storage,
        limits: { fileSize: maxMb * 1024 * 1024 },
        fileFilter: (_req, file, cb) => {
            if (!/^image\/(jpeg|png|webp)$/.test(file.mimetype)) {
                cb(new Error('فقط تصاویر JPG, PNG و WEBP مجاز هستند'));
                return;
            }
            cb(null, true);
        },
    });
}