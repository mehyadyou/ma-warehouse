import { Prisma } from '@prisma/client';
import { prisma } from '../../utils/prisma';
import { AppError } from '../../common/exceptions/AppError';
import { writeAuditStandalone } from '../../utils/audit';

// محاسبهٔ نام پیشنهادی با پسوند فارسی — «X (۲)»، «X (۳)» و… — چک علیه نام‌های فعال و بایگانیشده
async function nextAvailableName(base: string): Promise<string> {
    const faDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const toFa = (n: number) => String(n).split('').map(d => faDigits[+d]).join('');
    for (let i = 2; i <= 1000; i++) {
        const candidate = `${base} (${toFa(i)})`;
        const [active, archived] = await Promise.all([
            prisma.product.findFirst({ where: { name: candidate, deletedAt: null }, select: { id: true } }),
            prisma.product.findFirst({ where: { name: candidate, deletedAt: { not: null } }, select: { id: true } }),
        ]);
        if (!active && !archived) return candidate;
    }
    return `${base} (${toFa(Date.now() % 10000)})`;
}

async function archivedNameConflict(productName: string): Promise<AppError | null> {
    const archived = await prisma.product.findFirst({
        where: { name: productName, deletedAt: { not: null } },
        select: { id: true, name: true, deletedAt: true },
    });
    if (!archived) return null;
    return new AppError(
        `محصول «${productName}» در بایگانی است`,
        409,
        'ARCHIVED_CONFLICT',
        {
            id: archived.id,
            name: archived.name,
            archivedAt: archived.deletedAt,
            suggestedName: await nextAvailableName(productName),
        },
    );
}

