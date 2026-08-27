import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_inventory_model.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'package:ma_app/shared/utils/numbers.dart';

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

class _ChartBar {
  final String productId;
  final String name;
  final int count;
  final Color color;

  const _ChartBar({
    required this.productId,
    required this.name,
    required this.count,
    required this.color,
  });
}

/// محتوای مشترک «موجودی» — هم در تب داشبورد انباردار، هم در صفحهٔ کامل.
/// فقط انبارِ متصل به کاربر را نشان می‌دهد (سرویس بک‌اند از warehouseId توکن تغذیه می‌شود).
/// چیدمان: نمودار ستونی (موجودی هر محصول) + لیست محصولات که زیر هر محصول
/// تعداد موجودی مدل‌های همان محصول نمایش داده می‌شود.
class InventoryListView extends ConsumerStatefulWidget {
  const InventoryListView({super.key});

  @override
  ConsumerState<InventoryListView> createState() => _InventoryListViewState();
}

class _InventoryListViewState extends ConsumerState<InventoryListView> {
  static const _pageSize = 50;

  String _query = '';
  bool _onlyInStock = false;
  Timer? _debounce;

  final _scrollCtrl = ScrollController();

  /// کلید هر کارت محصول برای پرش از نمودار ستونی به کارت همان محصول
  final Map<String, GlobalKey> _productKeys = {};

  /// صفحه‌های بعدی — صفحهٔ اول از provider (با فیلترها) می‌آید
  List<KeeperProductRowModel> _extraProducts = [];
  int _nextPage = 2;
  bool _hasMore = false;
  bool _loadingMore = false;
  String? _loadMoreError;

