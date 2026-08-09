import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/manager_inventory_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _card = Color(0xFF1E2128);
const _green = Color(0xFF4ADE80);
const _blue = Color(0xFF60A5FA);

const _palette = <Color>[
  Color(0xFF4ADE80),
  Color(0xFFFB923C),
  Color(0xFF60A5FA),
  Color(0xFFF472B6),
  Color(0xFFA78BFA),
  Color(0xFFFBBF24),
  Color(0xFF34D399),
  Color(0xFF2DD4BF),
];

class ManagerInventoryScreen extends ConsumerStatefulWidget {
  const ManagerInventoryScreen({super.key});

  @override
  ConsumerState<ManagerInventoryScreen> createState() => _ManagerInventoryScreenState();
}

class _ManagerInventoryScreenState extends ConsumerState<ManagerInventoryScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  ManagerInventoryModel? _data;
  Map<String, Color> _productColors = {};
  bool _loading = true;

  List<ManagerProductRowModel> get _products {
    return _data?.products ?? const [];
  }

  List<WarehouseStockRowModel> get _warehouses {
    return _data?.warehouses ?? const [];
  }

  int get _totalUnits => _products.fold(0, (sum, p) => sum + p.totalCount.toInt());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getManagerInventory();
      if (!mounted) return;
      setState(() {
        _data = data;
        _buildColors();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _buildColors() {
    final map = <String, Color>{};
    for (var i = 0; i < _products.length; i++) {
      final pid = _products[i].productId ?? '';
      if (pid.isEmpty) continue;
      map[pid] = _palette[i % _palette.length];
    }
    _productColors = map;
  }

  Color _colorFor(String? productId) =>
      _productColors[productId] ?? _blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('موجودی سیستم', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : RefreshIndicator(
              color: _green,
              backgroundColor: _surface,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // ── نمودار عمودی کل محصولات ──
                  Container(
                    padding: const EdgeInsets.all(16),
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
                            const Expanded(
                              child: Text(
                                'موجودی هر محصول در تمام انبارها',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                            _MiniChip(label: '${_products.length} محصول', color: _green),
                            const SizedBox(width: 6),
                            _MiniChip(label: '$_totalUnits واحد', color: _blue),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_products.isEmpty)
                          SizedBox(
                            height: 90,
                            child: Center(child: Text('هیچ محصولی ثبت نشده', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13))),
                          )
                        else
                          _BarChart(
                            data: _products
                                .map((p) => {
                                      'name': p.name ?? '',
                                      'count': p.totalCount.toInt(),
                                      'color': _colorFor(p.productId),
                                    })
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── موجودی هر انبار ──
                  Text('موجودی انبارها', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (_warehouses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)),
                      child: Text('هنوز هیچ انباری ساخته نشده', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13), textAlign: TextAlign.center),
                    )
                  else
                    ..._warehouses.map((w) => _WarehouseCard(
                          warehouse: w,
                          colorFor: _colorFor,
                        )),
                ],
              ),
            ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

/// نمودار ستونی (عمودی) — ارتفاع هر ستون متناسب با موجودی نسبت به بیشترین موجودیِ همان لیست
class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  static const double _barWidth = 38;
  static const double _chartHeight = 120;

  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxCount = data.fold<int>(0, (m, e) => math.max(m, _asInt(e['count'])));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final item in data)
            _Bar(
              label: item['name'] ?? '',
              count: _asInt(item['count']),
              color: item['color'] is Color ? item['color'] as Color : _green,
              maxCount: maxCount,
              barWidth: _barWidth,
              chartHeight: _chartHeight,
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final int maxCount;
  final double barWidth;
  final double chartHeight;

  const _Bar({
    required this.label,
    required this.count,
    required this.color,
    required this.maxCount,
    required this.barWidth,
    required this.chartHeight,
  });

  @override
  Widget build(BuildContext context) {
    // فضای بالای نمودار برای نمایش عدد مقدار رزرو می‌شود
    const labelStrip = 16.0;
    final maxBarHeight = chartHeight - labelStrip;
    final barHeight = maxCount <= 0
        ? 8.0
        : math.max(8.0, (count / maxCount) * maxBarHeight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: chartHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    '$count',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 10, fontWeight: FontWeight.w700, height: 1.2),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: barWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.55), color],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: barWidth + 22),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9.5, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  final WarehouseStockRowModel warehouse;
  final Color Function(String?) colorFor;

  const _WarehouseCard({required this.warehouse, required this.colorFor});

  @override
  Widget build(BuildContext context) {
    final items = warehouse.items;
    final totalCount = warehouse.totalCount.toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: _green,
          collapsedIconColor: _green,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.warehouse_rounded, color: _green, size: 22),
          ),
          title: Text('${warehouse.warehouseName ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('$totalCount واحد', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          children: [
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12)),
                child: Text('موجودی در این انبار ثبت نشده', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13), textAlign: TextAlign.center),
              )
            else
              _BarChart(
                data: items
                    .map((i) => {
                          'name': i.name ?? '',
                          'count': i.count.toInt(),
                          'color': colorFor(i.productId),
                        })
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}