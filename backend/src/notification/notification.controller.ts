import { Request, Response } from 'express';
import { notificationService } from './notification.service';
import { prisma } from '../utils/prisma';
import { asyncHandler } from '../middleware/asyncHandler';

// کلیدهای پیش‌فرض = همهٔ نوع‌های اعلانی که سیستم ارسال می‌کند — تا (۱) toggle هر نوع در UI
// کار کند و (۲) updateSettings هرگز کلیدی را بی‌صدا حذف نکند (فقط کلیدهای همین لیست پذیرفته می‌شوند)
export const DEFAULT_NOTIFICATION_SETTINGS = {
  // ورود/خروج کالا (انبار → مدیر)
  CARGO_ENTRY:    true,
  RETURN_ENTRY:   true,
  SCAN_OUT:       true,
  SCAN_OUT_ERROR: true,
  // سفارش‌ها (مدیر → انبار)
  NEW_ORDER:      true,
  ORDER_UPDATED:  true,
  ORDER_DELETED:  true,
  // دستورهای جابه‌جایی/خروج مدیر (مدیر → انبار)
  TRANSFER_CREATED:    true,
  EXIT_CREATED:        true,
  TRANSFER_EXECUTED:   true,
  EXIT_EXECUTED:       true,
  TRANSFER_COMPLETED:  true,
  TRANSFER_CANCELED:   true,
  // تحویل راننده (راننده → مدیر/انبار)
  DELIVERY_COMPLETED:  true,
  // تخصیص/حذف بار (انبار → راننده و مدیر)
  DRIVER_ORDER_ASSIGNED: true,
  DRIVER_ORDER_REMOVED:  true,
  DRIVER_ASSIGNED:       true,
  DRIVER_UNASSIGNED:     true,
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
