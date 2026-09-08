import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../core/storage/secure_storage.dart';

/// راستی‌آزمایی محلی رمز برای «آنلاک آفلاین» (زیرزمین/نقطه کور).
///
/// مدل تهدید: هش نمک‌دار (salt + ۱۰هزار دور SHA256) فقط در Keystore/Keychain
/// دستگاه می‌ماند و با خروج از حساب پاک می‌شود. شمارش تلاش + کولداون صفحه
/// قفل (۵ خطا → ۳۰ ثانیه) جلوی حدس محلی را می‌گیرد. این جایگزین تأیید سرور
/// نیست — فقط وقتی شبکه قطع است و توکن ذخیره‌شده هنوز معتبر است، ورود
/// «حالت آفلاین» (فقط‌خواندنی + صف عملیات) باز می‌شود.
class OfflineVerifier {
  static const _saltKey = 'offline_pwd_salt';
  static const _hashKey = 'offline_pwd_hash';
  static const _iterations = 10000;

  static String _stretch(String salt, String password) {
    List<int> bytes = utf8.encode('$salt:$password');
    for (var i = 0; i < _iterations; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return sha256.convert(bytes).toString();
  }

  /// ذخیره verifier پس از ورود موفق یا تغییر رمز (رمز plaintext هرگز ذخیره نمی‌شود)
  static Future<void> save(String password) async {
    try {
      final salt = List.generate(16, (_) => _random.nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      await SecureStorage.write(key: _saltKey, value: salt);
      await SecureStorage.write(key: _hashKey, value: _stretch(salt, password));
    } catch (_) {
      // شکست ذخیره امن هرگز لاگین را خراب نمی‌کند — فقط آنلاک آفلاین نخواهد بود
    }
  }

  /// بررسی محلی — فقط وقتی شبکه قطع است صدا زده می‌شود
  static Future<bool> verify(String password) async {
    try {
      final salt = await SecureStorage.read(key: _saltKey);
      final hash = await SecureStorage.read(key: _hashKey);
      if (salt == null || hash == null || salt.isEmpty || hash.isEmpty) {
        return false;
      }
      return _constantTimeEquals(_stretch(salt, password), hash);
    } catch (_) {
      return false;
    }
  }

  static Future<void> clear() async {
    try {
      await SecureStorage.delete(key: _saltKey);
      await SecureStorage.delete(key: _hashKey);
    } catch (_) {}
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

final _random = Random.secure();
