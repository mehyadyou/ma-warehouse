import crypto from 'crypto';
import { prisma } from '../../utils/prisma';
import { buildQrForSerial, verifySerialPayload } from '../../utils/qr';
import { nextSerial } from '../../utils/serial';
import { AppError } from '../../common/exceptions/AppError';
import type { Prisma } from '@prisma/client';

export interface CheckinItem {
    productId: string;
    modelId?: string | null;
    entryType?: 'NEW' | 'RETURNED';
    serialNumber?: string | null;
    qrPayload?: string | null;
    cartonCount: number;
    individualCount: number;
}

export interface CheckinResultCarton {
    id: string;
    qrPayload: string;
    isIndividual: boolean;
    entryType: 'NEW' | 'RETURNED';
    serialNumber: string | null;
    productName: string;
    modelName: string | null;
    capacityPerBox: number;
}

export interface CheckinResult {
    cartons: CheckinResultCarton[];
    totalUnits: number;
}

const IDEMPOTENCY_OPERATION = 'checkin';

function isIdempotencyConflict(e: unknown): boolean {
    if (typeof e !== 'object' || e === null) return false;
    const err = e as { code?: unknown; meta?: { target?: unknown } };
    return err.code === 'P2002' && String(err.meta?.target ?? '').includes('userId_operation_key');
}

interface EntryGroup {
    productName: string;
    modelName: string | null;
    entryType: 'NEW' | 'RETURNED';
    cartons: number;
    individuals: number;
}

function buildEntryGroups(cartons: CheckinResultCarton[]): EntryGroup[] {
    const grouped = new Map<string, EntryGroup>();
    for (const c of cartons) {
        const key = `${c.productName}|${c.modelName ?? ''}|${c.entryType}`;
        const g = grouped.get(key) ?? {
            productName: c.productName,
            modelName: c.modelName,
            entryType: c.entryType,
            cartons: 0,
            individuals: 0,
        };
        if (c.isIndividual) g.individuals += 1;
        else g.cartons += 1;
        grouped.set(key, g);
    }
    return Array.from(grouped.values());
}

