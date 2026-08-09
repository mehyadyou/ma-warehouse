import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/manager_api_service.dart';
import '../../providers/manager_api_provider.dart';
import '../../models/manager_inventory_model.dart';
import '../../models/product_models_model.dart';

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

class _WhRow {
  final String warehouseName;
  final num count;
  const _WhRow(this.warehouseName, this.count);
}

class ProductInventoryScreen extends ConsumerStatefulWidget {
  const ProductInventoryScreen({super.key});

  @override
  ConsumerState<ProductInventoryScreen> createState() =>
      _ProductInventoryScreenState();
}

class _ProductInventoryScreenState
    extends ConsumerState<ProductInventoryScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  ManagerInventoryModel? _data;
  bool _loading = true;
  String _query = '';
  bool _onlyInStock = false;

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
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<ManagerProductRowModel> get _visibleProducts {
    final q = _query.trim();
    final products = _data?.products ?? const <ManagerProductRowModel>[];
    return products.where((p) {
      if (_onlyInStock && p.totalCount.toInt() <= 0) return false;
      if (q.isEmpty) return true;
      return (p.name ?? '').contains(q);
    }).toList();
  }

  Map<String, List<_WhRow>> get _breakdown {
    final map = <String, List<_WhRow>>{};
    for (final w in _data?.warehouses ?? const <WarehouseStockRowModel>[]) {
      final wname = w.warehouseName ?? '';
      for (final it in w.items) {
        final pid = it.productId ?? '';
        if (pid.isEmpty) continue;
        map.putIfAbsent(pid, () => []).add(_WhRow(wname, it.count));
      }
    }
    return map;
  }

  int get _totalUnits => (_data?.products ?? const <ManagerProductRowModel>[])
      .fold(0, (sum, p) => sum + p.totalCount.toInt());

  String _unitOf(ManagerProductRowModel p) {
    final unit = (p.unit ?? '').trim();
    return unit.isEmpty ? 'عدد' : unit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('موجودی کل', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                  // ─── خلاصه ───
                  Row(
                    children: [
                      _SummaryChip(
                        label: 'محصول',
                        value: '${_data?.products.length ?? 0}',
                        color: _green,
                      ),
                      const SizedBox(width: 8),
                      _SummaryChip(
                        label: 'واحد موجودی',
                        value: '$_totalUnits',
                        color: _blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ─── جستجو و فیلتر ───
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'جستجوی محصول…',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 20,
                            ),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: Colors.white.withValues(alpha: 0.4),
                                    ),
                                    onPressed: () =>
                                        setState(() => _query = ''),
                                  ),
                            filled: true,
                            fillColor: _surface,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'فقط موجودی',
                        active: _onlyInStock,
                        onTap: () =>
                            setState(() => _onlyInStock = !_onlyInStock),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── لیست محصولات ───
                  if (_visibleProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _query.trim().isEmpty
                            ? 'موجودی ثبت نشده'
                            : 'محصولی یافت نشد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ..._visibleProducts.asMap().entries.map(
                          (e) => _ProductCard(
                            product: e.value,
                            breakdown: _breakdown[e.value.productId] ?? const [],
                            unit: _unitOf(e.value),
                            color: _palette[e.key % _palette.length],
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

class _ProductCard extends ConsumerStatefulWidget {
  final ManagerProductRowModel product;
  final List<_WhRow> breakdown;
  final String unit;
  final Color color;

  const _ProductCard({
    required this.product,
    required this.breakdown,
    required this.unit,
    required this.color,
  });

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  ProductModelsData? _data;
  bool _loading = false;
  bool _loaded = false;

  Future<void> _load() async {
    if (_loading || _loaded) return;
    setState(() => _loading = true);
    try {
      final data = await ref
          .read(managerApiServiceProvider)
          .getProductModels(widget.product.productId ?? '');
      if (!mounted) return;
      setState(() {
        _data = data;
        _loaded = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _unit {
    final unit = _data?.product?.unit;
    if (unit != null && unit.trim().isNotEmpty) return unit.trim();
    final fallback = widget.unit.trim();
    return fallback.isEmpty ? 'عدد' : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.product.totalCount.toInt();
    final hasStock = count > 0;
    final color = widget.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: _surface,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              iconColor: color,
              collapsedIconColor: color,
              onExpansionChanged: (expanded) {
                if (expanded) _load();
              },
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: hasStock ? 0.15 : 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: color.withValues(alpha: hasStock ? 1 : 0.35),
                  size: 20,
                ),
              ),
              title: Text(
                widget.product.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasStock
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '$count $_unit',
                  style: TextStyle(
                    color: hasStock
                        ? color
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              children: [_children(color)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _children(Color color) {
    if (_loading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _green),
          ),
        ),
      );
    }

    if (!_loaded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'بارگذاری مدل‌ها ناموفق بود',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12.5,
                ),
              ),
            ),
            TextButton(
              onPressed: _load,
              child: const Text('تلاش دوباره', style: TextStyle(color: _green, fontSize: 12)),
            ),
          ],
        ),
      );
    }

    final models = _data?.models ?? const <ProductModelStockModel>[];
    if (models.isEmpty) {
      if (widget.breakdown.isNotEmpty) {
        // محصول بدون مدل (موجودی لِگاسی) — تفکیک انباری همان‌جا نمایش داده می‌شود
        return _WarehouseRows(rows: widget.breakdown, unit: _unit);
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'مدلی ثبت نشده',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12.5,
          ),
        ),
      );
    }

    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: models.asMap().entries.map(
          (e) => _ModelRow(
            model: e.value,
            unit: _unit,
            modelColor: _palette[(e.key + 1) % _palette.length],
          ),
        ).toList(),
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  final ProductModelStockModel model;
  final String unit;
  final Color modelColor;

  const _ModelRow({
    required this.model,
    required this.unit,
    required this.modelColor,
  });

  @override
  Widget build(BuildContext context) {
    final count = model.count.toInt();
    final hasStock = count > 0;
    final packageType = (model.packageType ?? '').trim();
    final unitsPerBox = model.unitsPerBox;
    final infoParts = <String>[
      if (packageType.isNotEmpty) packageType,
      if (unitsPerBox != null && unitsPerBox > 0) '$unitsPerBox در هر جعبه',
    ];
    final subtitle = infoParts.isEmpty ? null : infoParts.join(' • ');

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        dense: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        iconColor: modelColor,
        collapsedIconColor: modelColor,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: modelColor.withValues(alpha: hasStock ? 0.15 : 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.category_rounded,
            color: modelColor.withValues(alpha: hasStock ? 1 : 0.35),
            size: 17,
          ),
        ),
        title: Text(
          model.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hasStock
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10.5,
                  ),
                ),
              ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: (hasStock ? modelColor : Colors.white).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count $unit',
            style: TextStyle(
              color: hasStock
                  ? modelColor
                  : Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        children: [
          if (model.warehouses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'موجودی در انبارها ثبت نشده',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: model.warehouses
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warehouse_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                w.warehouseName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${w.count.toInt()} $unit',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _WarehouseRows extends StatelessWidget {
  final List<_WhRow> rows;
  final String unit;

  const _WarehouseRows({
    required this.rows,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows
            .map(
              (w) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Icon(
                      Icons.warehouse_rounded,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        w.warehouseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    Text(
                      '${w.count.toInt()} $unit',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? _green.withValues(alpha: 0.15)
              : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? _green.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            if (active) ...[
              const Icon(Icons.check_circle_rounded, color: _green, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: active ? _green : Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
