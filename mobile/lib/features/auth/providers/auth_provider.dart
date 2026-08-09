import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_api_service.dart';
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

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;

  /// نشست ذخیره‌شده هست اما باید با اثر انگشت/فیس آید باز شود
  final bool isLocked;
  final String? token;
  final String? role;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final String? error;

  AuthState({
    this.isLoading = false,
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
    final biometricEnabled = LocalStorage.getBiometricEnabled();

    // نشست ذخیره‌شده + بیومتریک فعال → صفحه قفل اثر انگشت
    // (روی وب که بیومتریک وجود ندارد این مسیر رد می‌شود)
    if (refreshToken != null &&
        refreshToken.isNotEmpty &&
        biometricEnabled &&
        !kIsWeb) {
      state = state.copyWith(isLocked: true);
      return;
    }

    // پلتفرم بدون بیومتریک (وب) یا بیومتریک خاموش: بازیابی نشست قبلی
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(phone, password);
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

  /// پس از تأیید اثر انگشت/فیس آید: رفرش سایلنت و ورود به داشبورد
  Future<bool> unlockWithBiometrics() async {
    final newAccess = await AuthSession.refreshAccessToken();
    if (newAccess == null) {
      // رفرش توکن منقضی/باطل شده → خروج کامل (بازگشت به صفحه رمز)
      await logout();
      return false;
    }

    state = state.copyWith(
      isLoggedIn: true,
      isLocked: false,
      token: newAccess,
      role: LocalStorage.getRole() ?? '',
      name: LocalStorage.getName(),
      phone: LocalStorage.getPhone(),
      avatarUrl: LocalStorage.getAvatarUrl(),
    );

    await _connectServices();
    return true;
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

    try {
      // ابطال توکن رفرش در سرور (در صورت امکان — آفلاین/منقضی اشکالی ندارد)
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await ref.read(authServiceProvider).logout(refreshToken);
        } catch (_) {
          // بی‌صدا: نشست محلی در هر صورت پاک می‌شود
        }
      }
    } finally {
      // Disconnect socket before logout
      SocketService().disconnect();

      await SecureStorage.clearTokens();
      await LocalStorage.clearAll();
      _loggingOut = false;
      state = AuthState();
    }
  }
}
