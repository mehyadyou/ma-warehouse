import { Server } from 'socket.io';

type RoleString = 'MANAGER' | 'WAREHOUSE_KEEPER' | 'DRIVER';

interface RealtimeServer {
  toRole(role: RoleString, event: string, data: unknown): void;
  toUser(userId: string, event: string, data: unknown): void;
  toWarehouse(warehouseId: string, event: string, data: unknown): void;
  toRoles(roles: RoleString[], event: string, data: unknown): void;
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
}

export const realtime = new RealtimeStub();
