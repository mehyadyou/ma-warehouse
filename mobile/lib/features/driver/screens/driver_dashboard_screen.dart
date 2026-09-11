import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/core/refresh/resume_tick.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/dashboard_header.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../providers/driver_provider.dart';
import '../widgets/loading_plan_tab.dart';
import '../widgets/delivery_tab.dart';
import '../widgets/history_tab.dart';
import '../widgets/driver_bottom_nav.dart';
import '../../../shared/settings/settings_screen.dart';

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

  /// لیست هندلرهای سوکت — برای حذف کامل در dispose نگه داشته می‌شود
  final Map<String, Function(dynamic)> _socketHandlers = {};

  /// رفرش دوره‌ای به‌عنوان پشتیبان سوکت: اگر رویداد زنده از دست برود،
  /// پنل راننده حداکثر ظرف ۳۰ ثانیه به‌روز می‌شود
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_registerSocketListeners);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _onOrdersChanged(null),
    );
  }

  /// رویدادهای زندهٔ انبار: سفارش جدید/ویرایش/حذف + خروج کالا — پنل راننده همان‌لحظه به‌روز می‌شود
  void _registerSocketListeners() {
    final socket = ref.read(socketServiceProvider);
    socket.on('driver:assigned', _onOrdersChanged);
    socket.on('order:created', _onOrdersChanged);
    socket.on('order:updated', _onOrdersChanged);
    socket.on('order:deleted', _onOrdersChanged);
    socket.on('scanout:done', _onOrdersChanged);
    // انباردار بار را به این راننده تخصیص داد (بعد از اسکن خروج) — همان لحظه در پنل بیاید
    socket.on('order:assigned', _onOrdersChanged);
    // بار از این راننده گرفته شد و به رانندهٔ دیگری واگذار شد — همان لحظه از پنلش پاک شود
    socket.on('order:unassigned', _onOrdersChanged);
    // انباردار چیدمان صف بارگیری را تغییر داد — صفِ پنل راننده همان لحظه به همان ترتیب بازچینی می‌شود
    socket.on('carriers:reordered', _onOrdersChanged);
    _socketHandlers['driver:assigned'] = _onOrdersChanged;
    _socketHandlers['order:created'] = _onOrdersChanged;
    _socketHandlers['order:updated'] = _onOrdersChanged;
    _socketHandlers['order:deleted'] = _onOrdersChanged;
    _socketHandlers['scanout:done'] = _onOrdersChanged;
    _socketHandlers['order:assigned'] = _onOrdersChanged;
    _socketHandlers['order:unassigned'] = _onOrdersChanged;
    _socketHandlers['carriers:reordered'] = _onOrdersChanged;
  }

  void _onOrdersChanged(dynamic data) {
    if (!mounted) return;
    ref.invalidate(readyOrdersProvider);
    ref.invalidate(loadingPlanProvider);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    final socket = ref.read(socketServiceProvider);
    _socketHandlers.forEach(
      (event, handler) => socket.offEvent(event, handler),
    );
    _socketHandlers.clear();
    super.dispose();
  }

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
    // بازگشت از پس‌زمینه → تازه‌سازی خودکار سفارش‌ها (بدون خروج/ورود)
    ref.listen<int>(resumeTickProvider, (_, _) => _onOrdersChanged(null));
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
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      body: SafeArea(
        child: Column(children: [
          DashboardHeader(
            title: auth.name ?? 'راننده',
            showDate: true,
            avatarUrl: auth.avatarUrl,
            trailing: _onlineBadge(),
          ),
          const OfflineBanner(),
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