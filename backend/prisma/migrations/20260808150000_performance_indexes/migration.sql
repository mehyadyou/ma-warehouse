-- ایندکس‌های کارایی فاز ۴
-- FK های بدون ایندکس + مرتب‌سازی createdAt برای لیست‌ها + trgm برای join نام محصول
SET search_path = public, extensions;
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION ma_migrator;

CREATE INDEX IF NOT EXISTS "Delivery_driverId_idx" ON "Delivery"("driverId");

CREATE INDEX IF NOT EXISTS "Order_createdById_idx" ON "Order"("createdById");

CREATE INDEX IF NOT EXISTS "Order_createdAt_idx" ON "Order"("createdAt" DESC);

CREATE INDEX IF NOT EXISTS "OrderItem_orderId_idx" ON "OrderItem"("orderId");

CREATE INDEX IF NOT EXISTS "OrderItem_productId_idx" ON "OrderItem"("productId");

CREATE INDEX IF NOT EXISTS "Transaction_productName_idx" ON "Transaction" USING GIN ("productName" extensions.gin_trgm_ops);

-- بازنویسی با شکل متعارف (یکسان‌سازی متن ایندکس برای diff های بعدی)
DROP INDEX IF EXISTS "Product_name_trgm_idx";
CREATE INDEX IF NOT EXISTS "Product_name_trgm_idx" ON "Product" USING GIN ("name" extensions.gin_trgm_ops) WHERE ("deletedAt" IS NULL);

DROP INDEX IF EXISTS "Warehouse_name_trgm_idx";
CREATE INDEX IF NOT EXISTS "Warehouse_name_trgm_idx" ON "Warehouse" USING GIN ("name" extensions.gin_trgm_ops);
