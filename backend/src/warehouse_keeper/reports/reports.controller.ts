import { Request, Response } from 'express';
import { getKeeperReports, ReportsScope } from './reports.service';
import { asyncHandler } from '../../middleware/asyncHandler';

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

const parseDate = (raw: unknown, fallback: Date, label: string): Date => {
  const s = String(raw ?? '').trim();
  if (!s) return fallback;
  if (!DATE_RE.test(s)) throw new Error(`تاریخ ${label} نامعتبر است`);
  const [y, m, d] = s.split('-').map(Number);
  const date = new Date(Date.UTC(y, m - 1, d));
  if (Number.isNaN(date.getTime())) throw new Error(`تاریخ ${label} نامعتبر است`);
  return date;
};

export const reportsController = {
  overview: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const warehouseId = req.user!.warehouseId as string;
    if (!warehouseId) return res.status(400).json({ error: 'انباری به این کاربر متصل نیست' });

    // بازهٔ پیش‌فرض: ۳۰ روز اخیر (شامل امروز)
    const now = new Date();
    const todayUtc = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
    const fromDefault = new Date(todayUtc.getTime() - 29 * 86_400_000);

    const from = parseDate(req.query.from, fromDefault, 'شروع');
    const to = parseDate(req.query.to, todayUtc, 'پایان');
    if (to < from) return res.status(400).json({ error: 'تاریخ پایان قبل از تاریخ شروع است' });

    const scopeRaw = String(req.query.scope ?? 'mine');
    const scope: ReportsScope = scopeRaw === 'all' ? 'all' : 'mine';

    const toExclusive = new Date(Date.UTC(to.getUTCFullYear(), to.getUTCMonth(), to.getUTCDate() + 1));
    const data = await getKeeperReports({ warehouseId, userId, from, toExclusive, scope });
    res.json(data);
  }),
};