import { prisma } from '../../utils/prisma';
import { AppError } from '../../common/exceptions/AppError';
import { writeAuditStandalone } from '../../utils/audit';

export const productsService = {
    //لیست محصولات (با مدل‌ها) — بدون موارد بایگانی‌شده
    getProducts: async () => {
        return await prisma.product.findMany({
            where: { deletedAt: null },
            orderBy: { name: 'asc' },
            include: {
                models: {
                    where: { deletedAt: null },
                    orderBy: { name: 'asc' },
                    select: {
                        id: true,
                        name: true,
                        price: true,
                        packageType: true,
                        unitsPerBox: true,
                    },
                },
            },
        });
    },

    //محصولات بایگانی‌شده — برای بازیابی با آخرین دادهٔ کامل
    getArchivedProducts: async () => {
        return await prisma.product.findMany({
            where: { deletedAt: { not: null } },
            orderBy: { deletedAt: 'desc' },
            include: {
                models: {
                    orderBy: { name: 'asc' },
                    select: {
                        id: true,
                        name: true,
                        price: true,
                        packageType: true,
                        unitsPerBox: true,
                        deletedAt: true,
                    },
                },
                _count: { select: { cartons: true } },
            },
        });
    },

    //ساخت محصول جدید (با duplicate check + مدل‌های اجباری + ظرفیت بسته)
    createProduct: async (
        name: string,
        models: { name: string; price?: string; packageType?: string; unitsPerBox?: string | number }[],
        managerId?: string,
        unit?: string,
    ) => {
        const productName = name.trim();
        const productUnit = unit?.trim() || 'عدد';
        const validModels = models.filter(m => m.name?.trim());
        if (validModels.length === 0) {
            throw new AppError('حداقل یک مدل برای محصول وارد کنید', 400);
        }

        const buildModelData = (m: typeof validModels[number]) => ({
            name: m.name.trim(),
            price: m.price ? parseFloat(String(m.price)) : null,
            packageType: m.packageType?.trim() || null,
            unitsPerBox:
                m.unitsPerBox !== undefined && m.unitsPerBox !== null && String(m.unitsPerBox).trim() !== ''
                    ? parseInt(String(m.unitsPerBox), 10)
                    : null,
        });

        let product = await prisma.product.findFirst({ where: { name: productName, deletedAt: null } });

        if (product) {
            for (const m of validModels) {
                const existingModel = await prisma.productModel.findUnique({
                    where: {
                        productId_name: {
                            productId: product.id,
                            name: m.name.trim(),
                        },
                    },
                });
                if (existingModel && !existingModel.deletedAt) {
                    throw new AppError(`مدل "${m.name.trim()}" قبلاً برای این محصول ثبت شده است`, 409);
                }
                if (existingModel) {
                    // احیأ مدل بایگانی‌شده با آخرین دادهٔ ارسال‌شده
                    await prisma.productModel.update({
                        where: { id: existingModel.id },
                        data: { ...buildModelData(m), deletedAt: null },
                    });
                } else {
                    await prisma.productModel.create({
                        data: { productId: product.id, ...buildModelData(m) },
                    });
                }
            }

            if (unit?.trim() && unit.trim() !== product.unit) {
                await prisma.product.update({ where: { id: product.id }, data: { unit: productUnit } });
            }

            //ثبت در تاریخچه
            if (managerId) {
                await prisma.activityLog.create({
                    data: {
                        type: 'product_updated',
                        label: `مدل‌های جدید برای محصول «${productName}»: ${validModels.map(m => m.name.trim()).join('، ')}`,
                        userId: managerId,
                    },
                }).catch(() => {});
            }

            return await prisma.product.findUnique({
                where: { id: product.id },
                include: {
                    models: {
                        select: { id: true, name: true, price: true, packageType: true, unitsPerBox: true },
                    },
                },
            });
        }

        const created = await prisma.product.create({
            data: {
                name: productName,
                unit: productUnit,
                models: {
                    create: validModels.map(buildModelData),
                },
            },
            include: {
                models: {
                    select: { id: true, name: true, price: true, packageType: true, unitsPerBox: true },
                },
            },
        });

        //ثبت در تاریخچه
        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'product_created',
                    label: `محصول «${productName}» ثبت شد — مدل‌ها: ${validModels.map(m => m.name.trim()).join('، ')}`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return created;
    },

    //بایگانی محصول — هیچ داده‌ای حذف فیزیکی نمی‌شود؛ کارتن‌ها و QRها کاملاً سالم می‌مانند
    deleteProduct: async (id: string, managerId?: string) => {
        const existing = await prisma.product.findUnique({ where: { id } });
        if (!existing) throw new AppError('محصول یافت نشد', 404);
        if (existing.deletedAt) throw new AppError('این محصول قبلاً بایگانی شده است', 400);

        await prisma.$transaction([
            prisma.product.update({ where: { id }, data: { deletedAt: new Date() } }),
            prisma.productModel.updateMany({
                where: { productId: id, deletedAt: null },
                data: { deletedAt: new Date() },
            }),
        ]);

        //ثبت در تاریخچه
        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'product_archived',
                    label: `محصول «${existing.name}» بایگانی شد — با بازیابی، آخرین داده‌ها برمی‌گردد`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return existing;
    },

    //بازیابی محصول بایگانی‌شده با تمام مدل‌ها و آخرین داده‌ها
    restoreProduct: async (id: string, managerId?: string) => {
        const existing = await prisma.product.findUnique({ where: { id } });
        if (!existing) throw new AppError('محصول یافت نشد', 404);
        if (!existing.deletedAt) throw new AppError('این محصول بایگانی نشده است', 400);

        await prisma.$transaction([
            prisma.product.update({ where: { id }, data: { deletedAt: null } }),
            prisma.productModel.updateMany({
                where: { productId: id, deletedAt: { not: null } },
                data: { deletedAt: null },
            }),
        ]);

        //ثبت در تاریخچه
        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'product_restored',
                    label: `محصول «${existing.name}» از بایگانی بازگردانده شد`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return prisma.product.findUnique({
            where: { id },
            include: {
                models: {
                    orderBy: { name: 'asc' },
                    select: { id: true, name: true, price: true, packageType: true, unitsPerBox: true },
                },
            },
        });
    },

    //بایگانی مدل محصول — کارتن‌ها و QRها سالم می‌مانند
    deleteProductModel: async (id: string, managerId?: string) => {
        const model = await prisma.productModel.findUnique({ where: { id } });
        if (!model) throw new AppError('مدل یافت نشد', 404);
        if (model.deletedAt) throw new AppError('این مدل قبلاً بایگانی شده است', 400);

        await prisma.productModel.update({ where: { id }, data: { deletedAt: new Date() } });

        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'model_archived',
                    label: `مدل «${model.name}» بایگانی شد`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return model;
    },

    //بازیابی مدل بایگانی‌شده
    restoreProductModel: async (id: string, managerId?: string) => {
        const model = await prisma.productModel.findUnique({ where: { id } });
        if (!model) throw new AppError('مدل یافت نشد', 404);
        if (!model.deletedAt) throw new AppError('این مدل بایگانی نشده است', 400);

        await prisma.productModel.update({ where: { id }, data: { deletedAt: null } });

        if (managerId) {
            await prisma.activityLog.create({
                data: {
                    type: 'model_restored',
                    label: `مدل «${model.name}» از بایگانی بازگردانده شد`,
                    userId: managerId,
                },
            }).catch(() => {});
        }

        return model;
    },

    //ویرایش نام/واحد شمارش محصول
    updateProduct: async (id: string, name: string, unit?: string) => {
        const trimmed = name.trim();
        const dup = await prisma.product.findFirst({ where: { name: trimmed, NOT: { id } } });
        if (dup) throw new AppError('محصولی با این نام قبلاً ثبت شده است', 409);
        const data: { name: string; unit?: string } = { name: trimmed };
        if (unit?.trim()) data.unit = unit.trim();
        return prisma.product.update({ where: { id }, data });
    },

    //ویرایش مدل محصول
    updateProductModel: async (
        id: string,
        data: { name?: string; price?: number | null; packageType?: string | null; unitsPerBox?: number | null },
        managerId?: string,
    ) => {
        const model = await prisma.productModel.findUnique({ where: { id } });
        if (!model) throw new AppError('مدل یافت نشد', 404);
        if (data.name) {
            const dup = await prisma.productModel.findFirst({
                where: { productId: model.productId, name: data.name.trim(), deletedAt: null, NOT: { id } },
            });
            if (dup) throw new AppError(`مدل "${data.name.trim()}" قبلاً برای این محصول ثبت شده است`, 409);
        }
        const before = { name: model.name, price: model.price, packageType: model.packageType, unitsPerBox: model.unitsPerBox };
        const updated = await prisma.productModel.update({ where: { id }, data });

        // ممیزی تغییر قیمت مدل
        if (managerId && data.price !== undefined && (data.price ?? null) !== (model.price ? Number(model.price) : null)) {
            await writeAuditStandalone({
                actorId: managerId, action: 'product_model.change_price', entity: 'ProductModel', entityId: id,
                before: { price: model.price }, after: { price: data.price },
            }).catch(() => {});
        }

        return updated;
    },
};