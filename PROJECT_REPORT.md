# گزارش کامل پروژه «ما — مدیریت انبار» (MA Warehouse)

> تاریخ گزارش: ۲۰۲۶-۰۹-۰۵ · تهیه‌شده برای تحویل به متخصص خارجی · بر اساس بازرسی مستقیم کل مخزن

---

## ۱) پروژه در یک نگاه

سیستم جامع **مدیریت انبار، سفارش، توزیع و تحویل** کاملاً بومی‌شده برای ایران: تقویم شمسی در تمام لایه‌ها (شماره‌گذاری روزانهٔ سفارش بر مبنای روزِ کاری تهران، سریال کارتن به‌تفکیک سال شمسی، فیلترهای تاریخ شمسی)، رابط کاربری فارسی RTL، و چرخهٔ فیزیکی کامل کالا از «چاپ لیبل QR» تا «تحویل به مشتری نهایی».

**Monorepo با یک بک‌اند و سه کلاینت:**

| بخش | فناوری | کاربر |
|---|---|---|
| `backend/` | Node.js + TypeScript + Express 4 + Prisma 7 + PostgreSQL 16 + Redis 7 | سرور مرکزی (REST + WebSocket) |
| `mobile/` | Flutter (Dart 3.11) + Riverpod | مدیر / انباردار / راننده (اندروید، iOS، وب) |
| `desktop_panel/` | Flutter Desktop (ویندوز) | ایستگاه انبار: چاپ لیبل QR و برگهٔ بیجک |

**آمار کد (بدون کدِ تولیدشده):**

| | فایل سورس | خط سورس | فایل تست | خط تست |
|---|---|---|---|---|
| backend (TS) | ۱۰۵ | ~۱۲,۴۰۰ | ۳۲ | ~۷,۷۰۰ |
| mobile (Dart) | ۲۱۸ | ~۶۳,۲۰۰ | ۲۹ | ~۳,۸۰۰ |
| desktop_panel (Dart) | ۱۸ | ~۶,۴۰۰ | ۱۰ | ~۱,۴۰۰ |

**تست‌ها:** ۳۹۰ تست بک‌اند (Vitest) + ۱۳۱ تست موبایل + ۱۰ فایل تست پنل — همگی سبز.

---

## ۲) استک فناوری

### بک‌اند (`backend/`)
| فناوری | نسخه | نقش |
|---|---|---|
| Node.js + TypeScript | TS 5.7 (module Node16) | رانتیم و زبان |
| Express | 4.21 | HTTP framework (REST) |
| Prisma + @prisma/adapter-pg | 7.8 | ORM + مهاجرت‌ها + درایور pg |
| PostgreSQL 16 | docker (پورت 5433) | بانک اصلی — TLS اجباری، pg_stat_statements، WAL archive |
| PgBouncer | edoburu (پورت 6432) | استخر اتصال رانتایم (scram + TLS) |
| Redis 7 (ioredis) | docker (پورت 6379) | سوکت/نوبت‌دهی، AOF روشن |
| socket.io | 4.8 | Realtime (اتاق‌های user/role/warehouse) |
| openai (SDK) | 7.5 | دستیار هوش مصنوعی (سازگار با هر endpoint اوپن‌AI) |
| zod | 4.4 | اعتبارسنجی ورودی |
| jsonwebtoken / bcryptjs | 9 / 3 | JWT + هش رمز |
| pino | 10 | لاگ ساختاریافته با requestId |
| helmet / cors / multer | — | امنیت هدرها، CORS، آپلود فایل |
| pgsql-ast-parser | 12 | پارس AST کوئری‌های SQL دستیار (گارد امنیتی) |
| Vitest | 4 | تست (globals، فقط `src/**/*.test.ts`) |

### موبایل (`mobile/`)
| فناوری | نقش |
|---|---|
| Flutter 3.x / Dart ^3.11.5 | فریمورک (اندروید + iOS + وب) |
| flutter_riverpod 3 + riverpod_annotation | مدیریت state |
| go_router 17 | ناوبری declarative |
| dio 5 | HTTP client |
| socket_io_client | Realtime |
| flutter_secure_storage / shared_preferences | توکن در Keystore/Keychain + ترجیحات |
| freezed + json_serializable | مدل‌های immutable + codegen (`.freezed.dart` / `.g.dart`) |
| mobile_scanner | اسکن QR کارتن |
| local_auth + crypto | قفل بیومتریک اپ + هش |
| pdf + printing + share_plus + path_provider | ساخت/اشتراک PDF فاکتور |
| shamsi_date | تقویم شمسی سمت کلاینت |
| speech_to_text 7 | دیکتهٔ فارسی در دستیار |
| flutter_markdown | رندر پاسخ دستیار |
| image_picker | آپلود آواتار/عکس بیجک |
| فونت Vazirmatn (Regular/Bold) | فونت فارسی فاکتورها |

### پنل دسکتاپ (`desktop_panel/`)
| فناوری | نقش |
|---|---|
| Flutter Windows (Dart ^3.12) | اپ دسکتاپ انبار |
| qr + qr_flutter + pdf + printing | تولید و چاپ لیبل QR و برگهٔ بیجک |
| dio + socket_io_client | API + Realtime |
| shared_preferences | تنظیمات چاپگر |

