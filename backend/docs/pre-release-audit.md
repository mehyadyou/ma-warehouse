# چک‌لیست آدیتِ پیش از انتشار (Pre-Release Audit Runbook)

> نسخهٔ ۱.۰ — ۲۰۲۶-۰۹-۰۵ · مکملِ `docs/db-ops.md` · سناریوهای حساسِ مخصوصِ این سورس‌کد + ابزارهای استانداردِ متن‌باز

هر سناریو سه بخش دارد: **(A)** تستِ خودکارِ موجود در مخزن، **(B)** اجرای دستی/ابزاری، **(C)** معیارِ گذر (Pass Criteria).

| سناریو | تستِ خودکار | ابزار |
|---|---|---|
| ۱. Midnight Rollback شمارهٔ سفارش | ✅ `src/manager/orders/__audit__/order-number-rollover.audit.test.ts` | vitest (fake timers) |
| ۲. جعل لیبل QR (HMAC) | ✅ `src/warehouse_keeper/__audit__/qr-tamper.audit.test.ts` | vitest + sqlmap (اختیاری) |
| ۳. ایدمپوتنسی ورود کالا (قطعی شبکه) | ✅ `src/warehouse_keeper/__audit__/idempotency-race.audit.test.ts` | vitest + Artillery |
| ۴. Token Revocation Cascade | ✅ `src/auth/__audit__/token-revocation.audit.test.ts` | vitest (JWT واقعی) |
| ۵. چاپ گروهی ۵۰۰ لیبل (پنل) | ✅ `desktop_panel/test/print_stress_test.dart` | flutter test + Task Manager |
| ۶. بارِ ترکیبی REST + Socket.IO | — (سناریو آماده) | `scripts/loadtest/artillery-peak.yml` |

اجرا:
```bash
cd backend && npx vitest run \
  src/manager/orders/__audit__ \
  src/warehouse_keeper/__audit__ \
  src/auth/__audit__                              # ۲۱ تستِ آدیت (۴ سناریو)
cd desktop_panel && flutter test test/print_stress_test.dart  # سناریو ۵
```

وضعیتِ فعلی (۲۰۲۶-۰۹-۰۵): ۲۱/۲۱ آدیتِ بک‌اند ✓ · ۵۴/۵۴ پنل ✓ · کلِ سوئیتِ بک‌اند ۴۱۱/۴۱۱ ✓

---

## سناریو ۱ — Midnight Rollback شمارهٔ سفارش

**ریسک:** `orderDay` (کلید روز شمسی تهران) و `orderNumber` (هر روز از ۱، unique ترکیبی) اگر در مرز نیمه‌شبِ تهران اشتباه شوند → شماره‌های تکراری/جهش‌دار در روزِ کاری.

- **(A)** تست خودکار با fake timers روی ۴ لحظهٔ واقعی: `۰۰:۰۰:۰۱ تهران`، هشتمین سفارشِ همان روز، `۲۳:۵۹:۵۸ تهران`، و لحظهٔ دقیق مرز (۲۰:۳۰ UTC). انتظار: `orderDay=۱۴۰۵۰۶۱۵ / orderNumber=۱` در روزِ جدید.
- **(B)** دستی (اختیاری، محیط staging): با `faketime` یا تغییر TZ کانتینر Postgres نه — فقط ساعتِ سرورِ اپ مهم است؛ چند سفارش پشت سر هم اطراف ۲۰:۳۰ UTC ثبت کنید و `orderDay` را در DB ببینید:
  ```sql
  SELECT "orderDay", "orderNumber", "createdAt" FROM "Order" ORDER BY "createdAt" DESC LIMIT 10;
  ```
- **(C)** گذر: در `۰۰:۰۰:۰۱ تهران` اولین سفارشِ روز = `(orderDay=کلیدِ جدید, orderNumber=۱)`؛ سفارش‌های قبل از مرز روی روزِ قبلی باقی‌اند؛ خطای P2002 صفر (retry خودکار خدمت گرفته شده).

## سناریو ۲ — جعل لیبل QR (HMAC)

**ریسک:** مهاجم با QR دست‌ساز سریالِ کارتنِ دیگری را جعل کند تا خروجِ کالا را به نام کارتنِ دیگر ثبت کند.

