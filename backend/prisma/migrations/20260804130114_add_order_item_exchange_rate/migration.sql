-- AlterTable
ALTER TABLE "OrderItem" ADD COLUMN     "exchangeRate" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "Product" ALTER COLUMN "deletedAt" SET DATA TYPE TIMESTAMP(3);

-- AlterTable
ALTER TABLE "ProductModel" ALTER COLUMN "deletedAt" SET DATA TYPE TIMESTAMP(3);
