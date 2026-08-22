-- جابه‌جایی محصول: افزودن وضعیت خروج کارتن + جدول ثبت جابه‌جایی‌ها + انواع لاگ فعالیت
ALTER TYPE "CartonStatus" ADD VALUE IF NOT EXISTS 'EXITED';

CREATE TABLE IF NOT EXISTS "Transfer" (
    "id" TEXT NOT NULL,
    "fromWarehouseId" TEXT NOT NULL,
    "toWarehouseId" TEXT,
    "productId" TEXT NOT NULL,
    "modelId" TEXT,
    "quantity" INTEGER NOT NULL,
    "description" TEXT DEFAULT '',
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Transfer_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "Transfer_fromWarehouseId_createdAt_idx" ON "Transfer"("fromWarehouseId", "createdAt" DESC);
CREATE INDEX IF NOT EXISTS "Transfer_toWarehouseId_createdAt_idx" ON "Transfer"("toWarehouseId", "createdAt" DESC);
CREATE INDEX IF NOT EXISTS "Transfer_productId_idx" ON "Transfer"("productId");

ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_fromWarehouseId_fkey" FOREIGN KEY ("fromWarehouseId") REFERENCES "Warehouse"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_toWarehouseId_fkey" FOREIGN KEY ("toWarehouseId") REFERENCES "Warehouse"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "ProductModel"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'product_transfer';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'product_exit';