-- افزودن مقادیر فعالیت انبار (ساخت، ویرایش، تغییر انباردار)
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'warehouse_created';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'warehouse_updated';
ALTER TYPE "ActivityLogType" ADD VALUE IF NOT EXISTS 'warehouse_keeper_changed';