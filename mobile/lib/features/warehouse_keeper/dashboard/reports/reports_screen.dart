import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ma_app/features/warehouse_keeper/data/warehouse_keeper_api_service.dart';
import 'package:ma_app/features/warehouse_keeper/dashboard/home/activity_section.dart'
    show orderStatusStyle;
import 'package:ma_app/features/warehouse_keeper/models/keeper_report_model.dart';
import 'package:ma_app/shared/utils/numbers.dart';
import 'package:ma_app/shared/widgets/inventory_donut_card.dart';
import 'package:ma_app/shared/widgets/jalali_month_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _blue = Color(0xFF60A5FA);
const _red = Color(0xFFF87171);
const _purple = Color(0xFFA78BFA);

/// گزارش عملکرد انباردار — نمودارهای دقیق + فیلتر بازه/محدوده/نوع عملکرد
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _api = WarehouseKeeperApiService();

  Jalali _from = Jalali.now().addDays(-29);
  Jalali _to = Jalali.now();
  String _scope = 'mine'; // mine | all
  String? _feedType; // null=همه | in | out | order | transfer

  KeeperReportsData? _data;
  bool _loading = true;
  String? _error;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _gregorianKey(Jalali j) {
    final dt = j.toDateTime();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  String _jalaliLabel(Jalali j) =>
      faDigits('${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');

  Future<void> _load() async {
    final seq = ++_seq;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getReports(
        from: _gregorianKey(_from),
        to: _gregorianKey(_to),
        scope: _scope,
      );
      if (!mounted || seq != _seq) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || seq != _seq) return;
      setState(() {
        _loading = false;
        _error = 'خطا در دریافت گزارش — اتصال اینترنت را بررسی کنید';
      });
    }
  }

  void _setRange({required Jalali from, required Jalali to}) {
    setState(() {
      _from = from;
      _to = to;
    });
    _load();
  }

  Future<void> _pickFrom() async {
    final picked = await showJalaliMonthPicker(context, initial: _from);
    if (picked == null || !mounted) return;
    _setRange(from: picked, to: picked > _to ? picked : _to);
  }

  Future<void> _pickTo() async {
    final picked = await showJalaliMonthPicker(context, initial: _to);
    if (picked == null || !mounted) return;
    if (picked < _from) {
      _setRange(from: _from, to: _from);
    } else {
      _setRange(from: _from, to: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: _green,
      backgroundColor: _surface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _filterCard(),
          if (_loading) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(color: _green, minHeight: 2),
          ],
          const SizedBox(height: 14),
          if (_error != null && _data == null) _errorBox()
          else if (_data == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator(color: _green)),
            )
          else ...[
            _summaryCards(_data!.summary),
            const SizedBox(height: 14),
            _barChartCard(_data!),
            const SizedBox(height: 14),
            _ordersDonutCard(_data!),
            const SizedBox(height: 14),
            _topProductsCard(_data!),
            const SizedBox(height: 14),
            _activityCard(_data!),
          ],
        ],
      ),
    );
  }

  // ── فیلترها ──
  Widget _filterCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: _green, size: 18),
              const SizedBox(width: 8),
              const Text(
                'فیلتر گزارش',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${_jalaliLabel(_from)} تا ${_jalaliLabel(_to)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dateChip('از تاریخ', _jalaliLabel(_from), _pickFrom),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dateChip('تا تاریخ', _jalaliLabel(_to), _pickTo),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _quickChip('امروز', () {
                final now = Jalali.now();
                _setRange(from: now, to: now);
              }),
              _quickChip('۷ روز اخیر', () {
                final now = Jalali.now();
                _setRange(from: now.addDays(-6), to: now);
              }),
              _quickChip('۳۰ روز اخیر', () {
                final now = Jalali.now();
                _setRange(from: now.addDays(-29), to: now);
              }),
              _quickChip('این ماه', () {
                final now = Jalali.now();
                _setRange(from: Jalali(now.year, now.month, 1), to: now);
              }),
            ],
          ),
          const SizedBox(height: 12),
          // محدوده: فعالیت‌های من / کل انبار
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'mine',
                icon: Icon(Icons.person_rounded, size: 16),
                label: Text('فعالیت‌های من'),
              ),
              ButtonSegment(
                value: 'all',
                icon: Icon(Icons.warehouse_rounded, size: 16),
                label: Text('کل انبار'),
              ),
            ],
            selected: {_scope},
            onSelectionChanged: _loading
                ? null
                : (s) {
                    setState(() => _scope = s.first);
                    _load();
                  },
            style: SegmentedButton.styleFrom(
              backgroundColor: _bg,
              selectedBackgroundColor: _green.withValues(alpha: 0.18),
              selectedForegroundColor: _green,
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _green.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month_rounded, color: _green, size: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 11.5),
      backgroundColor: _bg,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _errorBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.white.withValues(alpha: 0.4), size: 32),
          const SizedBox(height: 10),
          Text(
            _error ?? 'خطا',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: _green, size: 18),
            label: const Text('تلاش دوباره', style: TextStyle(color: _green)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _green),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── کارت‌های آماری ──
  Widget _summaryCards(KeeperReportSummary s) {
    final cards = [
      ('ورودی (واحد)', formatNumber(s.inUnits), _green, Icons.move_to_inbox_rounded),
      ('خروجی (واحد)', formatNumber(s.outUnits), _orange, Icons.output_rounded),
      ('دفعات خروج', formatNumber(s.outCount), _blue, Icons.qr_code_scanner_rounded),
      ('سفارش ارسالی', formatNumber(s.ordersShipped), _purple, Icons.local_shipping_rounded),
    ];
    return Column(
      children: [
        Row(
          children: [
            for (final c in cards.sublist(0, 2)) ...[
              Expanded(child: _statCard(c.$2, c.$1, c.$3, c.$4)),
              if (c != cards[1]) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final c in cards.sublist(2)) ...[
              Expanded(child: _statCard(c.$2, c.$1, c.$3, c.$4)),
              if (c != cards.last) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // جزئیات تکمیلی: ورود کالا / مرجوعی / دستورهای اجراشده / کل عملکردها
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _miniChip('${formatNumber(s.checkinCount)} ورود کالا', _green),
            _miniChip('${formatNumber(s.returnUnits)} واحد مرجوعی', _orange),
            _miniChip('${formatNumber(s.transfersExecuted)} دستور اجراشده', _purple),
            _miniChip('${formatNumber(s.myActions)} عملکرد ثبت‌شده', _blue),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── نمودار میله‌ای ورود در برابر خروج ──
  Widget _barChartCard(KeeperReportsData data) {
    final groups = _buildBarGroups(data.daily);
    final hasData = groups.any((g) => g.inUnits > 0 || g.outUnits > 0);
    final weekly = data.daily.length > 31;

    return _card(
      title: 'ورود و خروج روزانه',
      subtitle: weekly ? 'نمایش هفتگی (بازهٔ طولانی)' : 'بر اساس روز',
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot('ورود', _green),
          SizedBox(width: 10),
          _LegendDot('خروج', _orange),
        ],
      ),
      child: hasData
          ? SizedBox(
              height: 190,
              width: double.infinity,
              child: CustomPaint(
                painter: _DailyBarPainter(
                  groups: groups,
                  inColor: _green,
                  outColor: _orange,
                ),
              ),
            )
          : const _EmptyBox('در این بازه تراکنشی ثبت نشده'),
    );
  }

  List<_BarGroup> _buildBarGroups(List<KeeperDailyPoint> daily) {
    if (daily.isEmpty) return [];
    if (daily.length <= 31) {
      return daily
          .map(
            (d) => _BarGroup(
              label: _shortDate(d.date),
              inUnits: d.inUnits,
              outUnits: d.outUnits,
            ),
          )
          .toList();
    }
    // بازهٔ طولانی → گروه‌بندی هفتگی
    final first = DateTime.parse(daily.first.date);
    final groups = <_BarGroup>[];
    for (final d in daily) {
      final dt = DateTime.parse(d.date);
      final week = dt.difference(first).inDays ~/ 7;
      if (groups.isEmpty || groups.last.week != week) {
        groups.add(
          _BarGroup(label: _shortDate(d.date), inUnits: 0, outUnits: 0, week: week),
        );
      }
      groups.last.inUnits += d.inUnits;
      groups.last.outUnits += d.outUnits;
    }
    return groups;
  }

  String _shortDate(String iso) {
    try {
      final j = Jalali.fromDateTime(DateTime.parse(iso).toLocal());
      return '${j.day}/${j.month}';
    } catch (_) {
      return iso;
    }
  }

  // ── وضعیت سفارش‌ها (دونات) ──
  Widget _ordersDonutCard(KeeperReportsData data) {
    final items = <InventoryItem>[
      for (final s in data.ordersByStatus)
        if (s.count > 0)
          InventoryItem(
            name: orderStatusStyle(s.status).label,
            count: s.count,
            unit: 'سفارش',
            color: orderStatusStyle(s.status).color,
          ),
    ];
    final total = data.ordersByStatus.fold<int>(0, (sum, s) => sum + s.count);
    final shipped = data.ordersByStatus
        .where((s) => s.status == 'SHIPPED')
        .fold<int>(0, (sum, s) => sum + s.count);
    final delivered = data.ordersByStatus
        .where((s) => s.status == 'DELIVERED')
        .fold<int>(0, (sum, s) => sum + s.count);

    return _card(
      title: 'وضعیت سفارش‌های ثبت‌شده در بازه',
      subtitle: 'وضعیت فعلی سفارش‌های این انبار',
      child: InventoryDonutCard(
        items: items,
        emptyMessage: 'سفارشی در این بازه ثبت نشده',
        stats: [
          InventoryStat(label: 'کل سفارش‌ها', value: formatNumber(total), color: Colors.white),
          InventoryStat(label: 'ارسالی', value: formatNumber(shipped), color: _green),
          InventoryStat(label: 'تحویلی', value: formatNumber(delivered), color: _blue),
        ],
      ),
    );
  }

  // ── محصولات پرتکرار ──
  Widget _topProductsCard(KeeperReportsData data) {
    final empty = data.topIn.isEmpty && data.topOut.isEmpty;
    return _card(
      title: 'محصولات پرتکرار',
      subtitle: 'بیشترین واحد ورود/خروج در بازه',
      child: empty
          ? const _EmptyBox('محصولی در این بازه ثبت نشده')
          : Column(
              children: [
                if (data.topIn.isNotEmpty) ...[
                  _topList('ورودی‌ها', data.topIn, _green),
                  const SizedBox(height: 14),
                ],
                if (data.topOut.isNotEmpty) _topList('خروجی‌ها', data.topOut, _orange),
              ],
            ),
    );
  }

  Widget _topList(String title, List<KeeperProductUnits> items, Color color) {
    final maxV = items.fold<int>(1, (m, i) => math.max(m, i.units));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatNumber(item.units),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: item.units / maxV,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.8)),
              ),
            ),
          ),
      ],
    );
  }

  // ── فید فعالیت‌های اخیر ──
  Widget _activityCard(KeeperReportsData data) {
    final filtered = data.recent.where(_matchesFeed).toList();
    return _card(
      title: 'فعالیت‌های اخیر',
      subtitle: _scope == 'mine' ? 'عملکردهای خود شما' : 'عملکرد همهٔ انباردارها',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _feedChip('همه', null),
                _feedChip('ورود کالا', 'in'),
                _feedChip('خروج کالا', 'out'),
                _feedChip('سفارش‌ها', 'order'),
                _feedChip('جابه‌جایی', 'transfer'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            const _EmptyBox('فعالیتی در این بازه ثبت نشده')
          else
            ...filtered.take(20).map(_activityTile),
        ],
      ),
    );
  }

  bool _matchesFeed(KeeperActivityItem item) {
    switch (_feedType) {
      case 'in':
        return item.type == 'product_checkin' || item.type == 'return_received';
      case 'out':
        return item.type == 'order_shipped' || item.type == 'product_exit';
      case 'order':
        return item.type == 'order_created' ||
            item.type == 'order_updated' ||
            item.type == 'order_deleted' ||
            item.type == 'order_completed';
      case 'transfer':
        return item.type == 'product_transfer';
      default:
        return true;
    }
  }

  Widget _feedChip(String label, String? value) {
    final selected = _feedType == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _feedType = value),
        labelStyle: TextStyle(
          color: selected ? _green : Colors.white70,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: _green.withValues(alpha: 0.15),
        backgroundColor: _bg,
        side: BorderSide(
          color: selected
              ? _green.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _activityTile(KeeperActivityItem item) {
    final style = _activityStyle(item.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: style.$2.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(style.$1, color: style.$2, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDateTime(item.createdAt),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _activityStyle(String type) {
    switch (type) {
      case 'product_checkin':
        return (Icons.inventory_2_rounded, _green);
      case 'return_received':
        return (Icons.replay_rounded, _orange);
      case 'order_shipped':
        return (Icons.local_shipping_rounded, _blue);
      case 'product_transfer':
        return (Icons.swap_horiz_rounded, _purple);
      case 'product_exit':
        return (Icons.exit_to_app_rounded, _orange);
      case 'order_created':
        return (Icons.add_box_rounded, _blue);
      case 'order_updated':
        return (Icons.edit_rounded, _blue);
      case 'order_deleted':
        return (Icons.delete_rounded, _red);
      case 'order_completed':
        return (Icons.check_circle_rounded, _green);
      default:
        return (Icons.circle_rounded, Colors.white38);
    }
  }

  String _formatDateTime(String iso) {
    try {
      final j = Jalali.fromDateTime(DateTime.parse(iso).toLocal());
      final h = j.hour.toString().padLeft(2, '0');
      final m = j.minute.toString().padLeft(2, '0');
      return faDigits('${j.month}/${j.day} $h:$m');
    } catch (_) {
      return '';
    }
  }

  // ── کارت مشترک ──
  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BarGroup {
  final String label;
  int inUnits;
  int outUnits;
  final int week; // فقط برای گروه‌بندی هفتگی
  _BarGroup({
    required this.label,
    required this.inUnits,
    required this.outUnits,
    this.week = -1,
  });
}

/// نقاش نمودار میله‌ای گروهی (ورود/خروج) — بدون کتابخانهٔ خارجی
class _DailyBarPainter extends CustomPainter {
  final List<_BarGroup> groups;
  final Color inColor;
  final Color outColor;

  _DailyBarPainter({
    required this.groups,
    required this.inColor,
    required this.outColor,
  });

  static const _leftPad = 38.0;
  static const _bottomPad = 22.0;
  static const _topPad = 8.0;
  static const _gridColor = Color(0x14FFFFFF);

  double _niceStep(double raw) {
    if (raw <= 0) return 1;
    final pow10 = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final n = raw / pow10;
    final f = n <= 1 ? 1.0 : n <= 2 ? 2.0 : n <= 5 ? 5.0 : 10.0;
    return f * pow10;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = groups.fold<int>(0, (m, g) => math.max(m, math.max(g.inUnits, g.outUnits)));
    if (maxV <= 0 || groups.isEmpty) return;

    final plotW = size.width - _leftPad - 6;
    final plotH = size.height - _topPad - _bottomPad;
    final plotLeft = _leftPad;
    final plotBottom = _topPad + plotH;

    final step = _niceStep(maxV / 4.0);
    final textStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.35),
      fontSize: 9,
    );

    // خطوط شبکه + برچسب محور Y
    for (var v = 0.0; v <= maxV + 0.001; v += step) {
      final y = plotBottom - (v / maxV) * plotH;
      canvas.drawLine(
        Offset(plotLeft, y),
        Offset(plotLeft + plotW, y),
        Paint()..color = _gridColor..strokeWidth = 1,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: faDigits(v.toInt().toString()),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plotLeft - tp.width - 5, y - tp.height / 2));
    }

    // میله‌ها
    final slotW = plotW / groups.length;
    final barW = math.min(9.0, slotW * 0.3);
    final showValues = groups.length <= 15;
    final valueStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.55),
      fontSize: 8.5,
    );

    for (var i = 0; i < groups.length; i++) {
      final g = groups[i];
      final cx = plotLeft + slotW * i + slotW / 2;

      void bar(double x, int value, Color color) {
        if (value <= 0) return;
        final h = (value / maxV) * plotH;
        final top = plotBottom - h;
        final rrect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, top, barW, h),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(rrect, Paint()..color = color);
        if (showValues) {
          final tp = TextPainter(
            text: TextSpan(text: faDigits('$value'), style: valueStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(x + barW / 2 - tp.width / 2, top - tp.height - 2),
          );
        }
      }

      bar(cx - barW - 1.5, g.inUnits, inColor);
      bar(cx + 1.5, g.outUnits, outColor);
    }

    // برچسب محور X — هر چند گروه یکی
    final labelEvery = math.max(1, (groups.length / 8).ceil());
    final xStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.45),
      fontSize: 9,
    );
    for (var i = 0; i < groups.length; i++) {
      if (i % labelEvery != 0 && i != groups.length - 1) continue;
      final cx = plotLeft + slotW * i + slotW / 2;
      final tp = TextPainter(
        text: TextSpan(text: groups[i].label, style: xStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(cx - tp.width / 2, plotBottom + 5),
      );
    }
  }

  @override
  bool shouldRepaint(_DailyBarPainter oldDelegate) =>
      oldDelegate.groups != groups ||
      oldDelegate.inColor != inColor ||
      oldDelegate.outColor != outColor;
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;
  const _EmptyBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.5),
      ),
    );
  }
}