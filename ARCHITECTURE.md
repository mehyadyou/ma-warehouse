# معماری MA Warehouse (نقشه یک‌صفحه‌ای + تصمیم‌ها)

> این سند «چرایی» ساختار است، نه آموزش نصب (نصب: `backend/docs/`).

## نقشه مونورپو

```
ma-warehouse/
├── backend/            # API واحد (Node 22 + Express 4 + Prisma 7 + PostgreSQL 16 + Redis 7)
│   └── src/
│       ├── auth/                 # ورود، JWT چرخشی، RBAC، سیاست رمز
│       ├── manager/              # ۱۳+ دامنه مدیریتی (+ crm/ فقط‌خواندنی مالک)
│       ├── warehouse_keeper/     # ورود/خروج/انتقال/گزارش انبار
│       ├── driver/               # تحویل و برنامه بار راننده
│       ├── badge/ notification/ realtime/ # بیجک، اعلان، سوکت + Outbox dispatcher
│       ├── api_keys/ app_updates/ public_api/  # کلید API، OTA، API عمومی v1
│       ├── middleware/ config/ common/ utils/  # لایه‌های عرضی
│       └── *.service.test.ts     # تست کنار سورس (vitest)
├── mobile/             # اپ Flutter سه‌نقشه (مدیر/انباردار/راننده) — اندروید/iOS/وب
├── desktop_panel/      # پنل ویندوز انبار (چاپ QR/بیجک) — فقط WAREHOUSE_KEEPER
└── crm_panel/          # پنل ویندوز مالک (نظارت فقط‌خواندنی + مدیریت کلید) — فقط MANAGER
```

جریان داده: کلاینت‌ها → REST (`/api/*` داخلی + `/api/v1` عمومی با کلید) → Prisma → PostgreSQL (از طریق PgBouncer)؛ رویدادها → جدول Outbox (تراکنشی) → dispatcher → سوکت + نوتیف.

## تصمیم‌های ثبت‌شده (ADRs خلاصه)

1. **PgBouncer در حالت session (نه transaction)** — درایور pg از prepared statement استفاده می‌کند؛ تغییر حالت نیازمند `?pgbouncer=true` + تست بار است. (`backend/docker/pgbouncer.ini`)
2. **هرگز `migrate dev` روی DB تیون‌شده** — ایندکس‌های raw مثل trgm در diff برمی‌گردند؛ فقط SQL دستی + `migrate deploy`. (`docs/db-ops.md`)
3. **PIN شش‌رقمی برای نقش‌های عملیاتی، رمز قوی برای مدیر** — انباردار با دستکش کار می‌کند؛ مدیر دسترسی کامل دارد. (`src/common/password.ts`)
4. **شماره سفارش روزانه + سریال سالانه با جدول شمارنده اتمی** — نه `count+1` (رقابت در پیک). (`OrderDaySequence`, `SerialSequence`)
5. **Idempotency فقط برای «ثبت»ها** (ورود/خروج) — خواندن‌ها idempotent ذاتی‌اند.
6. **دو پنل دسکتاپ جدا، بدون پکیج مشترک (فعلاً)** — اندازه‌گیری ۱۴۰۵/۰۶: از کل `core/` فقط `palette.dart` یکسان است (۰ خط فرق)؛ بقیه (api/socket/login/workspace) عمیقاً واگرا شده‌اند. استخراج پکیج برای ۱ فایل ۲۱ خطی هزینه > فایده است. **تریگر بازنگری:** اگر فایل دومی همگرا شد یا یک باگ مشترک در هر دو تکرار شد.
7. **سکرت‌ها هرگز در گیت نیستند** — فقط `.env.example`. استثنای تاریخی `.env.staging` هرگز کامیت نشد (فقط لوکال).
8. **فایل‌های امنیتی DB کنار داکرند** — `backend/docker/pg_hba_final.conf` (قبلاً سرگردان در روت بود).
9. **CI روی main + تگ نسخه** — گیت مایگریشن روی Postgres واقعی + آدیت وابستگی‌ها؛ انتشارها با تگ `vX.Y.Z`.
10. **CRM فقط‌خواندنی است** — تنها نوشتنِ مجاز پنل مالک، مدیریت کلیدهاست (همان APIهای موجود). هر گزارش جدید = endpoint GET جدید با سقف صفحه‌بندی، نه تغییر endpoint موجود.

## قراردادهای کدنویسی

- خطا: `AppError` → `errorHandler` مرکزی؛ پیام‌ها فارسی و کاربرپسند.
- اعتبارسنجی ورودی: zod در لبه (`validate`), سیاست دامنه در سرویس.
- Decimal دیتابیس فقط برای نمایش به Number (L5) — محاسبه مالی روی Decimal.
- تست‌ها: unit با Prisma mock؛ integration واقعی فقط روی staging.
- فارسی/شمسی: روز کاری تهران (`jalaliDayKey`)، اعداد نمایشی فارسی در UI.
- کامیت‌ها: فارسی، دستوری، با scope (`feat/fix/test/docs/ops:`).
