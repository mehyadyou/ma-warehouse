/*
  Warnings:

  - A unique constraint covering the columns `[qrUuid]` on the table `Carton` will be added. If there are existing duplicate values, this will fail.
  - The required column `qrUuid` was added to the `Carton` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.

*/
-- AlterTable
ALTER TABLE "Carton" ADD COLUMN     "orderId" TEXT,
ADD COLUMN     "qrUuid" TEXT NOT NULL,
ADD COLUMN     "scannedOutAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'info',
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "data" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Notification_userId_isRead_idx" ON "Notification"("userId", "isRead");

-- CreateIndex
CREATE INDEX "Notification_createdAt_idx" ON "Notification"("createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "Carton_qrUuid_key" ON "Carton"("qrUuid");

-- CreateIndex
CREATE INDEX "Carton_scannedOutAt_idx" ON "Carton"("scannedOutAt");

-- CreateIndex
CREATE INDEX "Carton_orderId_idx" ON "Carton"("orderId");

-- AddForeignKey
ALTER TABLE "Carton" ADD CONSTRAINT "Carton_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
