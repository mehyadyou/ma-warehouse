import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/storage/local_storage.dart';
import 'lock_config.dart';
import 'lock_storage.dart';

final lockProvider = NotifierProvider<LockNotifier, LockState>(
  LockNotifier.new,
);

class LockState {
  /// بارگذاری اولیه تنظیمات (روش قفل، پین، قابلیت‌های بیومتریک دستگاه)
  final bool checking;

  final LockMethod method;
  final bool hasPin;

  /// آیا دستگاه از اثر انگشت پشتیبانی می‌کند (برای نمایش گزینه در تنظیمات)
  final bool fingerprintAvailable;
  final bool faceAvailable;

  /// تعداد پین‌های اشتباه پیاپی در صفحه قفل
  final int failedAttempts;

  /// کولداون بعد از ۵ پین اشتباه — در این بازه پین پذیرفته نمی‌شود
  final DateTime? cooldownUntil;

  const LockState({
    this.checking = true,
    this.method = LockMethod.none,
    this.hasPin = false,
    this.fingerprintAvailable = false,
    this.faceAvailable = false,
    this.failedAttempts = 0,
    this.cooldownUntil,
  });

  bool get isBiometric => method == LockMethod.fingerprint || method == LockMethod.face;

  LockState copyWith({
    bool? checking,
    LockMethod? method,
    bool? hasPin,
    bool? fingerprintAvailable,
    bool? faceAvailable,
    int? failedAttempts,
    DateTime? cooldownUntil,
    bool clearCooldown = false,
  }) {
    return LockState(
      checking: checking ?? this.checking,
      method: method ?? this.method,
      hasPin: hasPin ?? this.hasPin,
      fingerprintAvailable: fingerprintAvailable ?? this.fingerprintAvailable,
      faceAvailable: faceAvailable ?? this.faceAvailable,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      cooldownUntil: clearCooldown ? null : (cooldownUntil ?? this.cooldownUntil),
    );
  }
}

/// مدیریت تنظیمات قفل برنامه: روش قفل + پین (۴ رقمی، هش SHA-256 + salt)
/// و محدودیت تلاش روی صفحه قفل (۵ اشتباه → کولداون ۳۰ ثانیه).
class LockNotifier extends Notifier<LockState> {
  static const int maxFailedAttempts = 5;
  static const Duration cooldownDuration = Duration(seconds: 30);

  @override
  LockState build() {
    Future.microtask(_init);
    return const LockState();
  }

  Future<void> _init() async {
    var method = await LockStorage.getMethod();
    final hasPin = await LockStorage.hasPin();

    var fingerprint = false;
    var face = false;
    try {
      final localAuth = LocalAuthentication();
      final supported =
          await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
      if (supported) {
        final types = await localAuth.getAvailableBiometrics();
        fingerprint = types.contains(BiometricType.fingerprint) ||
            types.contains(BiometricType.strong);
        face = types.contains(BiometricType.face) ||
            types.contains(BiometricType.weak);
      }
    } catch (_) {
      // پلتفرم بدون بیومتریک (مثل تست/وب) — گزینه‌ها نمایش داده نمی‌شوند
    }

    // مهاجرت یک‌باره از سوئیچ قدیمی «ورود با اثر انگشت» به روش قفل
    if (method == LockMethod.none &&
        LocalStorage.hasBiometricSetting() &&
        LocalStorage.getBiometricEnabled()) {
      method = fingerprint ? LockMethod.fingerprint : LockMethod.none;
      await LockStorage.saveMethod(method);
    }

    if (!ref.mounted) return;
    state = LockState(
      checking: false,
      method: method,
      hasPin: hasPin,
      fingerprintAvailable: fingerprint,
      faceAvailable: face,
    );
  }

  /// تغییر روش قفل — تغییر روش هرگز پین را پاک نمی‌کند (مصوب)
  Future<bool> changeMethod(LockMethod method) async {
    if (method == LockMethod.pin && !state.hasPin) return false;
    await LockStorage.saveMethod(method);
    state = state.copyWith(method: method);
    return true;
  }

  /// تعیین پین — فقط ۴ رقم
  Future<bool> setupPin(String pin) async {
    if (!_isValidPin(pin)) return false;
    await LockStorage.setPin(pin);
    state = state.copyWith(hasPin: true);
    return true;
  }

  /// تغییر پین — نیازمند پین فعلی
  Future<bool> changePin(String currentPin, String newPin) async {
    if (!_isValidPin(newPin)) return false;
    final ok = await LockStorage.verifyPin(currentPin);
    if (!ok) return false;
    await LockStorage.setPin(newPin);
    return true;
  }

  /// حذف پین (فقط وقتی روش قفل پین نیست — روش قفل دست می‌خورد)
  Future<void> clearPin() async {
    await LockStorage.clearPin();
    state = state.copyWith(hasPin: false);
  }

  /// بررسی پین روی صفحه قفل — مدیریت تلاش‌های اشتباه و کولداون
  Future<bool> verifyPin(String pin) async {
    final now = DateTime.now();
    if (state.cooldownUntil != null && now.isBefore(state.cooldownUntil!)) {
      return false;
    }

    final ok = await LockStorage.verifyPin(pin);
    if (!ok) {
      final attempts = state.failedAttempts + 1;
      if (attempts >= maxFailedAttempts) {
        state = state.copyWith(
          failedAttempts: 0,
          cooldownUntil: now.add(cooldownDuration),
        );
      } else {
        state = state.copyWith(failedAttempts: attempts);
      }
      return false;
    }

    state = state.copyWith(failedAttempts: 0, clearCooldown: true);
    return true;
  }

  /// بعد از موفقیت در قفل‌گشایی (بیومتریک یا پین)
  void resetAttempts() {
    state = state.copyWith(failedAttempts: 0, clearCooldown: true);
  }

  /// پاک‌سازی کامل قفل — «خروج کامل از حساب» (مصوب: پین و روش پاک می‌شوند)
  Future<void> clearAllForLogout() async {
    await LockStorage.clearAll();
    state = LockState(
      checking: false,
      fingerprintAvailable: state.fingerprintAvailable,
      faceAvailable: state.faceAvailable,
    );
  }

  bool _isValidPin(String pin) {
    return pin.length == LockStorage.maxPinLength &&
        RegExp(r'^\d{4}$').hasMatch(pin);
  }
}
