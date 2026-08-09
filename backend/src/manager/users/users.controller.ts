import { Request, Response } from 'express';
import { usersService } from './users.service';
import { asyncHandler } from '../../middleware/asyncHandler';

export const usersController = {
  getAllUsers: asyncHandler(async (req: Request, res: Response) => {
    const users = await usersService.getAllUsers();
    res.json({ users });

  }),

  getUserReport: asyncHandler(async (req: Request, res: Response) => {
    const report = await usersService.getUserReport(req.params.id as string);
    res.json(report);

  }),

  createUser: asyncHandler(async (req: Request, res: Response) => {
    const { name, phone, password, role, warehouseId } = req.body;
    const user = await usersService.createUser(name, phone, password, role, warehouseId, req.user!.id);
    res.status(201).json({ message: 'کاربر با موفقیت ساخته شد', user });

  }),

  updateUser: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.params.id as string;
    const { name, phone, password, role, warehouseId } = req.body;
    const user = await usersService.updateUser(userId, { name, phone, password, role, warehouseId }, req.user!.id);
    res.json({ message: 'کاربر ویرایش شد', user });

  }),

  deleteUser: asyncHandler(async (req: Request, res: Response) => {
    const result = await usersService.deleteUser(req.params.id as string, req.user!.id);
    res.json(result);

  }),
};