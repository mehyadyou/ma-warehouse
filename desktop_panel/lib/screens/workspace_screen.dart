import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/palette.dart';
import '../core/socket_client.dart';
import '../widgets/app_widgets.dart';
import 'tabs/badges_tab.dart';
import 'tabs/cartons_tab.dart';
import 'tabs/transactions_tab.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.api,
    required this.socket,
    required this.userName,
    required this.onLogout,
  });

  final ApiService api;
  final SocketClient socket;
  final String userName;
  final VoidCallback onLogout;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  int _selectedIndex = 0;
  String _warehouseName = 'نامشخص';
  String _keeperName = '';
  String _subtitle = 'در حال بارگذاری اطلاعات...';

  final GlobalKey<CartonsTabState> _recentKey = GlobalKey();
  final GlobalKey<CartonsTabState> _shippedKey = GlobalKey();
  final GlobalKey<TransactionsTabState> _transactionsKey = GlobalKey();
  final GlobalKey<BadgesTabState> _badgesKey = GlobalKey();

  late final CartonsTab _recentTab = CartonsTab(
    key: _recentKey,
    fetch: widget.api.getCartons,
    initialSummary: 'آخرین برچسب‌های ثبت شده',
    emptySummary: 'هیچ کارتنی برای امروز ثبت نشده است.',
    emptyState: 'هیچ ورودی جدیدی ثبت نشده است.',
    summary: (groups, total) => '$groups گروه کالا | $total برچسب آماده چاپ',
    errorSummary: 'خطا در دریافت اطلاعات',
  );

  late final CartonsTab _shippedTab = CartonsTab(
    key: _shippedKey,
    fetch: widget.api.getShippedCartons,
    initialSummary: 'کارتن‌های تکمیل شده و ارسال شده',
    emptySummary: 'هیچ کارتن ارسال شده‌ای موجود نیست.',
    emptyState: 'هیچ کارتن ارسالی ثبت نشده است.',
    summary: (groups, total) => '$groups گروه کالا | $total کارتن ارسال شده',
    errorSummary: 'خطا در دریافت اطلاعات',
  );

  late final TransactionsTab _transactionsTab = TransactionsTab(
    key: _transactionsKey,
    api: widget.api,
  );
  late final BadgesTab _badgesTab = BadgesTab(key: _badgesKey, api: widget.api);

  @override
  void initState() {
    super.initState();
    widget.socket.onScanoutDone = (data) {
      _recentKey.currentState?.reload();
      _shippedKey.currentState?.reload();
    };
    widget.socket.onCheckinCompleted = (data) {
      _recentKey.currentState?.reload();
    };
    loadData();
  }

  @override
  void dispose() {
    widget.socket.onScanoutDone = null;
    widget.socket.onCheckinCompleted = null;
    super.dispose();
  }

  Future<void> loadData() async {
    _loadWarehouse();
    _recentKey.currentState?.reload();
    _shippedKey.currentState?.reload();
    _transactionsKey.currentState?.reloadLatest();
    _badgesKey.currentState?.load();
  }

  Future<void> _loadWarehouse() async {
    try {
      final warehouse = await widget.api.getMyWarehouse();
      if (!mounted) return;
      setState(() {
        _warehouseName = warehouse['name']?.toString() ?? 'انبار نامشخص';
        _keeperName = warehouse['keeperName']?.toString() ?? '';
      });
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _warehouseName = 'انبار';
        _subtitle = 'عدم دریافت اطلاعات انبار: $exc';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _keeperName.isEmpty
        ? _subtitle
        : 'کاربر فعال: ${widget.userName}${_keeperName == widget.userName ? '' : ' ($_keeperName)'}';

    return Scaffold(
      backgroundColor: Palette.appBg,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: Palette.surfaceAlt,
                    border: Border(bottom: BorderSide(color: Palette.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'داشبورد $_warehouseName',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Palette.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Palette.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: 'بروزرسانی',
                        variant: AppButtonVariant.secondary,
                        onPressed: loadData,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _recentTab,
                      _shippedTab,
                      _transactionsTab,
                      _badgesTab,
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Sidebar(
            userName: widget.userName,
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
            onLogout: widget.onLogout,
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.userName,
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
  });

  static const _navItems = [
    'ورودی‌های اخیر',
    'تکمیل شده‌ها',
    'تاریخچه تراکنش‌ها',
    'بیجک',
  ];

  final String userName;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Palette.surface,
        border: Border(left: BorderSide(color: Palette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      child: Column(
        children: [
          const Text(
            'MA WAREHOUSE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Palette.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            userName.isEmpty ? 'انباردار' : userName,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Palette.border,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          for (var i = 0; i < _navItems.length; i++)
            _NavItem(
              label: _navItems[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          AppButton(
            label: 'خروج از حساب',
            variant: AppButtonVariant.danger,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? Palette.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Palette.surfaceHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Palette.textMuted,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
