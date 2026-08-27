-- AlterTable
ALTER TABLE "Carton" ADD COLUMN "printedAt" TIMESTAMP(3);

-- CreateIndex
CREATE INDEX "Carton_printedAt_idx" ON "Carton"("printedAt");
