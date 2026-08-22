import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import 'lock_config.dart';

/// ذخیره‌سازی تنظیمات قفل برنامه:
/// - روش قفل → LocalStorage (غیرحساس)
/// - مدت قفل خودکار → LocalStorage
///
/// پین جداگانه وجود ندارد — قفل با همان رمز اصلی ۶ رقمی حساب (تأیید سمت سرور)
/// یا بیومتریک دستگاه باز می‌شود.
class LockStorage {
  // ═══ روش قفل ═══
  static Future<void> saveMethod(LockMethod method) {
    return LocalStorage.saveLockMethod(method.name);
  }

  static Future<LockMethod> getMethod() async {
    return LockMethod.fromName(LocalStorage.getLockMethod());
  }

  // ═══ زمان قفل خودکار ═══
  /// ۰ = فوراً (با رفتن به پس‌زمینه) — مقدار پیش‌فرض
  static const int defaultAutoLockMinutes = 0;

  static Future<void> saveAutoLockMinutes(int minutes) {
    return LocalStorage.saveAutoLockMinutes(minutes);
  }

  static int getAutoLockMinutes() {
    return LocalStorage.getAutoLockMinutes() ?? defaultAutoLockMinutes;
  }

  /// پاک‌سازی کامل قفل — فقط در «خروج کامل از حساب» صدا زده می‌شود
  static Future<void> clearAll() async {
    await saveMethod(LockMethod.none);
    await _clearLegacyPinData();
  }

  /// حذف پین قدیمی (نسخه‌های قبل از یکپارچه‌سازی رمز) — از دستگاه پاک شود
  static Future<void> _clearLegacyPinData() async {
    if (kIsWeb) {
      await LocalStorage.clearPinData();
      return;
    }
    await SecureStorage.delete(key: 'lock_pin_salt');
    await SecureStorage.delete(key: 'lock_pin_hash');
  }
}
