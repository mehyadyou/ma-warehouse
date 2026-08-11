import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import 'lock_config.dart';

/// ذخیره‌سازی تنظیمات قفل برنامه:
/// - روش قفل → LocalStorage (غیرحساس)
/// - پین → هش SHA-256 + salt تصادفی در SecureStorage (روی وب در LocalStorage)
///
/// تصمیم مصوب: تغییر روش قفل هرگز پین را پاک نمی‌کند؛ پین فقط با
/// «خروج کامل از حساب» یا حذف صریح توسط کاربر پاک می‌شود.
class LockStorage {
  static const _pinSaltKey = 'lock_pin_salt';
  static const _pinHashKey = 'lock_pin_hash';

  static const int maxPinLength = 4;

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  // ═══ روش قفل ═══
  static Future<void> saveMethod(LockMethod method) {
    return LocalStorage.saveLockMethod(method.name);
  }

  static Future<LockMethod> getMethod() async {
    return LockMethod.fromName(await LocalStorage.getLockMethod());
  }

  // ═══ پین ═══
  static Future<void> setPin(String pin) async {
    assert(pin.length == maxPinLength && RegExp(r'^\d{4}$').hasMatch(pin));
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    if (kIsWeb) {
      await LocalStorage.savePinData(salt: salt, hash: hash);
      return;
    }
    await SecureStorage.write(key: _pinSaltKey, value: salt);
    await SecureStorage.write(key: _pinHashKey, value: hash);
  }

  static Future<bool> hasPin() async {
    final salt = await _readPinSalt();
    final hash = await _readPinHash();
    return salt != null && salt.isNotEmpty && hash != null && hash.isNotEmpty;
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await _readPinSalt();
    final hash = await _readPinHash();
    if (salt == null || hash == null) return false;
    return _hashPin(pin, salt) == hash;
  }

  static Future<void> clearPin() async {
    if (kIsWeb) {
      await LocalStorage.clearPinData();
      return;
    }
    await SecureStorage.delete(key: _pinSaltKey);
    await SecureStorage.delete(key: _pinHashKey);
  }

  /// پاک‌سازی کامل قفل — فقط در «خروج کامل از حساب» صدا زده می‌شود
  static Future<void> clearAll() async {
    await clearPin();
    await saveMethod(LockMethod.none);
  }

  static Future<String?> _readPinSalt() async {
    if (kIsWeb) return LocalStorage.getPinSalt();
    return SecureStorage.read(key: _pinSaltKey);
  }

  static Future<String?> _readPinHash() async {
    if (kIsWeb) return LocalStorage.getPinHash();
    return SecureStorage.read(key: _pinHashKey);
  }
}
