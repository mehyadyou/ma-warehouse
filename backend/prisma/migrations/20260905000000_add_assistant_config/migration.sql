-- CreateTable: پیکربندی مدل هوش مصنوعی دستیار مدیر — یک ردیف تکی (id='default')
-- از منوی تنظیمات مدیریت قابل ویرایش است تا مدل بدون تغییر کد/env عوض شود.
-- وقتی ردیفی وجود ندارد، دستیار به مقادیر پیش‌فرض env (ZAI_*) برمی‌گردد.
CREATE TABLE "AssistantConfig" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "baseUrl" TEXT NOT NULL,
    "apiKey" TEXT,
    "model" TEXT NOT NULL,
    "maxTokens" INTEGER NOT NULL DEFAULT 8000,
    "thinking" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AssistantConfig_pkey" PRIMARY KEY ("id")
);