### زیرساخت
- `docker-compose.yml`: PostgreSQL 16 (tuned: shared_buffers=2GB، statement_timeout=30s، archive_mode=on، WAL archiving)، Redis 7 (AOF)، PgBouncer (userlist با هش SCRAM).
- `pg_hba_final.conf`: بدون trust — همه‌جا scram-sha-256؛ TCP فقط با TLS؛ hostnossl reject.
- `ecosystem.config.cjs`: PM2 برای بار تستِ staging.
- `scripts/backup.ps1|sh` / `restore.ps1|sh` / `verify-backup.ps1` / `db-health.ps1`: پشتیبان‌گیری/بازیابی و سلامت.
- `docs/db-ops.md`: Runbook عملیاتی (چرخش رمز ۶ ماهه، نقش‌ها، PgBouncer).

---

## ۳) معماری کلان

```
                    ┌──────────────────────┐
   اپ موبایل ───────▶│                      │──▶ PostgreSQL 16 ◀── PgBouncer ◀─┐
   (Flutter:         │   Express REST API   │        (TLS + scram،             │
    مدیر/انباردار/   │   /api/auth          │         رول فقط-DML: ma_app)     │
    راننده)          │   /api/manager       │                                  │
                     │   /api/warehouse-…   │──▶ Redis 7 (سوکت/نوبت)          │
   پنل دسکتاپ ──────▶│   /api/driver        │                                  │
   (چاپ QR/بیجک)     │   /api/badges        │◀── WebSocket (socket.io) ────────┘
                     │   /api/notifications │    اتاق‌ها: user:{id} | role:{r} | warehouse:{id}
                     └──────────┬───────────┘
                                │ Transactional Outbox
                                ▼
                     جدول OutboxEvent (PENDING) ──dispatcher هر ۱ ثانیه──▶ سوکت + Notification
```

**الگوهای معماری برجسته:**

1. **Transactional Outbox** — هر رویداد دامنه (سفارش/تحویل/انتقال) داخل همان تراکنش DB در `OutboxEvent` نوشته می‌شود؛ dispatcher دومیشنی آن را تحویل می‌دهد (attempts/lastError/claimedAt = retry امن). ایندکس جزئی فقط PENDING را اسکن می‌کند.
2. **لایه‌بندی ماژولار** — هر دامنه `service / controller (/ schema) / test`؛ سرویس منطق و DB، کنترلر HTTP، `asyncHandler` خطاها را به `errorHandler` مرکزی می‌برد.
3. **RBAC سه‌نقشی** — `MANAGER / WAREHOUSE_KEEPER / DRIVER` با middleware `authenticate` + `authorize`؛ مسیرها به‌تفکیک نقش mount شده‌اند.
4. **دفاع در عمق برای دستیار AI** — مدل زبانی SQL تولید می‌کند؛ سه لایه: `sql-guard` (پارس AST، فقط SELECT تک‌عبارتی، سقف ۸۰۰۰ کاراکتر، ماسک ستون‌های حساس) → اجرا در تراکنش `READ ONLY` با `statement_timeout` و سقف ردیف → ماسک خروجی. پیکربندی مدل در دیتابیس (`AssistantConfig`) با fallback به env — تعویض مدل بدون تغییر کد.
5. **شمارش سریال اتمی** — `SerialSequence` (به‌تفکیک سال شمسی) داخل همان تراکنشِ ورود کالا افزایش می‌یابد؛ سریال: `MA-<سال>-<شمارهٔ ۶ رقمی>` (مثل `MA-1405-000024`).
6. **شمارهٔ سفارش روزانه** — `orderDay` (کلید روز شمسی تهران) + `orderNumber` با unique ترکیبی؛ هر روز از ۱ (منطق `jalaliDayKey` با timezone Asia/Tehran).
7. **انتقال دوفازی** — `Transfer` با وضعیت `PENDING→DONE/CANCELED`؛ اسکن کارتن‌ها مرحلهٔ دوم است؛ انصراف فقط وقتی اسکنی انجام نشده.
8. **QR امضاشده** — هر کارتن `qrPayload` + `hmac` (با `QR_SECRET`) دارد؛ `qrUuid` جدا برای چرخهٔ چاپ؛ جعل لیبل عملاً ناممکن.
9. **Idempotency** — `IdempotencyKey` (user, operation, key) برای ورود/خروج کالا؛ دابل‌اسکن یا قطع‌وشدن شبکه دوباره ثبت نمی‌کند.
10. **Optimistic concurrency** — فیلد `version` روی User/Warehouse/Product/Carton برای تشخیص تداخل هم‌زمانی.
11. **Soft-delete همه‌جا** — `deletedAt` روی User/Warehouse/Product/ProductModel؛ تاریخچه هرگز سخت حذف نمی‌شود؛ ایندکس‌های partial فقط رکوردهای فعال.
12. **Refresh Token Rotation** — فقط هش توکن ذخیره می‌شود (`RefreshToken.tokenHash`)، با `revokedAt/replacedBy` و `tokenVersion` روی کاربر برای ابطال سراسری.
13. **Audit Log** — `AuditLog` (actor, action, entity, before/after JSON, ip) برای تغییرات حساس.

---

## ۴) مدل داده (Prisma — ۱۶ مدل، ۹ enum)

**چرخهٔ کالا:** `Product` → `ProductModel` (مدل/رنگ/بسته‌بندی) → `Carton` (واحد فیزیکی با QR؛ `isIndividual` برای فروش تکی، `entryType` NEW/RETURNED، `status` IN_STOCK/SHIPPED/RETURNED/EXITED، `printedAt` جدا از موجودی) → `Transaction` (IN/OUT/RETURN) → `Order`/`OrderItem` → `Delivery` (راننده؛ عکس بیجک باربری پیش‌شرط ثبت تحویل).

