-- AlterTable
-- شماره ترتیبی سفارش (نام خودکار «سفارش شماره N») — SERIAL ردیف‌های موجود را هم پر می‌کند
ALTER TABLE "Order" ADD COLUMN "orderNumber" SERIAL NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Order_orderNumber_key" ON "Order"("orderNumber");
