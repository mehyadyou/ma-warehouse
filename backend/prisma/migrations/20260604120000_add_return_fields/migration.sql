-- AlterTable
ALTER TABLE "Carton"
ADD COLUMN "entryType" TEXT NOT NULL DEFAULT 'NEW',
ADD COLUMN "serialNumber" TEXT;

-- CreateIndex
CREATE INDEX "Carton_entryType_idx" ON "Carton"("entryType");

-- CreateIndex
CREATE UNIQUE INDEX "Carton_serialNumber_key" ON "Carton"("serialNumber");
