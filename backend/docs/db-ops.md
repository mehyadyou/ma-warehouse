# دیتابیس — کتابچهی عملیات (DB Ops Runbook)

## معماری

| سرویس | کانتینر | پورت هاست | نقش |
|---|---|---|---|
| PostgreSQL 16 | `ma-warehouse-db` | `5433` | بانک اصلی (TLS اجباری + scram) |
| PgBouncer | `ma-warehouse-pgbouncer` | `6432` | استخر اتصال اپ (TLS + scram) |
| Redis 7 | `ma-warehouse-redis` | `6379` | کش/توکن (AOF روشن) |

- اپ از `DATABASE_POOL_URL` (pgbouncer) استفاده میکند؛ `DATABASE_URL` مسیر مستقیم پشتیبان است.
- `MIGRATOR_URL` برای مهاجرت مستقیم به postgres.
- همهی فایلهای تنظیم: `backend/docker/` (pgbouncer.ini, userlist.txt).
- گواهی TLS در داخل volume دیتا: `PGDATA/server.crt|server.key` (اعتبار تا ۲۰۳۶).
- **پشتیبان دوم (offsite):** `backup.ps1 -RemoteDir <مسیر>` — هنوز پیکربندی نشده؛
  به محض اعلام مسیر، در Task Scheduler تنظیم میشود.

## رمزها و چرخش رمز

مقادیر رمز فقط در `backend/.env` ذخیره میشوند (این فایل را نباید در git گذاشت).
چرخش کامل (هر ۶ ماه یا پس از هر گمانهزنی لو رفتن):

1. `ALTER ROLE` برای هر سه رول (`postgres`, `ma_app`, `ma_migrator`)
2. بهروزرسانی `backend/.env` (هر ۵ کلید: `POSTGRES_PASSWORD`, `MA_APP_DB_PASSWORD`,
   `MA_MIGRATOR_DB_PASSWORD` + بخش رمزِ `DATABASE_URL`/`DATABASE_POOL_URL`/`MIGRATOR_URL`)
3. بازسازی `backend/docker/userlist.txt` با هش SCRAM جدید:
   `SELECT '"'||rolname||'" "'||rolpassword||'"' FROM pg_authid WHERE rolname IN ('ma_app','ma_migrator','postgres');`
4. `docker compose restart pgbouncer` (از پوشه `backend`)
5. `pm2 restart ma-warehouse-backend --update-env`
6. تست: `scripts\db-health.ps1` و یک ورود واقعی در اپ

⚠️ هشدار شناختهشده: در PowerShell هنگام فراخوانی docker، مقدار hashtable نباید مستقیم
در آرگومان بیاید؛ از `-e ("PGPASSWORD=" + $var)` استفاده کنید (در اسکریپتها رعایت شده).

## بکاپ و بازیابی

- **بکاپ روزانه:** Task Scheduler → `MaWarehouseBackupDaily` هر روز ۰۲:۳۰
  (`scripts\backup.ps1` → `backend\backups\ma_warehouse_<stamp>.dump`، فرمت custom، نگهداری ۳۰ روز)
- **بکاپ دستی:** `.\scripts\backup.ps1 -Dir ".\backups"`
- **WAL archiving:** همیشه روشن، هر ۶۰ ثانیه به volume `wal_archive` کپی میشود
  (پشتیبان PITR در کنار dump روزانه)
- **مانور ریستور (تأیید بکاپ):** `.\scripts\verify-backup.ps1 -File <dump>`
  → ریستور در `ma_warehouse_verify`، مقایسهی جدولها/سطرها، حذف خودکار.
  **روی بکاپ بعدی که وارد پروژه میشوید حتماً یک بار اجرا کنید.**
- **بازیابی واقعی:** `.\scripts\restore.ps1 -File <dump> -DropFirst`
  ⚠️ زمانبندی بکاپ و restore همزمان نشوند (رقابت روی dump).

## ترتیب دیپلوی روی سرور (بعد از git pull)
1. `npm ci`
2. `npx prisma generate` (اجباری بعد از هر npm ci — بدون آن بیلد strict می‌شکند)
3. `npx prisma migrate deploy`
4. `npm run build`
5. `sudo systemctl restart ma-warehouse.service` + چک `/healthz`

## امنیت اتصال (pg_hba)

فایل در `PGDATA/pg_hba.conf` — امن شده (هیچ `trust`، همهجا `scram-sha-256`،
تمامی TCP از طریق `hostssl` و `hostnossl reject`).
هر تغییری: با `docker exec` کپی در فایل + `SELECT pg_reload_conf();`
(نسخه مرجع در مخزن: `backend/docker/pg_hba_final.conf`)

## مانیتورینگ و هشدار

- `scripts\db-health.ps1` → هر روز ۰۶:۰۰ (Task: `MaWarehouseHealthCheck`)
  - بررسی: postgres، pgbouncer، تازگی WAL archive، سن آخرین بکاپ، dead tuples، اتصالات
  - گزارش: `backend\logs\db-health-<date>.log` (JSON، خطی)
  - هشدار تلگرام: `-TelegramToken ... -TelegramChatId ...` (اختیاری)
- کوئریهای کند (>200ms) در لاگ postgres (log_min_duration_statement=200)
- `scripts\slow-queries.sql` برای تحلیل pg_stat_statements

## عیبیابی سریع

| نشانه | اقدام |
|---|---|
| `password authentication failed` در لاگ اپ | .env با رمز DB هماهنگ نیست یا pgbouncer restart نشده |
| `no such user` در pgbouncer | userlist.txt قدیمی است → بازسازی + restart pgbouncer |
| `database access denied` | دوباره `docker compose restart pgbouncer` (کاربر list) |
| WAL archive نمیگیرد | `chown 70:70 /wal_archive` داخل volume؛ `SELECT pg_switch_wal();` |
| پرشدن دیسک | retention بکاپ ۳۰ روزه + `max_wal_size=2GB` |
| بکاپ Task نتیجه -196608 | از `Register-ScheduledTask` دوباره ثبت کنید |
| ریستور باینری خراب | از `cmd /c "docker exec -i ... < file"` استفاده کنید (پایپ PS باینری را خراب میکند) |

## احیا از صفر (فرمت کامل)

```
docker compose down
docker compose up -d postgres      # volume ها ساخته میشوند
# (certs سابق در volume میمانند)
docker run --rm -u postgres -v backend_wal_archive:/wal_archive alpine sh -c "chown 70:70 /wal_archive"
docker compose up -d
.\scripts\restore.ps1 -File <backup> -DropFirst
```
