-- افزودن مقادیر فعالیت‌هایی که سرویس‌ها واقعاً استفاده می‌کنند (order_completed, product_updated, مدل و کاربر)
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'order_completed';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'product_updated';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'model_archived';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'model_restored';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'user_created';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'user_deleted';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'user_role_changed';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'user_warehouse_changed';
