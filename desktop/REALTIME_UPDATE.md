# تغییرات Real-time در پنل دسکتاپ

## خلاصه تغییرات

### ۱. تب "تکمیل شده‌ها" (Shipped Tab)
- یک تب جدید به dashboard اضافه شد که کارتن‌های با وضعیت `SHIPPED` را نمایش می‌دهد
- این تب از همان ساختار Accordion استفاده می‌کند و کارتن‌ها را بر اساس محصول و مدل گروه‌بندی می‌کند
- دکمه "بارگذاری مجدد" برای refresh کردن دستی کارتن‌های ارسال شده

### ۲. Real-time با Socket.IO
- ماژول جدید `socket_client.py` برای مدیریت ارتباط Socket.IO
- Listening به event های زیر:
  - `scanout:done`: وقتی کارتن scan-out می‌شود
  - `checkin:completed`: وقتی کارتن جدید check-in می‌شود
- زمانی که این event ها رخ می‌دهند، پنل به صورت خودکار refresh می‌شود

### ۳. API Endpoint جدید
- Backend endpoint جدید: `GET /api/warehouse-keeper/cartons/shipped`
- این endpoint آخرین 100 کارتن با status=SHIPPED را برمی‌گرداند
- شامل اطلاعات محصول، مدل، و سفارش مرتبط

## نصب Dependencies

برای استفاده از Socket.IO در پنل دسکتاپ، باید dependency جدید را نصب کنید:

```bash
pip install python-socketio[client]==5.11.0
```

یا از فایل requirements استفاده کنید:

```bash
pip install -r requirements.txt
```

## فایل‌های تغییر یافته

### Backend
- `backend/src/warehouse_keeper/warehouse.routes.ts` - endpoint جدید برای shipped cartons

### Desktop
- `desktop/requirements.txt` - اضافه شدن python-socketio
- `desktop/src/socket_client.py` - ماژول جدید برای Socket.IO
- `desktop/src/dashboard.py` - تب shipped و real-time handlers
- `desktop/src/main.py` - setup Socket.IO connection
- `desktop/src/api.py` - متد جدید `get_shipped_cartons()`

## نحوه کار Real-time

1. **Login**: وقتی کاربر login می‌کند، token به Socket.IO client ارسال می‌شود
2. **Connection**: Socket.IO به backend متصل می‌شود و authenticate می‌شود
3. **Events**: Backend وقتی scan-out یا check-in انجام می‌شود، event emit می‌کند
4. **Auto-refresh**: پنل دسکتاپ event را دریافت کرده و data را refresh می‌کند

## مزایا

✅ موجودی به صورت real-time در تمام پنل‌ها بروز می‌شود
✅ کارتن‌های ارسال شده در تب جداگانه قابل مشاهده است
✅ بدون نیاز به refresh دستی، اطلاعات همیشه به‌روز است
✅ کم شدن موجودی بعد از scan-out به صورت خودکار نمایش داده می‌شود

## تست

1. پنل دسکتاپ را اجرا کنید
2. وارد شوید
3. یک کارتن را scan-out کنید (از طریق mobile یا endpoint مستقیم)
4. پنل دسکتاپ باید به صورت خودکار refresh شود
5. تب "تکمیل شده‌ها" را باز کنید تا کارتن‌های ارسال شده را ببینید
