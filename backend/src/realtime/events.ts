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

  // Notifications
  NOTIFICATION = 'notification',
}
