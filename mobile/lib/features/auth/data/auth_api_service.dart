import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';

class AuthApiService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'phone': phone,
        'password': password,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createFirstManager(
      String name, String phone, String password) async {
    final response = await _dio.post(
      ApiConstants.createFirstManager,
      data: {
        'name': name,
        'phone': phone,
        'password': password,
      },
    );
    return response.data;
  }

  /// پروفایل کاربر جاری
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/profile');
    return Map<String, dynamic>.from(response.data['profile']);
  }

  /// تأیید رمز اصلی برای قفل‌گشایی برنامه — همان رمز ورود (۶ رقم)
  Future<bool> verifyPassword(String password) async {
    final response = await _dio.post(
      ApiConstants.verifyPassword,
      data: {'password': password},
    );
    return response.data?['ok'] == true;
  }

  /// تغییر رمز عبور — سرور در صورت تغییر رمز، توکن‌های تازه برمی‌گرداند
  /// (چون tokenVersion بالا می‌رود و توکن‌های قبلی باطل می‌شوند)
  Future<Map<String, dynamic>> updateProfile({String? name, String? phone, String? password}) async {
    final response = await _dio.put(
      '/auth/profile',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// خروج — ابطال توکن رفرش جاری در سرور.
  /// توکن اکسس صریح داده می‌شود چون خروج پس از پاک‌سازی محلی فرستاده می‌شود
  /// و اینترسپتور دیگر توکنی برای افزودن ندارد.
  Future<void> logout(String refreshToken, {String? accessToken}) async {
    await _dio.post(
      ApiConstants.logout,
      data: {'refreshToken': refreshToken},
      options: (accessToken != null && accessToken.isNotEmpty)
          ? Options(headers: {'Authorization': 'Bearer $accessToken'})
          : null,
    );
  }
}