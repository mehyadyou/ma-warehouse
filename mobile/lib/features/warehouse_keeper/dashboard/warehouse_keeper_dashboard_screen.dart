import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/manager/dashboard/bottom_nav_bar/bottom_nav_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/settings/settings_screen.dart';
import '../providers/warehouse_keeper_provider.dart';
import 'header/warehouse_header.dart';
import 'search/search_bar.dart';
import 'product_management/product_management_button.dart';
import 'bottom_nav/keeper_nav_items.dart';
import 'home/home_screen.dart';
import 'inventory/inventory_screen.dart';
import 'orders/orders_screen.dart';
import 'reports/reports_screen.dart';
import '../scan_out/scan_out_screen.dart';

const _bg    = Color(0xFF0F1114);

class WarehouseKeeperDashboardScreen extends ConsumerStatefulWidget {
  const WarehouseKeeperDashboardScreen({super.key});
  @override
  ConsumerState<WarehouseKeeperDashboardScreen> createState() =>
      _WarehouseKeeperDashboardScreenState();
}

class _WarehouseKeeperDashboardScreenState
    extends ConsumerState<WarehouseKeeperDashboardScreen> {
  int _selectedIndex = 0;

  final _screens = [  // ← const رو برداشتیم
    const HomeScreen(),
    const InventoryScreen(),
    const ReportsScreen(),
    OrdersScreen(),  // ← const نداره
  ];

  @override
  void initState() {
    super.initState();
    
    // Setup socket listeners for real-time updates
    Future.microtask(() {
      final socket = ref.read(socketServiceProvider);
      
      // Listen for new orders
      socket.on('order:created', (data) {
        if (mounted) {
          ref.invalidate(ordersProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('سفارش جدید دریافت شد!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });

      // Listen for order edit — مدیر سفارش را ویرایش کرد
      socket.on('order:updated', (data) {
        if (mounted) {
          ref.invalidate(ordersProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('یک سفارش توسط مدیریت ویرایش شد'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });

      // Listen for order deletion — مدیر سفارش را حذف کرد
      socket.on('order:deleted', (data) {
        if (mounted) {
          ref.invalidate(ordersProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('سفارش حذف شد — لیست سفارش‌ها به‌روز شد'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
      
      // Listen for check-in completed
      socket.on('checkin:completed', (data) {
        if (mounted) {
          ref.invalidate(inventorySummaryProvider);
          ref.invalidate(keeperInventoryListProvider);
          ref.invalidate(transactionsProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ورود کالا ثبت شد - موجودی آپدیت شد'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
      
      // Listen for scan-out completed
      socket.on('scanout:done', (data) {
        if (mounted) {
          ref.invalidate(inventorySummaryProvider);
          ref.invalidate(keeperInventoryListProvider);
          ref.invalidate(transactionsProvider);
          ref.invalidate(ordersProvider);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: _bg,
      drawer: AppDrawer(
        onLogout: () => ref.read(authProvider.notifier).logout(),
        userName: auth.name ?? 'کاربر',
        userRole: 'انباردار',
        avatarUrl: auth.avatarUrl,
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      body: Column(children: [
        WarehouseHeader(avatarUrl: auth.avatarUrl),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(children: [
            const Expanded(child: WarehouseSearchBar()),
            const SizedBox(width: 8),
            const ProductManagementButton(),
          ]),
        ),
        Expanded(child: _screens[_selectedIndex]),
      ]),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        items: keeperNavItems,
        fabIcon: Icons.output_rounded,
        onTap: (i) => setState(() => _selectedIndex = i),
        onAddPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanOutScreen()));
        },
      ),
    );
  }
}
