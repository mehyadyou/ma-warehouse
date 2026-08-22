import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_error.dart';
import '../../../../../shared/utils/numbers.dart';
import '../../../../../shared/widgets/inventory_product_cards.dart';
import '../../data/manager_api_service.dart';
import '../../providers/manager_api_provider.dart';
import '../../models/manager_inventory_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _blue = Color(0xFF60A5FA);

class ProductInventoryScreen extends ConsumerStatefulWidget {
  const ProductInventoryScreen({super.key});

  @override
  ConsumerState<ProductInventoryScreen> createState() =>
      _ProductInventoryScreenState();
}

class _ProductInventoryScreenState
    extends ConsumerState<ProductInventoryScreen> {
  static const _pageSize = 50;

  late final ManagerApiService _api = ref.read(managerApiServiceProvider);

  ManagerInventoryModel? _data;
  bool _loading = true;
  String? _error;
  String _query = '';
  bool _onlyInStock = false;

  Timer? _debounce;
  int _searchSeq = 0;
  final _scrollCtrl = ScrollController();

  /// صفحه‌های بعدی — صفحهٔ اول مستقیماً از API با فیلترهای جاری می‌آید
  List<ManagerProductRowModel> _extraProducts = [];
  int _nextPage = 2;
  bool _hasMore = false;
  bool _loadingMore = false;
  String? _loadMoreError;

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
      );
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _data = data;
        _hasMore = data.hasMore;
        _loading = false;
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
    await _load();
  }

  List<ManagerProductRowModel> get _visibleProducts => [
    ...?_data?.products,
    ..._extraProducts,
  ];

  /// تفکیک انباری صفحهٔ اول (آیتم‌های هر انبار با فیلترهای جاری هماهنگ است)
  Map<String, List<InventoryWhRow>> get _breakdown {
    final map = <String, List<InventoryWhRow>>{};
    for (final w in _data?.warehouses ?? const <WarehouseStockRowModel>[]) {
      final wname = w.warehouseName ?? '';
      for (final it in w.items) {
        final pid = it.productId ?? '';
        if (pid.isEmpty) continue;
        map.putIfAbsent(pid, () => []).add(InventoryWhRow(wname, it.count));
      }
    }
    return map;
  }

  int get _totalUnits =>
      _visibleProducts.fold(0, (sum, p) => sum + p.totalCount.toInt());

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
                  side: const BorderSide(color: _green, width: 1.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('تلاش دوباره'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: _refresh,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ─── خلاصه ───
          Row(
            children: [
              InventorySummaryChip(
                label: 'محصول',
                value: faDigits((_data?.total ?? 0).toString()),
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
          if (_data != null && _visibleProducts.length < (_data!.total))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'و ${faDigits((_data!.total - _visibleProducts.length).toString())} محصول دیگر — برای نمایش بیشتر به پایین بروید',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11.5,
                ),
              ),
            ),

          // ─── لیست محصولات ───
          if (_visibleProducts.isEmpty)
            Container(
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
            )
          else
            ..._visibleProducts.asMap().entries.map(
              (e) => InventoryProductCard(
                product: e.value,
                breakdown: _breakdown[e.value.productId] ?? const [],
                unit: _unitOf(e.value),
                color: inventoryPalette[e.key % inventoryPalette.length],
              ),
            ),

          // ─── پاورقی صفحه‌بندی ───
          if (_hasMore || _loadingMore || _loadMoreError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _loadingMore
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _green,
                          ),
                        ),
                      ),
                    )
                  : _loadMoreError != null
                  ? GestureDetector(
                      onTap: _loadMore,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
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
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
