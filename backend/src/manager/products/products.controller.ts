import { Request, Response } from 'express';
import { productsService } from './products.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const productsController = {
  getProducts: asyncHandler(async (req: Request, res: Response) => {
    const products = await productsService.getProducts();
    res.json({ products });

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
      const raw = req.body.price;
      data.price = raw === null || String(raw).trim() === '' ? null : parseFloat(String(raw));
    }
    if (req.body?.packageType !== undefined) {
      const raw = req.body.packageType;
      data.packageType = raw === null || String(raw).trim() === '' ? null : String(raw).trim();
    }
    if (req.body?.unitsPerBox !== undefined) {
      const raw = req.body.unitsPerBox;
      data.unitsPerBox = raw === null || String(raw).trim() === '' ? null : parseInt(String(raw), 10);
    }
    const model = await productsService.updateProductModel(id, data);
    res.json({ message: 'مدل ویرایش شد', model });

  }),
};