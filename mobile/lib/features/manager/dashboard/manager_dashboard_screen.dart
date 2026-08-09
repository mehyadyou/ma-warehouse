import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/warehouses_provider.dart';
import '../providers/activity_provider.dart';
import '../../warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'header/header_section.dart';
import 'inventory_chart/inventory_chart_card.dart';
import 'search/app_search_bar.dart';
import 'quick_actions/quick_actions_section.dart';
import 'activity/activity_section.dart';
import 'quick_actions/inventory/inventory_screen.dart';
import 'bottom_nav_bar/bottom_nav_bar.dart';
import 'navigation_drawer/screens/settings/settings_screen.dart';
import 'navigation_drawer/screens/history_screen.dart';
import 'navigation_drawer/screens/archive_screen.dart';
import 'navigation_drawer/app_drawer.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState
    extends ConsumerState<ManagerDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _selectedIndex = 0;

  String _todayShamsi() {
    final jalali = Jalali.fromDateTime(DateTime.now());
    return 'امروز ${jalali.year}/${jalali.month}/${jalali.day}';
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'WAREHOUSE_KEEPER': return 'انباردار';
      case 'DRIVER': return 'راننده';
      default: return 'مدیر';
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
    
    // Setup socket listeners for real-time updates
    Future.microtask(() {
      final socket = ref.read(socketServiceProvider);

      // رویدادهای تراکنشی — موجودی و فعالیت‌های اخیر را به‌روزرسانی کن
      void invalidateTransactionData() {
        if (mounted) {
          ref.invalidate(managerInventorySummaryProvider);
          ref.invalidate(recentActivitiesProvider);
        }
      }

      // ورود کالا به انبار ثبت شد
      socket.on('checkin:completed', (_) => invalidateTransactionData());

      // خروج کالا از انبار ثبت شد
      socket.on('scanout:done', (_) => invalidateTransactionData());

      // تحویل تکمیل شد — فعالیت جدید ثبت شده
      socket.on('delivery:completed', (_) {
        if (mounted) ref.invalidate(recentActivitiesProvider);
      });

      // سفارش ثبت/ویرایش/حذف شد — فعالیت جدید ثبت شده
      socket.on('order:created', (_) {
        if (mounted) ref.invalidate(recentActivitiesProvider);
      });
      socket.on('order:updated', (_) {
        if (mounted) ref.invalidate(recentActivitiesProvider);
      });
      socket.on('order:deleted', (_) {
        if (mounted) ref.invalidate(recentActivitiesProvider);
      });
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(primary: _green, surface: _surface),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        drawer: AppDrawer(
          onLogout: _logout,
          userName: auth.name ?? 'کاربر',
          userRole: _roleLabel(auth.role),
          avatarUrl: auth.avatarUrl,
          onDashboardTap: () => setState(() => _selectedIndex = 0),
          onSettingsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          onHistoryTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          },
          onArchiveTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArchiveScreen()),
            );
          },
        ),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: HeaderSection(
                      title: auth.name ?? 'کاربر',
                      subtitle: _todayShamsi(),
                      avatarUrl: auth.avatarUrl,
                    ),
                  ),
                  const SliverToBoxAdapter(child: AppSearchBar()),
                  const SliverToBoxAdapter(child: InventoryChartCard()),
                  const SliverToBoxAdapter(child: QuickActionsSection()),
                  const SliverToBoxAdapter(child: ActivitySection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (i) async {
            if (i == 1) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagerInventoryScreen()),
              );
              if (mounted) ref.invalidate(managerInventorySummaryProvider);
              return;
            }
            if (i == 2) {
              await context.push('/manager/shipments');
              if (mounted) ref.invalidate(recentActivitiesProvider);
              return;
            }
            setState(() => _selectedIndex = i);
          },
          onAddPressed: () async {
            await context.push('/manager/orders/create');
            if (mounted) ref.invalidate(recentActivitiesProvider);
          },
        ),
      ),
    );
  }
}
