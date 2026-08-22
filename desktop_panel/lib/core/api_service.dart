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
    user = (payload['user'] as Map<String, dynamic>?) ?? {};
    if (token == null || user == null) {
      throw ApiError('اطلاعات کاربری کامل دریافت نشد.');
    }
    return payload;
  }

  Future<Map<String, dynamic>> getMyWarehouse() async {
    final payload = await _request('GET', '/warehouse-keeper/my-warehouse');
    return ((payload is Map<String, dynamic>) ? payload['warehouse'] : null)
            as Map<String, dynamic>? ??
        {};
  }

  Future<List<dynamic>> getCartons() async {
    final payload = await _request('GET', '/warehouse-keeper/checkin/recent');
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

  Future<List<dynamic>> getTransactions({String? date}) async {
    final payload = await _request(
      'GET',
      '/warehouse-keeper/transactions',
      query: date != null ? {'date': date} : null,
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

  Future<List<dynamic>> getBadges() async {
    final payload = await _request('GET', '/badges');
    return payload as List<dynamic>? ?? [];
  }

  void logout() {
    token = null;
    user = null;
  }
}
