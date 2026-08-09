import { Request, Response, NextFunction, RequestHandler } from 'express';

// گرفتن کنترلر async و پاس دادن خطاها به next — دیگر نیازی به try/catch دستی نیست
export const asyncHandler =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>): RequestHandler =>
  (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };