import { Request, Response } from 'express';
import { dashboardService } from './dashboard.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const dashboardController = {
  dashboard: asyncHandler(async (req: Request, res: Response) => {
    const data = await dashboardService.getDashboard();
    res.json({ message: 'داشبورد مدیر', data });

  }),

  getAllTransactionsByDate: asyncHandler(async (req: Request, res: Response) => {
    const date = req.query.date as string;
    const transactions = await dashboardService.getAllTransactionsByDate(date);
    res.json({ transactions });

  }),

  getRecentActivities: asyncHandler(async (req: Request, res: Response) => {
    const activities = await dashboardService.getRecentActivities();
    res.json(activities);

  }),

  getHistory: asyncHandler(async (req: Request, res: Response) => {
    const { page, pageSize, category, q } = req.query;
    const result = await dashboardService.getHistory({
      page: typeof page === 'string' && page !== '' ? Number(page) : undefined,
      pageSize: typeof pageSize === 'string' && pageSize !== '' ? Number(pageSize) : undefined,
      category: typeof category === 'string' ? category : undefined,
      q: typeof q === 'string' ? q : undefined,
    });
    res.json(result);
  }),
};