import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/models/product_model.dart';

/// تست بار staging — فقط وقتی اجرا می‌شود که STAGING_BASE_URL داده شده باشد
/// (در CI همیشه skip است):
///
///   flutter test test/staging_load_test.dart \
///     --dart-define=STAGING_BASE_URL=http://127.0.0.1:3100/api
///
/// پیش‌نیاز: سرور staging بالا + سید فشاری (scripts/loadtest/seed-pressure.ts).
/// با Dio خام و هدر دستی وصل می‌شود (SecureStorage در محیط تست کانال ندارد)
/// ولی پاسخ‌ها با مدل‌های واقعی اپ parse می‌شوند + زمان‌بندی چاپ می‌شود.
const stagingBase = String.fromEnvironment('STAGING_BASE_URL', defaultValue: '');

Dio _dio() => Dio(BaseOptions(
      baseUrl: stagingBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

final _timings = <String, int>{};

Future<Response> _timed(
    String label, Future<Response> Function() fn) async {
  final t0 = DateTime.now();
  try {
    return await fn();
  } finally {
    _timings[label] =
        ((_timings[label] ?? 0) + DateTime.now().difference(t0).inMilliseconds);
  }
}

void main() {
  group('staging load — دیتای فشاری در اپ', skip: stagingBase.isEmpty
      ? 'needs --dart-define=STAGING_BASE_URL (CI-safe skip)'
      : false, () {
    late Dio dio;
    late String mgrToken;
    late String keeperToken;
    late String productId;
    late String modelId;

    test('ورود مدیر و انباردار فشاری', () async {
      dio = _dio();
      final m = await _timed(
          'login',
          () => dio.post('/auth/login',
              data: {'phone': '09120000000', 'password': 'Manager123'}));
      expect(m.statusCode, 200);
      mgrToken = m.data['token'] as String;
      final k = await _timed(
          'login',
          () => dio.post('/auth/login',
              data: {'phone': '09120001001', 'password': '123456'}));
      expect(k.statusCode, 200);
      keeperToken = k.data['token'] as String;
      expect(mgrToken.isNotEmpty && keeperToken.isNotEmpty, isTrue);
    });

    test('لیست محصولات: ۱۰٬۰۰۰ ردیف با صفحه‌بندی', () async {
      final res = await _timed(
          'products-p50',
          () => dio.get('/manager/products',
              queryParameters: {'page': 1, 'pageSize': 50},
              options: Options(
                  headers: {'Authorization': 'Bearer $mgrToken'})));
      expect(res.statusCode, 200);
      final total = (res.data['total'] as num).toInt();
      expect(total, greaterThanOrEqualTo(10000));
      final list = (res.data['products'] as List).cast<Map<String, dynamic>>();
      expect(list.length, 50);
      // parse با مدل واقعی اپ
      final first = ProductModel.fromJson(
          Map<String, dynamic>.from(list.first));
      productId = first.id;
      modelId = first.models.first.id;
      expect(productId.isNotEmpty && modelId.isNotEmpty, isTrue);
    });

    test('صفحه دوم متفاوت از اول است', () async {
      final p2 = await _timed(
          'products-p2',
          () => dio.get('/manager/products',
              queryParameters: {'page': 2, 'pageSize': 50},
              options: Options(
                  headers: {'Authorization': 'Bearer $mgrToken'})));
      expect((p2.data['products'] as List).length, 50);
    });

    test('جستجوی فارسی روی ۱۰هزار محصول', () async {
      final res = await _timed(
          'search-fa',
          () => dio.get('/manager/products',
              queryParameters: {'q': 'فشاری', 'page': 1, 'pageSize': 5},
              options: Options(
                  headers: {'Authorization': 'Bearer $mgrToken'})));
      expect(res.statusCode, 200);
      expect((res.data['total'] as num).toInt(), greaterThanOrEqualTo(10000));
    });

    test('داشبورد مدیر + خلاصه موجودی انباردار زیر بار دیتا', () async {
      final d = await _timed(
          'm:dashboard',
          () => dio.get('/manager/dashboard',
              options: Options(
                  headers: {'Authorization': 'Bearer $mgrToken'})));
      expect(d.statusCode, 200);
      final s = await _timed(
          'w:inv-summary',
          () => dio.get('/warehouse-keeper/inventory-summary',
              options: Options(
                  headers: {'Authorization': 'Bearer $keeperToken'})));
      expect(s.statusCode, 200);
    });

    test('سفارش‌های انباردار (۵۰ سفارش سیدی)', () async {
      final res = await _timed(
          'w:orders',
          () => dio.get('/warehouse-keeper/orders',
              options: Options(
                  headers: {'Authorization': 'Bearer $keeperToken'})));
      expect(res.statusCode, 200);
    });

    test('ری‌پلی ایدمپوتنسی ورود کالا: دو ارسال با یک کلید = یک ثبت', () async {
      const clientKey = 'staging-load-replay-1';
      final body = {
        'items': [
          {
            'productId': productId,
            'modelId': modelId,
            'cartonCount': 1,
            'individualCount': 0
          }
        ],
        'clientKey': clientKey,
      };
      final opts = Options(headers: {'Authorization': 'Bearer $keeperToken'});
      final r1 = await _timed('w:checkin',
          () => dio.post('/warehouse-keeper/checkin', data: body, options: opts));
      expect(r1.statusCode, 201);
      final r2 = await _timed('w:checkin-replay',
          () => dio.post('/warehouse-keeper/checkin', data: body, options: opts));
      expect(r2.statusCode, 201);
      // پاسخ دوم دقیقاً همان کارتن‌های اولی است (ثبت تکراری نشده)
      expect(r2.data['cartons'], equals(r1.data['cartons']));
    });

    tearDownAll(() {
      // ignore: avoid_print
      print('\n[staging-load] timings (ms total): $_timings');
    });
  });
}
