-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('PENDING', 'SHIPPED', 'DELIVERED', 'CANCELED');

-- CreateEnum
CREATE TYPE "CartonStatus" AS ENUM ('IN_STOCK', 'SHIPPED', 'SCANNED_OUT', 'RETURNED');

-- CreateEnum
CREATE TYPE "CartonEntryType" AS ENUM ('NEW', 'RETURNED');

-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM ('IN', 'OUT', 'RETURN');

-- CreateEnum
CREATE TYPE "DeliveryStatus" AS ENUM ('IN_TRANSIT', 'DELIVERED');

-- CreateEnum
CREATE TYPE "ActivityLogType" AS ENUM ('order_created', 'order_updated', 'order_deleted', 'return_received', 'product_checkin', 'order_shipped', 'product_archived', 'product_created', 'product_restored', 'warehouse_archived', 'warehouse_restored');

-- DropForeignKey
ALTER TABLE "Delivery" DROP CONSTRAINT "Delivery_orderId_fkey";

-- DropForeignKey
ALTER TABLE "OrderItem" DROP CONSTRAINT "OrderItem_orderId_fkey";

-- AlterTable
-- تبدیل ستون‌های متنی به enum با کست USING (حفظ داده به‌جای drop/recreate)
ALTER TABLE "ActivityLog" ALTER COLUMN "type" TYPE "ActivityLogType" USING "type"::"ActivityLogType";

-- AlterTable
ALTER TABLE "Carton" ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 0,
ALTER COLUMN "status" DROP DEFAULT,
ALTER COLUMN "status" TYPE "CartonStatus" USING "status"::"CartonStatus",
ALTER COLUMN "status" SET DEFAULT 'IN_STOCK',
ALTER COLUMN "entryType" DROP DEFAULT,
ALTER COLUMN "entryType" TYPE "CartonEntryType" USING "entryType"::"CartonEntryType",
ALTER COLUMN "entryType" SET DEFAULT 'NEW';

-- AlterTable
ALTER TABLE "Delivery" ALTER COLUMN "status" DROP DEFAULT,
ALTER COLUMN "status" TYPE "DeliveryStatus" USING "status"::"DeliveryStatus",
ALTER COLUMN "status" SET DEFAULT 'IN_TRANSIT';

-- AlterTable
ALTER TABLE "Order" ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 0,
ALTER COLUMN "status" DROP DEFAULT,
ALTER COLUMN "status" TYPE "OrderStatus" USING "status"::"OrderStatus",
ALTER COLUMN "status" SET DEFAULT 'PENDING';

-- AlterTable
ALTER TABLE "OrderItem" ALTER COLUMN "price" SET DATA TYPE DECIMAL(18,2),
ALTER COLUMN "exchangeRate" SET DATA TYPE DECIMAL(18,6);

-- AlterTable
ALTER TABLE "Product" ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "ProductModel" ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 0,
ALTER COLUMN "price" SET DATA TYPE DECIMAL(18,2);

-- AlterTable
ALTER TABLE "Transaction" ALTER COLUMN "type" TYPE "TransactionType" USING "type"::"TransactionType";

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "failedLoginAttempts" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "lockUntil" TIMESTAMP(3),
ADD COLUMN     "mustChangePassword" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "Warehouse" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 0;

-- بک‌فیل: updatedAt = createdAt برای ردیف‌های موجود، سپس حذف پیش‌فرض (Prisma مقدار را کلاینتی ست می‌کند)
UPDATE "Warehouse" SET "updatedAt" = "createdAt";
ALTER TABLE "Warehouse" ALTER COLUMN "updatedAt" DROP DEFAULT;

-- ایندکس‌های قدیمی که شِما جدید جایگزینشان کرده (composite جایگزین دو ایندکس مجزای Notification شد)
DROP INDEX "Notification_userId_isRead_idx";
DROP INDEX "Notification_createdAt_idx";

-- CreateTable
CREATE TABLE "IdempotencyKey" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "operation" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "responseJson" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "IdempotencyKey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OutboxEvent" (
    "id" TEXT NOT NULL,
    "aggregate" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dispatchedAt" TIMESTAMP(3),

    CONSTRAINT "OutboxEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "actorId" TEXT,
    "action" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "entityId" TEXT,
    "before" JSONB,
    "after" JSONB,
    "ip" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),
    "replacedBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "IdempotencyKey_createdAt_idx" ON "IdempotencyKey"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "IdempotencyKey_userId_operation_key_key" ON "IdempotencyKey"("userId", "operation", "key");

