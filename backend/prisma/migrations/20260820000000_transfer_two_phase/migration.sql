-- دستورات جابه‌جایی/خروج دوفازی: وضعیت + ردیابی اجرای کارتن‌ها
CREATE TYPE "TransferStatus" AS ENUM ('PENDING', 'DONE', 'CANCELED');

ALTER TABLE "Transfer" ADD COLUMN "status" "TransferStatus" NOT NULL DEFAULT 'PENDING';
ALTER TABLE "Transfer" ADD COLUMN "completedAt" TIMESTAMP(3);

-- ردیف‌های موجود قبلاً اجرا شده‌اند
UPDATE "Transfer" SET "status" = 'DONE', "completedAt" = "createdAt";

ALTER TABLE "Carton" ADD COLUMN "transferId" TEXT;

CREATE INDEX IF NOT EXISTS "Transfer_status_fromWarehouseId_idx" ON "Transfer"("status", "fromWarehouseId");
CREATE INDEX IF NOT EXISTS "Carton_transferId_idx" ON "Carton"("transferId");

ALTER TABLE "Carton" ADD CONSTRAINT "Carton_transferId_fkey" FOREIGN KEY ("transferId") REFERENCES "Transfer"("id") ON DELETE SET NULL ON UPDATE CASCADE;