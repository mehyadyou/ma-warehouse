-- AlterTable
ALTER TABLE "OrderItem" ADD COLUMN     "modelId" TEXT;

-- CreateIndex
CREATE INDEX "OrderItem_modelId_idx" ON "OrderItem"("modelId");

-- AddForeignKey
ALTER TABLE "OrderItem" ADD CONSTRAINT "OrderItem_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "ProductModel"("id") ON DELETE SET NULL ON UPDATE CASCADE;
