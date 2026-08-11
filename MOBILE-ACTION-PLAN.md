# نقشهٔ راه رساندن اپ موبایل به ۱۰۰٪ — ما انبارداری (mobile/)

> **هدف:** برای هر ۸ حوزهٔ کارنامه، اقدامات **دقیق و قابل‌پیاده‌سازی** با کد آماده.
> هر اقدام یک چک‌باکس دارد؛ با انجام همهٔ چک‌باکس‌های یک حوزه، آن حوزه به ۱۰۰ می‌رسد.
> **مکمل:** `MOBILE-SCORECARD.md` (امتیازها) و `MOBILE-BUGS-LIST.md` (شرح باگ‌ها).

---

## 📋 خلاصهٔ مسیر امتیاز

| حوزه | فعلی | هدف | تعداد اقدام |
|------|:---:|:---:|:---:|
| معماری و ساختار | 82 | 100 | 6 |
| کیفیت کد | 73 | 100 | 7 |
| امنیت | 70 | 100 | 7 |
| پایداری و ضدکرش | 66 | 100 | 8 |
| صحت محاسبات | 80 | 100 | 5 |
| مقیاس‌پذیری | 52 | 100 | 6 |
| تست | 74 | 100 | 6 |
| تجربهٔ کاربری | 80 | 100 | 6 |

**ترتیب اجرای پیشنهادی:** امنیت (A) → پایداری (D) → مقیاس (F) → کیفیت (B) → صحت (E) → تست (G) → UX (H) → معماری (پاک‌سازی نهایی).

---

## حوزه ۱ — معماری و ساختار (82 → 100)

### □ A1-1 — حذف فایل‌های تکراری (duplication)
سه جفت فایل موازی وجود دارد که باید یکی شوند:

| نگه‌دار | حذف/ادغام کن |
|---------|--------------|
| `core/notifications/` (منبع اصلی) | `features/manager/dashboard/widgets/notification_bell.dart` |
| `shared/widgets/notification_bell.dart` (نسخهٔ مشترک) | `features/manager/dashboard/widgets/notifications_screen.dart` |
| `features/shared/notifications/notifications_screen.dart` | نسخهٔ تکراری در manager |
| `shared/settings/settings_screen.dart` + `shared/settings/data/settings_api_service.dart` | `features/manager/dashboard/navigation_drawer/screens/settings/*` |

**اقدام:** یک نسخه را canonical کن، importها را با جستجوی سراسری اصلاح کن، بقیه را به Recycle Bin بفرست. با `flutter analyze` تأیید کن importی نشکسته.

### □ A1-2 — متمرکز کردن endpointها
همهٔ مسیرهای هاردکد در `manager_api_service.dart` (و سایر سرویس‌ها) به یک فایل واحد منتقل شوند:

```dart
// lib/core/network/api_endpoints.dart
class Endpoints {
  // Manager - Products
  static const products = '/manager/products';
  static String product(String id) => '/manager/products/$id';
  static const productsArchived = '/manager/products/archived';
  static String productRestore(String id) => '/manager/products/$id/restore';
  // Manager - Orders
  static const orders = '/manager/orders';
  static String order(String id) => '/manager/orders/$id';
  // Inventory / Search / ...
  static const inventory = '/manager/inventory';
  static const inventorySummary = '/manager/inventory-summary';
  static const searchShipments = '/manager/search/shipments';
  // ... بقیه
}
```
`ApiConstants` فقط `baseUrl` و helperها را نگه دارد؛ همهٔ pathها به `Endpoints`.

### □ A1-3 — یک لایهٔ Repository بین Provider و ApiService
برای هر feature یک `Repository` اضافه کن که کش/خطا/مپینگ را مدیریت کند تا Provider نازک بماند:
```
Screen → Provider → Repository → ApiService(Dio)
```

