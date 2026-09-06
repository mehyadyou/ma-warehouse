-- شمارهٔ روزانهٔ سفارش: از اول هر روزِ شمسی (کلید روز در orderDay) شماره از ۱ شروع می‌شود.
-- چون تبدیل میلادی→شمسی در SQL قابل انجام نیست، شماره‌گذاریِ ردیف‌های موجود با اسکریپت
-- backend/scripts/renumber-orders-daily.ts انجام می‌شود (بعد از اعمال این مهاجرت یک‌بار اجرا شود).

-- ۱) شماره‌ی خودکارِ سراسری (SERIAL) و ایندکس یکتای سراسری دیگر لازم نیست
ALTER TABLE "Order" ALTER COLUMN "orderNumber" DROP DEFAULT;
DROP INDEX IF EXISTS "Order_orderNumber_key";
DROP SEQUENCE IF EXISTS "Order_orderNumber_seq";

-- ۲) کلید روزِ شمسیِ ساخت سفارش (yyyy*10000+mm*100+dd) — تهی برای ردیف‌های قدیمی تا بازشماره‌گذاری
ALTER TABLE "Order" ADD COLUMN "orderDay" INTEGER;

-- ۳) یکتایی فقط «در هر روز» — شماره در روزهای مختلف می‌تواند تکرار شود
CREATE UNIQUE INDEX "Order_orderDay_orderNumber_key" ON "Order"("orderDay", "orderNumber");
