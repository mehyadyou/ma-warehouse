import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/biometric_lock_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/manager/manager_screens.dart';
import '../../features/warehouse_keeper/dashboard/warehouse_keeper_dashboard_screen.dart';
import '../../features/driver/screens/driver_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLocked = authState.isLocked;
      final location = state.matchedLocation;
      final isLoginPage = location == '/login';

      // نشست ذخیره‌شده اما قفل → صفحه اثر انگشت
      if (isLocked && !isLoggedIn) {
        if (location != '/lock') return '/lock';
        return null;
      }

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && (isLoginPage || location == '/lock')) {
        final role = authState.role;
        if (role == 'MANAGER') return '/manager/dashboard';
        if (role == 'WAREHOUSE_KEEPER') return '/warehouse/dashboard';
        if (role == 'DRIVER') return '/driver/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/lock', builder: (_, __) => const BiometricLockScreen()),
      GoRoute(path: '/manager/dashboard', builder: (_, __) => const ManagerDashboardScreen()),
      GoRoute(path: '/manager/warehouses', builder: (_, __) => const WarehousesScreen()),
      GoRoute(path: '/manager/orders/create', builder: (_, __) => const CreateOrderScreen()),
      GoRoute(path: '/manager/shipments', builder: (_, __) => const ShipmentsScreen()),
      GoRoute(path: '/warehouse/dashboard', builder: (_, __) => const WarehouseKeeperDashboardScreen()),
      GoRoute(path: '/driver/dashboard', builder: (_, __) => const DriverDashboardScreen()),
    ],
  );
});