### □ A1-4 — یکسان‌سازی نام‌گذاری و ساختار feature
هر feature دقیقاً این ساختار را داشته باشد: `data/ models/ providers/ screens/ widgets/`. پوشهٔ `warehouse_keeper/dashboard/...` را با manager هم‌تراز کن (الان عمق‌ها ناهمگون است).

### □ A1-5 — Barrel exports
برای هر feature یک `<feature>.dart` بساز که همهٔ خروجی‌های عمومی را `export` کند تا importها کوتاه و پایدار شوند (الگوی `manager_screens.dart` که از قبل هست را به همهٔ featureها تعمیم بده).

### □ A1-6 — مستندسازی معماری
یک `mobile/ARCHITECTURE.md` بساز: نمودار لایه‌ها، قرارداد نام‌گذاری، جریان state (Riverpod)، و قرارداد خطا. برای پروژهٔ تیمی الزامی است.

---

## حوزه ۲ — کیفیت کد (73 → 100)

### □ B2-1 — حذف همهٔ ۴۸ مورد `catch (_)` خاموش
هر `catch (_) {}` باید یا خطا را به کاربر نشان دهد یا لاگ کند. الگوی استاندارد:
```dart
} on DioException catch (e, st) {
  AppLogger.error('loadProducts failed', e, st);   // لاگ
  if (!mounted) return;
  setState(() { _loading = false; _error = friendlyError(e); });
  return;
}
```
جاهایی که واقعاً باید بی‌صدا باشند (مثل logout آفلاین) را با کامنت `// ignore: intentional` مستند کن.

### □ B2-2 — مهاجرت همهٔ ۱۴۸ مورد `withOpacity`
```dart
// قبل:  Colors.white.withOpacity(0.08)
// بعد:  Colors.white.withValues(alpha: 0.08)
```
با find & replace با regex انجام‌پذیر است. سپس `flutter analyze` باید صفر deprecation بدهد.

### □ B2-3 — سخت‌گیرانه‌کردن lint
`analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore
    dead_code: error
    unused_import: error
linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls
    - prefer_const_constructors
    - require_trailing_commas
    - unawaited_futures
    - use_build_context_synchronously
    - avoid_print
```

### □ B2-4 — جایگزینی مدل غیرtyped در `products_screen`
`List<Map<String,dynamic>>` (خط ۲۳) با `List<ProductModel>` جایگزین شود؛ flatten حذف و لیست دو‌سطحی typed رندر شود.

### □ B2-5 — logger ساخت‌یافته
یک `lib/core/logging/app_logger.dart` بساز (wrapper روی `dart:developer log` یا پکیج `logger`) و همهٔ `print`ها (مثل `socket_service.dart:47`) را جایگزین کن. در release خاموش شود.

### □ B2-6 — حذف کد مرده
`nav_items` آیتم «پروفایل» بدون مقصد، و هر importی که analyze به‌عنوان unused می‌دهد.

### □ B2-7 — فرمت و CI
`dart format .` روی کل پروژه + یک GitHub Action / اسکریپت pre-commit که `flutter analyze` و `flutter test` را اجرا کند.

---

## حوزه ۳ — امنیت (70 → 100)

### □ C3-1 — baseUrl از dart-define (حذف localhost)
```dart
// api_constants.dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api', // فقط توسعه (امولاتور)
);
```
بیلد تولید:
```
flutter build apk --dart-define=API_BASE_URL=https://api.company.local/api
```

### □ C3-2 — اجبار TLS و بستن cleartext
- Android `AndroidManifest.xml`: `android:usesCleartextTraffic="false"`.
- iOS `Info.plist`: ATS فعال (پیش‌فرض) و استثنا نده.
- در توسعه، cleartext فقط برای دامنهٔ لوکال با `network_security_config.xml` مجاز شود.

### □ C3-3 — Certificate Pinning
برای سیستم اختصاصی شرکتی، گواهی سرور را pin کن:
```dart
(dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) =>
      sha256.convert(cert.der).toString() == kPinnedCertSha256;
  return client;
};
```

