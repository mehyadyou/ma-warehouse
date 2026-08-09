-- ابطال توکن‌های قبلی با تغییر رمز/نقش/انبار: نسخه‌ی توکن در JWT (claim: ver) چک می‌شود
ALTER TABLE "User" ADD COLUMN "tokenVersion" INTEGER NOT NULL DEFAULT 0;
