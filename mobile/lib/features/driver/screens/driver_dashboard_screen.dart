import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/dashboard_header.dart';
import '../widgets/loading_plan_tab.dart';
import '../widgets/delivery_tab.dart';
import '../widgets/history_tab.dart';
import '../widgets/driver_bottom_nav.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  int _currentTab = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _logout() {
    _scaffoldKey.currentState?.closeDrawer();
    ref.read(authProvider.notifier).logout();
  }

  /// نشان وضعیت راننده + آیکون کامیون — سمت راست هدر
  Widget _onlineBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: _green.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _green.withOpacity(0.3)),
          ),
          child: const Icon(Icons.local_shipping_rounded, color: _green, size: 22),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bg,
      drawer: AppDrawer(
        onLogout: _logout,
        userName: auth.name ?? 'راننده',
        userRole: 'راننده',
        avatarUrl: auth.avatarUrl,
        greenColor: _green,
        surfaceColor: _surface,
        bgColor: _bg,
      ),
      body: SafeArea(
        child: Column(children: [
          DashboardHeader(
            title: auth.name ?? 'راننده',
            showDate: true,
            avatarUrl: auth.avatarUrl,
            trailing: _onlineBadge(),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: const [
                LoadingPlanTab(),
                DeliveryTab(),
                HistoryTab(),
              ],
            ),
          ),
          DriverBottomNav(
            currentIndex: _currentTab,
            onTap: (index) => setState(() => _currentTab = index),
          ),
        ]),
      ),
    );
  }
}