export const productsService = {
    //لیست محصولات (با مدل‌ها) — بدون موارد بایگانی‌شده
    // q: جستجوی نام محصول/مدل؛ page/pageSize: صفحه‌بندی؛ بدون پارامتر = رفتار قدیمی (همه)
    getProducts: async (opts: { q?: string; page?: number; pageSize?: number } = {}) => {
        const where: Prisma.ProductWhereInput = {
            deletedAt: null,
            ...(opts.q?.trim()
                ? {
                      OR: [
                          { name: { contains: opts.q.trim(), mode: 'insensitive' } },
                          { models: { some: { name: { contains: opts.q.trim(), mode: 'insensitive' } } } },
                      ],
                  }
                : {}),
        };
        const include = {
            models: {
                where: { deletedAt: null },
                orderBy: { name: 'asc' as const },
                select: {
                    id: true,
                    name: true,
                    price: true,
                    packageType: true,
                    unitsPerBox: true,
                },
            },
        } satisfies Prisma.ProductInclude;

        if (opts.page !== undefined && opts.pageSize !== undefined) {
            const skip = (Math.max(1, opts.page) - 1) * Math.max(1, opts.pageSize);
            const [products, total] = await prisma.$transaction([
                prisma.product.findMany({
                    where,
                    orderBy: { name: 'asc' },
                    include,
                    skip,
                    take: Math.max(1, opts.pageSize),
                }),
                prisma.product.count({ where }),
            ]);
            return { products, items: products.length, total, page: opts.page, pageSize: opts.pageSize };
        }

        return await prisma.product.findMany({ where, orderBy: { name: 'asc' }, include });
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
    //نام همنام با محصول بایگانیشده → 409 ARCHIVED_CONFLICT (دیالوگ: بازیابی یا پسوند)
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

        const product = await prisma.product.findFirst({ where: { name: productName, deletedAt: null } });

        if (product) {
            //ادغام مدل‌ها با محصول موجود — در تراکنش تا نصفه‌نیمه نماند
            await prisma.$transaction(async (tx) => {
                for (const m of validModels) {
                    const existingModel = await tx.productModel.findUnique({
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
                        await tx.productModel.update({
                            where: { id: existingModel.id },
                            data: { ...buildModelData(m), deletedAt: null },
                        });
                    } else {
                        await tx.productModel.create({
                            data: { productId: product.id, ...buildModelData(m) },
                        });
                    }
                }

                if (unit?.trim() && unit.trim() !== product.unit) {
                    await tx.product.update({ where: { id: product.id }, data: { unit: productUnit } });
                }

                //ثبت در تاریخچه
                if (managerId) {
                    await tx.activityLog.create({
                        data: {
                            type: 'product_updated',
                            label: `مدل‌های جدید برای محصول «${productName}»: ${validModels.map(m => m.name.trim()).join('، ')}`,
                            userId: managerId,
                        },
                    }).catch(() => {});
                }
            });

            return await prisma.product.findUnique({
                where: { id: product.id },
                include: {
                    models: {
                        select: { id: true, name: true, price: true, packageType: true, unitsPerBox: true },
                    },
                },
            });
        }

        // نام همنام با محصول بایگانیشده → دیالوگ سمت اپ
        const conflict = await archivedNameConflict(productName);
        if (conflict) throw conflict;

        try {
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
        } catch (e: any) {
            // race: نام بین چک و ساخت ثبت شد (partial unique index)
            if (e?.code === 'P2002') {
                throw new AppError('محصولی با این نام در حال حاضر ثبت شده است؛ صفحه را تازه کنید', 409);
            }
            throw e;
        }
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

    //بازیابی محصول بایگانی‌شده با تمام مدل‌ها و آخرین داده‌ها — idempotent (اگر فعال است موفق برمی‌گردد)
    //اگر یکی از مدل‌های بایگانیشده با مدلِ فعالِ همنام در همین محصول برخورد کند → 409 (به‌جای 500)
    restoreProduct: async (id: string, managerId?: string) => {
        const existing = await prisma.product.findUnique({ where: { id } });
        if (!existing) throw new AppError('محصول یافت نشد', 404);

        if (!existing.deletedAt) {
            return prisma.product.findUnique({
                where: { id },
                include: {
                    models: { orderBy: { name: 'asc' }, select: { id: true, name: true, price: true, packageType: true, unitsPerBox: true } },
                },
            });
        }

        const colliding = await prisma.productModel.findFirst({
            where: {
                productId: id,
                deletedAt: { not: null },
                name: { in: await prisma.productModel.findMany({ where: { productId: id, deletedAt: null }, select: { name: true } }).then(ms => ms.map(m => m.name)) },
            },
            select: { name: true },
        });
        if (colliding) {
            throw new AppError(`مدل «${colliding.name}» برای این محصول فعال است؛ ابتدا آن را به نام دیگری تغییر دهید یا بایگانی کنید`, 409);
        }

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

    //بازیابی مدل بایگانی‌شده — idempotent؛ اگر مدلِ فعالِ همنام در همین محصول باشد → 409
    restoreProductModel: async (id: string, managerId?: string) => {
        const model = await prisma.productModel.findUnique({ where: { id } });
        if (!model) throw new AppError('مدل یافت نشد', 404);
        if (!model.deletedAt) return model;

        const dup = await prisma.productModel.findFirst({
            where: { productId: model.productId, name: model.name, deletedAt: null, NOT: { id } },
            select: { id: true },
        });
        if (dup) {
            throw new AppError(`مدل «${model.name}» برای این محصول فعال است؛ ابتدا نامش را تغییر دهید یا آن را بایگانی کنید`, 409);
        }

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
        const dup = await prisma.product.findFirst({ where: { name: trimmed, deletedAt: null, NOT: { id } } });
        if (dup) throw new AppError('محصولی با این نام قبلاً ثبت شده است', 409);
        const archivedDup = await prisma.product.findFirst({ where: { name: trimmed, deletedAt: { not: null }, NOT: { id } }, select: { id: true } });
        if (archivedDup) throw new AppError('محصولی با این نام در بایگانی است؛ ابتدا آن را بازگردانی کنید یا نام دیگری انتخاب کنید', 409);
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