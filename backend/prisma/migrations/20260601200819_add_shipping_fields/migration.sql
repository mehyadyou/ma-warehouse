-- AlterTable
ALTER TABLE "Order" ADD COLUMN     "address" TEXT,
ADD COLUMN     "carrier" TEXT,
ADD COLUMN     "city" TEXT,
ADD COLUMN     "customerPhone" TEXT,
ADD COLUMN     "postalCode" TEXT,
ADD COLUMN     "shippingMethod" TEXT NOT NULL DEFAULT 'باربری';
