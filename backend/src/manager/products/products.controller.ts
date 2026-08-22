import { Request, Response } from 'express';
import { productsService } from './products.service';
import { asyncHandler } from '../../middleware/asyncHandler';
import { parseOptionalInt, parseOptionalPrice } from '../../utils/numbers';

export const productsController = {
  getProducts: asyncHandler(async (req: Request, res: Response) => {
    const q = String(req.query.q ?? '').trim();
    const page = req.query.page !== undefined ? Number(req.query.page) : undefined;
    const pageSize = req.query.pageSize !== undefined ? Number(req.query.pageSize) : undefined;
    const products = await productsService.getProducts({
      ...(q ? { q } : {}),
      ...(Number.isInteger(page) && page! > 0 ? { page } : {}),
      ...(Number.isInteger(pageSize) && pageSize! > 0 ? { pageSize: Math.min(pageSize!, 500) } : {}),
    });
    res.json(Array.isArray(products) ? { products } : products);

  }),

  getProduct: asyncHandler(async (req: Request, res: Response) => {
    const product = await productsService.getProductById(req.params.id as string);
    if (!product || product.deletedAt !== null) {
      res.status(404).json({ error: 'محصول یافت نشد' });
      return;
    }
    res.json({ product });

  }),

  createProduct: asyncHandler(async (req: Request, res: Response) => {
    const { name, models, unit } = req.body;
    const product = await productsService.createProduct(name, models || [], req.user!.id, unit);
    res.status(201).json({ message: 'محصول با مدل‌ها ساخته شد', product });

  }),

  deleteProduct: asyncHandler(async (req: Request, res: Response) => {
    const product = await productsService.deleteProduct(req.params.id as string, req.user!.id);
    res.json({ message: 'محصول بایگانی شد — با بازیابی برمی‌گردد', mode: 'archived', product });

  }),

  restoreProduct: asyncHandler(async (req: Request, res: Response) => {
    const product = await productsService.restoreProduct(req.params.id as string, req.user!.id);
    res.json({ message: 'محصول بازگردانده شد', product });

  }),

  deleteProductModel: asyncHandler(async (req: Request, res: Response) => {
    const model = await productsService.deleteProductModel(req.params.id as string, req.user!.id);
    res.json({ message: 'مدل بایگانی شد — با بازیابی برمی‌گردد', mode: 'archived', model });

  }),

  addProductModels: asyncHandler(async (req: Request, res: Response) => {
    const product = await productsService.addProductModels(req.params.id as string, req.body?.models || [], req.user!.id);
    res.status(201).json({ message: 'مدل‌ها اضافه شدند', product });

  }),

  restoreProductModel: asyncHandler(async (req: Request, res: Response) => {
    const model = await productsService.restoreProductModel(req.params.id as string, req.user!.id);
    res.json({ message: 'مدل بازگردانده شد', model });

  }),

  getArchivedProducts: asyncHandler(async (req: Request, res: Response) => {
    const products = await productsService.getArchivedProducts();
    res.json({ products });

  }),

  updateProduct: asyncHandler(async (req: Request, res: Response) => {
    const name = String(req.body?.name ?? '').trim();
    if (!name) {
      res.status(400).json({ error: 'نام محصول را وارد کنید' });
      return;
    }
    const unit = req.body?.unit !== undefined ? String(req.body.unit).trim() : undefined;
    const product = await productsService.updateProduct(req.params.id as string, name, unit);
    res.json({ message: 'محصول ویرایش شد', product });

  }),

  updateProductModel: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const data: { name?: string; price?: number | null; packageType?: string | null; unitsPerBox?: number | null } = {};
    if (req.body?.name !== undefined) data.name = String(req.body.name).trim() || undefined;
    if (req.body?.price !== undefined) {
      data.price = parseOptionalPrice(req.body.price, 'قیمت');
    }
    if (req.body?.packageType !== undefined) {
      const raw = req.body.packageType;
      data.packageType = raw === null || String(raw).trim() === '' ? null : String(raw).trim();
    }
    if (req.body?.unitsPerBox !== undefined) {
      data.unitsPerBox = parseOptionalInt(req.body.unitsPerBox, 'ظرفیت بسته');
    }
    const model = await productsService.updateProductModel(id, data, req.user!.id);
    res.json({ message: 'مدل ویرایش شد', model });

  }),
};