### □ C3-4 — تفکیک secure storage روی وب
اگر بیلد وب لازم نیست، در `secure_storage.dart` روی وب خطا بده به‌جای fallback ناامن به `SharedPreferences`. اگر لازم است، هشدار امنیتی مستند شود.

### □ C3-5 — پاک‌سازی حساس هنگام بک‌گراند
هنگام رفتن اپ به بک‌گراند، اسکرین‌شات‌های حاوی داده را بلاک کن:
```dart
// Android: FLAG_SECURE
const platform = MethodChannel('app/security');
// در main یا هر صفحهٔ حساس، FLAG_SECURE ست شود
```

### □ C3-6 — Rate limit / anti-bruteforce ورود سمت کلاینت
پس از N تلاش ناموفق ورود، تأخیر تصاعدی روی دکمهٔ ورود (مکمل rate limit سرور).

### □ C3-7 — هماهنگی با بک‌اند (H1)
سوکت سمت سرور باید `tokenVersion` و `isActive` را چک کند (باگ H1). سمت موبایل بعد از force-logout، سوکت را کامل dispose کن (به D4-7 وصل است).

---

## حوزه ۴ — پایداری و ضدکرش (66 → 100)

### □ D4-1 — ErrorBoundary سراسری در `main.dart`
```dart
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      AppLogger.error('FlutterError', details.exception, details.stack);
      // Crashlytics/Sentry.captureException(...)
    };
    await LocalStorage.init();
    runApp(const ProviderScope(child: MaApp()));
  }, (error, stack) {
    AppLogger.error('Uncaught zone error', error, stack);
  });
}
```

### □ D4-2 — گزارش کرش (Crashlytics یا Sentry)
`sentry_flutter` یا `firebase_crashlytics` اضافه شود تا کرش‌های تولید دیده شوند. بدون این، «بی‌باگ بودن» قابل اثبات نیست.

### □ D4-3 — ویجت خطای سراسری
`ErrorWidget.builder` را با یک ویجت فارسی تمیز جایگزین کن تا صفحهٔ قرمز Flutter به کاربر نشان داده نشود.

### □ D4-4 — چک `mounted` بعد از هر `await`
همهٔ نقاط `products_screen.dart:64,66` و مشابه اصلاح شوند:
```dart
final data = await _api.getX();
if (!mounted) return;
setState(() { ... });
```
با grep روی `await` + `setState` همهٔ موارد را پیدا و اصلاح کن.

### □ D4-5 — رفع نشت listener سوکت (MH4)
در `manager_dashboard_screen.dart` (و هر صفحه‌ای که `socket.on` می‌زند)، در `dispose` همه را off کن:
```dart
static const _events = ['checkin:completed','scanout:done',
  'delivery:completed','order:created','order:updated','order:deleted'];
@override
void dispose() {
  final s = ref.read(socketServiceProvider);
  for (final e in _events) s.off(e);
  _fadeCtrl.dispose(); _slideCtrl.dispose();
  super.dispose();
}
```

### □ D4-6 — subscription واقعی برای سوکت
`SocketService.on` را طوری بازطراحی کن که یک آبجکت لغوپذیر برگرداند (به‌جای off کردن کل event) تا دو صفحه به یک رویداد تداخل نکنند.

### □ D4-7 — reconnect سوکت با توکن تازه (MH5)
```dart
_socket?.onConnectError((e) async {
  _isConnected = false;
  final fresh = await AuthSession.refreshAccessToken();
  if (fresh != null) _socket?.auth = {'token': fresh};
});
// در disconnect: _socket?.dispose(); _socket = null;
```

### □ D4-8 — رفع Race در check_in (MH6)
هنگام `_submitting`، کل فرم را `AbsorbPointer(absorbing: _submitting)` کن و دکمه‌های افزودن/حذف ردیف `onPressed: _submitting ? null : ...`.

---

## حوزه ۵ — صحت محاسبات (80 → 100)

