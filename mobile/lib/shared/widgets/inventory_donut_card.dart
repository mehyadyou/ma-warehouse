import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/numbers.dart';

/// آیتم موجودی برای نمودار دایره‌ای — هر محصول یک قطاع با رنگ خودش
class InventoryItem {
  final String name;
  final int count;
  final String unit;
  final Color color;
  const InventoryItem({
    required this.name,
    required this.count,
    this.unit = 'عدد',
    required this.color,
  });
}

const _otherColor = Color(0xFF64748B);

/// سقف قطاع‌های دونات: با هزاران محصول هزاران drawArc باعث لگ می‌شود.
/// فقط [cap] قطاع برتر می‌ماند و بقیه در یک قطاع «سایر» جمع می‌شوند.
List<InventoryItem> cappedDonutItems(
  List<InventoryItem> items, {
  int cap = 60,
}) {
  if (items.length <= cap) return items;
  final top = items.take(cap).toList();
  final rest = items.skip(cap);
  final restCount = rest.fold<int>(0, (sum, i) => sum + i.count);
  if (restCount <= 0) return top;
  final restUnit = rest
      .firstWhere((i) => i.unit.trim().isNotEmpty, orElse: () => top.first)
      .unit;
  return [
    ...top,
    InventoryItem(
      name: 'سایر',
      count: restCount,
      unit: restUnit,
      color: _otherColor,
    ),
  ];
}

/// آمار کنار نمودار (محصول ثبت‌شده / موجودی فعلی / مرجوعی‌ها)
class InventoryStat {
  final String label;
  final String value;
  final Color color;
  const InventoryStat({
    required this.label,
    required this.value,
    required this.color,
  });
}

const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);

/// کارت نمودار دایره‌ای موجودی — بخش‌بندی‌شده با انتخاب محصول.
/// بدون انتخاب: هر محصول یک قطاع از حلقه به‌اندازهٔ سهمش از کل؛ مرکز = موجودی کلی.
/// با انتخاب (لمس ردیف راهنما): دور دایره فقط حلقهٔ محصول انتخاب‌شده با رنگ خودش؛
/// مرکز = عدد و نام همان محصول. لمس مجدد ردیف → برگشت به حالت کلی.
class InventoryDonutCard extends StatefulWidget {
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;
  final List<InventoryItem> items;
  final List<InventoryStat> stats;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String emptyMessage;

  const InventoryDonutCard({
    super.key,
    this.loading = false,
    this.error,
    this.onRetry,
    this.items = const [],
    this.stats = const [],
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.emptyMessage = 'موجودی ثبت نشده',
  });

  @override
  State<InventoryDonutCard> createState() => _InventoryDonutCardState();
}

