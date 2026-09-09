-- مصرف روزانهٔ کلیدهای API برای داشبورد CRM (فقط ضمیمه؛ هیچ منطق دامنه‌ای وابسته نیست)
-- CreateTable
CREATE TABLE "ApiKeyDailyUsage" (
    "apiKeyId" TEXT NOT NULL,
    "dayKey" INTEGER NOT NULL,
    "hits" INTEGER NOT NULL DEFAULT 0,
    "errors" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ApiKeyDailyUsage_pkey" PRIMARY KEY ("apiKeyId", "dayKey")
);

-- CreateIndex
CREATE INDEX "ApiKeyDailyUsage_dayKey_idx" ON "ApiKeyDailyUsage"("dayKey");

-- AddForeignKey
ALTER TABLE "ApiKeyDailyUsage" ADD CONSTRAINT "ApiKeyDailyUsage_apiKeyId_fkey" FOREIGN KEY ("apiKeyId") REFERENCES "ApiKey"("id") ON DELETE CASCADE ON UPDATE CASCADE;
