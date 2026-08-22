import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/network/api_error.dart';
import '../../../core/storage/local_storage.dart';
import '../data/auth_api_service.dart';
import 'lock_config.dart';
import 'lock_storage.dart';

final lockProvider = NotifierProvider<LockNotifier, LockState>(
  LockNotifier.new,
);

/// سرویس تأیید رمز قفل — override در تست‌ها
final lockVerifyApiProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(),
);

class LockState {
  /// بارگذاری اولیه تنظیمات (روش قفل، قابلیت‌های بیومتریک دستگاه)
  final bool checking;

  final LockMethod method;

  /// آیا دستگاه از اثر انگشت پشتیبانی می‌کند (برای نمایش گزینه در تنظیمات)
  final bool fingerprintAvailable;
  final bool faceAvailable;

  /// مدت حضور در پس‌زمینه (دقیقه) که پس از آن برنامه خودکار قفل می‌شود؛
  /// ۰ = فوراً با رفتن به پس‌زمینه
  final int autoLockMinutes;

  /// تعداد رمزهای اشتباه پیاپی در صفحه قفل
  final int failedAttempts;

  /// کولداون بعد از ۵ رمز اشتباه — در این بازه رمز پذیرفته نمی‌شود
  final DateTime? cooldownUntil;

  const LockState({
    this.checking = true,
    this.method = LockMethod.none,
    this.fingerprintAvailable = false,
    this.faceAvailable = false,
    this.autoLockMinutes = LockStorage.defaultAutoLockMinutes,
    this.failedAttempts = 0,
    this.cooldownUntil,
  });

  bool get isBiometric =>
      method == LockMethod.fingerprint || method == LockMethod.face;

  LockState copyWith({
    bool? checking,
    LockMethod? method,
    bool? fingerprintAvailable,
    bool? faceAvailable,
    int? autoLockMinutes,
    int? failedAttempts,
    DateTime? cooldownUntil,
    bool clearCooldown = false,
  }) {
    return LockState(
      checking: checking ?? this.checking,
      method: method ?? this.method,
      fingerprintAvailable: fingerprintAvailable ?? this.fingerprintAvailable,
      faceAvailable: faceAvailable ?? this.faceAvailable,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      cooldownUntil: clearCooldown ? null : (cooldownUntil ?? this.cooldownUntil),
    );
  }
}

/// مدیریت تنظیمات قفل برنامه: روش قفل (بیومتریک / بدون قفل) + محدودیت تلاش روی
/// صفحه قفل (۵ رمز اشتباه → کولداون ۳۰ ثانیه).
/// قفل با همان رمز اصلی ۶ رقمی حساب باز می‌شود (تأیید سمت سرور) — پین جداگانه وجود ندارد.
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
      fingerprintAvailable: fingerprint,
      faceAvailable: face,
      autoLockMinutes: LockStorage.getAutoLockMinutes(),
    );
  }

  /// تغییر مدت قفل خودکار (دقیقه — ۰ یعنی فوراً)
  Future<bool> changeAutoLockMinutes(int minutes) async {
    if (minutes < 0) return false;
    await LockStorage.saveAutoLockMinutes(minutes);
    state = state.copyWith(autoLockMinutes: minutes);
    return true;
  }

  /// تغییر روش قفل (بیومتریک) — غیرفعال‌کردن نیازمند تأیید در UI است
  Future<bool> changeMethod(LockMethod method) async {
    await LockStorage.saveMethod(method);
    state = state.copyWith(method: method);
    return true;
  }

  /// بررسی رمز اصلی (۶ رقمی) روی صفحه قفل — تأیید سمت سرور با همان رمز ورود.
  /// مدیریت تلاش‌های اشتباه و کولداون.
  Future<bool> verifyPassword(String password) async {
    final now = DateTime.now();
    if (state.cooldownUntil != null && now.isBefore(state.cooldownUntil!)) {
      return false;
    }

    final ok = await _verify(password);
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

  Future<bool> _verify(String password) async {
    try {
      return await ref.read(lockVerifyApiProvider).verifyPassword(password);
    } catch (e) {
      // خطای شبکه/سرور — به‌عنوان شکست تلاش حساب می‌شود تا کاربر دوباره تلاش کند
      debugPrint('lock verify error: ${friendlyError(e)}');
      return false;
    }
  }

  /// بعد از موفقیت در قفل‌گشایی (بیومتریک یا رمز)
  void resetAttempts() {
    state = state.copyWith(failedAttempts: 0, clearCooldown: true);
  }

  /// پاک‌سازی کامل قفل — «خروج کامل از حساب» (مصوب: روش قفل پاک می‌شود)
  Future<void> clearAllForLogout() async {
    await LockStorage.clearAll();
    state = LockState(
      checking: false,
      fingerprintAvailable: state.fingerprintAvailable,
      faceAvailable: state.faceAvailable,
    );
  }
}