class _InventoryDonutCardState extends State<InventoryDonutCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _selectedIndex;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _total => widget.items.fold<int>(0, (sum, i) => sum + i.count);

  InventoryItem? get _selected {
    final idx = _selectedIndex;
    if (idx == null || idx < 0 || idx >= widget.items.length) return null;
    return widget.items[idx];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.error != null) {
      return _stateBox(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.error!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
            if (widget.onRetry != null)
              TextButton(
                onPressed: widget.onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: _green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                ),
                child: const Text(
                  'تلاش دوباره',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }

    if (widget.loading) {
      return _stateBox(
        const Center(child: CircularProgressIndicator(color: _green)),
      );
    }

    if (widget.items.isEmpty) {
      return _stateBox(
        Center(
          child: Text(
            widget.emptyMessage,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final selected = _selected;

    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
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
                  if (widget.stats.isNotEmpty) ...[
                    Row(
                      children: [
                        for (final s in widget.stats) ...[
                          _InfoChip(
                            label: s.label,
                            value: s.value,
                            color: s.color,
                          ),
                          if (s != widget.stats.last) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (_, _) => CustomPaint(
                            painter: _DonutPainter(
                              items: widget.items,
                              selectedIndex: _selectedIndex,
                              animationValue: _animation.value,
                            ),
                            child: Center(child: _centerContent(selected)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...widget.items
                                .take(3)
                                .toList()
                                .asMap()
                                .entries
                                .map(
                                  (e) => _LegendRow(
                                    item: e.value,
                                    index: e.key,
                                    selectedIndex: _selectedIndex,
                                    total: _total,
                                    onTap: () => setState(
                                      () => _selectedIndex =
                                          _selectedIndex == e.key
                                          ? null
                                          : e.key,
                                    ),
                                  ),
                                ),
                            if (widget.items.length > 3)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _expanded = !_expanded),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _expanded
                                            ? 'نمایش کمتر'
                                            : '${widget.items.length - 3} محصول دیگر',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        _expanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_expanded && widget.items.length > 3)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 150,
                                ),
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  children: widget.items
                                      .skip(3)
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => _LegendRow(
                                          item: e.value,
                                          index: e.key + 3,
                                          selectedIndex: _selectedIndex,
                                          total: _total,
                                          onTap: () => setState(
                                            () => _selectedIndex =
                                                _selectedIndex == e.key + 3
                                                ? null
                                                : e.key + 3,
                                          ),
                                        ),
                                      )
                                      .toList(),
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
  }

  /// محتوای مرکز دایره: انتخاب‌شده → عدد+نام محصول با رنگ خودش؛ در غیر این صورت موجودی کلی
  Widget _centerContent(InventoryItem? selected) {
    if (selected != null) {
      final color = selected.color;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${formatNumber(selected.count)} ${selected.unit}',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              selected.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color.withValues(alpha: 0.75),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatNumber(_total),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'موجودی کل',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _stateBox(Widget child) {
    return Padding(
      padding: widget.padding,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

/// نقاش حلقهٔ بخش‌بندی‌شده:
/// بدون انتخاب → هر محصول یک قطاع با سهمش از کل موجودی؛
/// با انتخاب → فقط حلقهٔ کامل محصول انتخاب‌شده با رنگ خودش.
class _DonutPainter extends CustomPainter {
  final List<InventoryItem> items;
  final int? selectedIndex;
  final double animationValue;

  static const double _gap = 0.035; // شکاف بین قطاع‌ها (رادیان)
  static const double _thickness = 7.0;

  _DonutPainter({
    required this.items,
    required this.selectedIndex,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<int>(0, (s, i) => s + i.count);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - _thickness / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final selected =
        (selectedIndex != null &&
            selectedIndex! >= 0 &&
            selectedIndex! < items.length)
        ? items[selectedIndex!]
        : null;

    if (selected != null) {
      // فقط حلقهٔ محصول انتخاب‌شده
      final sweep = math.max(0.001, math.pi * 2 * animationValue - _gap);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = selected.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _thickness
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // قطاع‌های همهٔ محصولات به اندازهٔ سهمشان از کل
      var start = -math.pi / 2;
      for (final item in items) {
        if (item.count <= 0) continue;
        final share = item.count / total;
        final sweep = math.max(
          0.001,
          share * math.pi * 2 * animationValue - _gap,
        );
        canvas.drawArc(
          rect,
          start + _gap / 2,
          sweep,
          false,
          Paint()
            ..color = item.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = _thickness
            ..strokeCap = StrokeCap.round,
        );
        start += share * math.pi * 2 * animationValue;
      }
    }

    // قاب ظریف دور نمودار
    canvas.drawCircle(
      center,
      radius + _thickness / 2 - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.06),
    );
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.items != items;
}

class _LegendRow extends StatelessWidget {
  final InventoryItem item;
  final int index;
  final int? selectedIndex;
  final int total;
  final VoidCallback onTap;

  const _LegendRow({
    required this.item,
    required this.index,
    required this.selectedIndex,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final percent = total > 0 ? (item.count / total * 100) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: item.color.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${formatNumber(item.count)} ${item.unit}',
              style: TextStyle(
                color: item.color,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${faDigits(percent.toStringAsFixed(1))}٪',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 9.5,
              ),
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
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
