import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import '../inventory/inventory_detail_screen.dart';

const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _blue = Color(0xFF60A5FA);
const _orange = Color(0xFFFB923C);

class InventoryItem {
  final String name;
  final int count;
  final String unit;
  final Color color;
  const InventoryItem({required this.name, required this.count, this.unit = 'عدد', required this.color});
}

/// نمودار لایه‌لایه با منطق پنل مدیر:
/// هر محصول یک حلقه با ضخامت یکسان = ظرفیت ۱۰٬۰۰۰؛ پرشدگیِ رنگی = حجم فعلی، بقیهٔ حلقه خاکستری (فضای خالی)
class _DonutPainter extends CustomPainter {
  final List<InventoryItem> items;
  final double animationValue;
  final int? hoveredIndex;
  static const double _gap = 0.035; // شکاف ابتدای هر حلقه
  static const Color _track = Color(0xFF2B2F36); // خاکستری فضای خالی
  static const double _maxThickness = 7.0; // حداکثر قطر خط هر حلقه
  static const double _minCapacity = 100; // کمینهٔ سقف ظرفیت

  /// سقف ظرفیت سازگار: محصول با بیشترین موجودی، پرشدگی کامل را می‌گیرد
  /// تا اختلاف حجم بین محصولات کاملاً دیده شود
  static double capacityFor(List<InventoryItem> items) {
    final maxCount = items.fold<int>(0, (m, i) => math.max(m, i.count));
    return math.max(maxCount, _minCapacity).toDouble();
  }

  _DonutPainter({required this.items, required this.animationValue, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final n = items.length;
    if (n == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final totalThickness = outerRadius - outerRadius * 0.45;

    // ضخامت یکسان برای همهٔ حلقه‌ها — با افزایش تعداد محصولات قطر خطوط کم می‌شود
    // و قطر دایره همیشه ثابت می‌ماند (هرگز بزرگ‌تر نمی‌شود)
    final thickness = math.min(_maxThickness, totalThickness / n);
    final innerRadius = outerRadius - n * thickness;

    var innerEdge = innerRadius;
    for (int i = 0; i < n; i++) {
      final outerEdge = innerEdge + thickness;
      final isHovered = hoveredIndex == i;
      final isDimmed = hoveredIndex != null && hoveredIndex != i;
      final color = items[i].color;

      // انیمیشن پله‌ای: هر حلقه در بازهٔ زمانی خودش ظاهر می‌شود
      final p = ((animationValue * n) - i).clamp(0.0, 1.0);
      if (p <= 0) {
        innerEdge = outerEdge;
        continue;
      }

      final arcRadius = (innerEdge + outerEdge) / 2;
      final rect = Rect.fromCircle(center: center, radius: arcRadius);
      final startAngle = -math.pi / 2 + _gap * math.pi * 2 / 2;
      final trackSweep = math.max(0.001, math.pi * 2 * p - _gap * math.pi * 2);

      // پرشدگی حجم محصول نسبت به سقف ظرفیتِ سازگار
      final fraction = (items[i].count / capacityFor(items)).clamp(0.0, 1.0);
      final fillSweep = math.max(0.001, math.pi * 2 * fraction * p - _gap * math.pi * 2);

      // ─── مسیر خاکستری (فضای خالی) ───
      canvas.drawArc(
        rect,
        startAngle,
        trackSweep,
        false,
        Paint()
          ..color = _track
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round,
      );

      // ─── پرشدگی رنگی (حجم داخل انبار) ───
      canvas.drawArc(
        rect,
        startAngle,
        fillSweep,
        false,
        Paint()
          ..color = isDimmed ? color.withValues(alpha: 0.25) : color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness + (isHovered ? 1.6 : 0)
          ..strokeCap = StrokeCap.round,
      );

      // ─── هایلایت حلقهٔ انتخاب‌شده ───
      if (isHovered && p >= 1.0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerEdge),
          -math.pi / 2,
          math.pi * 2 - _gap * math.pi * 2,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: innerEdge),
          -math.pi / 2,
          math.pi * 2 - _gap * math.pi * 2,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }

      innerEdge = outerEdge;
    }

    // ─── قاب ظریف دور نمودار ───
    canvas.drawCircle(
      center,
      outerRadius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.06),
    );
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.hoveredIndex != hoveredIndex ||
      oldDelegate.items != items;
}

