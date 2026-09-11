import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiError implements Exception {
  ApiError(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService();

  static const _serverUrlKey = 'server_url';
  static const defaultServerUrl = 'http://127.0.0.1:3000';

  late Dio _dio;
  String? token;
  String? refreshToken;
  Map<String, dynamic>? user;

  /// وقتی رفرش هم شکست (خروج اجباری/ابطال) — UI به صفحه ورود برمی‌گردد.
  void Function()? onAuthExpired;

  /// بعد از هر تمدید موفق — سوکت باید با توکن جدید وصل شود.
  void Function(String token)? onTokenRefreshed;

  /// single-flight: چند 401 هم‌زمان فقط یک رفرش می‌زنند (چرخش رفرش‌توکن).
  Future<String>? _refreshing;

  Future<String> loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? defaultServerUrl;
  }

  Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }

  void configure(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        // توکن دسترسی ۱۵ دقیقه است؛ روی 401 یک بار رفرش و تکرار درخواست.
        // اگر رفرش هم شکست → نشست واقعاً مرده: پاک‌سازی + بازگشت به ورود.
        onError: (err, handler) async {
          final req = err.requestOptions;
          final status = err.response?.statusCode;
          final isAuthCall = req.path.contains('/auth/');
          if (status == 401 && !isAuthCall && req.extra['retried'] != true) {
            if (refreshToken != null) {
              try {
                final newToken = await _refreshOnce();
                req.extra['retried'] = true;
                req.headers['Authorization'] = 'Bearer $newToken';
                final retry = await _dio.fetch<dynamic>(req);
                return handler.resolve(retry);
              } catch (_) {
                _dropSession();
              }
            } else {
              _dropSession();
            }
          }
          handler.next(err);
        },
      ),
    );
  }

  dynamic _request(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      return response.data;
    } on DioException catch (exc) {
      final payload = exc.response?.data;
      String? message;
      if (payload is Map<String, dynamic>) {
        message = (payload['error'] ?? payload['message']) as String?;
      }
      if (exc.type == DioExceptionType.connectionTimeout ||
          exc.type == DioExceptionType.receiveTimeout) {
        throw ApiError('ارتباط با سرور بیش از حد طول کشید.');
      }
      if (exc.type == DioExceptionType.connectionError ||
          exc.type == DioExceptionType.unknown) {
        throw ApiError('اتصال به سرور برقرار نشد.');
      }
      throw ApiError(message ?? 'درخواست به سرور با خطا مواجه شد.');
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final payload = await _request(
      'POST',
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    if (payload is! Map<String, dynamic>) {
      throw ApiError('پاسخ ورود نامعتبر است.');
    }
    token = payload['token'] as String?;
    refreshToken = payload['refreshToken'] as String?;
    user = (payload['user'] as Map<String, dynamic>?) ?? {};
    if (token == null || user == null) {
      throw ApiError('اطلاعات کاربری کامل دریافت نشد.');
    }
    return payload;
  }

  /// تمدید نشست با چرخش رفرش‌توکن (سرور: POST /auth/refresh).
  /// single-flight تا فراخوان‌های هم‌زمان باعث ابطال خانواده نشوند.
  Future<String> _refreshOnce() {
    final ongoing = _refreshing;
    if (ongoing != null) return ongoing;
    final fut = _performRefresh();
    _refreshing = fut;
    fut.then((_) {
      _refreshing = null;
    }, onError: (_) {
      _refreshing = null;
    });
    return fut;
  }

  Future<String> _performRefresh() async {
    final rt = refreshToken;
    if (rt == null) throw ApiError('نشست منقضی شده است.');
    final resp = await _dio.post<dynamic>(
      '/auth/refresh',
      data: {'refreshToken': rt},
    );
    final data = resp.data;
    if (data is! Map<String, dynamic>) {
      throw ApiError('پاسخ تمدید نشست نامعتبر است.');
    }
    final newToken = data['token'] as String?;
    final newRefresh = data['refreshToken'] as String?;
    if (newToken == null || newRefresh == null) {
      throw ApiError('پاسخ تمدید نشست نامعتبر است.');
    }
    token = newToken;
    refreshToken = newRefresh;
    onTokenRefreshed?.call(newToken);
    return newToken;
  }

  void _dropSession() {
    token = null;
    refreshToken = null;
    user = null;
    onAuthExpired?.call();
  }

  /// تغییر رمز عبور کاربر جاری (تغییر اجباری در اولین ورود با رمز موقت)
  Future<void> updateMyPassword(String newPassword) async {
    await _request(
      'PUT',
      '/auth/profile',
      data: {'password': newPassword},
    );
  }

  Future<Map<String, dynamic>> getMyWarehouse() async {
    final payload = await _request('GET', '/warehouse-keeper/my-warehouse');
    return ((payload is Map<String, dynamic>) ? payload['warehouse'] : null)
            as Map<String, dynamic>? ??
        {};
  }

  /// صف چاپ لیبل: همهٔ کارتن‌های چاپ‌نشده (سقف ۵۰۰ — سرور بیشتر نمی‌دهد).
  /// سقف قبلیِ ضمنی ۵۰ باعث می‌شد در انبارهای شلوغ بخشی از لیبل‌ها دیده نشوند.
  Future<List<dynamic>> getCartons({int limit = 500}) async {
    final payload = await _request(
      'GET',
      '/warehouse-keeper/checkin/recent',
      query: {'limit': limit},
    );
    return (payload is Map<String, dynamic> ? payload['cartons'] : null)
            as List<dynamic>? ??
        [];
  }

  Future<List<dynamic>> getShippedCartons() async {
    final payload = await _request('GET', '/warehouse-keeper/cartons/shipped');
    return (payload is Map<String, dynamic> ? payload['cartons'] : null)
            as List<dynamic>? ??
        [];
  }

  /// کارتن‌هایی که لیبل‌شان چاپ شده — تب «چاپ شده‌ها»
  Future<List<dynamic>> getPrintedCartons() async {
    final payload = await _request('GET', '/warehouse-keeper/cartons/printed');
    return (payload is Map<String, dynamic> ? payload['cartons'] : null)
            as List<dynamic>? ??
        [];
  }

  /// ثبت لحظهٔ چاپ لیبل — کارتن‌ها از «محصولات» به «چاپ شده‌ها» منتقل می‌شوند
  Future<void> markCartonsPrinted(List<String> cartonIds) async {
    await _request(
      'POST',
      '/warehouse-keeper/cartons/printed',
      data: {'cartonIds': cartonIds},
    );
  }

  Future<List<dynamic>> getTransactions({String? date, String? type}) async {
    final payload = await _request(
      'GET',
      '/warehouse-keeper/transactions',
      query: {
        'date': ?date,
        'type': ?type,
      },
    );
    return (payload is Map<String, dynamic> ? payload['transactions'] : null)
            as List<dynamic>? ??
        [];
  }

  Future<List<dynamic>> getLabels() async {
    final payload = await _request('GET', '/warehouse-keeper/labels');
    return (payload is Map<String, dynamic> ? payload['cartons'] : null)
            as List<dynamic>? ??
        [];
  }

  /// محصولات تعریف‌شده توسط مدیر (با مدل‌ها و ظرفیت بسته) — برای ورود کالا
  Future<({List<dynamic> products, int total})> getProducts({
    String q = '',
    int page = 1,
    int pageSize = 50,
  }) async {
    final payload = await _request(
      'GET',
      '/warehouse-keeper/products',
      query: {
        if (q.trim().isNotEmpty) 'q': q.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final map = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final products = (map['products'] as List<dynamic>?) ?? [];
    final total = (map['total'] as num?)?.toInt() ?? products.length;
    return (products: products, total: total);
  }

  /// ثبت ورود کالا — سرور برای هر کارتن/تکی QR و سریال می‌سازد
  Future<List<dynamic>> submitCheckin(
    List<Map<String, dynamic>> items, {
    String? clientKey,
  }) async {
    final payload = await _request(
      'POST',
      '/warehouse-keeper/checkin',
      data: {'items': items, 'clientKey': ?clientKey},
    );
    return (payload is Map<String, dynamic> ? payload['cartons'] : null)
            as List<dynamic>? ??
        [];
  }

  /// بیجک‌ها — با فیلتر چاپ: true → فقط چاپ‌شده، false → فقط چاپ‌نشده، null → همه
  Future<List<dynamic>> getBadges({bool? printed}) async {
    final payload = await _request(
      'GET',
      '/badges',
      query: {'printed': ?printed},
    );
    return payload as List<dynamic>? ?? [];
  }

  /// ثبت لحظهٔ چاپ برگهٔ بیجک — بیجک‌ها از منوی «بیجک» حذف و در
  /// تب «چاپ شده‌ها» (فیلتر بیجک) نمایش داده می‌شوند
  Future<void> markBadgesPrinted(List<String> badgeIds) async {
    await _request('POST', '/badges/printed', data: {'badgeIds': badgeIds});
  }

  /// خروج: ابطال سمت سرور (best-effort) + پاک‌سازی محلی.
  Future<void> logout() async {
    final rt = refreshToken;
    token = null;
    refreshToken = null;
    user = null;
    if (rt != null) {
      try {
        await _dio.post<dynamic>('/auth/logout', data: {'refreshToken': rt});
      } catch (_) {
        // خروج محلی مهم است؛ خطای شبکه نادیده گرفته می‌شود.
      }
    }
  }
}
