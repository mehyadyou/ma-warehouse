import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';


/// تب سلامت سیستم — شمارنده‌ها، صف outbox، مصرف کلیدها
class HealthTab extends StatefulWidget {
  const HealthTab({super.key, required this.api, required this.refreshTick});

  final CrmApiService api;
  final int refreshTick;

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  Map<String, dynamic>? _health;
  Map<String, dynamic>? _usage;
  bool _loading = true;
  String? _error;
  int _seenTick = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HealthTab old) {
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
        widget.api.getHealth(),
        widget.api.getApiUsage(),
      ]);
      if (!mounted) return;
      setState(() {
        _health = results[0] as Map<String, dynamic>;
        _usage = results[1] as Map<String, dynamic>;
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
      title: 'سلامت سیستم',
      subtitle: 'نبض زیرساخت + مصرف کلیدهای بیرونی',
      onRefresh: () => _load(),
      child: _loading && _health == null
          ? const LoadingState()
          : _error != null && _health == null
              ? ErrorState(message: _error!, onRetry: () => _load())
              : _content(),
    );
  }

  Widget _content() {
    final counts = (_health?['counts'] as Map<String, dynamic>?) ?? {};
    final outbox = (_health?['outbox'] as Map<String, dynamic>?) ?? {};
    final keys = ((_usage?['keys'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
    final failed = (outbox['failed'] as num?)?.toInt() ?? 0;
    final pending = (outbox['pending'] as num?)?.toInt() ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _kpi('کاربران', '${counts['users'] ?? '-'}', Icons.people_rounded),
            _kpi('سفارش‌ها', '${counts['orders'] ?? '-'}', Icons.receipt_long_rounded),
            _kpi('کارتن‌ها', '${counts['cartons'] ?? '-'}', Icons.inventory_2_rounded),
            _kpi('محصولات', '${counts['products'] ?? '-'}', Icons.category_rounded),
            _kpi(
              'outbox در انتظار',
              '$pending',
              Icons.outbox_rounded,
              color: pending > 20 ? Palette.danger : null,
              subtitle: outbox['oldestPendingAt'] != null
                  ? 'قدیمی‌ترین: ${faDateTime(outbox['oldestPendingAt'])}'
                  : null,
            ),
            _kpi('outbox ناموفق', '$failed', Icons.error_rounded,
                color: failed > 0 ? Palette.danger : null),
            _kpi('Redis', '${_health?['redis'] == true ? 'وصل' : _health?['redis'] == false ? 'قطع' : 'نامشخص'}',
                Icons.memory_rounded,
                color: _health?['redis'] == false ? Palette.danger : null),
            _kpi('آپتایم سرور', '${((_health?['uptimeSec'] as num?) ?? 0).toInt()} ثانیه',
                Icons.timer_rounded),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: SectionTitle('مصرف کلیدهای API (۱۴ روز اخیر)')),
            Text(
              'بازه: ${_usage?['from'] ?? '-'} تا ${_usage?['to'] ?? '-'}',
              style: const TextStyle(color: Palette.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (keys.isEmpty)
          const Text('مصرفی ثبت نشده', style: TextStyle(color: Palette.textMuted))
        else
          Container(
            decoration: BoxDecoration(
              color: Palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Palette.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle:
                    const TextStyle(color: Palette.textMuted, fontSize: 12),
                dataTextStyle: const TextStyle(color: Palette.text, fontSize: 13),
                columns: const [
                  DataColumn(label: Text('کلید')),
                  DataColumn(label: Text('وضعیت')),
                  DataColumn(label: Text('درخواست‌ها'), numeric: true),
                  DataColumn(label: Text('خطاها'), numeric: true),
                ],
                rows: [
                  for (final k in keys)
                    DataRow(cells: [
                      DataCell(Text(
                          '${(k['key'] as Map?)?['name'] ?? ''} (${(k['key'] as Map?)?['prefix'] ?? ''})')),
                      DataCell(Text(
                        (k['key'] as Map?)?['isActive'] == true ? 'فعال' : 'غیرفعال',
                        style: TextStyle(
                          color: (k['key'] as Map?)?['isActive'] == true
                              ? Palette.primary
                              : Palette.danger,
                        ),
                      )),
                      DataCell(Text('${k['totalHits'] ?? 0}')),
                      DataCell(Text(
                        '${k['totalErrors'] ?? 0}',
                        style: TextStyle(
                          color: ((k['totalErrors'] as num?) ?? 0) > 0
                              ? Palette.danger
                              : Palette.text,
                        ),
                      )),
                    ]),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _kpi(String title, String value, IconData icon,
      {Color? color, String? subtitle}) {
    return SizedBox(
      width: 200,
      child: KpiCard(
        title: title,
        value: value,
        icon: icon,
        color: color,
        subtitle: subtitle,
      ),
    );
  }
}