- **(A)** تست خودکار: دستکاریِ سریال/نام محصول، HMAC دست‌ساز ۳۲ و ۱۶ کاراکتری، طول غلط HMAC — همه رد می‌شوند؛ مهم‌تر: `scanOut` با QR جعلی **قبل از هر کوئریِ DB** رد می‌شود (assert صفر بودنِ `carton.findUnique/findFirst`).
- **(B)** دستی: QR جعلی را با اسکنر واقعی در اپ انباردار بزنید؛ باید «کد QR معتبر نیست» ببیند و در `AuditLog`/رفتارِ سرویس ردی از lookup نباشد.
- **(C)** گذر: هیچ مسیری از QR جعلی به کارتنِ موجود نمی‌رسد؛ پیام خطا بدونِ جزئیاتِ داخلی (no info-leak)؛ QRهای قدیمی چاپ‌شده با HMAC-۱۶ هنوز کار می‌کنند (سازگاری گذار).

## سناریو ۳ — ایدمپوتنسی ورود کالا (قطعی شبکه)

**ریسک:** قطعی موبایل حین «ثبت ورود» → دابل‌سابمیت → دو برابر کارتن/تراکنش در DB.

- **(A)** تست خودکار سه مسیر: replay بعد از commit (بدون باز شدن تراکنش)، تعارضِ هم‌زمان `P2002` روی `userId_operation_key` (بازنده پاسخِ برنده را می‌گیرد و کارتن نمی‌سازد)، و مسیرِ سالمِ اولین ارسال.
- **(B)** دستی: در اپ، دکمهٔ ثبت را بزنید و بلافاصله `Airplane Mode` کنید؛ بعد از وصل‌شدن، همان درخواست دوباره برود (ری‌تری کلاینت) → تعداد کارتن‌های DB باید دقیقاً یک‌بار ثبت شده باشد:
  ```sql
  SELECT COUNT(*) FROM "Carton" WHERE "createdAt" > now() - interval '5 min';
  ```
- **(C)** گذر: پاسخِ دو درخواستِ هم‌کلید عیناً یکسان؛ جمعِ `Transaction.quantity` با تعدادِ فیزیکی کارتن‌ها برابر؛ کلیدهای قدیمی بعد از پاک‌سازیِ روزانه (`utils/cleanup.ts`) دیگر تداخل ندارند.

## سناریو ۴ — Token Revocation Cascade

**ریسک:** پس از تغییرِ رمز، نشست‌های قدیمی (access ۵ دقیقه‌ای + refresh ۱۴ روزه) باید فوراً بمیرند.

- **(A)** تست خودکار با JWT واقعی: تغییرِ رمز → `tokenVersion+1` و ابطالِ refreshهای فعال؛ access قدیمی (ver=0) → `401 «نشست شما منقضی شده»` و بدونِ `next`؛ access جدید (ver=1) → عبور با بازنویسی نقش/انبار از DB؛ refresh چرخش‌خورده → ابطالِ کلِ خانواده.
- **(B)** دستی: از دو دستگاه لاگین کنید؛ از دستگاه اول رمز را عوض کنید؛ دستگاه دوم باید در همان لحظه (اولین درخواست بعدی) `401` بگیرد — نه بعد از ۵ دقیقه. سوکتِ دستگاه دوم هم باید در handshake بعدی رد شود.
- **(C)** گذر: `AuditLog` رکورد `user.change_password` دارد؛ هیچ توکنِ ver=0 پاس نمی‌کند؛ خانوادهٔ refresh با `replacedBy` کامل ابطال شده.

## سناریو ۵ — چاپ گروهی ۵۰۰ لیبل (پنل دسکتاپ)

**ریسک:** نشت حافظه/فریز UI در اسپول ۵۰۰ برچسب؛ خرابی فونت فارسی/QR در ابعاد حرارتی.

- **(A)** تست خودکار: `PdfLabels.buildLabelPdfBytes` برای ۵۰۰ لیبل → PDF معتبر با ≥۵۰۰ صفحه؛ سقفِ حجم ۱۵۰MB (رشدِ بی‌رویه = باگ)؛ ۵۰۰ بیجک در حالت دوتایی → ۲۵۰ برگهٔ A5؛ ۳ بچِ پشت‌سرهم بدونِ افت (نشتِ تجمعی).
  مبناِ اندازه‌گیری‌شده روی همین مخزن: **۵۰۰ لیبل = ۳٫۳ مگابایت در ~۹ ثانیه** — هر انحرافِ فاحش از این مبنا (رشد حجم/زمان) یعنی رگرسیون.