### □ E5-1 — مبالغ مالی با Decimal (نه double)
پکیج `decimal` اضافه شود؛ قیمت‌ها و جمع مبالغ با `Decimal` محاسبه شوند تا خطای اعشاری روی مبالغ بزرگ (تومان/ریال) رخ ندهد. هم‌سو با باگ L5 بک‌اند.

### □ E5-2 — محاسبات سنگین خارج از build
`_totalUnits` (inventory_screen:48) یک‌بار بعد از `_load` محاسبه و در فیلد ذخیره شود، نه در گتر داخل build.

### □ E5-3 — فرمت اعداد فارسی متمرکز
یک util واحد برای جداکنندهٔ هزارگان و ارقام فارسی (`intl` با locale fa) بساز و همه‌جا استفاده کن تا نمایش اعداد یکدست باشد.

### □ E5-4 — گرد کردن کنترل‌شده
هرجا `toInt()` روی مقدار احتمالاً اعشاری استفاده شده (مثل `totalCount.toInt()`)، سیاست گرد کردن (round/floor) صریح و مستند شود.

### □ E5-5 — تست واحد محاسبات
تست برای: جمع موجودی، تبدیل تاریخ شمسی، parse نرخ دلار، و فرمت مبالغ (شامل edge caseهای صفر/منفی/بسیار بزرگ).

---

## حوزه ۶ — مقیاس‌پذیری (52 → 100) 🔴 مهم‌ترین

### □ F6-1 — pagination سمت سرور + کلاینت
سرویس‌ها را با صفحه‌بندی بازنویسی کن:
```dart
class PagedResult<T> {
  final List<T> items; final bool hasMore; final int total;
  const PagedResult({required this.items, required this.hasMore, required this.total});
}

Future<PagedResult<ProductModel>> getProducts({int page = 1, int limit = 30, String? search}) async {
  final r = await _dio.get(Endpoints.products, queryParameters: {
    'page': page, 'limit': limit,
    if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
  });
  final list = r.data['products'] as List;
  return PagedResult(
    items: list.map((j) => ProductModel.fromJson(j)).toList(),
    hasMore: r.data['hasMore'] as bool? ?? false,
    total: r.data['total'] as int? ?? list.length,
  );
}
```
> نیازمند تغییر بک‌اند (هم‌سو با باگ C2). با تیم بک‌اند هماهنگ شود.

### □ F6-2 — infinite scroll در UI
```dart
final _scroll = ScrollController();
@override void initState() { super.initState();
  _scroll.addListener(() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300
        && !_loadingMore && _hasMore) _loadMore();
  });
}
```
لیست‌های محصولات، سفارش‌ها، ارسالی‌ها و تاریخچه همه باید صفحه‌بندی شوند.

### □ F6-3 — حذف پردازش سنگین از UI thread
flatten محصولات (products_screen) حذف یا با `compute()` به Isolate منتقل شود. با pagination عملاً روی ≤۳۰ آیتم اجرا می‌شود.

### □ F6-4 — نمودار موجودی top-N
`_BarChart` فقط ۱۰-۱۵ محصول برتر را نشان دهد؛ لیست کامل با `ListView.builder`/`SliverList`:
```dart
final top = [..._products]..sort((a,b)=>b.totalCount.compareTo(a.totalCount));
final chartData = top.take(12).toList();
```

### □ F6-5 — کش لوکال (offline-first)
`isar` یا `hive` اضافه شود؛ آخرین دادهٔ موجودی/محصولات کش شود تا ورود به صفحه فوری باشد و بعد در پس‌زمینه refresh شود (stale-while-revalidate).

### □ F6-6 — جستجوی سمت سرور با debounce
جستجو نباید روی لیست کامل لوکال فیلتر کند؛ به سرور با `?search=` و debounce ~۴۰۰ms برود (به H8-x وصل است).

---

## حوزه ۷ — تست (74 → 100)

