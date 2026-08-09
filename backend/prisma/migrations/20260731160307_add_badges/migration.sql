-- CreateTable
CREATE TABLE "Badge" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "sequence" INTEGER NOT NULL DEFAULT 1,
    "senderName" TEXT,
    "receiverName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Badge_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Badge_orderId_idx" ON "Badge"("orderId");

-- AddForeignKey
ALTER TABLE "Badge" ADD CONSTRAINT "Badge_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE CASCADE ON UPDATE CASCADE;