export const checkinService = {
    submitCheckin: async (
        warehouseId: string,
        userId: string,
        items: CheckinItem[],
        clientKey?: string,
    ): Promise<CheckinResult> => {
        if (!warehouseId) throw new AppError('انباردار به انباری وصل نیست', 403);
        if (!items.length) throw new AppError('حداقل یک محصول وارد کنید', 400);

        // پاسخ قبلی برای کلید یکسان — جلوگیری از ثبت دوباره‌ی ورود کالا
        if (clientKey) {
            const existing = await prisma.idempotencyKey.findUnique({
                where: { userId_operation_key: { userId, operation: IDEMPOTENCY_OPERATION, key: clientKey } },
            });
            if (existing) {
                return existing.responseJson as unknown as CheckinResult;
            }
        }

        const warehouse = await prisma.warehouse.findUnique({
            where: { id: warehouseId },
            select: { name: true },
        });
        const warehouseName = warehouse?.name ?? '';

        // برای مرجوعی: اگر سریال دستی نیامده ولی QR اسکن شده، سریال را از QR جدید (v2) استخراج کن
        for (const item of items) {
            if (item.entryType !== 'RETURNED' || item.serialNumber?.trim() || !item.qrPayload) continue;
            let parsed;
            try {
                parsed = verifySerialPayload(item.qrPayload);
            } catch (e: any) {
                throw new AppError(
                    'سریال در QR اسکن‌شده موجود نیست؛ لطفاً سریال را دستی وارد کنید',
                    400,
                );
            }
            item.serialNumber = parsed.serial;
        }

        const productIds = Array.from(new Set(items.map(i => i.productId)));
        const modelIds = Array.from(
            new Set(items.map(i => i.modelId).filter((v): v is string => !!v)),
        );
        const returnedSerials = items
            .filter((item) => item.entryType === 'RETURNED')
            .map((item) => item.serialNumber?.trim())
            .filter((value): value is string => !!value);

        const products = await prisma.product.findMany({
            where: { id: { in: productIds } },
            include: { models: true },
        });
        const productMap = new Map(products.map(p => [p.id, p]));
        const modelMap = new Map(
            products.flatMap(p => p.models).map(m => [m.id, m]),
        );

        if (returnedSerials.length) {
            if (new Set(returnedSerials).size !== returnedSerials.length) {
                throw new AppError('سریال مرجوعی در ردیف‌ها تکراری است', 400);
            }

            // بررسی وجود سریال در سیستم و خروج‌زده بودن آن
            const existingCartons = await prisma.carton.findMany({
                where: { serialNumber: { in: returnedSerials } },
                select: { serialNumber: true, status: true, scannedOutAt: true, entryType: true },
            });

            for (const serial of returnedSerials) {
                const found = existingCartons.find(c => c.serialNumber === serial);
                if (!found) {
                    throw new AppError(`سریال ${serial} در سیستم یافت نشد. فقط کالاهای خروج‌زده قابل مرجوعی هستند.`, 404);
                }
                if (!found.scannedOutAt) {
                    throw new AppError(`سریال ${serial} هنوز در انبار موجود است و نیازی به مرجوعی ندارد.`, 400);
                }
                if (found.entryType === 'RETURNED') {
                    throw new AppError(`سریال ${serial} قبلاً به عنوان مرجوعی ثبت شده است.`, 400);
                }
            }
        }

        for (const item of items) {
            const product = productMap.get(item.productId);
            if (!product) throw new AppError('محصول یافت نشد', 404);
            if (item.modelId) {
                const model = modelMap.get(item.modelId);
                if (!model) throw new AppError('مدل محصول یافت نشد', 404);
                if (model.productId !== item.productId) {
                    throw new AppError('مدل انتخاب‌شده متعلق به این محصول نیست', 400);
                }
            }
            if (item.cartonCount < 0 || item.individualCount < 0) {
                throw new AppError('تعداد نمی‌تواند منفی باشد', 400);
            }
            if (item.cartonCount === 0 && item.individualCount === 0) {
                throw new AppError('برای هر ردیف حداقل یک کارتن یا یک تکی وارد کنید', 400);
            }
            if (item.entryType === 'RETURNED') {
                if (!item.serialNumber?.trim()) {
                    throw new AppError('برای کالای مرجوعی وارد کردن سریال الزامی است', 400);
                }
                if (item.cartonCount !== 0 || item.individualCount !== 1) {
                    throw new AppError('کالای مرجوعی فقط باید به صورت یک عدد تکی ثبت شود', 400);
                }
            }
            if (item.cartonCount > 0) {
                const model = item.modelId ? modelMap.get(item.modelId) : null;
                const capacity = model?.unitsPerBox ?? 0;
                if (capacity <= 0) {
                    throw new AppError(
                        `ظرفیت بسته برای ${product.name}${model ? ` (${model.name})` : ''} تعیین نشده است`,
                        400,
                    );
                }
            }
        }

        const created: CheckinResultCarton[] = [];
        let totalUnits = 0;
        let checkinOutboxPayload: {
            warehouseId: string;
            warehouseName: string;
            userId: string;
            totalUnits: number;
            cartonCount: number;
            entries: EntryGroup[];
        } | null = null;

        try {
            await prisma.$transaction(async (tx) => {
            for (const item of items) {
                const product = productMap.get(item.productId)!;
                const model = item.modelId ? modelMap.get(item.modelId)! : null;
                const entryType = item.entryType === 'RETURNED' ? 'RETURNED' : 'NEW';
                const serialNumber = entryType === 'RETURNED' ? item.serialNumber?.trim() ?? null : null;
                const capacityPerBox = model?.unitsPerBox ?? 1;

                for (let i = 0; i < item.cartonCount; i++) {
                    const id = crypto.randomUUID();
                    // هر کارتن سریال اختصاصی می‌گیرد؛ محتوای QR همان سریال است
                    const serial = await nextSerial(tx);
                    const { qrPayload, hmac } = buildQrForSerial({ serial, uuid: id });
                    await tx.carton.create({
                        data: {
                            id,
                            productId: product.id,
                            modelId: model?.id ?? null,
                            warehouseId,
                            qrPayload,
                            hmac,
                            isIndividual: false,
                            entryType,
                            serialNumber: serial,
                            createdById: userId,
                        },
                    });
                    created.push({
                        id,
                        qrPayload,
                        isIndividual: false,
                        entryType,
                        serialNumber: serial,
                        productName: product.name,
                        modelName: model?.name ?? null,
                        capacityPerBox,
                    });
                    totalUnits += capacityPerBox;
                }

                for (let i = 0; i < item.individualCount; i++) {
                    // برای مرجوعی: سریال را با قفل شرطی از کارتن اصلی (خروج‌زده) پاک کن —
                    // اگر هم‌زمان درخواست دیگری همین سریال را مرجوع کرده باشد، ۰ ردیف برمی‌گردد و خطا می‌دهد
                    if (entryType === 'RETURNED' && serialNumber) {
                        const cleared = await tx.carton.updateMany({
                            where: {
                                serialNumber,
                                scannedOutAt: { not: null },
                            },
                            data: { serialNumber: null },
                        });
                        if (cleared.count === 0) {
                            throw new AppError(
                                `سریال ${serialNumber} قبلاً مرجوع شده است یا در انبار موجود است`,
                                400,
                            );
                        }
                    }
                    const id = crypto.randomUUID();
                    // مرجوعی: سریال همان کارتن خروج‌زده؛ جدید: سریال اختصاصی تازه
                    const serial = serialNumber ?? (await nextSerial(tx));
                    const { qrPayload, hmac } = buildQrForSerial({
                        serial,
                        uuid: id,
                    });
                    await tx.carton.create({
                        data: {
                            id,
                            productId: product.id,
                            modelId: model?.id ?? null,
                            warehouseId,
                            qrPayload,
                            hmac,
                            isIndividual: true,
                            entryType,
                            serialNumber: serial,
                            createdById: userId,
                        },
                    });
                    created.push({
                        id,
                        qrPayload,
                        isIndividual: true,
                        entryType,
                        serialNumber: serial,
                        productName: product.name,
                        modelName: model?.name ?? null,
                        capacityPerBox: 1,
                    });
                    totalUnits += 1;
                }

                await tx.transaction.create({
                    data: {
                        type: entryType === 'RETURNED' ? 'RETURN' : 'IN',
                        productName: product.name + (model ? ` (${model.name})` : ''),
                        productId: product.id,
                        quantity: item.cartonCount * capacityPerBox + item.individualCount,
                        warehouseId,
                        userId,
                    },
                });

                //ثبت در تاریخچه
                const productPart = product.name + (model ? ` (${model.name})` : '');
                if (entryType === 'RETURNED') {
                    await tx.activityLog.create({
                        data: {
                            type: 'return_received',
                            label: `${productPart} — سریال ${serialNumber ?? ''} — بازگشت به انبار ${warehouseName}`,
                            userId,
                        },
                    });
                } else {
                    const qtyParts: string[] = [];
                    if (item.cartonCount > 0) qtyParts.push(`${item.cartonCount} ${model?.packageType ?? 'کارتن'}`);
                    if (item.individualCount > 0) qtyParts.push(`${item.individualCount} تکی`);
                    await tx.activityLog.create({
                        data: {
                            type: 'product_checkin',
                            label: `${productPart} — ${qtyParts.join(' + ')} — ورود به انبار ${warehouseName}`,
                            userId,
                        },
                    });
                }
            }

            checkinOutboxPayload = {
                warehouseId,
                warehouseName,
                userId,
                totalUnits,
                cartonCount: created.length,
                entries: buildEntryGroups(created),
            };
            await tx.outboxEvent.create({
                data: {
                    aggregate: 'warehouse',
                    type: 'checkin:completed',
                    payload: checkinOutboxPayload as unknown as Prisma.InputJsonValue,
                },
            });

            // قفل ایدمپوتنسی داخل همان تراکنش: یا ورود کالا ثبت می‌شود یا کلید؛ هر دو با هم
            if (clientKey) {
                await tx.idempotencyKey.create({
                    data: {
                        userId,
                        operation: IDEMPOTENCY_OPERATION,
                        key: clientKey,
                        responseJson: { cartons: created, totalUnits } as unknown as Prisma.InputJsonValue,
                    },
                });
            }
            });
        } catch (e) {
            // دو درخواست همزمان با کلید یکسان: یکی برنده می‌شود، دیگری پاسخ ذخیره‌شده را می‌گیرد
            if (isIdempotencyConflict(e) && clientKey) {
                const existing = await prisma.idempotencyKey.findUnique({
                    where: { userId_operation_key: { userId, operation: IDEMPOTENCY_OPERATION, key: clientKey } },
                });
                if (existing) {
                    return existing.responseJson as unknown as CheckinResult;
                }
            }
            throw e;
        }

        return { cartons: created, totalUnits };
    },

    listRecentCartons: async (warehouseId: string, limit = 50) => {
        return await prisma.carton.findMany({
            where: { warehouseId },
            orderBy: { createdAt: 'desc' },
            take: limit,
            include: {
                product: { select: { name: true } },
                model: { select: { name: true, unitsPerBox: true } },
            },
        });
    },
};