### □ G7-1 — تست ویجت برای صفحات سنگین
`products_screen`, `inventory_screen`, `scan_out_screen` — با mock provider تست شوند (حالت loading / error / empty / data).

### □ G7-2 — تست حالت خطا و mounted
تست کن که وقتی API خطا می‌دهد، پیام خطا نمایش داده می‌شود (نه صفحهٔ خالی) و کرش نمی‌شود.

### □ G7-3 — تست pagination
تست بارگذاری صفحهٔ بعد، `hasMore=false`، و جلوگیری از درخواست تکراری.

### □ G7-4 — Golden tests
برای حباب چت دستیار، کارت‌های داشبورد و حالت‌های RTL.

### □ G7-5 — Integration test
جریان کامل: login → dashboard → scan_out → مشاهدهٔ نتیجه، با `integration_test`.

### □ G7-6 — پوشش و CI gate
`flutter test --coverage`؛ هدف ≥۶۰٪ روی `lib/` (به‌جز generated). PR بدون عبور تست merge نشود.

---

## حوزه ۸ — تجربهٔ کاربری (80 → 100)

### □ H8-1 — بخش «دستیار» (جایگزین پروفایل مرده)
طبق بخش E در `MOBILE-BUGS-LIST.md`: چت‌بات + ویس‌به‌متن + LLM با tool-calling امن.

### □ H8-2 — حالت‌های خطا/خالی یکدست
یک ویجت مشترک `AppStateView(loading/error/empty/data)` برای همهٔ صفحات تا تجربه یکدست شود و دیگر صفحهٔ سفید گمراه‌کننده نباشد.

### □ H8-3 — Skeleton loading
به‌جای `CircularProgressIndicator` تنها، از shimmer/skeleton استفاده کن (حس سریع‌تر).

### □ H8-4 — بهبود اسکنر
تأخیر ثابت ۲۵۰۰ms اسکنر (`scan_out_screen`) به ~۸۰۰ms یا دکمهٔ «اسکن بعدی» فوری کاهش یابد؛ فیدبک صوتی/لرزشی موفق/ناموفق اضافه شود.

### □ H8-5 — دسترس‌پذیری (a11y)
`Semantics` برای دکمه‌ها، اندازهٔ لمس ≥۴۸dp، پشتیبانی از متن بزرگ، و کنتراست کافی رنگ‌ها.

### □ H8-6 — اسپلش هوشمند + pull-to-refresh فراگیر
تأخیر ثابت ۱۵۰۰ms اسپلش (auth_provider:132) به «فقط باقیمانده تا آماده شدن» تبدیل شود؛ `RefreshIndicator` روی همهٔ لیست‌ها.

---

## 🗺️ ترتیب اجرا (Sprintها)

**Sprint 1 — بلاکرهای تولید (بدون اینها اپ اصلاً کار/امن نیست):**
- C3-1, C3-2 (baseUrl + TLS)
- D4-1, D4-2, D4-3 (ErrorBoundary + crash reporting)
- D4-4, D4-5, D4-7 (mounted + نشت/reconnect سوکت)

**Sprint 2 — مقیاس (بدون اینها با ۲۰هزار محصول کرش):**
- F6-1, F6-2, F6-3, F6-4 (pagination + بهینه‌سازی)
- B2-4 (مدل typed)

**Sprint 3 — سخت‌سازی کیفیت:**
- B2-1 (حذف catch خاموش), B2-2 (withValues), B2-3 (lint), B2-5 (logger)
- E5-1..E5-5 (محاسبات)

**Sprint 4 — دستیار + UX:**
- H8-1 (دستیار), H8-2..H8-6

**Sprint 5 — تثبیت:**
- G7-1..G7-6 (تست + CI)
- A1-1..A1-6 (پاک‌سازی معماری + مستندات)
- C3-3, C3-5, C3-6 (سخت‌سازی امنیت), F6-5 (کش)

---

## ✅ معیار پذیرش «۱۰۰٪» هر حوزه

