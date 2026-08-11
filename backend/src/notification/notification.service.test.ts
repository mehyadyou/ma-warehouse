import { describe, it, expect, vi, beforeEach } from 'vitest';

const mocks = vi.hoisted(() => {
    const user = { findUnique: vi.fn() };
    const notification = { create: vi.fn(), createMany: vi.fn(), findUnique: vi.fn() };
    return { user, notification, toUser: vi.fn() };
});

vi.mock('../utils/prisma', () => ({
    prisma: {
        user: mocks.user,
        notification: mocks.notification,
    },
}));

vi.mock('../realtime/realtime', () => ({
    realtime: { toUser: mocks.toUser },
}));

import { notificationService } from './notification.service';

const NOTIF = {
    id: 'n1',
    title: 'عنوان',
    body: 'متن',
    type: 'info',
    isRead: false,
    data: null,
    createdAt: new Date(),
};

beforeEach(() => {
    vi.clearAllMocks();
    mocks.user.findUnique.mockResolvedValue({ notificationSettings: null });
});

describe('notificationService.create — dedupeKey (N2)', () => {
    it('کلید جدید: نوتیفیکیشن ساخته می‌شود و ریل‌تایم emit می‌شود', async () => {
        mocks.notification.createMany.mockResolvedValue({ count: 1 });
        mocks.notification.findUnique.mockResolvedValue(NOTIF);

        const result = await notificationService.create('u1', 'عنوان', 'متن', 'info', { type: 'NEW_ORDER' }, 'ev1:u1');

        expect(mocks.notification.createMany).toHaveBeenCalledWith(
            expect.objectContaining({ skipDuplicates: true }),
        );
        expect(mocks.toUser).toHaveBeenCalledTimes(1);
        expect(mocks.toUser).toHaveBeenCalledWith('u1', expect.anything(), expect.objectContaining({ id: 'n1' }));
        expect(result?.id).toBe('n1');
    });

    it('retry با کلید تکراری: نه ساخته می‌شود نه emit می‌شود', async () => {
        mocks.notification.createMany.mockResolvedValue({ count: 0 });
        mocks.notification.findUnique.mockResolvedValue(NOTIF);

        const result = await notificationService.create('u1', 'عنوان', 'متن', 'info', { type: 'NEW_ORDER' }, 'ev1:u1');

        expect(mocks.toUser).not.toHaveBeenCalled();
        expect(result?.id).toBe('n1');
    });

    it('بدون dedupeKey: رفتار قبلی (create + emit) حفظ می‌شود', async () => {
        mocks.notification.create.mockResolvedValue(NOTIF);

        const result = await notificationService.create('u1', 'عنوان', 'متن', 'info');

        expect(mocks.notification.create).toHaveBeenCalledTimes(1);
        expect(mocks.toUser).toHaveBeenCalledTimes(1);
        expect(result?.id).toBe('n1');
    });
});
