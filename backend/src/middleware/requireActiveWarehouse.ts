import { Request, Response, NextFunction } from 'express';
import { prisma } from '../utils/prisma';

//فریز انبار بایگانیشده — همهٔ عملیات انباردار روی انبار بایگانیشده مسدود است
export const requireActiveWarehouse = async (req: Request, res: Response, next: NextFunction) => {
    const warehouseId = req.user?.warehouseId;
    if (!warehouseId) {
        res.status(403).json({ error: 'انباری به این کاربر متصل نیست' });
        return;
    }

    const warehouse = await prisma.warehouse.findUnique({
        where: { id: warehouseId },
        select: { deletedAt: true },
    });
    if (!warehouse || warehouse.deletedAt) {
        res.status(403).json({ error: 'انبار شما بایگانیشده شده است؛ با مدیر سیستم هماهنگ کنید' });
        return;
    }

    next();
};