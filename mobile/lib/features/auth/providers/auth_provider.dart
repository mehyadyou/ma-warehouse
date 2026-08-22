import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_api_service.dart';
import '../lock/lock_config.dart';
import '../lock/lock_provider.dart';
import '../lock/lock_storage.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/network/api_error.dart';

final authServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// نتیجهٔ قفل‌گشایی — تفکیک برای نمایش پیام مناسب در صفحه قفل
enum UnlockResult { success, invalidSession, networkError }

class AuthState {
  final bool isLoading;

  /// باز شدن اولیه برنامه — تا پایان آن صفحه اسپلش نمایش داده می‌شود
  final bool isInitializing;

  final bool isLoggedIn;

  /// نشست ذخیره‌شده هست اما باید با پین/اثر انگشت/فیس آید باز شود
  final bool isLocked;
  final String? token;
  final String? role;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isInitializing = true,
    this.isLoggedIn = false,
    this.isLocked = false,
    this.token,
    this.role,
    this.name,
    this.phone,
    this.avatarUrl,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isInitializing,
    bool? isLoggedIn,
    bool? isLocked,
    String? token,
    String? role,
    String? name,
    String? phone,
    String? avatarUrl,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLocked: isLocked ?? this.isLocked,
      token: token ?? this.token,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  bool _loggingOut = false;

  @override
  AuthState build() {
    // Initialize asynchronously without blocking build
    Future.microtask(() => _init());

    // Return initial state immediately
    return AuthState();
  }

  Future<void> _init() async {
    AuthSession.onSessionExpired = logout;

    final refreshToken = await SecureStorage.getRefreshToken();
    final lockMethod = await LockStorage.getMethod();

    // نشست ذخیره‌شده + قفل فعال → صفحه قفل (پین/اثر انگشت/فیس آید)
    if (refreshToken != null && refreshToken.isNotEmpty && lockMethod != LockMethod.none) {
      state = state.copyWith(isLocked: true);
      await _finishInit();
      return;
    }

    // بدون قفل: بازیابی نشست قبلی
    final token = await SecureStorage.getAccessToken();
    final role = LocalStorage.getRole();
    if (token != null && token.isNotEmpty && role != null) {
      state = state.copyWith(
        isLoggedIn: true,
        token: token,
        role: role,
        name: LocalStorage.getName(),
        phone: LocalStorage.getPhone(),
        avatarUrl: LocalStorage.getAvatarUrl(),
      );

      // برای نشست‌های قدیمی که مشخصات ذخیره نشده، از سرور بگیر
      if (LocalStorage.getName() == null) {
        await _fetchProfile();
      }

      await _connectServices();
    }

    await _finishInit();
  }