| حوزه | تعریف Done |
|------|-----------|
| معماری | صفر فایل تکراری، endpoint متمرکز، ARCHITECTURE.md موجود |
| کیفیت کد | `flutter analyze` = صفر warning/deprecation، صفر `catch(_)` بی‌مستند |
| امنیت | https+TLS اجباری، pinning فعال، صفر cleartext در release |
| پایداری | ErrorBoundary + crash reporting فعال، صفر `setState after dispose` |
| صحت محاسبات | مبالغ با Decimal، تست‌های edge case سبز |
| مقیاس | لیست‌ها paginated، تست با ۲۰هزار رکورد بدون فریز/کرش |
| تست | پوشش ≥۶۰٪، CI gate فعال |
| UX | حالت‌های یکدست، دستیار فعال، a11y پایه |

> **یادآوری:** موارد F6-1 و H8-1 به تغییر بک‌اند وابسته‌اند و باید با `BUGS-LIST.md` هماهنگ شوند. بقیه کاملاً سمت موبایل قابل اجرا هستند.

---

## 🌳 ساختار درختی پیشنهادی نهایی (Target Structure)

این ساختاری است که پس از اجرای همهٔ اقدامات حوزهٔ معماری (A1-1 تا A1-6) باید به آن برسیم.
اصول: **feature-first**، عمق حداکثر ۴ سطح، سه لایهٔ ثابت (`data → domain → presentation`)، صفر فایل تکراری.

