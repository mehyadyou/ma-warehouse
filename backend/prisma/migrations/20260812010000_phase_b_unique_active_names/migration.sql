-- نام‌های فعال محصول و انبار منحصربه‌فرد — امنیت race در برابر ساخت همزمان همنام
-- (محصول/انبار بایگانیشده می‌تواند همنام داشته باشد؛ فقط فعال‌ها یکتا)
CREATE UNIQUE INDEX "Product_name_active_key" ON "Product"("name") WHERE "deletedAt" IS NULL;
CREATE UNIQUE INDEX "Warehouse_name_active_key" ON "Warehouse"("name") WHERE "deletedAt" IS NULL;