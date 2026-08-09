-- Soft delete (بایگانی) برای محصول و مدل — هیچ داده‌ای فیزیکی حذف نمی‌شود
ALTER TABLE "Product" ADD COLUMN "deletedAt" TIMESTAMPTZ;
ALTER TABLE "ProductModel" ADD COLUMN "deletedAt" TIMESTAMPTZ;