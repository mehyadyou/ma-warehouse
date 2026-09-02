import { Server } from 'socket.io';

type RoleString = 'MANAGER' | 'WAREHOUSE_KEEPER' | 'DRIVER';

interface RealtimeServer {
  toRole(role: RoleString, event: string, data: unknown): void;
  toUser(userId: string, event: string, data: unknown): void;
  toWarehouse(warehouseId: string, event: string, data: unknown): void;
  toRoles(roles: RoleString[], event: string, data: unknown): void;
  moveUserToWarehouse(userId: string, warehouseId: string | null): void;
}

class RealtimeStub implements RealtimeServer {
  private _io: Server | null = null;

  init(io: Server) {
    this._io = io;
  }

  toRole(role: RoleString, event: string, data: unknown) {
    this._io?.to(`role:${role}`).emit(event, data);
  }

  toUser(userId: string, event: string, data: unknown) {
    this._io?.to(`user:${userId}`).emit(event, data);
  }

  toWarehouse(warehouseId: string, event: string, data: unknown) {
    this._io?.to(`warehouse:${warehouseId}`).emit(event, data);
  }

  toRoles(roles: RoleString[], event: string, data: unknown) {
    roles.forEach((r) => this.toRole(r, event, data));
  }

  /// انتقال سوکت‌های یک کاربر به اتاق انبار جدید — وقتی انبار راننده عوض می‌شود
  /// (تیک انباردار) باید سوکتش از اتاق قبلی خارج و به اتاق جدید/خالی منتقل شود
  /// تا رویدادهای زنده مثل order:created و scanout:done را درست دریافت کند.
  moveUserToWarehouse(userId: string, warehouseId: string | null) {
    if (!this._io) return;
    this._io.sockets.sockets.forEach((s) => {
      if (s.data?.userId !== userId) return;
      if (s.data?.warehouseId) s.leave(`warehouse:${s.data.warehouseId}`);
      s.data.warehouseId = warehouseId ?? undefined;
      if (warehouseId) s.join(`warehouse:${warehouseId}`);
    });
  }
}

export const realtime = new RealtimeStub();