- **(B)** دستی: چاپ واقعی روی پرینترِ لیبل (ابل ۱۰×۸cm): در Task Manager حین چاپ، RAM پروسس `ma_warehouse_panel.exe` را ببینید؛ ۵۰۰ کارتنِ واقعی از تب محصولات چاپ کنید.
- **(C)** گذر: RAM ثابت می‌ماند (نه رشد خطی تا Crash)؛ UI حین ساخت PDF فریز نمی‌شود (همه‌چیز async است)؛ روی کاغذ چاپی: QR اسکن می‌شود، متن فارسی RTL و بریده نشده، سریال لاتین با فونت Courier خوانا.

## سناریو ۶ — بارِ ترکیبی REST + Socket.IO

**ریسک:** زیرِ بارِ چند اپراتورِ هم‌زمان، شمارندهٔ سریال/شمارهٔ سفارش، Outbox dispatcher و اتاق‌های سوکت degrade کنند.

- **(A/B)** سناریوی آماده: `scripts/loadtest/artillery-peak.yml` — ۵۰ کاربرِ مجازی طی ۶۰ثانیه + نگهداشت ۲ دقیقه؛ ۷۰٪ پروب REST (شامل `/api/auth/me` با توکن واقعی)، ۳۰٪ سوکتِ Socket.IO با handshake توکن‌دار.
  ```bash
  cd backend && npm i -D artillery
  BASE_URL=http://localhost:3000 JWT=<توکن_معتبر> npx artillery run scripts/loadtest/artillery-peak.yml
  ```
- تستِ race واقعیِ سریال: چند ورودِ کالای هم‌زمان از چند session واقعی بزنید؛ سپس:
  ```sql
  SELECT year, lastSeq FROM "SerialSequence";
  SELECT COUNT(*), COUNT(DISTINCT "serialNumber") FROM "Carton" WHERE "serialNumber" LIKE 'MA-1405-%';
  -- count = count(distinct) → هیچ سریال تکراری؛ lastSeq = تعدادِ کلِ ورودِ سال
  ```
- تأخیرِ Outbox: حینِ بار، ورود کالا ثبت کنید و روی سوکتِ شنونده زمانِ رسیدنِ `checkin:completed` را اندازه بگیرید.
- **(C)** گذر: p95 < ۵۰۰ms؛ صفر 5xx؛ سریال تکراری صفر؛ رویدادِ outbox < ۱ ثانیه؛ `pg_stat_statements` هیچ کوئریِ جدیدِ کندی نشان نمی‌دهد (با `scripts/slow-queries.sql` چک کنید).

---

## ابزارهای استاندارد — راه‌اندازی روی این پشته

### ۱. Atlas — اعتبارسنجی مایگریشن‌ها (Schema Drift / Lock)
```bash
cd backend
curl -sSf https://atlasgo.sh | sh            # یا brew install ariga/tap/atlas
atlas migrate lint --dir file://prisma/migrations \
  --dir-format golang-migrate --dev-url "docker://postgres/16/dev"
```
گزارشِ destructive/locking را قبل از هر deploy ببینید؛ با ۴۵ مایگریشنِ فعلی (ایندکس‌های GIN/trgm raw) مهم‌ترین چکِ pre-deploy است. `migrate dev` روی دیتای tuned هرگز (طبق `db-ops.md`) — فقط `migrate deploy` + lint آفلاین.

### ۲. PgHero — مانیتورینگ کوئری/ایندکس
```bash
docker run -d --name pghero -p 8080:8080 \
  -e DATABASE_URL="postgres://ma_app:***@host.docker.internal:5433/ma_warehouse" \
  ankane/pghero
```
تب‌های Slow Queries (با pg_stat_statementsِ روشنِ compose)، Unused/Duplicate Indexes، و وضعیتِ Connection از PgBouncer. قبل از شروعِ ترافیک واقعی یک‌بار duplicate-index چک کنید (ایندکس‌های partial trgm تکراری نشده باشند).

### ۳. Artillery — بارِ REST + Socket.IO
بندِ سناریو ۶. سندِ کامل: `scripts/loadtest/artillery-peak.yml`. برای تستِ اسکنِ هم‌زمانِ ۱۰۰ انباردار، endpoint ورود/خروج را به‌صورت authenticated flow به scenario اضافه کنید.