  KeeperInventoryQuery get _q =>
      KeeperInventoryQuery(query: _query, onlyInStock: _onlyInStock);

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
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

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    setState(() {
      _query = v;
      _resetPaging();
    });
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _loadMoreError = null;
    });
    try {
      final res = await ref
          .read(wkApiProvider)
          .getInventoryProducts(
            page: _nextPage,
            pageSize: _pageSize,
            q: _query.trim().isEmpty ? null : _query,
            onlyInStock: _onlyInStock,
          );
      if (!mounted) return;
      setState(() {
        _extraProducts = [..._extraProducts, ...res.products];
        _nextPage++;
        _hasMore = res.hasMore;
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
    setState(_resetPaging);
    ref.invalidate(keeperInventoryListProvider);
    try {
      await ref.read(keeperInventoryListProvider(_q).future);
    } catch (_) {
      // خطا در حالت AsyncError نمایش داده می‌شود
    }
  }

  List<KeeperProductRowModel> _visibleProducts(KeeperInventoryListModel data) =>
      [...data.products, ..._extraProducts];

  int _totalUnits(List<KeeperProductRowModel> products) =>
      products.fold(0, (sum, p) => sum + p.totalCount.toInt());

  String _unitOf(KeeperProductRowModel p) {
    final unit = (p.unit ?? '').trim();
    return unit.isEmpty ? 'عدد' : unit;
  }

  /// پرش به کارت محصول از نمودار ستونی
  void _focusProduct(String productId) {
    final ctx = _productKeys[productId]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      alignment: 0.05,
    );
  }

  List<_ChartBar> _buildBars(List<KeeperProductRowModel> products) {
    return products.asMap().entries.map((e) {
      final p = e.value;
      return _ChartBar(
        productId: p.productId ?? '',
        name: p.name ?? '',
        count: p.totalCount.toInt(),
        color: _palette[e.key % _palette.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(keeperInventoryListProvider(_q));

    return async.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _green)),
      error: (e, _) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white38,
                size: 32,
              ),
              const SizedBox(height: 10),
              Text(
                'خطا در دریافت موجودی — اتصال اینترنت را بررسی کنید',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(keeperInventoryListProvider),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: _green,
                  size: 18,
                ),
                label: const Text(
                  'تلاش دوباره',
                  style: TextStyle(color: _green),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        final visible = _visibleProducts(data);
        final totalUnits = _totalUnits(visible);
        final bars = _buildBars(visible);

        // اطمینان از وجود کلید برای هر محصول (پرش از نمودار)
        for (final p in visible) {
          _productKeys.putIfAbsent(p.productId ?? '', () => GlobalKey());
        }

        return RefreshIndicator(
          color: _green,
          backgroundColor: _surface,
          onRefresh: _refresh,
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // ─── خلاصه ───
              Row(
                children: [
                  _SummaryChip(
                    label: 'محصول',
                    value: formatNumber(data.total),
                    color: _green,
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'واحد نمایش',
                    value: formatNumber(totalUnits),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                      ),
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
                  _FilterPill(
                    label: 'فقط موجودی',
                    active: _onlyInStock,
                    onTap: () => setState(() {
                      _onlyInStock = !_onlyInStock;
                      _resetPaging();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── نمودار ستونی موجودی هر محصول ───
              if (visible.isNotEmpty) ...[
                _ChartSection(bars: bars, onBarTap: _focusProduct),
                const SizedBox(height: 6),
              ],

              // ─── لیست محصولات ───
              if (visible.isEmpty)
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
                ...visible.asMap().entries.map(
                  (e) => _ProductCard(
                    key: _productKeys[e.value.productId ?? ''],
                    product: e.value,
                    unit: _unitOf(e.value),
                    color: _palette[e.key % _palette.length],
                  ),
                ),
              const SizedBox(height: 8),
              if (_hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: _loadingMore
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: _green,
                            ),
                          )
                        : _loadMoreError != null
                        ? GestureDetector(
                            onTap: _loadMore,
                            child: Text(
                              _loadMoreError!,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Text(
                            '${formatNumber(data.total - visible.length)} محصول دیگر — برای نمایش بیشتر به پایین بروید',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// سربرگ نمودار ستونی + خود نمودار (ستون‌های تفکیک‌شده به ازای هر محصول)
class _ChartSection extends StatelessWidget {
  final List<_ChartBar> bars;
  final ValueChanged<String> onBarTap;

  const _ChartSection({required this.bars, required this.onBarTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'موجودی محصولات',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'لمس ستون → رفتن به محصول',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bar in bars)
                  _ChartBarWidget(
                    bar: bar,
                    maxCount: bars.fold<int>(
                      0,
                      (m, b) => math.max(m, b.count),
                    ),
                    onTap: () => onBarTap(bar.productId),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// یک ستون در نمودار — ارتفاع متناسب با موجودی نسبت به بیشترین موجودی
class _ChartBarWidget extends StatelessWidget {
  final _ChartBar bar;
  final int maxCount;
  final VoidCallback onTap;

  static const double _barWidth = 40;
  static const double _chartHeight = 118;

  const _ChartBarWidget({
    required this.bar,
    required this.maxCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // فضای بالای نمودار برای نمایش عدد مقدار رزرو می‌شود
    const labelStrip = 18.0;
    final maxBarHeight = _chartHeight - labelStrip;
    final barHeight = maxCount <= 0
        ? 8.0
        : math.max(8.0, (bar.count / maxCount) * maxBarHeight);
    final hasStock = bar.count > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _chartHeight,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      faDigits(bar.count.toString()),
                      style: TextStyle(
                        color: hasStock
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: _barWidth,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            bar.color.withValues(alpha: 0.45),
                            bar.color,
                          ],
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
              constraints: const BoxConstraints(maxWidth: _barWidth + 20),
              child: Text(
                bar.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasStock
                      ? Colors.white.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.28),
                  fontSize: 9.5,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// کارت محصول — سربرگ (نام + موجودی کل) + ردیف مدل‌ها با موجودی هر مدل
class _ProductCard extends StatelessWidget {
  final KeeperProductRowModel product;
  final String unit;
  final Color color;

  const _ProductCard({
    super.key,
    required this.product,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final count = product.totalCount.toInt();
    final hasStock = count > 0;
    final models = product.models;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── سربرگ محصول ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Container(
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? '',
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
                      const SizedBox(height: 3),
                      Text(
                        models.isEmpty
                            ? 'بدون مدل'
                            : '${faDigits(models.length.toString())} مدل',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${formatNumber(count)} $unit',
                  style: TextStyle(
                    color: hasStock
                        ? color
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // ─── مدل‌ها با موجودی ───
          if (models.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  for (final entry in models.asMap().entries) ...[
                    if (entry.key > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    _ModelRow(
                      model: entry.value,
                      unit: unit,
                      maxCount: models.fold<int>(
                        0,
                        (m, x) => math.max(m, x.count.toInt()),
                      ),
                      modelColor:
                          _palette[(entry.key + 1) % _palette.length],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ردیف یک مدل: نام + نوار نسبت موجودی + تعداد
class _ModelRow extends StatelessWidget {
  final KeeperProductModelStockModel model;
  final String unit;
  final int maxCount;
  final Color modelColor;

  const _ModelRow({
    required this.model,
    required this.unit,
    required this.maxCount,
    required this.modelColor,
  });

  @override
  Widget build(BuildContext context) {
    final count = model.count.toInt();
    final hasStock = count > 0;
    final ratio = maxCount <= 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: modelColor.withValues(alpha: hasStock ? 0.14 : 0.05),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.category_rounded,
              color: modelColor.withValues(alpha: hasStock ? 1 : 0.3),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              model.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasStock
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // نوار نسبت موجودی مدل
          SizedBox(
            width: 46,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.07)),
                  FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: ratio,
                    child: Container(color: modelColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${formatNumber(count)} $unit',
            style: TextStyle(
              color: hasStock
                  ? modelColor
                  : Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
          color: active ? _green.withValues(alpha: 0.15) : _surface,
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
