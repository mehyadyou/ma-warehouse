import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiError implements Exception {
  ApiError(this.message);
  final String message;

  @override
  String toString() => message;
}

/// کلاینت API پنل CRM — فقط مدیر (MANAGER)، فقط خواندن (+ مدیریت کلیدهای API).
/// نشست فقط در حافظه است؛ با بستن برنامه باید دوباره وارد شد.
class CrmApiService {
  CrmApiService();

  static const _serverUrlKey = 'crm_server_url';
  static const defaultServerUrl = 'http://127.0.0.1:3000';

  late Dio _dio;
  String? token;
  Map<String, dynamic>? user;

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
        receiveTimeout: const Duration(seconds: 30),
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

  Map<String, dynamic> _asMap(dynamic payload) =>
      payload is Map<String, dynamic> ? payload : const <String, dynamic>{};

  List<dynamic> _asList(dynamic payload) =>
      payload is List<dynamic> ? payload : const <dynamic>[];

  // ─── احراز هویت ───

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
    user = (payload['user'] as Map<String, dynamic>?) ?? {};
    if (token == null || user == null) {
      throw ApiError('اطلاعات کاربری کامل دریافت نشد.');
    }
    return payload;
  }

  Future<void> updateMyPassword(String newPassword) async {
    await _request(
      'PUT',
      '/auth/profile',
      data: {'password': newPassword},
    );
  }

  void logout() {
    token = null;
    user = null;
  }

  // ─── نمای کلی ───

  Future<Map<String, dynamic>> getOverview() async =>
      _asMap(await _request('GET', '/manager/crm/overview'));

  Future<Map<String, dynamic>> getHealth() async =>
      _asMap(await _request('GET', '/manager/crm/health'));

  Future<Map<String, dynamic>> getInventorySummary() async =>
      _asMap(await _request('GET', '/manager/inventory-summary'));

  // ─── مشتریان ───

  Future<Map<String, dynamic>> getCustomers({
    String q = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final payload = await _request(
      'GET',
      '/manager/crm/customers',
      query: {
        if (q.trim().isNotEmpty) 'q': q.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final map = _asMap(payload);
    return {
      'customers': _asList(map['customers']),
      'total': (map['total'] as num?)?.toInt() ?? 0,
      'page': (map['page'] as num?)?.toInt() ?? page,
      'pageSize': (map['pageSize'] as num?)?.toInt() ?? pageSize,
    };
  }

  Future<Map<String, dynamic>> getCustomerDetail(String phone) async {
    return _asMap(await _request(
      'GET',
      '/manager/crm/customers/${Uri.encodeComponent(phone)}',
    ));
  }

  // ─── مالی ───

  Future<Map<String, dynamic>> getFinance({
    String? from,
    String? to,
    String? warehouseId,
  }) async {
    return _asMap(await _request(
      'GET',
      '/manager/crm/finance',
      query: {
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        if (warehouseId != null && warehouseId.isNotEmpty)
          'warehouseId': warehouseId,
      },
    ));
  }

  // ─── فعالیت و ممیزی ───

  Future<Map<String, dynamic>> getUserActivity({
    String? userId,
    String? from,
    String? to,
    int limit = 50,
  }) async {
    final payload = await _request(
      'GET',
      '/manager/crm/user-activity',
      query: {
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        'limit': limit,
      },
    );
    final map = _asMap(payload);
    return {
      'entries': _asList(map['entries']),
      'counts': _asMap(map['counts']),
    };
  }

  Future<Map<String, dynamic>> getAudit({
    String? actorId,
    String? entity,
    String? action,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final payload = await _request(
      'GET',
      '/manager/crm/audit',
      query: {
        if (actorId != null && actorId.isNotEmpty) 'actorId': actorId,
        if (entity != null && entity.isNotEmpty) 'entity': entity,
        if (action != null && action.isNotEmpty) 'action': action,
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final map = _asMap(payload);
    return {
      'entries': _asList(map['entries']),
      'total': (map['total'] as num?)?.toInt() ?? 0,
      'page': (map['page'] as num?)?.toInt() ?? page,
      'pageSize': (map['pageSize'] as num?)?.toInt() ?? pageSize,
    };
  }

  Future<List<dynamic>> getUsers() async {
    final payload = await _request('GET', '/manager/users');
    if (payload is Map<String, dynamic>) return _asList(payload['users']);
    return _asList(payload);
  }

  Future<List<dynamic>> getWarehouses() async {
    final payload = await _request('GET', '/manager/warehouses');
    if (payload is Map<String, dynamic>) return _asList(payload['warehouses']);
    return _asList(payload);
  }

  // ─── مصرف کلیدها ───

  Future<Map<String, dynamic>> getApiUsage({int? from, int? to}) async {
    final payload = await _request(
      'GET',
      '/manager/crm/api-usage',
      query: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    final map = _asMap(payload);
    return {
      'keys': _asList(map['keys']),
      'from': map['from'],
      'to': map['to'],
    };
  }

  // ─── مدیریت کلیدهای API (تنها نوشتنِ مجاز پنل) ───

  Future<List<dynamic>> getApiScopes() async {
    final payload = await _request('GET', '/manager/api-keys/scopes');
    if (payload is Map<String, dynamic>) return _asList(payload['scopes']);
    return _asList(payload);
  }

  Future<List<dynamic>> getApiKeys() async {
    final payload = await _request('GET', '/manager/api-keys');
    if (payload is Map<String, dynamic>) return _asList(payload['keys']);
    return _asList(payload);
  }

  /// ساخت کلید — پاسخ شامل کلید خامِ یک‌بارمصرف است (فقط همین‌جا نمایش داده شود)
  Future<Map<String, dynamic>> createApiKey({
    required String name,
    required List<String> scopes,
    String? expiresAt,
  }) async {
    final payload = await _request(
      'POST',
      '/manager/api-keys',
      data: {
        'name': name,
        if (scopes.isNotEmpty) 'scopes': scopes,
        if (expiresAt != null && expiresAt.isNotEmpty) 'expiresAt': expiresAt,
      },
    );
    return _asMap(payload);
  }

  Future<void> revokeApiKey(String id) async {
    await _request('POST', '/manager/api-keys/$id/revoke');
  }

  Future<void> restoreApiKey(String id) async {
    await _request('POST', '/manager/api-keys/$id/restore');
  }

  Future<void> deleteApiKey(String id) async {
    await _request('DELETE', '/manager/api-keys/$id');
  }
}
