import 'dotenv/config'
import { defineConfig } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    // مهاجرت‌ها با رول ma_migrator (دسترسی DDL) اجرا می‌شوند؛
    // رانتایم با ma_app (فقط DML) به دیتابیس متصل است.
    // توجه: DATABASE_POOL_URL (pgbouncer) در اینجا استفاده نمی‌شود چون pgbouncer
    // تراکنش‌های آماده‌سازی DDL را پشتیبانی نمی‌کند — رانتایم آن را در src/utils/prisma.ts می‌خواند.
    url:
      process.env.MIGRATOR_URL ??
      process.env.DATABASE_URL ??
      'postgresql://postgres:postgres@localhost:5433/ma_warehouse?schema=public',
    // شَدو دیتابیس مهاجرت (با اجازه CREATEDB که به ma_migrator در دوا داده شده)
    shadowDatabaseUrl:
      process.env.SHADOW_DATABASE_URL ??
      process.env.MIGRATOR_URL?.replace(/\/ma_warehouse(\?|$)/, '/ma_warehouse_shadow$1'),
  },
  migrations: {
    path: 'prisma/migrations',
  },
})
