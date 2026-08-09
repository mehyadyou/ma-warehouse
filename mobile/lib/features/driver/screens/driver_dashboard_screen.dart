import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../widgets/driver_header.dart';
import '../widgets/driver_bottom_nav.dart';
import '../widgets/loading_plan_tab.dart';
import '../widgets/delivery_tab.dart';
import '../widgets/history_tab.dart';

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
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('پنل راننده',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        onLogout: _logout,
        userName: 'راننده',
        userRole: 'راننده',
        greenColor: _green,
        surfaceColor: _surface,
        bgColor: _bg,
      ),
      body: Column(children: [
        const DriverHeader(
          name: 'راننده',
          warehouseName: 'انبار اصلی',
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
    );
  }
}