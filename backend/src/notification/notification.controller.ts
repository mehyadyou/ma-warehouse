import { Request, Response } from 'express';
import { notificationService } from './notification.service';
import { prisma } from '../utils/prisma';
import { asyncHandler } from '../middleware/asyncHandler';

export const DEFAULT_NOTIFICATION_SETTINGS = {
  CARGO_ENTRY:   true,
  RETURN_ENTRY:  true,
  SCAN_OUT:      true,
  SCAN_OUT_ERROR: true,
  NEW_ORDER:     true,
  ORDER_DELETED: true,
} as const;

export const notificationController = {
  list: asyncHandler(async (req: Request, res: Response) => {
    const limit = parseInt(String(req.query.limit ?? '50'), 10);
    const items = await notificationService.list(req.user!.id, limit);
    res.json(items);

  }),

  unreadCount: asyncHandler(async (req: Request, res: Response) => {
    const count = await notificationService.unreadCount(req.user!.id);
    res.json({ count });

  }),

  markRead: asyncHandler(async (req: Request, res: Response) => {
    const ids: string[] | undefined = Array.isArray(req.body?.ids) ? req.body.ids : undefined;
    await notificationService.markRead(req.user!.id, ids);
    res.json({ ok: true });

  }),

  clearAll: asyncHandler(async (req: Request, res: Response) => {
    const deleted = await notificationService.clearAll(req.user!.id);
    res.json({ ok: true, deleted });

  }),

  getSettings: asyncHandler(async (req: Request, res: Response) => {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
      select: { notificationSettings: true },
    });
    const stored = (user?.notificationSettings as Record<string, boolean> | null) ?? {};
    const settings = { ...DEFAULT_NOTIFICATION_SETTINGS, ...stored };
    res.json({ settings });

  }),

  updateSettings: asyncHandler(async (req: Request, res: Response) => {
    const incoming = (req.body?.settings ?? {}) as Record<string, unknown>;
    const settings: Record<string, boolean> = {};
    for (const key of Object.keys(DEFAULT_NOTIFICATION_SETTINGS)) {
      if (typeof incoming[key] === 'boolean') settings[key] = incoming[key];
    }
    await prisma.user.update({
      where: { id: req.user!.id },
      data: { notificationSettings: settings },
    });
    res.json({ settings });

  }),
};
