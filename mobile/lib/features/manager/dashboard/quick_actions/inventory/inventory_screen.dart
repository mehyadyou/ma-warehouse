import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_error.dart';
import '../../../../../shared/utils/numbers.dart';
import '../../../../../shared/widgets/inventory_product_cards.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/manager_inventory_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _card = Color(0xFF1E2128);
const _green = Color(0xFF4ADE80);
const _blue = Color(0xFF60A5FA);

class ManagerInventoryScreen extends ConsumerStatefulWidget {
  const ManagerInventoryScreen({super.key});

  @override
  ConsumerState<ManagerInventoryScreen> createState() =>
      _ManagerInventoryScreenState();
}

class _ManagerInventoryScreenState
    extends ConsumerState<ManagerInventoryScreen> {
  static const _pageSize = 50;

  late final ManagerApiService _api = ref.read(managerApiServiceProvider);

  ManagerInventoryModel? _data;
  bool _loading = true;
  String? _error;
  String _query = '';
  bool _onlyInStock = false;

  /// انبار انتخاب‌شده (null = همهٔ انبارها)
  String? _warehouseId;

  /// گزینه‌های چیپ انبار — از پاسخ «همهٔ انبارها» گرفته می‌شود
  List<_WhOpt> _warehouseOptions = [];

  Timer? _debounce;
  int _searchSeq = 0;
  final _scrollCtrl = ScrollController();

  Map<String, Color> _productColors = {};

  /// صفحه‌های بعدی — صفحهٔ اول مستقیماً از API با فیلترهای جاری می‌آید
  List<ManagerProductRowModel> _extraProducts = [];
  int _nextPage = 2;
  bool _hasMore = false;
  bool _loadingMore = false;
  String? _loadMoreError;

  List<ManagerProductRowModel> get _products => _data?.products ?? const [];
  List<WarehouseStockRowModel> get _warehouses => _data?.warehouses ?? const [];
  List<ManagerProductRowModel> get _visibleProducts => [
    ..._products,
    ..._extraProducts,
  ];

  int get _totalUnits =>
      _visibleProducts.fold(0, (sum, p) => sum + p.totalCount.toInt());

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  void _resetPaging() {
    _extraProducts = [];
    _nextPage = 2;
    _hasMore = false;
    _loadMoreError = null;
  }

  Future<void> _load() async {
    final seq = ++_searchSeq;
    setState(() {
      _loading = _data == null;
      _error = null;
      _resetPaging();
    });
    try {
      final data = await _api.getManagerInventory(
        page: 1,
        pageSize: _pageSize,
        q: _query.trim().isEmpty ? null : _query,
        onlyInStock: _onlyInStock,
        warehouseId: _warehouseId,
      );
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _data = data;
        _hasMore = data.hasMore;
        _buildColors();
        _loading = false;
        if (_warehouseId == null) {
          _warehouseOptions = data.warehouses
              .map(
                (w) =>
                    _WhOpt(w.warehouseId ?? '', (w.warehouseName ?? '').trim()),
              )
              .where((o) => o.name.isNotEmpty)
              .toList();
        }
      });
    } catch (e) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _loading = false;
        _error = friendlyError(e);
      });
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    setState(() {
      _query = v;
      _resetPaging();
      _error = null;
    });
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _load();
    });
  }

  void _toggleOnlyInStock() {
    setState(() => _onlyInStock = !_onlyInStock);
    _load();
  }

  void _selectWarehouse(String? id) {
    if (id == _warehouseId) return;
    setState(() {
      _warehouseId = id;
      _resetPaging();
      _error = null;
    });
    _load();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    setState(() {
      _loadingMore = true;
      _loadMoreError = null;
    });
    try {
      final res = await _api.getManagerInventory(
        page: _nextPage,
        pageSize: _pageSize,
        q: _query.trim().isEmpty ? null : _query,
        onlyInStock: _onlyInStock,
        warehouseId: _warehouseId,
      );
      if (!mounted) return;
      setState(() {
        _extraProducts = [..._extraProducts, ...res.products];
        _nextPage++;
        _hasMore = res.hasMore;
        _buildColors();
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _loadMoreError = 'خطا در بارگذاری بیشتر — لمس برای تلاش مجدد';
      });
    }
  }

  Future<void> _refresh() async {
    await _load();
  }

  void _buildColors() {
    final map = <String, Color>{};
    for (var i = 0; i < _visibleProducts.length; i++) {
      final pid = _visibleProducts[i].productId ?? '';
      if (pid.isEmpty) continue;
      map[pid] = inventoryPalette[i % inventoryPalette.length];
    }
    _productColors = map;
  }

  Color _colorFor(String? productId) => _productColors[productId] ?? _blue;

  /// تفکیک انباری صفحهٔ اول (آیتم‌های هر انبار با فیلترهای جاری هماهنگ است)
  Map<String, List<InventoryWhRow>> get _breakdown {
    final map = <String, List<InventoryWhRow>>{};
    for (final w in _warehouses) {
      final wname = w.warehouseName ?? '';
      for (final it in w.items) {
        final pid = it.productId ?? '';
        if (pid.isEmpty) continue;
        map.putIfAbsent(pid, () => []).add(InventoryWhRow(wname, it.count));
      }
    }
    return map;
  }

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
        title: const Text(
          'موجودی سیستم',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFF94A3B8),
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _load,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: _green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }

    final productCount = _visibleProducts.length;
    final hasFooter = _hasMore || _loadingMore || _loadMoreError != null;
    final warehouses = _warehouses;
    final showWarehouses = _warehouseId == null;
    final itemCount =
        1 +
        productCount +
        (hasFooter ? 1 : 0) +
        (showWarehouses ? 1 + warehouses.length : 0);

    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) return _buildProductsHeader();

          // ─── محصولات ───
          if (index <= productCount) {
            final i = index - 1;
            if (i == productCount) return _buildFooter();
            final p = _visibleProducts[i];
            return InventoryProductCard(
              product: p,
              breakdown: _breakdown[p.productId] ?? const [],
              unit: _unitOf(p),
              color: _colorFor(p.productId),
            );
          }

          // ─── بخش انبارها ───
          var remaining = index - productCount - (hasFooter ? 1 : 0) - 1;
          if (remaining == 0) return _buildWarehouseTitle();
          remaining -= 1;
          if (remaining >= 0 && remaining < warehouses.length) {
            return _WarehouseCard(
              warehouse: warehouses[remaining],
              colorFor: _colorFor,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductsHeader() {
    final data = _data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── انتخاب انبار ───
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _warehouseOptions.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final opt = index == 0 ? null : _warehouseOptions[index - 1];
              return _WarehouseChip(
                label: opt?.name ?? 'همهٔ انبارها',
                active: opt == null
                    ? _warehouseId == null
                    : _warehouseId == opt.id,
                onTap: () => _selectWarehouse(opt?.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ─── خلاصه ───
        Row(
          children: [
            InventorySummaryChip(
              label: 'محصول',
              value: faDigits((data?.total ?? 0).toString()),
              color: _green,
            ),
            const SizedBox(width: 8),
            InventorySummaryChip(
              label: 'واحد نمایش',
              value: formatNumber(_totalUnits),
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
                onChanged: _onSearchChanged,
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
                          onPressed: () => _onSearchChanged(''),
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
            InventoryFilterPill(
              label: 'فقط موجودی',
              active: _onlyInStock,
              onTap: _toggleOnlyInStock,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ─── هشدار محصولات بیشتر ───
        if (data != null && _visibleProducts.length < data.total)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'و ${faDigits((data.total - _visibleProducts.length).toString())} محصول دیگر — برای نمایش بیشتر به پایین بروید',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11.5,
              ),
            ),
          ),

        // ─── حالت خالی ───
        if (_visibleProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _query.trim().isEmpty && !_onlyInStock
                  ? 'موجودی ثبت نشده'
                  : 'محصولی یافت نشد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _green),
          ),
        ),
      );
    }
    if (_loadMoreError != null) {
      return GestureDetector(
        onTap: _loadMore,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Center(
            child: Text(
              _loadMoreError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildWarehouseTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'موجودی انبارها',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (_warehouses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'هنوز هیچ انباری ساخته نشده',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
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
    final totalItems = warehouse.totalItems;

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
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warehouse_rounded, color: _green, size: 22),
          ),
          title: Text(
            '${warehouse.warehouseName ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${faDigits(totalCount.toString())} واحد',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
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
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'موجودی در این انبار ثبت نشده',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              _BarChart(
                data: items
                    .map(
                      (i) => {
                        'name': i.name ?? '',
                        'count': i.count.toInt(),
                        'color': colorFor(i.productId),
                      },
                    )
                    .toList(),
              ),
              if (totalItems > items.length) ...[
                const SizedBox(height: 8),
                Text(
                  'و ${faDigits((totalItems - items.length).toString())} محصول دیگر (نمایش ۵۰ تای برتر)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
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
    final maxCount = data.fold<int>(
      0,
      (m, e) => math.max(m, _asInt(e['count'])),
    );

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
                    faDigits(count.toString()),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
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
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9.5,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhOpt {
  const _WhOpt(this.id, this.name);

  final String id;
  final String name;
}

class _WarehouseChip extends StatelessWidget {
  const _WarehouseChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? _green.withValues(alpha: 0.14) : _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _green : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? _green : Colors.white.withValues(alpha: 0.6),
            fontSize: 12.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
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
