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
    const entries = await dashboardService.getHistory();
    res.json({ entries });

  }),
};