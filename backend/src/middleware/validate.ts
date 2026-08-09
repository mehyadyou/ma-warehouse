import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';

type ValidateSource = 'query' | 'params' | 'body';

// اعتبارسنجی ورودی‌های مسیر با Zod — انطباق با errorHandler:
// { error: string } در غیر این صورت ادامه‌ی پردازش با داده‌ی پاک‌شده
export const validate = (schema: z.ZodType, source: ValidateSource = 'body') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const parsed = schema.safeParse(req[source]);
    if (!parsed.success) {
      return res.status(422).json({ error: parsed.error.issues[0].message });
    }
    (req as any)[source] = parsed.data;
    next();
  };
};