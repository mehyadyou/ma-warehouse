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

  /// آیا کلید قدیمی سوئیچ بیومتریک اصلاً تنظیم شده است (برای مهاجرت یک‌باره)
  static bool hasBiometricSetting() => _prefs.containsKey('biometric_enabled');

  // ═══ قفل برنامه (روش قفل + پین) ═══
  // روش قفل روی همه پلتفرم‌ها اینجا می‌ماند؛ پین روی وب (بدون SecureStorage) هم اینجا
  static const _lockMethodKey = 'lock_method';
  static const _pinSaltKey = 'lock_pin_salt';
  static const _pinHashKey = 'lock_pin_hash';
  static const _autoLockKey = 'lock_auto_lock_minutes';

  static Future<void> saveLockMethod(String method) async {
    await _prefs.setString(_lockMethodKey, method);
  }

  static String? getLockMethod() => _prefs.getString(_lockMethodKey);

  /// زمان قفل خودکار (دقیقه) — مدت حضور در پس‌زمینه که پس از آن برنامه قفل می‌شود
  static Future<void> saveAutoLockMinutes(int minutes) async {
    await _prefs.setInt(_autoLockKey, minutes);
  }

  static int? getAutoLockMinutes() => _prefs.getInt(_autoLockKey);

  static Future<void> savePinData({
    required String salt,
    required String hash,
  }) async {
    await _prefs.setString(_pinSaltKey, salt);
    await _prefs.setString(_pinHashKey, hash);
  }

  static String? getPinSalt() => _prefs.getString(_pinSaltKey);

  static String? getPinHash() => _prefs.getString(_pinHashKey);

  static Future<void> clearPinData() async {
    await _prefs.remove(_pinSaltKey);
    await _prefs.remove(_pinHashKey);
  }

  /// نوشتن مقدار دلخواه (فال‌بک وب برای SecureStorage)
  static Future<void> saveRaw(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getRaw(String key) => _prefs.getString(key);

  static Future<void> removeRaw(String key) async {
    await _prefs.remove(key);
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

  // ═══ پرچم تغییر اجباری رمز در اولین ورود ═══
  static const _mustChangePasswordKey = 'must_change_password';

  static Future<void> setMustChangePassword(bool value) async {
    if (value) {
      await _prefs.setBool(_mustChangePasswordKey, true);
    } else {
      await _prefs.remove(_mustChangePasswordKey);
    }
  }

  /// پیش‌فرض false — فقط وقتی سرور/لاگین گفته باشد true می‌شود
  static bool getMustChangePassword() =>
      _prefs.getBool(_mustChangePasswordKey) ?? false;

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}