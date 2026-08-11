import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'local_storage.dart';

/// ذخیره امن توکن‌ها — روی اندروید/iOS در کی‌استور/کیچین رمزنگاری‌شده؛ روی وب که
/// secure storage در دسترس نیست، به SharedPreferences برمی‌گردد.
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kIsWeb) {
      await LocalStorage.saveToken(accessToken);
      await LocalStorage.saveRefreshToken(refreshToken);
      return;
    }
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    if (kIsWeb) return LocalStorage.getToken();
    return _storage.read(key: _accessKey);
  }

  static Future<String?> getRefreshToken() async {
    if (kIsWeb) return LocalStorage.getRefreshToken();
    return _storage.read(key: _refreshKey);
  }

  static Future<void> clearTokens() async {
    if (kIsWeb) {
      await LocalStorage.clearAll();
      return;
    }
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  /// نوشتن مقدار دلخواه — روی وب به SharedPreferences برمی‌گردد
  static Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      await LocalStorage.saveRaw(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read({required String key}) async {
    if (kIsWeb) return LocalStorage.getRaw(key);
    return _storage.read(key: key);
  }

  static Future<void> delete({required String key}) async {
    if (kIsWeb) {
      await LocalStorage.removeRaw(key);
      return;
    }
    await _storage.delete(key: key);
  }
}
