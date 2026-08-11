-- AlterTable
ALTER TABLE "Badge" DROP COLUMN "sequence",
ADD COLUMN     "count" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "Notification" ADD COLUMN     "dedupeKey" TEXT;

-- AlterTable
ALTER TABLE "OutboxEvent" ADD COLUMN     "claimedAt" TIMESTAMP(3);

-- CreateIndex
CREATE UNIQUE INDEX "Notification_dedupeKey_key" ON "Notification"("dedupeKey");

-- CreateIndex
CREATE INDEX "OutboxEvent_dispatching_idx" ON "OutboxEvent"("claimedAt") WHERE (status = 'DISPATCHING');