-- CreateIndex
CREATE INDEX "OutboxEvent_status_createdAt_idx" ON "OutboxEvent"("status", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_entityId_idx" ON "AuditLog"("entityId");

-- CreateIndex
CREATE INDEX "AuditLog_actorId_createdAt_idx" ON "AuditLog"("actorId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "RefreshToken_tokenHash_key" ON "RefreshToken"("tokenHash");

-- CreateIndex
CREATE INDEX "RefreshToken_userId_idx" ON "RefreshToken"("userId");

-- CreateIndex
CREATE INDEX "ActivityLog_createdAt_idx" ON "ActivityLog"("createdAt" DESC);

-- CreateIndex
CREATE INDEX "ActivityLog_type_idx" ON "ActivityLog"("type");

-- CreateIndex
CREATE INDEX "Carton_serialNumber_idx" ON "Carton"("serialNumber");

-- CreateIndex
CREATE INDEX "Notification_userId_isRead_createdAt_idx" ON "Notification"("userId", "isRead", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Order_status_createdAt_idx" ON "Order"("status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Order_warehouseId_status_idx" ON "Order"("warehouseId", "status");

-- CreateIndex
CREATE INDEX "Transaction_warehouseId_createdAt_idx" ON "Transaction"("warehouseId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Transaction_userId_createdAt_idx" ON "Transaction"("userId", "createdAt" DESC);

-- AddForeignKey
ALTER TABLE "OrderItem" ADD CONSTRAINT "OrderItem_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Delivery" ADD CONSTRAINT "Delivery_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ============================================================================
-- سخت‌سازی سازمانی (قابل نمایش در شِما نیست): CHECK constraint ها، ایندکس trigram و جزئی
-- ============================================================================

SET search_path = public, extensions;

-- عملیات‌های trigram در schema ی جدا (در دیتابیس‌های تازه توسط رول مهاجرت ساخته می‌شود)
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION ma_migrator;
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;

-- یکپارچگی دیتا در سطح دیتابیس
ALTER TABLE "Order" ADD CONSTRAINT "Order_city_postal_check" CHECK (("city" IS NULL) = ("postalCode" IS NULL));
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_quantity_check" CHECK ("quantity" > 0);
ALTER TABLE "OrderItem" ADD CONSTRAINT "OrderItem_quantity_check" CHECK ("quantity" > 0);
ALTER TABLE "OrderItem" ADD CONSTRAINT "OrderItem_price_check" CHECK ("price" IS NULL OR "price" >= 0);
ALTER TABLE "OrderItem" ADD CONSTRAINT "OrderItem_exchangeRate_check" CHECK ("exchangeRate" IS NULL OR "exchangeRate" > 0);
ALTER TABLE "ProductModel" ADD CONSTRAINT "ProductModel_unitsPerBox_check" CHECK ("unitsPerBox" IS NULL OR "unitsPerBox" > 0);
ALTER TABLE "ProductModel" ADD CONSTRAINT "ProductModel_price_check" CHECK ("price" IS NULL OR "price" >= 0);

-- جستجوی فازی (ILIKE %…%) روی مسیرهای اصلی جستجو (opclass کوالیفای؛ مستقل از search_path)
CREATE INDEX "Product_name_trgm_idx" ON "Product" USING gin ("name" extensions.gin_trgm_ops) WHERE "deletedAt" IS NULL;
CREATE INDEX "Warehouse_name_trgm_idx" ON "Warehouse" USING gin ("name" extensions.gin_trgm_ops);
CREATE INDEX "Carton_serialNumber_trgm_idx" ON "Carton" USING gin ("serialNumber" extensions.gin_trgm_ops);

-- ایندکس جزئی برای مسیرهای پرتکرار
CREATE INDEX "Notification_unread_idx" ON "Notification" ("userId") WHERE "isRead" = false;
CREATE INDEX "OutboxEvent_pending_idx" ON "OutboxEvent" ("createdAt") WHERE "status" = 'PENDING';
