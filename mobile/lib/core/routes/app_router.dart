import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/lock_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/manager/manager_screens.dart';
import '../../features/warehouse_keeper/dashboard/warehouse_keeper_dashboard_screen.dart';
import '../../features/driver/screens/driver_dashboard_screen.dart';

/// منطق خالص مسیردهی بر اساس وضعیت نشست — جدا از GoRouter تا قابل تست باشد.
/// خروجی: مقصد جدید یا null (مکان فعلی درست است).
String? authRedirect(AuthState auth, String location) {
  // راه‌اندازی اولیه — صفحه اسپلش می‌ماند تا وضعیت نشست مشخص شود
  if (auth.isInitializing) {
    if (location != '/splash') return '/splash';
    return null;
  }

  // نشست ذخیره‌شده اما قفل → صفحه قفل (پین/اثر انگشت/فیس آید)
  if (auth.isLocked && !auth.isLoggedIn) {
    if (location != '/lock') return '/lock';
    return null;
  }

  if (!auth.isLoggedIn && location != '/login') return '/login';

  // لاگین‌شده → داشبورد نقش (از هر صفحهٔ ورودی: ورود/قفل/اسپلش)
  if (auth.isLoggedIn &&
      (location == '/login' || location == '/lock' || location == '/splash')) {
    switch (auth.role) {
      case 'MANAGER':
        return '/manager/dashboard';
      case 'WAREHOUSE_KEEPER':
        return '/warehouse/dashboard';
      case 'DRIVER':
        return '/driver/dashboard';
    }
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // خواندن زندهٔ وضعیت نشست بدون بازسازی GoRouter
      return authRedirect(ref.read(authProvider), state.matchedLocation);
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/lock', builder: (_, __) => const LockScreen()),
      GoRoute(path: '/manager/dashboard', builder: (_, __) => const ManagerDashboardScreen()),
      GoRoute(path: '/manager/warehouses', builder: (_, __) => const WarehousesScreen()),
      GoRoute(path: '/manager/orders/create', builder: (_, __) => const CreateOrderScreen()),
      GoRoute(path: '/manager/shipments', builder: (_, __) => const ShipmentsScreen()),
      GoRoute(path: '/warehouse/dashboard', builder: (_, __) => const WarehouseKeeperDashboardScreen()),
      GoRoute(path: '/driver/dashboard', builder: (_, __) => const DriverDashboardScreen()),
    ],
  );

  // واکنش زنده به هر تغییر وضعیت نشست (ورود/قفل/خروج) بدون بازسازی روتر
  ref.listen(authProvider, (_, __) => router.refresh());

  return router;
});
