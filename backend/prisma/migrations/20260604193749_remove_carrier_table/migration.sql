/*
  Warnings:

  - You are about to drop the column `carrierId` on the `Order` table. All the data in the column will be lost.
  - You are about to drop the `Carrier` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "Order" DROP CONSTRAINT "Order_carrierId_fkey";

-- AlterTable
ALTER TABLE "Order" DROP COLUMN "carrierId";

-- DropTable
DROP TABLE "Carrier";
