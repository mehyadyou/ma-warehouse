import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api_service.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';


/// تب مالی — جمع درآمد/واحد + تفکیک روز/انبار/شهر/باربری + کپی CSV
class FinanceTab extends StatefulWidget {
  const FinanceTab({super.key, required this.api, required this.refreshTick});

  final CrmApiService api;
  final int refreshTick;

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  Map<String, dynamic>? _data;
  List<dynamic> _warehouses = [];
  String? _warehouseId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    widget.api.getWarehouses().then((v) {
      if (mounted) setState(() => _warehouses = v);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.api.getFinance(
        from: _fromController.text.trim().isEmpty ? null : _fromController.text.trim(),
        to: _toController.text.trim().isEmpty ? null : _toController.text.trim(),
        warehouseId: _warehouseId,
      );
      if (!mounted) return;
      setState(() {
        _data = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _copyCsv() {
    final d = _data;
    if (d == null) return;
    final totals = (d['totals'] as Map<String, dynamic>?) ?? {};
    final buf = StringBuffer('metric,value\n');
    buf.writeln('revenue,${totals['revenue'] ?? 0}');
    buf.writeln('units,${totals['units'] ?? 0}');
    buf.writeln('orders,${totals['orders'] ?? 0}');
    for (final row in ((d['byDay'] as List<dynamic>?) ?? [])) {
      buf.writeln('day:${row['key']},${row['revenue'] ?? 0}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('خلاصه مالی در حافظه کپی شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CrmPage(
      title: 'مالی',
      subtitle: 'مبالغ نمایشی‌اند (از فاکتورها، نه سند حسابداری)',
      onRefresh: () => _load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 180,
                child: AppTextField(
                  controller: _fromController,
                  label: 'از تاریخ (میلادی)',
                  hint: '2026-09-01',
                  keyboardType: TextInputType.datetime,
                  onSubmitted: (_) => _load(),
                ),
              ),
              SizedBox(
                width: 180,
                child: AppTextField(
                  controller: _toController,
                  label: 'تا تاریخ (میلادی)',
                  hint: '2026-09-30',
                  keyboardType: TextInputType.datetime,
                  onSubmitted: (_) => _load(),
                ),
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('انبار',
                        style: TextStyle(color: Palette.textMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Palette.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _warehouseId,
                          hint: const Text('همه انبارها',
                              style: TextStyle(color: Palette.textMuted, fontSize: 13)),
                          isExpanded: true,
                          dropdownColor: Palette.surfaceAlt,
                          style: const TextStyle(color: Palette.text, fontSize: 13),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('همه انبارها'),
                            ),
                            for (final w in _warehouses)
                              DropdownMenuItem<String?>(
                                value: (w['id'] ?? '').toString(),
                                child: Text((w['name'] ?? '').toString(),
                                    overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: (v) {
                            setState(() => _warehouseId = v);
                            _load();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: AppButton(label: 'اعمال', onPressed: _loading ? null : () => _load(), small: true),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: AppButton(
                  label: 'کپی CSV',
                  onPressed: (_loading || _data == null) ? null : _copyCsv,
                  small: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const LoadingState()
          else if (_error != null)
            ErrorState(message: _error!, onRetry: () => _load())
          else
            _content(),
        ],
      ),
    );
  }

  Widget _content() {
    final totals = (_data?['totals'] as Map<String, dynamic>?) ?? {};
    final byDay = ((_data?['byDay'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
    final byWarehouse = ((_data?['byWarehouse'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
    final byCity = ((_data?['byCity'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
    final byCarrier = ((_data?['byCarrier'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
    final maxRev = [
      for (final l in [byDay, byWarehouse, byCity, byCarrier])
        for (final r in l) ((r['revenue'] as num?) ?? 0).toDouble(),
    ].fold<double>(0, (a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 210,
              child: KpiCard(
                title: 'جمع مبالغ',
                value: faMoney(totals['revenue']),
                icon: Icons.payments_rounded,
              ),
            ),
            SizedBox(
              width: 210,
              child: KpiCard(
                title: 'تعداد واحد',
                value: '${totals['units'] ?? 0}',
                icon: Icons.numbers_rounded,
              ),
            ),
            SizedBox(
              width: 210,
              child: KpiCard(
                title: 'تعداد سفارش',
                value: '${totals['orders'] ?? 0}',
                icon: Icons.receipt_long_rounded,
                subtitle: (totals['capped'] == true) ? 'سقف ۵۰۰۰ سفارش' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionTitle('درآمد روزانه'),
        const SizedBox(height: 8),
        if (byDay.isEmpty)
          const Text('داده‌ای نیست', style: TextStyle(color: Palette.textMuted))
        else
          for (final r in byDay.take(31))
            BarRow(
              label: (r['key'] ?? '').toString(),
              value: '${r['orders'] ?? 0} سفارش',
              display: faMoney(r['revenue']),
              fraction: maxRev == 0 ? 0 : ((r['revenue'] as num?) ?? 0).toDouble() / maxRev,
            ),
        const SizedBox(height: 18),
        const SectionTitle('به‌تفکیک انبار'),
        const SizedBox(height: 8),
        for (final r in byWarehouse)
          BarRow(
            label: ((r['name'] ?? r['key']) ?? '').toString(),
            value: '${r['orders'] ?? 0} سفارش',
            display: faMoney(r['revenue']),
            fraction: maxRev == 0 ? 0 : ((r['revenue'] as num?) ?? 0).toDouble() / maxRev,
            color: const Color(0xFF60A5FA),
          ),
        const SizedBox(height: 18),
        const SectionTitle('به‌تفکیک شهر'),
        const SizedBox(height: 8),
        for (final r in byCity.take(20))
          BarRow(
            label: (r['key'] ?? '').toString(),
            value: '${r['orders'] ?? 0} سفارش',
            display: faMoney(r['revenue']),
            fraction: maxRev == 0 ? 0 : ((r['revenue'] as num?) ?? 0).toDouble() / maxRev,
            color: const Color(0xFFFB923C),
          ),
        const SizedBox(height: 18),
        const SectionTitle('به‌تفکیک باربری/روش ارسال'),
        const SizedBox(height: 8),
        for (final r in byCarrier.take(20))
          BarRow(
            label: (r['key'] ?? '').toString(),
            value: '${r['orders'] ?? 0} سفارش',
            display: faMoney(r['revenue']),
            fraction: maxRev == 0 ? 0 : ((r['revenue'] as num?) ?? 0).toDouble() / maxRev,
            color: const Color(0xFFA78BFA),
          ),
      ],
    );
  }
}
