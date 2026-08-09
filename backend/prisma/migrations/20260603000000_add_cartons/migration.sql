-- AlterTable: ProductModel - add package metadata
ALTER TABLE "ProductModel" ADD COLUMN "packageType" TEXT;
ALTER TABLE "ProductModel" ADD COLUMN "unitsPerBox" INTEGER;

-- CreateTable: Carton
CREATE TABLE "Carton" (
    "id" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "modelId" TEXT,
    "warehouseId" TEXT NOT NULL,
    "qrPayload" TEXT NOT NULL,
    "hmac" TEXT NOT NULL,
    "isIndividual" BOOLEAN NOT NULL DEFAULT false,
    "status" TEXT NOT NULL DEFAULT 'IN_STOCK',
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Carton_pkey" PRIMARY KEY ("id")
);

-- Indexes
CREATE UNIQUE INDEX "Carton_qrPayload_key" ON "Carton"("qrPayload");
CREATE INDEX "Carton_warehouseId_status_idx" ON "Carton"("warehouseId", "status");
CREATE INDEX "Carton_productId_modelId_idx" ON "Carton"("productId", "modelId");

-- Foreign keys
ALTER TABLE "Carton" ADD CONSTRAINT "Carton_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Carton" ADD CONSTRAINT "Carton_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "ProductModel"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Carton" ADD CONSTRAINT "Carton_warehouseId_fkey" FOREIGN KEY ("warehouseId") REFERENCES "Warehouse"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Carton" ADD CONSTRAINT "Carton_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