class InventoryChartCard extends ConsumerStatefulWidget {
  const InventoryChartCard({super.key});

  @override
  ConsumerState<InventoryChartCard> createState() => _InventoryChartCardState();
}

class _InventoryChartCardState extends ConsumerState<InventoryChartCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredIndex;
  bool _expanded = false;

  final List<Color> _colors = const [
    Color(0xFF4ADE80),
    Color(0xFFFB923C),
    Color(0xFF60A5FA),
    Color(0xFFF472B6),
    Color(0xFFA78BFA),
    Color(0xFFFBBF24),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(inventorySummaryProvider);

    return summaryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: SizedBox(
          height: 110,
          child: Center(child: CircularProgressIndicator(color: _green)),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 110,
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)),
          child: Center(child: Text('خطا در بارگذاری', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13))),
        ),
      ),
      data: (summary) {
        final data = summary.products;

        if (data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 110,
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text('موجودی ثبت نشده', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13))),
            ),
          );
        }

        final items = data.asMap().entries.map((entry) {
          final unit = (entry.value.unit ?? '').trim();
          return InventoryItem(
            name: entry.value.name,
            count: entry.value.totalCount,
            unit: unit.isNotEmpty ? unit : 'عدد',
            color: _colors[entry.key % _colors.length],
          );
        }).toList();

        final totalRegisteredProducts = summary.totalProducts.toInt();
        final totalInventoryUnits = summary.totalUnits.toInt();
        final returnedUnits = summary.returnedUnits.toInt();
        final capacity = _DonutPainter.capacityFor(items);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryDetailScreen()),
            ),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _InfoChip(
                            label: 'محصول ثبت شده',
                            value: '$totalRegisteredProducts',
                            color: _green,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            label: 'موجودی فعلی',
                            value: '$totalInventoryUnits',
                            color: _blue,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            label: 'مرجوعی‌ها',
                            value: '$returnedUnits',
                            color: _orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (_, __) => CustomPaint(
                                painter: _DonutPainter(items: items, animationValue: _animation.value, hoveredIndex: _hoveredIndex),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('$totalInventoryUnits', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1)),
                                      const SizedBox(height: 2),
                                      Text('موجودی کل', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9.5, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...items.take(3).toList().asMap().entries.map(
                                      (e) => _LegendRow(
                                        item: e.value,
                                        index: e.key,
                                        hoveredIndex: _hoveredIndex,
                                        capacity: capacity,
                                        onTap: () => setState(
                                          () => _hoveredIndex =
                                              _hoveredIndex == e.key ? null : e.key,
                                        ),
                                      ),
                                    ),
                                if (items.length > 3)
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _expanded = !_expanded),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _expanded
                                                ? 'نمایش کمتر'
                                                : '${items.length - 3} محصول دیگر',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.5),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Icon(
                                            _expanded
                                                ? Icons.keyboard_arrow_up_rounded
                                                : Icons.keyboard_arrow_down_rounded,
                                            size: 18,
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_expanded && items.length > 3)
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 150),
                                    child: ListView(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      children: items.skip(3).toList().asMap().entries.map(
                                            (e) => _LegendRow(
                                              item: e.value,
                                              index: e.key + 3,
                                              hoveredIndex: _hoveredIndex,
                                              capacity: capacity,
                                              onTap: () => setState(
                                                () => _hoveredIndex =
                                                    _hoveredIndex == e.key + 3
                                                        ? null
                                                        : e.key + 3,
                                              ),
                                            ),
                                          ).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  final InventoryItem item;
  final int index;
  final int? hoveredIndex;
  final double capacity;
  final VoidCallback onTap;

  const _LegendRow({
    required this.item,
    required this.index,
    required this.hoveredIndex,
    required this.capacity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: hoveredIndex == index ? item.color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('${item.count} ${item.unit}', style: TextStyle(color: item.color, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Text(
              '${(item.count / capacity * 100).toStringAsFixed(1)}٪',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10.5)),
          ],
        ),
      ),
    );
  }
}