  /// حداقل زمان نمایش اسپلش (~۱.۵ ثانیه) + پایان وضعیت راه‌اندازی
  Future<void> _finishInit() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    state = state.copyWith(isInitializing: false);
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ref.read(authServiceProvider).getProfile();
      final name = profile['name'] as String?;
      final phone = profile['phone'] as String?;
      final avatarUrl = profile['avatarUrl'] as String?;
      await LocalStorage.saveUserData(name: name, phone: phone, avatarUrl: avatarUrl);
      state = state.copyWith(name: name, phone: phone, avatarUrl: avatarUrl);
    } catch (_) {
      // در صورت خطا، وضعیت فعلی حفظ می‌شود
    }
  }

  Future<void> login(String phone, String password) async {
    // خروج در جریان → لاگین جدیدی شروع نشود
    if (_loggingOut) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(phone, password);
      // در این فاصله خروج رخ داده → نتیجهٔ لاگین نادیده گرفته شود
      if (_loggingOut) return;
      final token = response['token'] as String;
      final refreshToken = response['refreshToken'] as String? ?? '';
      final role = response['user']?['role'] as String? ?? '';
      final name = response['user']?['name'] as String?;
      final avatarUrl = response['user']?['avatarUrl'] as String?;

      await SecureStorage.saveTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );
      await LocalStorage.saveRole(role);
      await LocalStorage.saveUserData(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      // پس از ذخیره‌سازی هم بررسی می‌شود تا لاگینِ دیررس جای خروج را نگیرد
      if (_loggingOut) return;

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        isLocked: false,
        token: token,
        role: role,
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      await _connectServices();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: friendlyError(e),
      );
    }
  }

  Future<UnlockResult>? _unlockFuture;

  /// قفل برنامه هنگام بازگشت از پس‌زمینه — نشست حفظ می‌شود اما تا تأیید
  /// پین/اثر انگشت/فیس آید، مسیردهی به صفحه قفل می‌رود
  void lock() {
    if (state.isLocked) return;
    state = state.copyWith(isLocked: true, isLoggedIn: false);
  }

  /// پس از تأیید پین/اثر انگشت/فیس آید: رفرش سایلنت و ورود به داشبورد.
  /// تک‌ریسکی — لمس دوباره همان آیندهٔ در جریان را برمی‌گرداند.
  Future<UnlockResult> unlock() {
    return _unlockFuture ??=
        _doUnlock().whenComplete(() => _unlockFuture = null);
  }

  Future<UnlockResult> _doUnlock() async {
    final outcome = await AuthSession.refreshWithOutcome();
    // خروج/بسته‌شدن نشست در فاصلهٔ رفرش → نتیجهٔ این آنلاک دور ریخته می‌شود
    if (_loggingOut || !state.isLocked) {
      return UnlockResult.invalidSession;
    }
    if (outcome.isOk) {
      final role = LocalStorage.getRole();
      // دفاعی: بدون نقش ذخیره‌شده مسیری برای ادامه نیست → نشست را ببند
      if (role == null || role.isEmpty) {
        await logout();
        return UnlockResult.invalidSession;
      }

      state = state.copyWith(
        isLoggedIn: true,
        isLocked: false,
        token: outcome.accessToken,
        role: role,
        name: LocalStorage.getName(),
        phone: LocalStorage.getPhone(),
        avatarUrl: LocalStorage.getAvatarUrl(),
      );

      await _connectServices();
      return UnlockResult.success;
    }

    if (outcome.failure == RefreshFailure.invalidSession) {
      // نشست واقعاً مرده (توکن باطل/منقضی) → خروج کامل به صفحه رمز
      await logout();
      return UnlockResult.invalidSession;
    }

    // خطای شبکه/سرور — نشست معتبر است؛ روی صفحه قفل می‌ماند
    return UnlockResult.networkError;
  }

  Future<void> _connectServices() async {
    await SocketService().connect();
    _registerForceLogoutListener();
    await NotificationService().init();
  }

  //به‌روزرسانی مشخصات کاربر جاری (بعد از ویرایش از تنظیمات)
  Future<void> updateProfileFields({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    await LocalStorage.saveUserData(name: name, phone: phone, avatarUrl: avatarUrl);
    state = state.copyWith(
      name: name ?? state.name,
      phone: phone ?? state.phone,
      avatarUrl: avatarUrl ?? state.avatarUrl,
    );
  }

  void _registerForceLogoutListener() {
    SocketService().off('user:force:logout');
    SocketService().on('user:force:logout', (_) {
      logout();
    });
  }

  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;

    // توکن‌ها برای ابطال سرور پس از پاک‌سازی محلی نگه داشته می‌شوند
    final refreshToken = await SecureStorage.getRefreshToken();
    final accessToken = await SecureStorage.getAccessToken();

    // رفرش‌های در جریان باطل می‌شوند تا توکن از نو نوشته نشود
    AuthSession.invalidatePendingRefresh();

    try {
      // اول وضعیت در حافظه ریست می‌شود — خروج فوری حتی وقتی شبکه در دسترس نیست
      state = AuthState(isInitializing: false);

      // Disconnect socket before logout
      SocketService().disconnect();

      await SecureStorage.clearTokens();
      // پاک‌سازی قفل برنامه (پین و روش قفل) — مصوب: بعد از خروج کامل پاک شوند
      await ref.read(lockProvider.notifier).clearAllForLogout();
      await LocalStorage.clearAll();
      // ریست اعلان‌ها تا به نشستِ بعدی (حتی کاربر دیگر) نشت نکنند
      NotificationService().reset();
    } finally {
      _loggingOut = false;
    }

    // ابطال توکن رفرش در سرور — بهترین تلاش؛ آفلاین/منقضی اشکالی ندارد
    // (پس از پاک‌سازی محلی، با هدر صریح ارسال می‌شود)
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await ref.read(authServiceProvider).logout(
              refreshToken,
              accessToken: accessToken,
            );
      } catch (_) {
        // بی‌صدا: نشست محلی در هر صورت پاک شده است
      }
    }
  }
}