```text
mobile/
├── lib/
│   ├── main.dart                      # فقط bootstrap: runZonedGuarded + ErrorBoundary (D4-1)
│   ├── app.dart                       # MaApp (MaterialApp.router) — از main جدا شود
│   │
│   ├── core/                          # زیرساخت مستقل از feature (هیچ importی از features ندارد)
│   │   ├── config/
│   │   │   ├── app_config.dart        # baseUrl از dart-define (C3-1)، محیط dev/prod
│   │   │   └── app_flavors.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart        # Dio + interceptorها + pinning (C3-3)
│   │   │   ├── api_constants.dart     # فقط baseUrl + helperها
│   │   │   ├── api_endpoints.dart     # ★ همهٔ pathها متمرکز (A1-2)
│   │   │   ├── api_error.dart         # friendlyError
│   │   │   ├── auth_session.dart      # ★ AuthSession از dio_client جدا شود
│   │   │   └── paged_result.dart      # ★ مدل عمومی pagination (F6-1)
│   │   ├── realtime/
│   │   │   └── socket_service.dart    # + subscription لغوپذیر (D4-6) + reconnect (D4-7)
│   │   ├── storage/
│   │   │   ├── secure_storage.dart
│   │   │   ├── local_storage.dart
│   │   │   └── cache/                 # ★ کش لوکال offline-first (F6-5)
│   │   │       └── inventory_cache.dart
│   │   ├── logging/
│   │   │   └── app_logger.dart        # ★ logger ساخت‌یافته (B2-5)
│   │   ├── error/
│   │   │   ├── error_boundary.dart    # ★ ErrorWidget.builder سفارشی (D4-3)
│   │   │   └── crash_reporter.dart    # ★ Sentry/Crashlytics wrapper (D4-2)
│   │   ├── notifications/             # ★ تنها منبع نوتیفیکیشن (حذف نسخه‌های تکراری A1-1)
│   │   │   ├── notification_model.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── notification_provider.dart
│   │   │   └── notification_handler.dart
│   │   ├── routes/
│   │   │   └── app_router.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart        # ★ رنگ‌های هاردکد (0xFF0F1114...) متمرکز شوند
│   │   │   └── app_text_styles.dart
│   │   └── utils/
│   │       ├── money.dart             # ★ محاسبهٔ Decimal مبالغ (E5-1)
│   │       ├── number_format_fa.dart  # ★ فرمت اعداد/ارقام فارسی (E5-3)
│   │       └── jalali_utils.dart      # تبدیل تاریخ شمسی متمرکز
│   │
│   ├── shared/                        # ویجت/منطق مشترک بین چند feature
│   │   ├── widgets/
│   │   │   ├── app_state_view.dart    # ★ loading/error/empty/data یکدست (H8-2)
│   │   │   ├── app_skeleton.dart      # ★ shimmer (H8-3)
│   │   │   ├── notification_bell.dart # ★ تنها نسخه (حذف تکراری‌ها A1-1)
│   │   │   ├── app_drawer.dart
│   │   │   └── lock_settings_tile.dart
│   │   └── settings/                  # ★ تنها صفحهٔ تنظیمات (حذف نسخهٔ manager)
│   │       ├── data/settings_api_service.dart
│   │       └── settings_screen.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── data/auth_api_service.dart
│       │   ├── providers/auth_provider.dart
│       │   ├── lock/                  # قفل پین/بیومتریک
│       │   │   ├── lock_config.dart
│       │   │   ├── lock_provider.dart
│       │   │   └── lock_storage.dart
│       │   ├── screens/
│       │   │   ├── splash_screen.dart
│       │   │   ├── login_screen.dart
│       │   │   └── lock_screen.dart
│       │   └── auth.dart              # ★ barrel export (A1-5)
│       │
│       ├── manager/
│       │   ├── data/
│       │   │   └── manager_api_service.dart   # با pagination (F6-1)
│       │   ├── repository/                     # ★ لایهٔ Repository (A1-3)
│       │   │   └── manager_repository.dart
│       │   ├── models/                          # همه freezed + typed (B2-4)
│       │   │   ├── product_model.dart
│       │   │   ├── order_model.dart
│       │   │   ├── warehouse_model.dart
│       │   │   ├── inventory_summary_model.dart
│       │   │   └── ... (سایر مدل‌ها)
│       │   ├── providers/
│       │   │   ├── manager_api_provider.dart   # autoDispose (MM5)
│       │   │   ├── products_provider.dart      # paginated
│       │   │   ├── inventory_provider.dart
│       │   │   └── activity_provider.dart
│       │   ├── dashboard/                       # صفحهٔ اصلی + اجزای آن
│       │   │   ├── manager_dashboard_screen.dart
│       │   │   ├── header/
│       │   │   ├── search/                      # با debounce سمت‌سرور (F6-6)
│       │   │   ├── quick_actions/
│       │   │   ├── activity/
│       │   │   ├── inventory_chart/
│       │   │   └── bottom_nav_bar/
│       │   │       ├── bottom_nav_bar.dart
│       │   │       ├── nav_item.dart
│       │   │       └── nav_items.dart           # «پروفایل» → «دستیار» (H8-1)
│       │   ├── products/                        # صفحات محصولات (paginated)
│       │   ├── inventory/                       # صفحات موجودی (SliverList + top-N)
│       │   ├── orders/                          # سفارش‌ها/ارسال‌ها
│       │   ├── users/  · warehouses/  · reports/  · archive/  · history/
│       │   ├── assistant/                       # ★ بخش جدید دستیار (H8-1)
│       │   │   ├── data/assistant_api_service.dart
│       │   │   ├── models/chat_message_model.dart
│       │   │   ├── providers/assistant_provider.dart
│       │   │   ├── voice/voice_input_controller.dart   # ویس‌به‌متن fa-IR
│       │   │   ├── assistant_screen.dart
│       │   │   └── widgets/
│       │   │       ├── message_bubble.dart
│       │   │       ├── chat_input_bar.dart
│       │   │       └── typing_indicator.dart
│       │   └── manager.dart            # ★ barrel export
│       │
│       ├── warehouse_keeper/
│       │   ├── data/warehouse_keeper_api_service.dart
│       │   ├── repository/keeper_repository.dart
│       │   ├── models/
│       │   ├── providers/warehouse_keeper_provider.dart
│       │   ├── check_in/check_in_screen.dart   # رفع Race (D4-8)
│       │   ├── scan_out/scan_out_screen.dart   # بهبود اسکنر (H8-4)
│       │   ├── loading_plan/
│       │   ├── dashboard/
│       │   │   ├── warehouse_keeper_dashboard_screen.dart
│       │   │   ├── home/ · inventory/ · orders/ · reports/ · search/ · bottom_nav/
│       │   └── warehouse_keeper.dart   # ★ barrel export
│       │
│       └── driver/
│           ├── data/driver_api_service.dart
│           ├── repository/driver_repository.dart
│           ├── providers/driver_provider.dart
│           ├── screens/driver_dashboard_screen.dart
│           ├── widgets/  (driver_header, driver_bottom_nav, delivery_tab, ...)
│           └── driver.dart             # ★ barrel export
│
├── test/                              # آینه‌ی ساختار lib/ (G7-x)
│   ├── core/         (auth_session, token_expiry, network, ...)
│   ├── features/
│   │   ├── auth/     (auth_provider_lock, lock_*, app_router)
│   │   ├── manager/  (products, inventory, assistant, pagination)
│   │   ├── warehouse_keeper/ (check_in, scan_out)
│   │   └── driver/
│   ├── utils/        (money, number_format, jalali)   # E5-5
│   ├── golden/       # G7-4
│   └── helpers/      (mock_secure_channel, fake_http_adapter)  # از تست‌های فعلی
│
├── integration_test/                  # ★ جریان کامل (G7-5)
│   └── app_flow_test.dart
│
├── android/  ·  ios/  ·  web/
├── analysis_options.yaml              # lint سخت‌گیرانه (B2-3)
├── pubspec.yaml
├── ARCHITECTURE.md                    # ★ مستند معماری (A1-6)
└── README.md
```

