import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/palette.dart';
import '../core/socket_client.dart';
import '../widgets/app_widgets.dart';
import 'tabs/activity_tab.dart';
import 'tabs/customers_tab.dart';
import 'tabs/finance_tab.dart';
import 'tabs/health_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/settings_tab.dart';

/// شل اصلی CRM — سایدبار راست + تب‌ها. رویداد ریل‌تایم تب فعال را تازه می‌کند.
class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.api,
    required this.socket,
    required this.userName,
    required this.onLogout,
  });

  final CrmApiService api;
  final CrmSocketClient socket;
  final String userName;
  final VoidCallback onLogout;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

const _navItems = [
  _NavItem('نمای کلی', Icons.dashboard_rounded),
  _NavItem('مشتریان', Icons.people_rounded),
  _NavItem('مالی', Icons.account_balance_wallet_rounded),
  _NavItem('فعالیت‌ها', Icons.history_rounded),
  _NavItem('سلامت سیستم', Icons.monitor_heart_rounded),
  _NavItem('تنظیمات', Icons.settings_rounded),
];

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  int _index = 0;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    widget.socket.onEvent = (_, __) {
      if (mounted) setState(() => _refreshTick++);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.appBg,
      body: Row(
        children: [
          _sidebar(),
          const VerticalDivider(width: 1, color: Palette.border),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                OverviewTab(api: widget.api, refreshTick: _refreshTick, onOpenCustomers: () => _go(1)),
                CustomersTab(api: widget.api, refreshTick: _refreshTick),
                FinanceTab(api: widget.api, refreshTick: _refreshTick),
                ActivityTab(api: widget.api, refreshTick: _refreshTick),
                HealthTab(api: widget.api, refreshTick: _refreshTick),
                SettingsTab(api: widget.api, userName: widget.userName, onLogout: widget.onLogout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _go(int i) => setState(() => _index = i);

  Widget _sidebar() {
    return Container(
      width: 232,
      color: Palette.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Palette.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Palette.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CRM مالک',
                        style: TextStyle(
                          color: Palette.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        widget.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Palette.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Palette.border, height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final selected = i == _index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => _go(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? Palette.primary.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? Palette.primary.withValues(alpha: 0.4) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: selected ? Palette.primary : Palette.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected ? Palette.primary : Palette.text,
                                fontSize: 13.5,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Palette.surfaceAlt,
                    title: const Text('خروج', style: TextStyle(color: Palette.text, fontSize: 16)),
                    content: const Text(
                      'از حساب مدیر خارج می‌شوید؟',
                      style: TextStyle(color: Palette.textMuted, fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('انصراف', style: TextStyle(color: Palette.textMuted)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onLogout();
                        },
                        child: const Text('خروج', style: TextStyle(color: Palette.danger)),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Palette.danger, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'خروج از حساب',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Palette.danger, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
