export enum RealtimeEvents {
  // Users
  USER_CREATED       = 'user:created',
  USER_DELETED       = 'user:deleted',
  USER_FORCE_LOGOUT  = 'user:force:logout',

  // Warehouses
  WAREHOUSE_CREATED = 'warehouse:created',

  // Products
  PRODUCT_CREATED       = 'product:created',
  PRODUCT_DELETED       = 'product:deleted',
  PRODUCT_MODEL_DELETED = 'product:model:deleted',

  // Orders
  ORDER_CREATED        = 'order:created',
  ORDER_UPDATED        = 'order:updated',
  ORDER_DELETED        = 'order:deleted',
  ORDER_STATUS_CHANGED = 'order:status:changed',

  // Inventory / cartons
  CARGO_ENTRY         = 'cargo:entry',
  CHECKIN_COMPLETED   = 'checkin:completed',
  SCANOUT_DONE        = 'scanout:done',
  QR_ERROR            = 'qr:error',

  // Delivery
  DELIVERY_COMPLETED  = 'delivery:completed',
  ORDER_ASSIGNED      = 'order:assigned',

  // بار از راننده گرفته شد و به رانندهٔ دیگری واگذار شد — پنل رانندهٔ قبلی همان لحظه پاک می‌شود
  ORDER_UNASSIGNED    = 'order:unassigned',

  // Drivers (اتصال/قطع راننده به انبار توسط انباردار)
  DRIVER_ASSIGNED     = 'driver:assigned',

  // Carriers (بازچینی صف بارگیری توسط انباردار — پنل راننده همان لحظه به‌روز می‌شود)
  CARRIERS_REORDERED  = 'carriers:reordered',

  // Transfers (دستورهای جابه‌جایی/خروج مدیر — چرخهٔ زندگی: صادر → اجرا → لغو)
  TRANSFER_CREATED    = 'transfer:created',
  TRANSFER_COMPLETED  = 'transfer:completed',
  TRANSFER_CANCELED   = 'transfer:canceled',

  // Notifications
  NOTIFICATION = 'notification',
}
