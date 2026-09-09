import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';

/// تب نمای کلی — KPIها + دونات وضعیت سفارش؟ (فعلاً شمارنده‌ها) + هشدار outbox
class OverviewTab extends StatefulWidget {
  const OverviewTab({
    super.key,
    required this.api,
    required this.refreshTick,
    required this.onOpenCustomers,
  });

  final CrmApiService api;
  final int refreshTick;
  final VoidCallback onOpenCustomers;

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _health;
  String? _error;
  bool _loading = true;
  int _seenTick = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant OverviewTab old) {
    super.didUpdateWidget(old);
    if (widget.refreshTick != _seenTick) {
      _seenTick = widget.refreshTick;
      _load(silent: true);
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        widget.api.getOverview(),
        widget.api.getHealth(),
      ]);
      if (!mounted) return;
      setState(() {
        _data = results[0] as Map<String, dynamic>;
        _health = results[1] as Map<String, dynamic>;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CrmPage(
      title: 'نمای کلی',
      subtitle: 'وضعیت زندهٔ کل سیستم در یک نگاه',
      onRefresh: () => _load(),
      child: _loading && _data == null
          ? const LoadingState()
          : _error != null && _data == null
              ? ErrorState(message: _error!, onRetry: () => _load())
              : _content(),
    );
  }

  Widget _content() {
    final d = _data ?? {};
    final h = (_health?['outbox'] as Map<String, dynamic>?) ?? {};
    final failed = (h['failed'] as num?)?.toInt() ?? 0;
    final pending = (h['pending'] as num?)?.toInt() ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (failed > 0)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Palette.dangerBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Palette.danger.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Palette.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$failed رویداد ناموفق در صف خروجی — از تب «سلامت سیستم» بررسی کنید.',
                    style: const TextStyle(color: Palette.text, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _kpi('کاربران فعال', '${d['usersCount'] ?? '-'}', Icons.people_rounded, null),
            _kpi('انبارها', '${d['warehousesCount'] ?? '-'}', Icons.warehouse_rounded, null),
            _kpi('سفارش‌های باز', '${d['ordersPending'] ?? '-'}', Icons.pending_actions_rounded,
                ((d['ordersPending'] as num?) ?? 0) > 0 ? Palette.primary : null),
            _kpi('دستورهای باز', '${d['transfersPending'] ?? '-'}', Icons.swap_horiz_rounded, null),
            _kpi('سفارش امروز', '${d['todayOrders'] ?? '-'}', Icons.today_rounded, null),
            _kpi('صف خروجی در انتظار', '$pending', Icons.outbox_rounded,
                pending > 20 ? Palette.danger : null),
          ],
        ),
        const SizedBox(height: 20),
        const SectionTitle('موجودی کلی'),
        const SizedBox(height: 10),
        _InventoryMini(api: widget.api),
      ],
    );
  }

  Widget _kpi(String title, String value, IconData icon, Color? color) {
    return SizedBox(
      width: 210,
      child: KpiCard(title: title, value: value, icon: icon, color: color),
    );
  }
}

/// خلاصه موجودی (خوانش سبک از همان API موجودی مدیر)
class _InventoryMini extends StatefulWidget {
  const _InventoryMini({required this.api});

  final CrmApiService api;

  @override
  State<_InventoryMini> createState() => _InventoryMiniState();
}

class _InventoryMiniState extends State<_InventoryMini> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    widget.api
        .getInventorySummary()
        .then((v) {
          if (mounted) setState(() => _data = v);
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    if (d == null) {
      return const Text('...', style: TextStyle(color: Palette.textMuted));
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 210,
          child: KpiCard(
            title: 'کالاهای فعال',
            value: '${d['activeProducts'] ?? '-'}',
            icon: Icons.inventory_2_rounded,
          ),
        ),
        SizedBox(
          width: 210,
          child: KpiCard(
            title: 'کل واحدها',
            value: faMoney(d['totalUnits']),
            icon: Icons.numbers_rounded,
          ),
        ),
      ],
    );
  }
}
