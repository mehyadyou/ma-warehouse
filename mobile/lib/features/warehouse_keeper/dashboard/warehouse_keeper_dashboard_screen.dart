import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/manager/dashboard/bottom_nav_bar/bottom_nav_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/settings/settings_screen.dart';
import '../providers/warehouse_keeper_provider.dart';
import 'header/warehouse_header.dart';
import '../../../shared/widgets/search_bar_trigger.dart';
import 'product_management/product_management_button.dart';
import 'bottom_nav/keeper_nav_items.dart';
import 'home/home_screen.dart';
import 'inventory/inventory_screen.dart';
import 'orders/orders_screen.dart';
import 'reports/reports_screen.dart';
import '../scan_out/manual_exit_screen.dart';
import '../scan_out/scan_out_screen.dart';
import 'transfers/transfer_instructions_screen.dart';
import '../drivers/drivers_screen.dart';
import '../carriers/carriers_screen.dart';
import '../../offline/pending_ops.dart';
import '../../../shared/widgets/offline_banner.dart';

const _bg = Color(0xFF0F1114);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);

class WarehouseKeeperDashboardScreen extends ConsumerStatefulWidget {
  const WarehouseKeeperDashboardScreen({super.key});
  @override
  ConsumerState<WarehouseKeeperDashboardScreen> createState() =>
      _WarehouseKeeperDashboardScreenState();
}

class _WarehouseKeeperDashboardScreenState
    extends ConsumerState<WarehouseKeeperDashboardScreen> {
  int _selectedIndex = 0;

  /// صفحه‌ها — late: کارت «سفارش‌های بررسی‌نشده» باید بتواند تب را عوض کند
  late final List<Widget> _screens = [
    HomeScreen(onOpenOrders: () => _selectTab(3)),
    const InventoryScreen(),
    const ReportsScreen(),
    OrdersScreen(), // ← const نداره
  ];

  /// تبهایی که تاکنون باز شدهاند — mount نازک (نخستین بازدید واقعی میسازد)
  final List<bool> _visited = [true, false, false, false];

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _visited[index] = true;
    });
  }

  @override
  void initState() {
    super.initState();

    // Setup socket listeners for real-time updates
    Future.microtask(_registerSocketListeners);
    // فلاش صف آفلاین هنگام اتصال مجدد سوکت (بازگشت اینترنت)
    Future.microtask(() {
      ref.read(socketServiceProvider).addReconnectListener(_flushPendingOps);
    });
  }

  /// فلاش خودکار صف آفلاین بعد از اتصال مجدد — بدون مزاحمت؛ فقط در موفقیت پیام می‌دهد
  Future<void> _flushPendingOps() async {
    if (!mounted) return;
    if (ref.read(pendingOpsProvider).isEmpty) return;
    try {
      final result = await ref.read(pendingOpsProvider.notifier).flush();
      if (!mounted) return;
      if (result.sent > 0) {
        ref.invalidate(inventorySummaryProvider);
        ref.invalidate(keeperInventoryListProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(ordersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.sent} عملیات صف آفلاین ارسال شد'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  /// لیست هندلرهای سوکت — برای حذف کامل در dispose نگه داشته می‌شود
  final Map<String, Function(dynamic)> _socketHandlers = {};

  void _registerSocketListeners() {
    final socket = ref.read(socketServiceProvider);

    final handlers = <String, Function(dynamic)>{
      // سفارش جدید از سوی مدیر ثبت شد
      'order:created': (data) {
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
      },
      // مدیر سفارش را ویرایش کرد
      'order:updated': (data) {
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
      },
      // مدیر سفارش را حذف کرد
      'order:deleted': (data) {
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
      },
      // ورود کالا به انبار ثبت شد
      'checkin:completed': (data) {
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
      },
      // خروج کالا از انبار ثبت شد
      'scanout:done': (data) {
        if (mounted) {
          ref.invalidate(inventorySummaryProvider);
          ref.invalidate(keeperInventoryListProvider);
          ref.invalidate(transactionsProvider);
          ref.invalidate(ordersProvider);
        }
      },
      // مدیر دستور خروج/جابه‌جایی جدید صادر کرد — انباردار باید برای اجرا اقدام کند
      'transfer:created': (data) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('دستور خروج/جابه‌جایی جدید از مدیریت صادر شد'),
              backgroundColor: _orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      // سهمیهٔ دستور با اسکن کامل اجرا شد — موجودی/دفتر تراکنش به‌روز می‌شود
      'transfer:completed': (data) {
        if (mounted) {
          ref.invalidate(inventorySummaryProvider);
          ref.invalidate(keeperInventoryListProvider);
          ref.invalidate(transactionsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('دستور خروج/جابه‌جایی کامل اجرا شد'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      // مدیر دستور در انتظار را لغو کرد — دیگر نباید برایش اسکن شود
      'transfer:canceled': (data) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('یک دستور خروج/جابه‌جایی توسط مدیریت لغو شد'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    };
    handlers.forEach((event, handler) {
      socket.on(event, handler);
      _socketHandlers[event] = handler;
    });
  }

  @override
  void dispose() {
    final socket = ref.read(socketServiceProvider);
    socket.removeReconnectListener(_flushPendingOps);
    _socketHandlers.forEach(
      (event, handler) => socket.offEvent(event, handler),
    );
    _socketHandlers.clear();
    super.dispose();
  }

  /// منوی خروج از انبار — با لمس دکمه‌ی سبز مرکزی، دوربین مستقیم باز نمی‌شود
  void _openExitMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'منوی خروج از انبار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'محصولات بدون QR را دستی خروج بدهید یا کارتن را اسکن کنید',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              _ExitMenuTile(
                icon: Icons.edit_note_rounded,
                title: 'خروج دستی (بدون QR)',
                subtitle: 'انتخاب محصول، مدل و تعداد — مناسب اقلام ریز بدون برچسب',
                color: _green,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManualExitScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ExitMenuTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'اسکن QR کارتن',
                subtitle: 'خروج با اسکن برچسب QR کارتن',
                color: Colors.white70,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanOutScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ExitMenuTile(
                icon: Icons.swap_horizontal_circle_rounded,
                title: 'دستورات خروج/جابه‌جایی',
                subtitle: 'اجرای دستورهای صادرشده توسط مدیر',
                color: _orange,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransferInstructionsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
        onDriversTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DriversScreen()),
          );
        },
        onCarriersTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CarriersScreen()),
          );
        },
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            WarehouseHeader(avatarUrl: auth.avatarUrl),
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  const Expanded(child: SearchBarTrigger()),
                  const SizedBox(width: 8),
                  const ProductManagementButton(),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  for (var i = 0; i < _screens.length; i++)
                    _visited[i] ? _screens[i] : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        items: keeperNavItems,
        fabIcon: Icons.output_rounded,
        onTap: _selectTab,
        onAddPressed: () => _openExitMenu(),
      ),
    );
  }
}

class _ExitMenuTile extends StatelessWidget {
  const _ExitMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1D22),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
