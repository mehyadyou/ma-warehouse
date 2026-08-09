import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';

class SettingsApiService {
  final Dio _dio = DioClient().dio;

  /// آدرس کامل برای نمایش عکس پروفایل
  static String fullAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return '';
    return ApiConstants.fullUrl(avatarUrl);
  }

  /// دریافت پروفایل کاربر جاری
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/profile');
    return Map<String, dynamic>.from(response.data['profile']);
  }

  /// ویرایش پروفایل (نام / شماره / رمز عبور)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? password,
  }) async {
    final response = await _dio.put(
      '/auth/profile',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
    return Map<String, dynamic>.from(response.data['profile']);
  }

  /// آپلود عکس پروفایل (بایت‌های آماده‌شده — مربع‌شده در سمت اپ)
  Future<Map<String, dynamic>> uploadAvatar(Uint8List bytes, {String filename = 'avatar.jpg'}) async {
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(
      '/auth/profile/avatar',
      data: formData,
    );
    return Map<String, dynamic>.from(response.data['profile']);
  }

  /// دریافت تنظیمات نوتیفیکیشن
  Future<Map<String, bool>> getNotificationSettings() async {
    final response = await _dio.get('/notifications/settings');
    return Map<String, bool>.from(response.data['settings'] as Map);
  }

  /// ذخیره تنظیمات نوتیفیکیشن
  Future<Map<String, bool>> updateNotificationSettings(Map<String, bool> settings) async {
    final response = await _dio.put('/notifications/settings', data: {'settings': settings});
    return Map<String, bool>.from(response.data['settings'] as Map);
  }
}