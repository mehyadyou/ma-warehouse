-- CreateTable
CREATE TABLE "Carrier" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 0,
    "phone" TEXT,
    "address" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Carrier_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Carrier_name_key" ON "Carrier"("name");

-- Seed: انتقال باربری‌های موجود در src/config/carriers.json به دیتابیس
INSERT INTO "Carrier" ("id", "name", "priority", "phone", "address", "updatedAt") VALUES
    (gen_random_uuid(), 'باربری فارس', 1, '071-12345678', 'شیراز', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'باربری جاوید ترابر', 2, '021-87654321', 'تهران', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'باربری قدس', 3, '025-11223344', 'قم', CURRENT_TIMESTAMP)
ON CONFLICT ("name") DO NOTHING;