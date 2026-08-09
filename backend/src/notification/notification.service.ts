import { prisma } from '../utils/prisma';
import { realtime } from '../realtime/realtime';
import { RealtimeEvents } from '../realtime/events';

export const notificationService = {
  create: async (
    userId: string,
    title: string,
    body: string,
    type: 'info' | 'success' | 'warning' | 'error' = 'info',
    data?: Record<string, unknown>,
  ) => {
    // اگر کاربر برای این رویداد نوتیفیکیشن را خاموش کرده باشد، ارسال نمی‌شود
    const eventType = data?.type;
    if (eventType) {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { notificationSettings: true },
      });
      const settings = (user?.notificationSettings as Record<string, boolean> | null) ?? {};
      if (settings[String(eventType)] === false) return null;
    }

    const notification = await prisma.notification.create({
      data: { userId, title, body, type, data: data as any },
    });
    realtime.toUser(userId, RealtimeEvents.NOTIFICATION, {
      id:        notification.id,
      title:     notification.title,
      body:      notification.body,
      type:      notification.type,
      isRead:    notification.isRead,
      data:      notification.data,
      createdAt: notification.createdAt,
    });
    return notification;
  },

  list: async (userId: string, limit = 50) => {
    return prisma.notification.findMany({
      where:   { userId },
      orderBy: { createdAt: 'desc' },
      take:    limit,
    });
  },

  unreadCount: async (userId: string) => {
    return prisma.notification.count({ where: { userId, isRead: false } });
  },

  markRead: async (userId: string, ids?: string[]) => {
    const where = ids?.length ? { userId, id: { in: ids } } : { userId };
    await prisma.notification.updateMany({ where, data: { isRead: true } });
  },

  clearAll: async (userId: string) => {
    await prisma.notification.deleteMany({ where: { userId } });
  },
};