> ★ = آیتم **جدید یا جابه‌جاشده** نسبت به ساختار فعلی.

### تفاوت‌های کلیدی با ساختار فعلی

| # | تغییر | چرا |
|---|-------|-----|
| 1 | جدا کردن `app.dart` از `main.dart` | main فقط bootstrap + ErrorBoundary باشد (D4-1) |
| 2 | افزودن `core/config` (baseUrl از dart-define) | حذف localhost هاردکد (C3-1) |
| 3 | افزودن `core/error` و `core/logging` | crash reporting + logger (D4-2, B2-5) |
| 4 | `api_endpoints.dart` واحد | حذف مسیرهای هاردکد (A1-2) |
| 5 | `AuthSession` از `dio_client` جدا | تک‌مسئولیتی، تست‌پذیری |
| 6 | لایهٔ `repository/` در هر feature | نازک‌کردن provider + کش (A1-3) |
| 7 | حذف ۳ جفت فایل تکراری (notification_bell، settings، notifications_screen) | صفر duplication (A1-1) |
| 8 | `features/manager/assistant/` جدید | جایگزین «پروفایل» مرده (H8-1) |
| 9 | `barrel export` برای هر feature | importهای کوتاه و پایدار (A1-5) |
| 10 | `test/` آینهٔ `lib/` + `integration_test/` + `golden/` | پوشش ساخت‌یافته (G7-x) |
| 11 | `core/utils/money.dart` (Decimal) | صحت محاسبات مالی (E5-1) |
| 12 | `core/theme/app_colors.dart` | رنگ‌های هاردکد `0xFF...` متمرکز |

### قانون وابستگی (Dependency Rule)
```
features/*  ──►  shared/  ──►  core/
   │                            ▲
   └────────────────────────────┘   (features فقط به core و shared وابسته است)

هرگز: core ──► features   یا   core ──► shared   (ممنوع)
هرگز: یک feature ──► feature دیگر (از طریق core/shared ارتباط بگیرند)
```
این قانون جلوی وابستگی حلقوی و درهم‌تنیدگی را می‌گیرد و ساختار را در بلندمدت تمیز نگه می‌دارد.
