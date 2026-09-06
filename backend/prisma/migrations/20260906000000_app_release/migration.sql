-- انتشار نسخهٔ جدید اپلیکیشن موبایل — آپدیت از راه دور (self-hosted OTA installer)
CREATE TABLE "AppRelease" (
    "id" TEXT NOT NULL,
    "versionName" TEXT NOT NULL,
    "versionCode" INTEGER NOT NULL,
    "changelog" TEXT NOT NULL,
    "isForce" BOOLEAN NOT NULL DEFAULT false,
    "apkUrl" TEXT NOT NULL,
    "apkSizeBytes" INTEGER NOT NULL,
    "apkSha256" TEXT NOT NULL,
    "minAndroidSdk" INTEGER NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "publishedById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AppRelease_pkey" PRIMARY KEY ("id")
);

-- انتشاردهنده باید کاربر موجود باشد (مدیر)
ALTER TABLE "AppRelease" ADD CONSTRAINT "AppRelease_publishedById_fkey" FOREIGN KEY ("publishedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- نسخهٔ تکراری منتشر نشود
CREATE UNIQUE INDEX "AppRelease_versionCode_key" ON "AppRelease"("versionCode");

-- ایندکس بررسی بروزرسانی: آخرین نسخهٔ فعال
CREATE INDEX "AppRelease_isActive_versionCode_desc_idx" ON "AppRelease"("isActive", "versionCode" DESC);
