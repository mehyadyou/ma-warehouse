-- ایندکس trgm روی نام مدل محصول — جستجوی `models.some(name ILIKE %q%)` در
-- لیست محصولات و جستجوی سراسری، بدون آن nested-loop روی ۱۰هزار محصول است.
-- (الگوی ایندکس‌های trgm موجود در 20260808120000_enterprise_schema)
CREATE INDEX IF NOT EXISTS "ProductModel_name_trgm_idx"
ON "ProductModel" USING gin ("name" extensions.gin_trgm_ops)
WHERE "deletedAt" IS NULL;