### ۴. Schemathesis — فازینگِ API بر اساس اسکیمای واقعی
```bash
pip install schemathesis
# OpenAPI نداریم؛ از probe استفاده کنید:
schemathesis run --base-url http://localhost:3000 http://localhost:3000/healthz --checks all
```
هدفِ اصلی: `errorHandler` مرکزی نباید ۵۰۰ بدهد؛ هر ورودیِ خراب باید ۴۰۰/۴۰۱ تمیز برگرداند. ورودی‌های خطرناک را روی `/api/auth/login` و endpointهای zod-دار متمرکز کنید.

### ۵. sqlmap — تستِ نفوذِ گاردِ SQL دستیار
```bash
sqlmap -u "http://localhost:3000/api/manager/assistant" \
  --data='{"message":"نمایش سفارش‌ها"}' --headers="Authorization: Bearer <JWT>" \
  --method POST --level=3 --risk=2 --batch
```
نکته: مسیرِ SQL از گارد AST + `READ ONLY` + سقفِ ردیف عبور می‌کند؛ sqlmap بیشتر نقشِ اطمینان‌سنجیِ لایه‌های قبل را دارد. همچنین فرار از `pgsql-ast-parser` (کامنت/CTE/`SELECT … INTO`/multi-statement) با تست‌های `sql-guard.test.ts` پوشش داده شده — هر bypass جدیدِ پیدا شده را آنجا اضافه کنید.

### ۶. Trivy — CVE پکیج‌ها و کانفیگ
```bash
trivy fs --severity HIGH,CRITICAL backend/package-lock.json
trivy config backend/docker-compose.yml      # misconfig داکر/پستگرس
trivy image ma-warehouse-db:latest
```

### ۷. Patrol — E2E موبایل با دیالوگ‌های سیستمی
```bash
cd mobile && dart pub add --dev patrol && patrol setup
```
سناریوهای کلیدیِ این اپ (که تستِ معمولِ Flutter از آن‌ها عاجز است):
- ورود انباردار → پاپ‌آپ مجوز دوربین → اسکنِ (mock) QR → نتیجهٔ خروج.
- قفل اپ: رفتن به background/بازگشت → نمایش `lock_screen` و احرازِ مجدد (local_auth).
اجرا: `patrol test --target integration_test/scan_flow_test.dart`

### ۸. Maestro — بلک‌باکس بدونِ کد
```yaml
# .maestro/invoice_flow.yaml
appId: com.ma.ma_app
---
- launchApp
- tapOn: "ارسالی‌ها"
- tapOn: "فاکتور جدید"
- tapOn: "ذخیره PDF"
- assertVisible: "پیش‌نمایش"
```
`maestro test .maestro/invoice_flow.yaml` — مسیرِ «ثبت فاکتور تا PDF» را روی شبیه‌ساز اجرا می‌کند.

### ۹. تستِ یکپارچهٔ پنل ویندوز
```bash
cd desktop_panel && flutter test integration_test
```
باز شدن تب‌ها، اتصالِ WebSocket به سرورِ واقعی staging، و فیلترهای جدول بدونِ فریز. برای Visual Regression خروجیِ PDF: `buildLabelPdfBytes` را با بچِ ثابت بسازید، با Ghostscript به PNG رندر کنید و با baseline مقایسه کنید (hash یا pdf-diff) — تغییرِ ناخواستهٔ layout/فونت را قبل از چاپ می‌گیرد.

---

## ترتیبِ پیشنهادیِ اجرا (Release Gate)

1. `npx vitest run` (کلِ ۴۱۱ تست، شامل ۲۱ آدیت) — سبز
2. `atlas migrate lint` — صفر خطای locking/destructive
3. `trivy fs backend` — بدونِ CRITICAL باز
4. Artillery peak (سناریو ۶) — آستانه‌های p95/5xx/سریال
5. سناریوهای دستیِ ۲/۳ روی staging با اسکنر و قطعِ شبکهٔ واقعی
6. Patrol/Maestro جریان‌های موبایل + `print_stress_test.dart` پنل
7. بازبینی PgHero (slow/unused/duplicate) و `scripts/slow-queries.sql`
8. تیکِ نهایی: پشتیبان‌گیری (`backup.ps1`) + تستِ بازیابی (`verify-backup.ps1` → restore روی DB تست)
