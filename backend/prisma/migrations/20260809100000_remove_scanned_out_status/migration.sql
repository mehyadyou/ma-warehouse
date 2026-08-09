-- حذف مقدار مرده SCANNED_OUT از enum (روش بازآفرینی: DROP VALUE در PostgreSQL 17+ است)
ALTER TYPE "CartonStatus" RENAME TO "CartonStatus_old";
CREATE TYPE "CartonStatus" AS ENUM ('IN_STOCK', 'SHIPPED', 'RETURNED');
ALTER TABLE "Carton" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "Carton" ALTER COLUMN "status" TYPE "CartonStatus" USING "status"::text::"CartonStatus";
ALTER TABLE "Carton" ALTER COLUMN "status" SET DEFAULT 'IN_STOCK';
DROP TYPE "CartonStatus_old";
