import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late final SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString('access_token', token);
  }

  static String? getToken() {
    return _prefs.getString('access_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _prefs.setString('refresh_token', token);
  }

  static String? getRefreshToken() {
    return _prefs.getString('refresh_token');
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool('biometric_enabled', enabled);
  }

  static bool getBiometricEnabled() {
    return _prefs.getBool('biometric_enabled') ?? true;
  }

  static Future<void> saveRole(String role) async {
    await _prefs.setString('user_role', role);
  }

  static String? getRole() {
    return _prefs.getString('user_role');
  }

  static Future<void> saveUserData({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    if (name != null) await _prefs.setString('user_name', name);
    if (phone != null) await _prefs.setString('user_phone', phone);
    if (avatarUrl != null) await _prefs.setString('user_avatar', avatarUrl);
  }

  static String? getName() => _prefs.getString('user_name');

  static String? getPhone() => _prefs.getString('user_phone');

  static String? getAvatarUrl() => _prefs.getString('user_avatar');

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}