# گزارش فنی جامع اپلیکیشن موبایل — ما انبارداری (ma-warehouse) v0.5

> **دامنه بررسی:** فقط پوشهٔ `mobile/` — اپلیکیشن Flutter (Dart 3.11 + Riverpod 3 + go_router + Dio + Socket.IO client)
> **هدف سیستم:** انبارداری اختصاصی یک شرکت — حداکثر **۳۰ کاربر** و **۲۰٬۰۰۰ محصول**
> **تاریخ بازبینی:** مرداد ۱۴۰۵
> **روش:** بازخوانی خط‌به‌خط فایل‌های `lib/core`، `lib/features` (سه نقش: مدیر، انباردار، راننده) و `lib/shared`
>
> این سند مکمل `BUGS-LIST.md` (بک‌اند) است و **فقط سمت موبایل** را پوشش می‌دهد.
> برای هر مورد: **وضعیت فعلی** → **مشکل** → **راه‌حل پیشنهادی (با کد)**.

---

## فهرست مطالب

1. [جمع‌بندی مدیریتی](#۰-جمعبندی-مدیریتی)
2. [جدول اولویت‌بندی باگ‌ها](#۱-جدول-اولویتبندی-باگها)
3. [بخش A — باگ‌های بحرانی مقیاس (۲۰هزار محصول)](#بخش-a--باگهای-بحرانی-مقیاس)
4. [بخش B — باگ‌های حساس پایداری و state](#بخش-b--باگهای-حساس-پایداری-و-state)
5. [بخش C — باگ‌های امنیت و شبکه](#بخش-c--باگهای-امنیت-و-شبکه)
6. [بخش D — باگ‌های تجربهٔ کاربری و متفرقه](#بخش-d--باگهای-تجربهٔ-کاربری-و-متفرقه)
7. [بخش E — طراحی کامل بخش «دستیار» (جایگزین پروفایل)](#بخش-e--طراحی-کامل-بخش-دستیار)
8. [نقشه‌راه اجرا](#۲-نقشهراه-اجرا)

---

## ۰. جمع‌بندی مدیریتی

**وضعیت کلی: خوب، اما با چند نقطهٔ شکست جدی در مقیاس واقعی.**

معماری موبایل تمیز و feature-based است و چند الگوی درست دارد:

- ✅ **رفرش توکن single-flight** (`AuthSession._getRefresh`) — چند درخواست همزمان فقط یک بار refresh می‌زنند
- ✅ **تفکیک «نشست مرده» از «خطای شبکه»** (`RefreshFailure.invalidSession` vs `network`) — کاربر با قطعی موقت شبکه از برنامه پرت نمی‌شود
- ✅ **قفل برنامه** (پین/بیومتریک) + بازیابی نشست
- ✅ **ذخیرهٔ امن توکن** در Keystore/Keychain
- ✅ **گارد خروج/ورود همزمان** (`_loggingOut`) در `AuthNotifier`
- ✅ **retry تک‌باره روی ۴۰۱** در interceptor

**اما برای «فوق‌العاده و بی‌باگ شدن» این موارد باید حل شوند:**

| # | مشکل | شدت |
|---|------|-----|
| MC1 | نبود صفحه‌بندی (pagination) در محصولات/سفارش‌ها — با ۲۰هزار محصول کرش/فریز | 🔴 بحرانی |
| MC2 | `ProductsScreen` کل لیست را flatten و کل مدل‌ها را در RAM می‌سازد | 🔴 بحرانی |
| MC3 | `ListView` معمولی و `SingleChildScrollView` نمودار در صفحه موجودی (رندر همهٔ آیتم‌ها) | 🔴 بحرانی |
| MH1 | `catch (_) {}` خاموش در بارگذاری محصولات — صفحهٔ سفید بدون پیام خطا | 🟠 بالا |
| MH2 | نبود چک `mounted` بعد از `await` در چند صفحه → کرش `setState after dispose` | 🟠 بالا |
| MH3 | `baseUrl` هاردکد شده روی `localhost:3000` — روی دستگاه واقعی کار نمی‌کند | 🟠 بالا |
| MH4 | نشت listener سوکت — رویدادها روی `off` نمی‌شوند و بعد از خروج صفحه فعال می‌مانند | 🟠 بالا |
| MH5 | سوکت پس از refresh توکن دوباره وصل نمی‌شود (توکن قدیمی در auth) | 🟠 بالا |

جزئیات کامل هر مورد در ادامه.

---

## ۱. جدول اولویت‌بندی باگ‌ها

### 🔴 بحرانی (باید قبل از استقرار با دیتای واقعی حل شود)

| کد | عنوان | محل |
|----|-------|-----|
| **MC1** | نبود pagination در `getProducts` / `getOrders` | `manager_api_service.dart:38,176` |
| **MC2** | flatten کل محصولات×مدل‌ها روی UI thread + مدل غیرtyped | `products_screen.dart:32-67` |
| **MC3** | `ListView(...)` و `SingleChildScrollView` نمودار به‌جای builder | `inventory_screen.dart:103,138` |

### 🟠 بالا

| کد | عنوان | محل |
|----|-------|-----|
| **MH1** | `catch (_) {}` خاموش در `_loadProducts` | `products_screen.dart:65` |
| **MH2** | نبود چک `mounted` بعد از `await` | `products_screen.dart:64,66` و چند صفحه |
| **MH3** | `baseUrl` هاردکد `http://localhost:3000` | `api_constants.dart:2` |
| **MH4** | نشت listener سوکت (off نشدن رویدادها) | `manager_dashboard_screen.dart:87-119` |
| **MH5** | عدم اتصال مجدد سوکت پس از رفرش/انقضای توکن | `socket_service.dart:16-50` |
| **MH6** | Race در دکمه‌های ویرایش ردیف حین ثبت (`_submitting`) | `check_in_screen.dart:176,222` |

### 🟡 متوسط

| کد | عنوان | محل |
|----|-------|-----|
| **MM1** | محاسبهٔ `_totalUnits` با `fold` در هر rebuild | `inventory_screen.dart:48` |
| **MM2** | نبود debounce/گارد در جستجوی ارسالی‌ها | `search_screen.dart:88` |
| **MM3** | مسیرهای API هاردکد به‌جای `ApiConstants` | `manager_api_service.dart:39,46,...` |
| **MM4** | استفاده از `List<Map<String,dynamic>>` به‌جای مدل typed | `products_screen.dart:23` |
| **MM5** | نبود `autoDispose` روی providerهای سرویس | `manager_api_provider.dart` |
| **MM6** | HTTP بدون TLS (cleartext) در تولید | `api_constants.dart:2` |

### 🟢 کم

| کد | عنوان | محل |
|----|-------|-----|
| **ML1** | تأخیر ثابت ۲۵۰۰ms ریست اسکنر — کند برای حجم بالا | `scan_out_screen.dart:65,76,117` |
| **ML2** | `print` در مسیر خطای سوکت (به‌جای logger) | `socket_service.dart:47` |
| **ML3** | تأخیر ثابت ۱۵۰۰ms اسپلش حتی وقتی init زودتر تمام شده | `auth_provider.dart:132` |
| **ML4** | `withOpacity` منسوخ‌شده (هشدار در Flutter جدید) | چند فایل UI |

---

## بخش A — باگ‌های بحرانی مقیاس

### 🔴 MC1 — نبود صفحه‌بندی در دریافت محصولات و سفارش‌ها

**وضعیت فعلی:** `manager_api_service.dart`

```dart
Future<List<ProductModel>> getProducts() async {
  final response = await _dio.get('/manager/products');   // ← بدون page/limit
  final data = response.data['products'] as List;
  return data.map((json) => ProductModel.fromJson(json)).toList();
}
Future<List<OrderModel>> getOrders() async {
  final response = await _dio.get('/manager/orders');     // ← بدون page/limit
  ...
}
```

**مشکل:** با ۲۰٬۰۰۰ محصول (و چند برابر آن مدل)، این درخواست:
1. کل payload را در یک پاسخ می‌گیرد → چند مگابایت JSON روی موبایل
2. کل لیست را `fromJson` می‌کند → فشار GC و احتمال **OutOfMemory** روی دستگاه‌های میان‌رده
3. زمان اولین رندر (TTI) به چند ثانیه می‌رسد

این هم‌سو با باگ **C2** بک‌اند (CROSS JOIN موجودی) است؛ حتی اگر بک‌اند سریع پاسخ دهد، موبایل خفه می‌شود.

**راه‌حل پیشنهادی:** صفحه‌بندی سمت سرور + بارگذاری تدریجی (infinite scroll) در کلاینت.

```dart
Future<PagedResult<ProductModel>> getProducts({
  int page = 1,
  int limit = 30,
  String? search,
}) async {
  final response = await _dio.get('/manager/products', queryParameters: {
    'page': page,
    'limit': limit,
    if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
  });
  final data = response.data['products'] as List;
  return PagedResult(
    items: data.map((j) => ProductModel.fromJson(j)).toList(),
    hasMore: response.data['hasMore'] as bool? ?? false,
    total: response.data['total'] as int? ?? data.length,
  );
}
```

در UI با `ScrollController` صفحهٔ بعدی را وقتی به انتهای لیست نزدیک شد بگیر. جستجو هم باید سمت سرور باشد نه فیلتر روی لیست کامل.

> **توجه مهم:** این تغییر به تغییر بک‌اند نیاز دارد. اگر بک‌اند فعلاً pagination ندارد، این مورد را با تیم بک‌اند هماهنگ کن (به `BUGS-LIST.md` بک‌اند اضافه شود).

---

### 🔴 MC2 — flatten کل محصولات×مدل‌ها روی UI thread

**وضعیت فعلی:** `products_screen.dart:32-67`

```dart
Future<void> _loadProducts() async {
  setState(() => _loading = true);
  try {
    final rawProducts = await _api.getProducts();
    final List<Map<String, dynamic>> flattenedList = [];
    for (var p in rawProducts) {              // ← ۲۰هزار محصول
      ...
      for (var m in models) {                 // ← × چند مدل هر کدام
        flattenedList.add({ 'productId': p.id, ... });   // Map غیرtyped
      }
    }
    setState(() => _products = flattenedList);
  } catch (_) {}          // ← MH1: خطای خاموش
  setState(() => _loading = false);
}
```

**مشکل:**
1. حلقهٔ تودرتو روی ده‌ها هزار آیتم در **UI thread** اجرا می‌شود → فریز و jank محسوس
2. هر آیتم یک `Map<String, dynamic>` است (MM4) → مصرف حافظه بالا و ریسک خطای runtime هنگام خواندن کلیدها
3. دو `setState` پیاپی + `catch (_)` خاموش

**راه‌حل پیشنهادی:**
- flatten را حذف کن؛ مستقیم از `ProductModel` typed در UI استفاده کن و لیست دو‌سطحی (محصول → مدل‌ها) را با `ListView.builder` تو‌در‌تو نمایش بده.
- اگر flatten لازم است، آن را سمت سرور انجام بده یا با `compute()` به Isolate ببر:

```dart
final flattenedList = await compute(_flattenProducts, rawProducts);
if (!mounted) return;                     // MH2
setState(() { _products = flattenedList; _loading = false; });
```

- با pagination (MC1) این حلقه هرگز روی بیش از ۳۰ آیتم اجرا نمی‌شود و مشکل ریشه‌ای حل می‌شود.

---

### 🔴 MC3 — لیست/نمودار موجودی بدون builder

**وضعیت فعلی:** `inventory_screen.dart`

```dart
child: ListView(                    // خط ۱۰۳ — نه ListView.builder
  padding: const EdgeInsets.all(20),
  children: [
    ...
    _BarChart(
      data: _products.map((p) => {...}).toList(),   // خط ۱۳۸ — همهٔ محصولات
    ),
```

و داخل `_BarChart` از `SingleChildScrollView` افقی برای همهٔ محصولات استفاده می‌شود.

**مشکل:** `ListView(children: [...])` و `SingleChildScrollView` **همهٔ فرزندان را یک‌جا می‌سازند** (نه lazy). نمودار میله‌ای با ۲۰هزار میله عملاً غیرقابل رندر است و عرض اسکرول بی‌معنا می‌شود.

**راه‌حل پیشنهادی:**
1. نمودار را به **۱۰ تا ۱۵ محصول برتر** محدود کن (top-N بر اساس موجودی) — کاربر برای جزئیات به لیست جداگانه برود:

```dart
final topProducts = [..._products]
  ..sort((a, b) => b.totalCount.compareTo(a.totalCount));
final chartData = topProducts.take(12).toList();
```

2. لیست انبارها را با `ListView.builder` (یا `SliverList`) بازنویسی کن.
3. برای صفحهٔ کامل، ساختار `CustomScrollView` + `SliverList` استفاده کن تا فقط آیتم‌های visible ساخته شوند.

---

## بخش B — باگ‌های حساس پایداری و state

### 🟠 MH1 — خطای خاموش در بارگذاری محصولات

**محل:** `products_screen.dart:65` — `catch (_) {}`

**مشکل:** اگر API خطا دهد (۵۰۰، تایم‌اوت، قطع شبکه)، لودینگ مخفی می‌شود و کاربر یک **صفحهٔ خالی «هیچ محصولی ثبت نشده»** می‌بیند — که گمراه‌کننده است (کاربر فکر می‌کند دیتا پاک شده).

**راه‌حل:**

```dart
} catch (e) {
  if (!mounted) return;
  setState(() { _loading = false; _error = friendlyError(e); });
  return;
}
if (!mounted) return;
setState(() { _products = flattenedList; _loading = false; });
```

و در `build`، حالت خطا را با دکمهٔ «تلاش دوباره» نمایش بده. همین الگو در `getArchivedProducts` و مسیرهای مشابه هم اعمال شود.

---

### 🟠 MH2 — نبود چک `mounted` بعد از `await`

**محل:** `products_screen.dart:64,66` و چند صفحهٔ دیگر که بعد از `await` مستقیم `setState` می‌زنند.

**مشکل:** اگر کاربر پیش از پایان درخواست صفحه را ببندد، `setState` روی widget جدا‌شده اجرا می‌شود → استثنا/کرش (`setState() called after dispose()`).

**راه‌حل:** پیش از هر `setState` که بعد از `await` می‌آید:

```dart
if (!mounted) return;
setState(() { ... });
```

صفحهٔ `inventory_screen.dart` این کار را درست انجام داده (خط ۶۰، ۶۷)؛ همان الگو را به همهٔ صفحات تعمیم بده. یک جستجوی سراسری روی `await` + `setState` انجام بده و همه را اصلاح کن.

---

### 🟠 MH4 — نشت listener سوکت

**وضعیت فعلی:** `manager_dashboard_screen.dart:87-119`

```dart
Future.microtask(() {
  final socket = ref.read(socketServiceProvider);
  socket.on('checkin:completed', (_) => invalidateTransactionData());
  socket.on('scanout:done',      (_) => invalidateTransactionData());
  socket.on('delivery:completed',(_) => ...);
  socket.on('order:created', ...);
  socket.on('order:updated', ...);
  socket.on('order:deleted', ...);
});
// dispose() هیچ‌کدام از این‌ها را off نمی‌کند
```

**مشکل:** `SocketService` **singleton** است. با هر بار ساخت این صفحه، listenerها **روی هم انباشته** می‌شوند و بعد از خروج از صفحه هم فعال می‌مانند. نتیجه: `invalidate` چندباره، rebuild اضافی، و نگه‌داری closureهایی که به `ref` صفحهٔ dispose‌شده اشاره دارند (نشت حافظه + احتمال خطا).

**راه‌حل:** در `dispose` همهٔ رویدادها را off کن (و در `initState` هم پیش از افزودن، off کن تا duplicate نشود):

```dart
static const _events = [
  'checkin:completed','scanout:done','delivery:completed',
  'order:created','order:updated','order:deleted',
];

@override
void dispose() {
  final socket = ref.read(socketServiceProvider);
  for (final e in _events) socket.off(e);
  _fadeCtrl.dispose();
  _slideCtrl.dispose();
  super.dispose();
}
```

**بهتر:** یک متد `SocketService.on` که `dispose`‌پذیر باشد یا از `StreamController` استفاده کند تا هر صفحه subscription خودش را لغو کند. الگوی فعلی `off(event)` کل event را پاک می‌کند و اگر دو صفحه هم‌زمان به یک رویداد گوش دهند تداخل می‌شود.

---

### 🟠 MH5 — عدم اتصال مجدد سوکت پس از رفرش توکن

**وضعیت فعلی:** `socket_service.dart:16-50`

```dart
Future<void> connect() async {
  if (_isConnected) return;
  var token = await SecureStorage.getAccessToken();
  if (isAccessTokenExpiringSoon(token)) {
    token = await AuthSession.refreshAccessToken();
  }
  _socket = io(baseUrl, OptionBuilder().setAuth({'token': token})...);
```

**مشکل‌ها:**
1. توکن فقط **یک بار هنگام اتصال** ست می‌شود. وقتی سرور به دلیل انقضای توکن اتصال را می‌بندد (هم‌سو با باگ **H1** بک‌اند که `tokenVersion`/`isActive` را چک می‌کند)، `onConnectError` فقط لاگ می‌کند و **auth را با توکن تازه به‌روزرسانی نمی‌کند** → سوکت در حلقهٔ reconnect با توکن باطل می‌ماند.
2. `if (_isConnected) return;` هنگام قطعی موقت (که `_isConnected=false` شده) درست است، اما بعد از logout/login مجدد ممکن است `_socket` قدیمی هنوز زنده باشد.

**راه‌حل:**
- در `onConnectError`/`onDisconnect`، هنگام تلاش مجدد، توکن تازه را از `AuthSession` بگیر و `_socket.auth` را به‌روز کن:

```dart
_socket?.onConnectError((error) async {
  _isConnected = false;
  final fresh = await AuthSession.refreshAccessToken();
  if (fresh != null) {
    _socket?.auth = {'token': fresh};
  }
});
```

- در `disconnect()` علاوه بر `disconnect`، `_socket?.dispose()` و `_socket = null` را هم انجام بده تا نمونهٔ قدیمی نشت نکند.

---

### 🟠 MH6 — Race در ویرایش ردیف‌ها حین ثبت ورود

**محل:** `check_in_screen.dart` — دکمه‌های افزودن/حذف ردیف حین `_submitting = true` غیرفعال نمی‌شوند.

**مشکل:** کاربر می‌تواند در فاصلهٔ ارسال درخواست، لیست اقلام را تغییر دهد؛ نتیجه ممکن است ثبت داده‌ای متفاوت از آنچه کاربر دید باشد. با idempotency-key بک‌اند (خوب است) ثبت دوباره رخ نمی‌دهد، اما ناسازگاری UI/داده باقی می‌ماند.

**راه‌حل:** هنگام `_submitting`، همهٔ کنترل‌های ویرایش لیست را `onPressed: _submitting ? null : ...` کن و روی کل فرم یک `AbsorbPointer(absorbing: _submitting)` بگذار.

---

## بخش C — باگ‌های امنیت و شبکه

### 🟠 MH3 / 🟡 MM6 — baseUrl هاردکد `localhost` و بدون TLS

**محل:** `api_constants.dart:2`

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**مشکل:**
1. روی دستگاه فیزیکی/بیلد تولیدی، `localhost` به خود گوشی اشاره می‌کند نه سرور → همه‌چیز شکست می‌خورد.
2. `http://` بدون TLS؛ توکن‌ها و داده روی شبکه plaintext منتقل می‌شوند. اندروید ۹+ به‌صورت پیش‌فرض cleartext را بلاک می‌کند.

**راه‌حل:**
- baseUrl را از build config بخوان (dart-define) و برای تولید `https://` بگذار:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api', // امولاتور اندروید
);
```
build: `flutter build apk --dart-define=API_BASE_URL=https://api.company.local/api`
- در تولید حتماً TLS فعال باشد و `usesCleartextTraffic=false`.

---

## بخش D — باگ‌های تجربهٔ کاربری و متفرقه

### 🟡 MM1 — محاسبهٔ `_totalUnits` در هر rebuild
**محل:** `inventory_screen.dart:48` — `_products.fold(...)` گتر است و در هر rebuild کل لیست را جمع می‌زند. مقدار را یک‌بار بعد از `_load` محاسبه و در فیلد ذخیره کن.

### 🟡 MM2 — نبود debounce در جستجو
**محل:** `search_screen.dart:88` — درخواست جستجو بدون گارد/debounce ارسال می‌شود؛ کلیک سریع = چند درخواست موازی. یک `Timer` با تأخیر ~۴۰۰ms یا گارد `_processing` اضافه کن و درخواست قبلی را cancel کن.

### 🟡 MM3 — مسیرهای API هاردکد
**محل:** `manager_api_service.dart` (خطوط ۳۹، ۴۶، ۵۴، ...) — رشته‌هایی مثل `/manager/products` مستقیم نوشته شده‌اند. همه به `ApiConstants` منتقل شوند تا تک‌نقطه‌ای مدیریت شوند.

### 🟡 MM5 — نبود `autoDispose`
**محل:** `manager_api_provider.dart` — providerهای سرویس بدون `autoDispose`؛ برای providerهای داده‌محور (نه خود سرویس Dio) از `autoDispose` و `AsyncNotifier`/`FutureProvider` استفاده کن تا state کهنه پاک شود.

### 🟢 ML1 — تأخیر ثابت ۲۵۰۰ms ریست اسکنر
**محل:** `scan_out_screen.dart:65,76,117` — برای انباردار در حجم بالا کند است. به ~۸۰۰ms کاهش بده یا دکمهٔ «اسکن بعدی» فوری اضافه کن.

### 🟢 ML2 — `print` در مسیر سوکت
**محل:** `socket_service.dart:47` — `print('Socket connection error...')` را با logger ساخت‌یافته یا `debugPrint` (که در release حذف می‌شود) جایگزین کن. هم‌سو با باگ **M6/L4** بک‌اند.

### 🟢 ML3 — تأخیر ثابت اسپلش
**محل:** `auth_provider.dart:132` — `Future.delayed(1500ms)` حتی وقتی init زودتر تمام شده. برای UX بهتر می‌توان زمان سپری‌شده را کم کرد (فقط باقیمانده تا ۱.۵s صبر شود).

### 🟢 ML4 — `withOpacity` منسوخ
در چند فایل UI از `Colors.x.withOpacity()` استفاده شده که در نسخه‌های جدید Flutter deprecated است؛ به `.withValues(alpha:)` مهاجرت کن (بعضی فایل‌ها مثل inventory از قبل این کار را کرده‌اند).

---

## بخش E — طراحی کامل بخش «دستیار»

هدف: دکمهٔ چهارم نوبار مدیر که الان **«پروفایل» (فایل مرده)** است، به **«دستیار»** تبدیل شود — یک چت‌بات مثل ChatGPT که:
- مدیر می‌تواند سؤالش را **تایپ یا با ویس** بگوید،
- برنامه ویس را به **متن** تبدیل کند،
- متن به **مدل LLM** فرستاده شود،
- مدل با **دسترسی امن به کل دیتابیس** آمار دقیق را استخراج و گزارش کند.

### وضعیت فعلی که باید تغییر کند

`nav_items.dart` — آیتم چهارم:
```dart
NavItem(icon: Icons.person_rounded, label: 'پروفایل'),   // ← فایل مرده
```
`manager_dashboard_screen.dart:191-206` — `onTap`: index 1 و 2 به موجودی و ارسال می‌روند، ولی index 3 (پروفایل) فقط `setState(_selectedIndex = i)` می‌کند و **هیچ صفحه‌ای برایش وجود ندارد**.

**تغییر لازم:**
```dart
// nav_items.dart
NavItem(icon: Icons.auto_awesome_rounded, label: 'دستیار'),
```
```dart
// manager_dashboard_screen.dart → onTap
if (i == 3) {
  await Navigator.push(context,
    MaterialPageRoute(builder: (_) => const AssistantScreen()));
  return;
}
```

---

### معماری کلان (۳ لایه)

```
┌─────────────── موبایل (Flutter) ───────────────┐
│  AssistantScreen (UI چت + استریم پاسخ)          │
│  VoiceInputController (STT: گفتار → متن)         │
│  AssistantApiService (Dio + SSE/WebSocket)      │
└───────────────────────┬─────────────────────────┘
                        │ HTTPS + Bearer token (نقش=MANAGER)
┌───────────────────────▼─────────── بک‌اند (Node) ┐
│  POST /assistant/chat  (احراز هویت + rate limit) │
│  Orchestrator: LLM → Tool-Calling                │
│    ├─ ابزارهای امن آماده (نه SQL خام مدل)        │
│    │   getInventorySummary(), getTopProducts()… │
│    └─ (اختیاری) text-to-SQL فقط-خواندنی محدود    │
│  Audit log هر پرسش/گزارش                          │
└───────────────────────┬─────────────────────────┘
                        │ Prisma (read-only)
                ┌───────▼────────┐
                │  PostgreSQL    │
                └────────────────┘
```

نکتهٔ اصلی: **مدل LLM هرگز نباید مستقیماً به دیتابیس وصل شود یا SQL خام دلخواه اجرا کند.** این خطرناک‌ترین بخش است. دو الگوی امن در ادامه.

---

### E.1 — بخش موبایل (Flutter)

**وابستگی‌های جدید در `pubspec.yaml`:**
```yaml
speech_to_text: ^7.0.0        # گفتار → متن (آفلاین/آنلاین، فارسی fa-IR)
permission_handler: ^11.3.0   # مجوز میکروفون
# (اختیاری برای صدای طبیعی‌تر: record + ارسال فایل به STT سرور)
```

**ساختار پوشهٔ پیشنهادی:**
```
lib/features/manager/assistant/
  data/assistant_api_service.dart
  models/chat_message_model.dart        (freezed)
  providers/assistant_provider.dart     (AsyncNotifier / StateNotifier)
  voice/voice_input_controller.dart
  assistant_screen.dart
  widgets/message_bubble.dart
  widgets/chat_input_bar.dart           (فیلد متن + دکمهٔ میکروفون)
  widgets/typing_indicator.dart
```

**مدل پیام:**
```dart
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String role,          // 'user' | 'assistant'
    required String content,
    @Default(false) bool isStreaming,
    @Default(false) bool isError,
    Map<String, dynamic>? report,  // داده ساخت‌یافتهٔ گزارش برای نمایش جدول/چارت
    DateTime? createdAt,
  }) = _ChatMessage;
}
```

**ویس‌به‌متن (`voice_input_controller.dart`):**
```dart
class VoiceInputController {
  final _stt = SpeechToText();
  bool _available = false;

  Future<bool> init() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return false;
    _available = await _stt.initialize(
      onError: (e) => debugPrint('STT error: $e'),
    );
    return _available;
  }

  Future<void> listen({required void Function(String) onResult}) async {
    if (!_available) return;
    await _stt.listen(
      localeId: 'fa_IR',
      onResult: (r) => onResult(r.recognizedWords),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
  }

  Future<void> stop() => _stt.stop();
}
```
- کاربر دکمهٔ میکروفون را نگه می‌دارد، `partialResults` به‌صورت زنده در فیلد متن نوشته می‌شود، رها که کرد متن نهایی در input می‌ماند و می‌تواند قبل از ارسال ویرایش کند.
- اگر دقت STT دستگاهی فارسی کافی نبود، جایگزین: صدا را با `record` ضبط کن و به یک endpoint سرور بفرست که از Whisper (یا سرویس STT) استفاده کند — دقت فارسی بهتر.

**UI چت (مثل ChatGPT):**
- `ListView.builder` معکوس (`reverse: true`) برای پیام‌ها، حباب کاربر راست/دستیار چپ (با در نظر گرفتن RTL)،
- استریم پاسخ توکن‌به‌توکن با نشانگر تایپ،
- پشتیبانی از رندر جدول/چارت وقتی پاسخ شامل `report` ساخت‌یافته است (مثلاً «موجودی هر انبار» به‌صورت جدول),
- دکمهٔ کپی، تلاش دوباره، و اسکرول خودکار به پایین.

**سرویس API با استریم (SSE):**
```dart
Future<Stream<String>> chatStream(String prompt, {String? conversationId}) async {
  final res = await _dio.post('/assistant/chat',
    data: {'message': prompt, 'conversationId': conversationId},
    options: Options(responseType: ResponseType.stream),
  );
  return (res.data.stream as Stream<List<int>>)
      .transform(utf8.decoder)
      .transform(const LineSplitter());
}
```

---

### E.2 — بخش بک‌اند (نقطهٔ حساس امنیتی)

مدل باید «به کل دیتابیس دسترسی داشته باشد» — اما دسترسی باید **کنترل‌شده** باشد. دو رویکرد:

#### رویکرد A (توصیه‌شده) — Tool Calling با توابع امن آماده
مدل SQL نمی‌نویسد؛ فقط از میان مجموعه‌ای از **ابزارهای از‌پیش‌تعریف‌شده و امن** انتخاب می‌کند و پارامتر می‌دهد. بک‌اند خودش کوئری امن Prisma را اجرا می‌کند.

```
ابزارهای پیشنهادی (همه read-only):
  get_inventory_summary()                      → مجموع کل موجودی/انبارها
  get_stock_by_product(productName?)           → موجودی یک/همه محصول
  get_stock_by_warehouse(warehouseId?)         → موجودی هر انبار
  get_top_products(limit, by='count')          → پرموجودی/پرگردش‌ترین‌ها
  get_transactions(from, to, type, warehouse?) → ورود/خروج بازهٔ زمانی
  get_orders(status?, from?, to?)              → سفارش‌ها/ارسالی‌ها
  get_user_activity(userId?, from?, to?)       → عملکرد کاربران
  get_low_stock(threshold)                     → کالاهای رو‌به‌اتمام
```

مزایا:
- **هیچ SQL دلخواهی** از مدل اجرا نمی‌شود → ضد SQL Injection و ضد دسترسی به داده‌های حساس (مثل هش رمز)،
- هر ابزار فیلترهای امنیتی و soft-delete را رعایت می‌کند (مثل بقیهٔ سرویس‌ها)،
- خروجی ساخت‌یافته است → موبایل می‌تواند جدول/چارت رندر کند.

جریان:
```
پیام مدیر → LLM (با تعریف toolها) → مدل تصمیم می‌گیرد کدام tool + پارامتر
        → بک‌اند tool را با Prisma اجرا می‌کند → نتیجه به LLM
        → LLM گزارش فارسی روان تولید می‌کند → استریم به موبایل
```

#### رویکرد B — text-to-SQL فقط‌خواندنی و سندباکس‌شده
اگر انعطاف کامل لازم است، مدل SQL تولید کند اما با **این نرده‌های محافظ اجباری**:
1. یک نقش دیتابیس **read-only** جدا (`GRANT SELECT` فقط) — نه کاربر اصلی برنامه،
2. اجرای کوئری در ترنزکشن `READ ONLY` با `statement_timeout` کوتاه (مثلاً ۳ ثانیه)،
3. **allow-list جدول/ستون‌ها**: جداول حساس (`User.password`, `RefreshToken`, `AuditLog`) بلاک شوند،
4. فقط `SELECT` مجاز؛ هر `INSERT/UPDATE/DELETE/DROP/;` رد شود (پارس AST، نه regex ساده)،
5. `LIMIT` اجباری تزریق شود،
6. هر کوئری تولیدی + نتیجه در **AuditLog** ثبت شود (این هم باگ **H4** بک‌اند را زنده می‌کند).

> توصیهٔ نهایی: **رویکرد A** برای این سیستم بسته و اختصاصی امن‌تر و کافی است. رویکرد B فقط اگر مدیر واقعاً به کوئری‌های دلخواه پیچیده نیاز دارد.

**نکات امنیتی مشترک (هر دو رویکرد):**
- endpoint `/assistant/*` فقط برای نقش `MANAGER` (میدلور نقش)،
- Rate limit اختصاصی (هم‌سو با باگ **M4** بک‌اند) — LLM پرهزینه است،
- کلید API مدل **فقط سمت سرور**؛ هرگز در اپ موبایل قرار نگیرد،
- محدودسازی طول context و تعداد toolهای زنجیره‌ای در هر پیام،
- ثبت audit هر تعامل دستیار (چه کسی، چه پرسید، چه داده‌ای دید).

---

### E.3 — نمونهٔ تجربهٔ کاربری

```
مدیر (ویس): «موجودی انبار مرکزی چقدره و کدوم محصول کمترین موجودی رو داره؟»
   ↓ STT → متن
دستیار: [فراخوانی get_stock_by_warehouse + get_low_stock]
   ↓
«انبار مرکزی در مجموع ۱٬۲۴۰ واحد موجودی دارد.
 کم‌موجودی‌ترین محصول: «فیلتر روغن X» با ۳ واحد (زیر آستانهٔ ۱۰).»
 [جدول ۵ محصول کم‌موجودی + دکمهٔ «گزارش کامل»]
```

---

## ۲. نقشه‌راه اجرا

**فاز ۱ — پایداری فوری (قبل از هر چیز):**
1. MH3/MM6 — baseUrl از dart-define + TLS (وگرنه اپ روی دستگاه واقعی کار نمی‌کند)
2. MH1 + MH2 — خطای خاموش و چک mounted در همهٔ صفحات
3. MH4 + MH5 — off کردن listenerهای سوکت + reconnect با توکن تازه

**فاز ۲ — مقیاس (برای ۲۰هزار محصول):**
4. MC1 — pagination سمت سرور و کلاینت (هماهنگ با بک‌اند)
5. MC2 + MC3 — حذف flatten روی UI thread، builderها، نمودار top-N
6. MM1/MM2/MM5 — بهینه‌سازی rebuild، debounce جستجو، autoDispose

**فاز ۳ — دستیار:**
7. تغییر nav «پروفایل» → «دستیار» + `AssistantScreen`
8. ویس‌به‌متن (`speech_to_text`, fa-IR)
9. بک‌اند `/assistant/chat` با **رویکرد A (tool calling امن)** + audit + rate limit
10. استریم پاسخ + رندر جدول/چارت گزارش

**فاز ۴ — پرداخت‌ها (متفرقه):**
11. ML1/ML2/ML3/ML4 — بهبود UX اسکنر، logger، اسپلش، مهاجرت withValues

---

> این سند فقط سمت `mobile/` را پوشش می‌دهد. موارد نشان‌دار «هم‌سو با بک‌اند» (MH5↔H1، MM6↔M3، ML2↔M6، و text-to-SQL↔H4) باید با تیم بک‌اند و `BUGS-LIST.md` هماهنگ شوند.