**ارکان عملیاتی:** `Warehouse`، `User` (با قفل حساب: `failedLoginAttempts/lockUntil/mustChangePassword`)، `Carrier` (باربری‌ها؛ نام به‌صورت متن در سفارش می‌ماند تا تاریخچه پایدار بماند)، `Badge` (برگهٔ بیجک با snapshot فرستنده/گیرنده — از ویرایش‌های بعدی مستقل)، `Transfer`، `SerialSequence`.

**ارکان سیستمی:** `ActivityLog` (۲۴ نوع رویداد برای «فعالیت‌های اخیر»، حتی بعد از حذف سفارش)، `Notification` (`dedupeKey` یونیک ضد تکرار، ایندکس جزئی خوانده‌نشده‌ها)، `OutboxEvent`، `IdempotencyKey`، `AuditLog`، `RefreshToken`، `AssistantConfig` (پیکربندی مدل AI).

**بهینه‌سازی‌های DB:** ایندکس‌های GIN/trgm روی نام محصول/انبار و سریال (جستجوی فارسی ILIKE سریع)، ایندکس‌های partial (رکوردهای فعال، نوتیف خوانده‌نشده، outbox در انتظار)، ایندکس‌های ترکیبی منطبق با کوئری‌ها (مثل `[warehouseId, createdAt desc]`).

---

## ۵) زیرسیستم‌های کلیدی

### بک‌اند
| ماژول (مسیر) | توضیح |
|---|---|
| `auth/` | ورود با قفل تدریجی، access 5m + refresh چرخشی 14d، تغییر رمز اجباری |
| `manager/` | ۱۳ ماژول: dashboard، users، warehouses، products، orders، inventory، search (serial/shipments)، rate (نرخ دلار tgju)، shipments، transfers (دوفازی)، delivery_inbox (صندوق عکس بیجک با فیلتر شمسی)، assistant (+config)، product_history |
| `warehouse_keeper/` | checkin (ورود کالا + سریال‌گذاری اتمی)، scanout (خروج با اسکن)، carriers، drivers، labels، loadingplan، qrcode، reports، warehouse |
| `driver/` | orders، delivery (ثبت تحویل با عکس بیجک)، loadingplan (برنامهٔ بارگیری)، profile |
| `badge/` | برگهٔ بیجک سفارش + عکس و چاپ |
| `notification/` | نوتیف درون‌برنامه‌ای با dedupe |
| `realtime/` | socket.io (اتاق user/role/warehouse) + Outbox dispatcher + cleanup روزانه |
| `utils/` | `jalali.ts` (تبدیل شمسی/میلادی، `jalaliDayKey` تهران، `tehranDayRange`)، `qr.ts` (HMAC)، `serial.ts`، `audit.ts`، `cache.ts`، `cleanup.ts`، `imageUpload.ts`، `serializableTx.ts` |

### موبایل (فلوتر)
| بخش | توضیح |
|---|---|
| `core/` | dio client + interceptor توکن، api_error، router، تم تیرهٔ RTL، socket_service، نوتیفیکیشن، secure/local storage |
| `features/auth` | اسپلش/ورود + **قفل اپ** (بیومتریک local_auth با life-cycle observer) |
| `features/manager` | داشبورد (نمودار موجودی، فعالیت‌ها)، محصولات، سفارش‌ها/ارسالی‌ها، انبارها/کاربران/گزارش‌ها، جابه‌جایی، صندوق تحویل، **فاکتور PDF** (builder + generator + مبلغ به حروف + خروجی PNG/PDF وب و موبایل)، **دستیار AI** (چت + **دیکتهٔ فارسی** speech_to_text + تنظیمات مدل در تنظیمات مدیر)، **سابقهٔ محصولات** (لیست تجمیعی + تایم‌لاین کامل کارتن/تراکنش/انتقال با فیلترهای دقیق و تاریخ شمسی دقیق) |
| `features/warehouse_keeper` | ورود کالا (اسکن)، خروج/اسکن‌اوت، موجودی، سفارش‌ها، باربری‌ها، راننده‌ها، برنامهٔ بارگیری، گزارش‌ها |
| `features/driver` | داشبورد راننده: تحویل، تاریخچه، برنامهٔ بار |
| `shared/` | ابزار اعداد فارسی، ویجت‌های مشترک، تقویم شمسی (month picker روزِ دقیق)، تنظیمات |

### پنل دسکتاپ
ورود → Workspace با تب‌های: کارتن‌ها (چاپ لیبل QR گروهی)، بیجک‌ها، چاپ‌شده‌ها، تراکنش‌ها؛ دیالوگ تنظیمات چاپگر و تنظیمات چاپ بیجک؛ اتصال Realtime برای به‌روزرسانی زنده.

---

## ۶) امنیت (خلاصهٔ ارزیابی)

✅ **قوی:** helmet + CORS با لیست مبدأ (در production خالی = fail-closed)، rate limit پرمیوژ، bcrypt، JWT با چرخش refresh + `tokenVersion`، قفل حساب، RBAC سراسری، تفکیک رول DB (ma_app فقط-DML / ma_migrator فقط-DDL)، PgBouncer با scram، pg_hba بدون trust و TLS-اجباری، HMAC روی QR، Idempotency، AuditLog، گارد SQL سه‌لایهٔ دستیار، ماسک کلید API در پاسخ تنظیمات (فقط tail ۴ کاراکتر).

⚠️ **نکات برای متخصص:** `strict: false` در tsconfig (پیشنهاد: فعال‌سازی تدریجی strictNullChecks)، آپلودها سرو می‌شوند از `/uploads` static (پیشنهاد: هدر Content-Disposition و محدودسازی MIME در Multer بازبینی شود)، CORS در dev با `*`، و `.env` واقعی روی همین ماشین (در git نیست — درست).

