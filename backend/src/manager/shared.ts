import { prisma } from '../utils/prisma';
export const roleLabel = (role?: string | null): string => {
    switch (role) {
        case 'MANAGER': return 'مدیر';
        case 'WAREHOUSE_KEEPER': return 'انباردار';
        case 'DRIVER': return 'راننده';
        default: return role ?? 'نامشخص';
    }
};

// نگارش کارتن‌های یک انبار به موجودی هر محصول/مدل (همان ساختار موجودی انباردار)
export const buildWarehouseInventory = (cartons: any[]) => {
    const productMap = new Map<string, any>();
    let totalUnits = 0;
    let totalCartons = 0;
    let returnedUnits = 0;

    for (const carton of cartons) {
        // کارتن‌های محصول بایگانی‌شده از آمار محاسبه نمی‌شوند (QR و اسکن سالم است)
        if (carton.product?.deletedAt) continue;
        if (carton.status !== 'IN_STOCK') continue;

        const units = carton.isIndividual ? 1 : carton.model?.unitsPerBox ?? 0;
        totalUnits += units;
        totalCartons += 1;
        if (carton.entryType === 'RETURNED') returnedUnits += units;

        const productKey = carton.productId;
        let product = productMap.get(productKey);
        if (!product) {
            product = {
                productId: carton.product.id,
                name: carton.product.name,
                unit: carton.product.unit?.trim() || 'عدد',
                totalCount: 0,
                cartonCount: 0,
                individualCount: 0,
                models: [] as any[],
                _modelMap: new Map<string, any>(),
            };
            productMap.set(productKey, product);
        }

        product.totalCount += units;
        if (carton.isIndividual) product.individualCount += 1;
        else product.cartonCount += 1;

        const modelKey = carton.model?.id ?? '__NO_MODEL__';
        let model = product._modelMap.get(modelKey);
        if (!model) {
            model = {
                modelId: carton.model?.id ?? null,
                name: carton.model?.name ?? 'بدون مدل',
                totalCount: 0,
                cartonCount: 0,
                individualCount: 0,
            };
            product._modelMap.set(modelKey, model);
            product.models.push(model);
        }
        model.totalCount += units;
        if (carton.isIndividual) model.individualCount += 1;
        else model.cartonCount += 1;
    }

    const products = Array.from(productMap.values())
        .sort((a, b) => a.name.localeCompare(b.name))
        .map((p: any) => ({
            productId: p.productId,
            name: p.name,
            unit: p.unit,
            totalCount: p.totalCount,
            cartonCount: p.cartonCount,
            individualCount: p.individualCount,
            modelCount: p.models.length,
            models: [...p.models]
                .sort((a: any, b: any) => (a.name || '').localeCompare(b.name || ''))
                .map((m: any) => ({
                    modelId: m.modelId,
                    name: m.name,
                    unit: p.unit,
                    totalCount: m.totalCount,
                    cartonCount: m.cartonCount,
                    individualCount: m.individualCount,
                })),
        }));

    return {
        totalUnits,
        totalCartons,
        totalProducts: products.length,
        totalModels: products.reduce((sum, p) => sum + p.models.length, 0),
        returnedUnits,
        products,
    };
};
