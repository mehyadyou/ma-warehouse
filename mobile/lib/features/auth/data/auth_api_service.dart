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

  /// خروج — ابطال توکن رفرش جاری در سرور
  Future<void> logout(String refreshToken) async {
    await _dio.post(ApiConstants.logout, data: {'refreshToken': refreshToken});
  }
}