---

## ۷) عملیات و استقرار

- اجرا: `npm run dev` (nodemon/ts-node) · build: `tsc` + کپی JSONهای config به dist · prod: `node dist/server.js`
- مهاجرت: `npx prisma migrate deploy` (هرگز `migrate dev` روی دیتای tuned — چون ایندکس‌های raw trgm در diff برمی‌گردند؛ در runbook ثبت شده)
- سلامت: `GET /healthz` (DB + Redis + uptime)
- Pm2 برای staging-loadtest، docker برای سرویس‌های data، پشتیبان‌گیری روزانه + WAL archive + اسکریپت‌های verify/restore

---

## ۸) ساختار درختی کامل پروژه (دقیق — شامل همهٔ فایل‌های متنی)

> پوشه‌های تولیدی/پکج (node_modules، dist، build، .dart_tool، uploads، backups، logs، .idea، .git، ephemeral) یک‌خطی ثبت شده‌اند؛ **هر فایل متنیِ واقعی به‌تفکیک آمده است.**

```
ma-warehouse/                          # ریشهٔ Monorepo
├── .freebuff/                         # state کلاینت Freebuff (gitignore)
├── .git/                              # مخزن Git
├── .idea/                             # تنظیمات IDE (gitignore)
├── .gitignore
├── pg_hba_final.conf                  # سیاست احراز هویت Postgres: scram همه‌جا، TLS اجباری
│
├── backend/                           # ═══ API سرور (Node/TS) ═══
│   ├── .env                           # secrets واقعی (gitignore)
│   ├── .env.example                   # قالب مستند env (DB/سکرت‌ها/AI/Redis/CORS/…)
│   ├── .env.staging                   # env بار تست staging (gitignore)
│   ├── .gitignore
│   ├── docker-compose.yml             # Postgres16 + Redis7 + PgBouncer (tuned)
│   ├── ecosystem.config.cjs           # PM2 (استیجینگ)
│   ├── package.json
│   ├── package-lock.json
│   ├── prisma.config.ts               # رول مهاجرت DDL جدا از رانتایم DML
│   ├── tsconfig.json
│   ├── vitest.config.mts
│   ├── docker/
│   │   ├── pgbouncer.ini              # پیکربندی استخر اتصال
│   │   └── userlist.txt               # هش SCRAM کاربران DB
│   ├── docs/
│   │   ├── db-ops.md                  # Runbook عملیات دیتابیس
│   │   └── price-estimate.md
│   ├── prisma/
│   │   ├── schema.prisma              # ۱۶ مدل + ۹ enum (منبع حقیقت)
│   │   ├── migration_lock.toml
│   │   └── migrations/                # ۴۵ مهاجرت (فهرست کامل):
│   │       ├── 20260528084007_init/migration.sql
│   │       ├── 20260530210524_add_transaction/migration.sql
│   │       ├── 20260530222151_add_products_orders/migration.sql
│   │       ├── 20260530223733_add_model_price_orderitem/migration.sql
│   │       ├── 20260531221222_add_product_models/migration.sql
│   │       ├── 20260601100858_remove_unique_product_name/migration.sql
│   │       ├── 20260601200819_add_shipping_fields/migration.sql
│   │       ├── 20260603000000_add_cartons/migration.sql
│   │       ├── 20260603112219_init/migration.sql
│   │       ├── 20260603124404_add_carrier_and_delivery/migration.sql
│   │       ├── 20260604120000_add_return_fields/migration.sql
│   │       ├── 20260604193749_remove_carrier_table/migration.sql
│   │       ├── 20260605105346_add_sender_receiver_names/migration.sql
│   │       ├── 20260730155730_add_soft_delete_to_user/migration.sql
│   │       ├── 20260731143132_add_avatar_url/migration.sql
│   │       ├── 20260731145938_add_notification_settings/migration.sql
│   │       ├── 20260731160307_add_badges/migration.sql
│   │       ├── 20260803131758_add_activity_log/migration.sql
│   │       ├── 20260803150000_add_soft_delete_product/migration.sql
│   │       ├── 20260803160000_add_soft_delete_warehouse/migration.sql
│   │       ├── 20260804130114_add_order_item_exchange_rate/migration.sql
│   │       ├── 20260808120000_enterprise_schema/migration.sql
│   │       ├── 20260808130000_extend_activity_log_types/migration.sql
│   │       ├── 20260808150000_performance_indexes/migration.sql
│   │       ├── 20260808160000_declare_outbox_pending_idx/migration.sql
│   │       ├── 20260808170000_auto_serial_numbers/migration.sql
│   │       ├── 20260809080000_add_token_version/migration.sql
│   │       ├── 20260809100000_remove_scanned_out_status/migration.sql
│   │       ├── 20260811054826_phase_a_outbox_notification_badge/migration.sql
│   │       ├── 20260811141648_phase_b_transaction_product_id/migration.sql
│   │       ├── 20260811141808_phase_b_orderitem_model_id/migration.sql
│   │       ├── 20260812010000_phase_b_unique_active_names/migration.sql
│   │       ├── 20260818000000_extend_activity_log_warehouse_types/migration.sql
│   │       ├── 20260819000000_add_transfers/migration.sql
│   │       ├── 20260820000000_transfer_two_phase/migration.sql
│   │       ├── 20260822000000_add_order_number/migration.sql
│   │       ├── 20260825000000_add_carton_printed_at/migration.sql
│   │       ├── 20260825110000_add_order_tipax_fields/migration.sql
│   │       ├── 20260827000000_add_badge_snapshot_fields/migration.sql
│   │       ├── 20260827000001_add_badge_item_snapshot/migration.sql
│   │       ├── 20260827000002_add_badge_printed_at/migration.sql
│   │       ├── 20260901000000_add_delivery_receipt_url/migration.sql
│   │       ├── 20260902000000_add_carrier_table/migration.sql
│   │       ├── 20260904000000_order_daily_number/migration.sql
│   │       └── 20260905000000_add_assistant_config/migration.sql
│   ├── scripts/
│   │   ├── backup.ps1  backup.sh      # پشتیبان‌گیری (ویندوز/لینوکس)
│   │   ├── restore.ps1 restore.sh     # بازیابی
│   │   ├── verify-backup.ps1          # صحت‌سنجی پشتیبان
│   │   ├── db-check.ts  db-health.ps1 # سلامت DB
│   │   ├── slow-queries.sql           # کوئری‌های کند pg_stat_statements
│   │   ├── renumber-orders-daily.ts   # بازشماری شمارهٔ روزانهٔ سفارش
│   │   ├── plan-check.ts  khazaei-orders-list.ts  warehouse-orders-count.ts
│   │   ├── carrier-queue-debug.ts  carrier-system-audit.ts  carrier-timestamps.ts
│   │   └── loadtest/
│   │       ├── loadtest.js  seed.ts  staging-run.js
│   ├── src/
│   │   ├── server.ts                  # بوت HTTP+WS، outbox، cleanup، graceful shutdown
│   │   ├── app.ts                     # Express: helmet/CORS/لاگ/healthz/مسیرها/errorHandler
│   │   ├── auth/
│   │   │   ├── auth.controller.ts  auth.routes.ts  auth.schema.ts
│   │   │   ├── auth.service.ts  auth.service.test.ts
│   │   ├── badge/
│   │   │   ├── badge.controller.ts  badge.routes.ts
│   │   │   ├── badge.service.ts  badge.service.test.ts
│   │   ├── common/
│   │   │   ├── exceptions/AppError.ts
│   │   │   └── password.ts
│   │   ├── config/
│   │   │   ├── env.ts  cors.ts  jwt.ts  redis.ts
│   │   │   ├── carriers.json          # باربری‌های پیش‌فرض
│   │   │   └── qr-template.json       # قالب لیبل QR
│   │   ├── driver/
│   │   │   ├── driver.routes.ts
│   │   │   ├── delivery/{delivery.controller,delivery.service,delivery.service.test}.ts
│   │   │   ├── loadingplan/{loadingplan.controller,loadingplan.service,loadingplan.service.test}.ts
│   │   │   ├── orders/{orders.controller,orders.service,orders.service.test}.ts
│   │   │   └── profile/profile.controller.ts
│   │   ├── manager/
│   │   │   ├── manager.routes.ts  shared.ts
│   │   │   ├── assistant/
│   │   │   │   ├── assistant.controller.ts  assistant.schema.ts
│   │   │   │   ├── assistant.service.ts  assistant.service.test.ts
│   │   │   │   ├── assistant-config.controller.ts
│   │   │   │   ├── assistant-config.service.ts  assistant-config.service.test.ts
│   │   │   │   ├── schema-description.ts
│   │   │   │   └── sql-guard.ts  sql-guard.test.ts
│   │   │   ├── dashboard/{dashboard.controller,dashboard.service,dashboard.service.test}.ts
│   │   │   ├── delivery_inbox/{delivery_inbox.controller,delivery_inbox.service,delivery_inbox.service.test}.ts
│   │   │   ├── inventory/{inventory.controller,inventory.service,inventory.service.test}.ts
│   │   │   ├── orders/{orders.controller,orders.schema,orders.service,orders.service.test}.ts
│   │   │   ├── product_history/{product-history.controller,product-history.service,product-history.service.test}.ts
│   │   │   ├── products/{products.controller,products.service,products.service.test}.ts
│   │   │   ├── rate/{rate.controller,rate.service,rate.service.test}.ts
│   │   │   ├── search/{search.controller,search.service,search.service.test}.ts
│   │   │   ├── shipments/{shipments.controller,shipments.service,shipments.service.test}.ts
│   │   │   ├── transfers/{transfers.controller,transfers.schema,transfers.service,transfers.service.test}.ts
│   │   │   ├── users/{users.controller,users.service,users.service.test}.ts
│   │   │   └── warehouses/{warehouses.controller,warehouses.service,warehouses.service.test}.ts
│   │   ├── middleware/
│   │   │   ├── auth.ts  asyncHandler.ts  errorHandler.ts
│   │   │   ├── rateLimit.ts  validate.ts
│   │   │   ├── requireActiveWarehouse.ts  requireActiveWarehouse.test.ts
│   │   ├── notification/
│   │   │   ├── notification.controller.ts  notification.routes.ts
│   │   │   └── notification.service.ts  notification.service.test.ts
│   │   ├── realtime/
│   │   │   ├── socket.server.ts  realtime.ts  events.ts
│   │   │   └── outbox.ts  outbox.service.test.ts
│   │   ├── utils/
│   │   │   ├── prisma.ts  redis.ts  logger.ts  cache.ts  cleanup.ts
│   │   │   ├── audit.ts  imageUpload.ts  numbers.ts  serializableTx.ts
│   │   │   ├── jalali.ts  jalali.test.ts
│   │   │   ├── qr.ts  qr.test.ts
│   │   │   └── serial.ts  serial.test.ts
│   │   └── warehouse_keeper/
│   │       ├── warehouse.routes.ts
│   │       ├── carriers/{carriers.controller,carriers.schema,carriers.service,carriers.service.test}.ts
│   │       ├── checkin/{checkin.controller,checkin.schema,checkin.service,checkin.service.test}.ts
│   │       ├── drivers/{drivers.controller,drivers.schema,drivers.service,drivers.service.test}.ts
│   │       ├── labels/labels.controller.ts  labels.service.ts
│   │       ├── loadingplan/loadingplan.controller.ts  loadingplan.service.ts
│   │       ├── qrcode/qrcode.controller.ts
│   │       ├── reports/{reports.controller,reports.service,reports.service.test}.ts
│   │       ├── scanout/{scanout.controller,scanout.schema,scanout.service,scanout.service.test}.ts
│   │       └── warehouse/{warehouse.controller,warehouse.service,warehouse.service.test}.ts
│   ├── (تولیدی/gitignore): node_modules/  dist/  uploads/  backups/  logs/
│   └── (محرمانه): .env  .env.staging
│
├── mobile/                            # ═══ اپ موبایل (Flutter) ═══
│   ├── .gitignore  .metadata  README.md  analysis_options.yaml
│   ├── ma_app.iml  pubspec.yaml  pubspec.lock
│   ├── (تولیدی/gitignore): .dart_tool/  build/  .idea/
│   ├── assets/fonts/
│   │   ├── Vazirmatn-Regular.ttf
│   │   └── Vazirmatn-Bold.ttf
│   ├── android/
│   │   ├── .gitignore  build.gradle.kts  gradle.properties  settings.gradle.kts
│   │   ├── gradle/wrapper/gradle-wrapper.properties
│   │   ├── local.properties
│   │   └── app/
│   │       ├── build.gradle.kts
│   │       └── src/
│   │           ├── main/AndroidManifest.xml          # مجوزها: دوربین، میکروفون، …
│   │           ├── main/kotlin/com/ma/ma_app/MainActivity.kt
│   │           ├── main/java/io/flutter/plugins/GeneratedPluginRegistrant.java
│   │           ├── main/res/ (launch_background ×2، values/styles.xml،
│   │           │            values-night/styles.xml، mipmap آیکون ×۴)
│   │           ├── debug/AndroidManifest.xml
│   │           └── profile/AndroidManifest.xml
│   ├── ios/
│   │   ├── .gitignore
│   │   ├── Flutter/ (AppFrameworkInfo.plist، Debug/Release/Generated.xcconfig، ephemeral/)
│   │   ├── Runner.xcodeproj/ (project.pbxproj، xcshareddata/…)
│   │   ├── Runner.xcworkspace/ (contents.xcworkspacedata، xcshareddata/…)
│   │   ├── Runner/
│   │   │   ├── AppDelegate.swift  SceneDelegate.swift  Runner-Bridging-Header.h
│   │   │   ├── GeneratedPluginRegistrant.h/.m
│   │   │   ├── Info.plist                            # توضیحات مجوز میکروفون/دوربین
│   │   │   ├── Assets.xcassets/ (AppIcon کامل، LaunchImage)
│   │   │   └── Base.lproj/ (LaunchScreen.storyboard، Main.storyboard)
│   │   └── RunnerTests/RunnerTests.swift
│   ├── web/
│   │   ├── index.html  manifest.json  favicon.png
│   │   └── icons/ (Icon-192.png، Icon-512.png، Icon-maskable-192.png، Icon-maskable-512.png)
│   ├── tool/                          # خالی
│   ├── lib/
│   │   ├── main.dart                  # ProviderScope + MaterialApp.router + RTL + قفل
│   │   ├── core/
│   │   │   ├── network/ (dio_client.dart، api_constants.dart، api_error.dart)
│   │   │   ├── realtime/socket_service.dart
│   │   │   ├── notifications/ (notification_handler.dart، notification_model.dart،
│   │   │   │              notification_provider.dart، notification_service.dart)
│   │   │   ├── routes/app_router.dart
│   │   │   ├── storage/ (local_storage.dart، secure_storage.dart)
│   │   │   └── theme/app_theme.dart
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── data/auth_api_service.dart
│   │   │   │   ├── lock/ (lock_config.dart، lock_lifecycle_observer.dart،
│   │   │   │   │         lock_provider.dart، lock_storage.dart)
│   │   │   │   ├── providers/auth_provider.dart
│   │   │   │   └── screens/ (splash_screen.dart، login_screen.dart، lock_screen.dart)
│   │   │   ├── driver/
│   │   │   │   ├── data/driver_api_service.dart
│   │   │   │   ├── providers/driver_provider.dart
│   │   │   │   ├── screens/driver_dashboard_screen.dart
│   │   │   │   └── widgets/ (delivery_tab.dart، driver_bottom_nav.dart،
│   │   │   │             history_tab.dart، loading_plan_tab.dart)
│   │   │   ├── manager/
│   │   │   │   ├── assistant/
│   │   │   │   │   ├── assistant_screen.dart  assistant_voice_service.dart
│   │   │   │   │   ├── assistant_model_settings_screen.dart
│   │   │   │   │   ├── data/ (assistant_api_service.dart، assistant_model_api_service.dart)
│   │   │   │   │   ├── models/ (assistant_message.dart + .freezed.dart)
│   │   │   │   │   └── providers/assistant_provider.dart
│   │   │   │   ├── dashboard/
│   │   │   │   │   ├── manager_dashboard_screen.dart
│   │   │   │   │   ├── activity/ (activity_model.dart، activity_section.dart، activity_tile.dart)
│   │   │   │   │   ├── bottom_nav_bar/ (bottom_nav_bar.dart، nav_item.dart، nav_items.dart)
│   │   │   │   │   ├── header/header_section.dart
│   │   │   │   │   ├── inventory_chart/ (inventory_chart_card.dart، product_inventory_screen.dart)
│   │   │   │   │   ├── navigation_drawer/screens/
│   │   │   │   │   │   ├── archive_screen.dart  history_screen.dart
│   │   │   │   │   │   ├── invoices_screen.dart
│   │   │   │   │   │   ├── product_history_screen.dart
│   │   │   │   │   │   └── product_history_detail_screen.dart
│   │   │   │   │   │   └── transfer_screen.dart
│   │   │   │   │   └── product_management/ (add_product_screen.dart، edit_product_screen.dart)
│   │   │   │   ├── quick_actions/
│   │   │   │   │   ├── quick_actions_section.dart  quick_action_tile.dart
│   │   │   │   │   ├── inventory/inventory_screen.dart
│   │   │   │   │   ├── products/products_screen.dart
│   │   │   │   │   ├── reports/ (reports_screen.dart، user_report_screen.dart)
│   │   │   │   │   ├── users/users_screen.dart
│   │   │   │   │   └── warehouses/ (warehouses_screen.dart، warehouse_detail_screen.dart،
│   │   │   │   │                  create_warehouse_dialog.dart)
│   │   │   │   ├── search/search_screen.dart
│   │   │   │   ├── data/manager_api_service.dart
│   │   │   │   ├── delivery_inbox/delivery_inbox_screen.dart
│   │   │   │   ├── invoices/                        # موتور فاکتور PDF
│   │   │   │   │   ├── invoice_builder_screen.dart  invoice_preview_screen.dart
│   │   │   │   │   ├── invoice_widget.dart  invoice_pdf_generator.dart
│   │   │   │   │   ├── invoice_png_exporter.dart  invoice_amount_words.dart
│   │   │   │   │   ├── invoice_models.dart (+.freezed/.g)  invoice_order_converter.dart
│   │   │   │   │   ├── invoice_repository.dart  invoice_repository_provider.dart
│   │   │   │   │   ├── invoice_file_store.dart (+_io/_web)
│   │   │   │   │   ├── invoice_asset_image.dart
│   │   │   │   │   └── invoices_home_screen.dart  invoices_history_screen.dart
│   │   │   │   │   └── invoices_cashbox_screen.dart
│   │   │   │   ├── manager_screens.dart
│   │   │   │   ├── models/                          # ۲۲ مدل + codegen
│   │   │   │   │   ├── archive_models.dart(+.freezed/.g)  carrier_model.dart(+…)
│   │   │   │   │   ├── carton_search_model.dart(+…)  delivery_inbox_item.dart
│   │   │   │   │   ├── history_entry_model.dart(+…)  inventory_summary_model.dart(+…)
│   │   │   │   │   ├── manager_inventory_model.dart(+…)  order_model.dart(+…)
│   │   │   │   │   ├── product_history_model.dart   # دستی، بدون codegen
│   │   │   │   │   ├── product_model.dart(+…)  product_models_model.dart(+…)
│   │   │   │   │   ├── recent_activity_model.dart(+…)  shipment_report_model.dart(+…)
│   │   │   │   │   ├── transaction_entry_model.dart(+)  transfer_model.dart(+…)
│   │   │   │   │   ├── user_model.dart(+…)  user_report_model.dart(+…)
│   │   │   │   │   ├── warehouse_detail_model.dart(+)  warehouse_inventory_row_model.dart(+…)
│   │   │   │   │   └── warehouse_model.dart(+…)
│   │   │   │   ├── orders/ (create_order_screen.dart، edit_order_screen.dart، shipments_screen.dart)
│   │   │   │   ├── providers/ (activity_provider.dart، manager_api_provider.dart،
│   │   │   │   │             warehouses_provider.dart)
│   │   │   │   └── transfers/transfer_screen.dart
│   │   │   ├── shared/notifications/notifications_screen.dart
│   │   │   └── warehouse_keeper/
│   │   │       ├── data/warehouse_keeper_api_service.dart
│   │   │       ├── providers/warehouse_keeper_provider.dart
│   │   │       ├── carriers/carriers_screen.dart
│   │   │       ├── check_in/check_in_screen.dart
│   │   │       ├── dashboard/
│   │   │       │   ├── warehouse_keeper_dashboard_screen.dart
│   │   │       │   ├── bottom_nav/keeper_nav_items.dart
│   │   │       │   ├── header/warehouse_header.dart
│   │   │       │   ├── home/ (home_screen.dart، activity_section.dart،
│   │   │       │   │          inventory_chart_card.dart، stat_card.dart،
│   │   │       │   │          unreviewed_orders_card.dart)
│   │   │       │   ├── inventory/ (inventory_screen.dart، inventory_list_view.dart،
│   │   │       │   │               inventory_detail_screen.dart)
│   │   │       │   ├── orders/orders_screen.dart
│   │   │       │   ├── product_management/product_management_button.dart
│   │   │       │   ├── reports/reports_screen.dart
│   │   │       │   └── transfers/transfer_instructions_screen.dart
│   │   │       ├── drivers/drivers_screen.dart
│   │   │       ├── loading_plan/loading_plan_screen.dart
│   │   │       ├── models/                          # ۱۶ مدل + codegen
│   │   │       │   ├── check_in_result_model.dart(+)  keeper_carrier_model.dart(+…)
│   │   │       │   ├── keeper_driver_model.dart(+)  keeper_inventory_model.dart(+…)
│   │   │       │   ├── keeper_inventory_summary_model.dart(+)  keeper_order_model.dart(+…)
│   │   │       │   ├── keeper_product_model.dart(+)  keeper_report_model.dart
│   │   │       │   ├── keeper_transaction_model.dart(+)  keeper_warehouse_model.dart(+…)
│   │   │       │   ├── loading_plan_item_model.dart(+)
│   │   │       │   └── scan_out_result_model.dart(+…)
│   │   │       └── scan_out/ (scan_out_screen.dart، manual_exit_screen.dart،
│   │   │                      target_picker_sheet.dart)
│   │   └── shared/
│   │       ├── settings/ (settings_screen.dart، data/settings_api_service.dart)
│   │       ├── utils/ (numbers.dart — ارقام فارسی، validators.dart)
│   │       └── widgets/ (app_drawer.dart، dashboard_header.dart، inventory_donut_card.dart،
│   │                    inventory_product_cards.dart، jalali_month_picker.dart،
│   │                    lock_settings_tile.dart، notification_bell.dart،
│   │                    search_bar_trigger.dart، search_picker.dart)
│   └── test/                                        # ۲۹ فایل تست
│       ├── activity_tile_time_test.dart  app_router_test.dart
│       ├── assistant_screen_test.dart  auth_provider_lock_test.dart
│       ├── auth_session_test.dart  carriers_screen_test.dart
│       ├── check_in_screen_test.dart  create_order_screen_test.dart
│       ├── dont_keep_debug_test.dart  inventory_donut_card_test.dart
│       ├── invoice_amount_words_test.dart  invoice_builder_screen_test.dart
│       ├── invoice_models_test.dart  invoice_order_converter_test.dart
│       ├── invoice_pdf_generator_test.dart  invoice_png_exporter_test.dart
│       ├── invoice_repository_test.dart  invoices_cashbox_screen_test.dart
│       ├── invoices_home_screen_test.dart  keeper_inventory_list_view_test.dart
│       ├── lock_provider_test.dart  lock_storage_test.dart
│       ├── manual_exit_screen_test.dart  product_inventory_screen_test.dart
│       ├── shipments_screen_test.dart  token_expiry_test.dart
│       ├── transfer_screen_test.dart  unreviewed_orders_card_test.dart
│       └── widget_test.dart
│
└── desktop_panel/                     # ═══ پنل دسکتاپ انبار (Flutter Windows) ═══
    ├── .gitignore  .metadata  README.md  analysis_options.yaml
    ├── ma_warehouse_panel.iml  pubspec.yaml  pubspec.lock
    ├── .flutter-plugins-dependencies
    ├── (تولیدی/gitignore): .dart_tool/  .idea/  build/
    ├── assets/fonts/ (Vazirmatn-Regular.ttf، Vazirmatn-Bold.ttf)
    ├── lib/
    │   ├── main.dart
    │   ├── core/ (api_service.dart، badge_print_settings.dart، label_data.dart،
    │   │          palette.dart، printer_settings.dart، socket_client.dart)
    │   ├── printing/pdf_labels.dart               # تولید PDF لیبل‌های QR
    │   ├── screens/ (login_screen.dart، workspace_screen.dart)
    │   ├── screens/tabs/ (badges_tab.dart، cartons_tab.dart،
    │   │                  printed_tab.dart، transactions_tab.dart)
    │   └── widgets/ (accordion_item.dart، app_widgets.dart، badge_group_card.dart،
    │                badge_print_settings_dialog.dart، badge_sheet_widget.dart،
    │                checkin_dialog.dart، printer_settings_dialog.dart، qr_label_widget.dart)
    ├── test/                                      # ۱۰ فایل تست
    │   ├── badge_print_settings_dialog_test.dart  badge_sheet_test.dart
    │   ├── checkin_dialog_test.dart  grouping_test.dart  label_data_test.dart
    │   ├── login_screen_test.dart  pdf_labels_test.dart  printed_tab_test.dart
    │   ├── printer_settings_dialog_test.dart  workspace_smoke_test.dart
    └── windows/                                   # رانر ویندوز (C++)
        ├── .gitignore  CMakeLists.txt
        ├── flutter/ (CMakeLists.txt، generated_plugin_registrant.cc/.h،
        │            generated_plugins.cmake، [ephemeral/ تولیدی])
        └── runner/ (main.cpp، flutter_window.cpp/.h، win32_window.cpp/.h،
                     utils.cpp/.h، Runner.rc، resource.h، runner.exe.manifest،
                     resources/app_icon.ico)
```

---

## ۹) جمع‌بندی برای متخصص

- **معماری:** Monorepo سه‌کلایته با API واحد؛ الگوهای production-grade (Outbox، Idempotency، Audit، Token Rotation، دو-فازی، Optimistic Lock، Soft Delete).
- **نقطهٔ تمایز:** بومی‌سازی عمیق شمسی/فارسی تا سطح الگوریتم (روز کاری تهران، سریال سال‌شمسی، فیلتر روزِ دقیق) و چرخهٔ فیزیکی QR-محور.
- **ایمنی AI:** دستیار SQL-محور با گارد AST + READ ONLY + ماسک — الگوی کم‌یاب و درست.
- **قابل تحویل بودن:** env نمونهٔ مستند، runbook دیتابیس، اسکریپت پشتیبان/بازیابی/سلامت، و پیکربندی مدل AI از خود اپ — تحویل به اپراتور/متخصص جدید کم‌دردسر است.
