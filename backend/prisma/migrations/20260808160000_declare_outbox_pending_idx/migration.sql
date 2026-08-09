-- اعلام ایندکس جزئی پولر outbox که پیش‌تر با SQL خام در مهاجرت enterprise_schema ساخته شده است.
-- این مهاجرت فقط برای هماهنگ‌سازی تاریخچه Prisma با دیتابیس است (IF NOT EXISTS بی‌اثر است).
CREATE INDEX IF NOT EXISTS "OutboxEvent_pending_idx" ON "OutboxEvent" ("createdAt") WHERE "status" = 'PENDING';
