-- AlterTable
ALTER TABLE "Transaction" ADD COLUMN     "productId" TEXT;

-- backfill مرحله ۱: تطبیق دقیق نام
UPDATE "Transaction" t SET "productId" = p.id FROM "Product" p
WHERE t."productId" IS NULL AND t."productName" = p.name;

-- backfill مرحله ۲: تطبیق LIKE با escape کامل (سه‌بار replace: اول \ بعد % بعد _)
UPDATE "Transaction" t SET "productId" = p.id FROM "Product" p
WHERE t."productId" IS NULL
  AND t."productName" LIKE (replace(replace(replace(p.name,'\','\\'),'%','\%'),'_','\_') || ' (%)') ESCAPE '\';

-- CreateIndex
CREATE INDEX "Transaction_productId_idx" ON "Transaction"("productId");

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;
