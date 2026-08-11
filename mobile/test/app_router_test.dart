import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/routes/app_router.dart';
import 'package:ma_app/features/auth/providers/auth_provider.dart';

void main() {
  AuthState loggedIn(String role) => AuthState(
        isInitializing: false,
        isLoggedIn: true,
        isLocked: false,
        role: role,
      );

  group('authRedirect (مسیردهی بر اساس وضعیت نشست)', () {
    test('در حال راه‌اندازی → همه مکان‌ها به اسپلش می‌روند', () {
      final auth = AuthState(isInitializing: true);
      expect(authRedirect(auth, '/login'), '/splash');
      expect(authRedirect(auth, '/lock'), '/splash');
      expect(authRedirect(auth, '/manager/dashboard'), '/splash');
      expect(authRedirect(auth, '/splash'), isNull);
    });

    test('نشست قفل → صفحه قفل (از هر مکان)', () {
      final auth = AuthState(
        isInitializing: false,
        isLocked: true,
        isLoggedIn: false,
      );
      expect(authRedirect(auth, '/splash'), '/lock');
      expect(authRedirect(auth, '/login'), '/lock');
      expect(authRedirect(auth, '/manager/dashboard'), '/lock');
      expect(authRedirect(auth, '/lock'), isNull);
    });

    test('خارج از سیستم → صفحه ورود (به‌جز خودِ ورود)', () {
      final auth = AuthState(isInitializing: false, isLoggedIn: false);
      expect(authRedirect(auth, '/splash'), '/login');
      expect(authRedirect(auth, '/manager/dashboard'), '/login');
      expect(authRedirect(auth, '/login'), isNull);
    });

    test('رگرسیون: لاگین‌شده روی اسپلش → به داشبورد نقش می‌رود', () {
      expect(authRedirect(loggedIn('MANAGER'), '/splash'), '/manager/dashboard');
      expect(
        authRedirect(loggedIn('WAREHOUSE_KEEPER'), '/splash'),
        '/warehouse/dashboard',
      );
      expect(authRedirect(loggedIn('DRIVER'), '/splash'), '/driver/dashboard');
    });

    test('لاگین‌شده روی ورود/قفل → به داشبورد نقش می‌رود', () {
      expect(
        authRedirect(loggedIn('MANAGER'), '/login'),
        '/manager/dashboard',
      );
      expect(authRedirect(loggedIn('MANAGER'), '/lock'), '/manager/dashboard');
      expect(
        authRedirect(loggedIn('WAREHOUSE_KEEPER'), '/lock'),
        '/warehouse/dashboard',
      );
    });

    test('لاگین‌شده روی داشبورد → بدون تغییر (null)', () {
      expect(authRedirect(loggedIn('MANAGER'), '/manager/dashboard'), isNull);
      expect(
        authRedirect(loggedIn('WAREHOUSE_KEEPER'), '/warehouse/dashboard'),
        isNull,
      );
      expect(authRedirect(loggedIn('DRIVER'), '/driver/dashboard'), isNull);
    });

    test('نقش ناشناختهٔ لاگین‌شده → null (بدون حلقهٔ بی‌پایان)', () {
      expect(authRedirect(loggedIn('UNKNOWN'), '/splash'), isNull);
    });
  });
}
