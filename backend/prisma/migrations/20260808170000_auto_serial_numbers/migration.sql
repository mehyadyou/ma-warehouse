-- شمارنده ترتیبی سریال کارتن‌ها به تفکیک سال شمسی
CREATE TABLE "SerialSequence" (
    "year" INTEGER NOT NULL,
    "lastSeq" INTEGER NOT NULL,
    CONSTRAINT "SerialSequence_pkey" PRIMARY KEY ("year")
);

-- بازپردازی سریال برای کارتن‌های قدیمی که سریال ندارند (به ترتیب زمان ورود)
-- فرمت: MA-1405-000001 (سال شمسی فعلی)
WITH ranked AS (
    SELECT "id", ROW_NUMBER() OVER (ORDER BY "createdAt", "id") AS rn
    FROM "Carton"
    WHERE "serialNumber" IS NULL
)
UPDATE "Carton" c
SET "serialNumber" = 'MA-1405-' || LPAD(r.rn::TEXT, 6, '0')
FROM ranked r
WHERE r."id" = c."id";

-- ادامه‌ی شماره‌گیری از آخرین شماره‌ی تخصیص‌یافته
INSERT INTO "SerialSequence" ("year", "lastSeq")
VALUES (1405, (SELECT COUNT(*) FROM "Carton" WHERE "serialNumber" LIKE 'MA-1405-%'));
