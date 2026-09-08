-- شمارنده اتمی شمارهٔ روزانهٔ سفارش (جایگزین count+1) + الزامی شدن orderDay
-- دلیل: رقابت ۱۰۰ انبار روی کلید یک روز در پیک؛ upsert اتمی به‌جای count+retry.
-- توجه: اگر روی کلونی با orderDay=NULL اجرا شد و SET NOT NULL خطا داد، اول
-- scripts/renumber-orders-daily.ts را اجرا کنید و بعد deploy را تکرار کنید.

-- CreateTable
CREATE TABLE "OrderDaySequence" (
    "day" INTEGER NOT NULL,
    "lastNumber" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "OrderDaySequence_pkey" PRIMARY KEY ("day")
);

-- سید شمارنده از حداکثر شمارهٔ موجود هر روز (تا شماره‌ها از ادامه تخصیص یابند، نه از ۱)
INSERT INTO "OrderDaySequence" ("day", "lastNumber")
SELECT "orderDay", max("orderNumber") FROM "Order" WHERE "orderDay" IS NOT NULL GROUP BY "orderDay"
ON CONFLICT ("day") DO NOTHING;

-- orderDay الزامی: NULL ایندکس یکتای [orderDay, orderNumber] را در Postgres دور می‌زند
ALTER TABLE "Order" ALTER COLUMN "orderDay" SET NOT NULL;
