import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/product_model.dart';
import '../../product_management/add_product_screen.dart';
import '../../product_management/edit_product_screen.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../shared/utils/numbers.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _red = Color(0xFFF87171);

class _ModelRow {
  final String id;
  final String name;
  final double? price;
  final int? unitsPerBox;
  final String? packageType;

  const _ModelRow({
    required this.id,
    required this.name,
    this.price,
    this.unitsPerBox,
    this.packageType,
  });
}

class _ProductGroup {
  final String id;
  final String name;
  final String unit;
  final List<_ModelRow> models;

  const _ProductGroup({
    required this.id,
    required this.name,
    required this.unit,
    required this.models,
  });
}

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  final List<_ProductGroup> _groups = [];
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  int _page = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String _query = '';
  String? _error;
  int _requestSeq = 0;
  final Set<String> _expandedProductIds = {};

  static const int _pageSize = 100;
  static const int _collapsedModelLimit = 3;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
      _loadProducts();
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    final seq = ++_requestSeq;
    setState(() => _loadingMore = true);
    try {
      final result = await _api.getProductsPage(
        q: _query.isEmpty ? null : _query,
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _addUnique(_buildGroups(result.products));
        _page += 1;
        _total = result.total;
        _hasMore = _groups.length < _total;
      });
    } catch (_) {}
    if (!mounted || seq != _requestSeq) return;
    setState(() => _loadingMore = false);
  }

  Future<void> _loadProducts() async {
    final seq = ++_requestSeq;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
      _groups.clear();
    });
    try {
      final result = await _api.getProductsPage(
        q: _query.isEmpty ? null : _query,
        page: 1,
        pageSize: _pageSize,
      );
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _groups.addAll(_buildGroups(result.products));
        _page = 1;
        _total = result.total;
        _hasMore = _groups.length < _total;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _loading = false;
        _error = friendlyError(e);
      });
    }
  }

  List<_ProductGroup> _buildGroups(List<ProductModel> rawProducts) {
    final map = <String, _ProductGroup>{};
    for (final p in rawProducts) {
      if (map.containsKey(p.id)) continue;
      final unit = (p.unit ?? '').trim().isNotEmpty ? p.unit! : 'عدد';
      map[p.id] = _ProductGroup(
        id: p.id,
        name: p.name,
        unit: unit,
        models: [
          for (final m in p.models)
            _ModelRow(
              id: m.id,
              name: m.name,
              price: m.price,
              unitsPerBox: m.unitsPerBox?.toInt(),
              packageType: m.packageType,
            ),
        ],
      );
    }
    return map.values.toList();
  }

  void _addUnique(List<_ProductGroup> incoming) {
    for (final g in incoming) {
      if (!_groups.any((existing) => existing.id == g.id)) {
        _groups.add(g);
      }
    }
  }

  void _deleteProduct(String productId, String productName) async {
    final confirmed = await _confirmArchive(
      '«$productName» و تمام مدل‌هایش بایگانی خواهد شد. هیچ داده‌ای حذف نمی‌شود؛ کارتن‌ها و QRها سالم می‌مانند و هر زمان قابل بازگرداندن است.',
    );
    if (confirmed != true) return;
    try {
      await _api.deleteProduct(productId);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('بایگانی شد', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1A1D22),
            action: SnackBarAction(
              label: 'بازگردانی',
              textColor: const Color(0xFF4ADE80),
              onPressed: () async {
                try {
                  await _api.restoreProduct(productId);
                  _loadProducts();
                } catch (_) {}
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteModel(String modelId, String modelName) async {
    final confirmed = await _confirmModelArchive(modelName);
    if (confirmed != true) return;
    try {
      await _api.deleteModel(modelId);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('مدل بایگانی شد', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1A1D22),
            action: SnackBarAction(
              label: 'بازگردانی',
              textColor: const Color(0xFF4ADE80),
              onPressed: () async {
                try {
                  await _api.restoreModel(modelId);
                  _loadProducts();
                } catch (_) {}
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool?> _confirmModelArchive(String modelName) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('بایگانی مدل', style: TextStyle(color: Colors.white)),
        content: Text(
          'مدل «$modelName» بایگانی خواهد شد و با بازگردانی، آخرین داده‌هایش برمی‌گردد.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بایگانی', style: TextStyle(color: Color(0xFFFBBF24))),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmArchive(String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('بایگانی محصول', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بایگانی', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('مدیریت محصولات', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
              _loadProducts();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _green.withOpacity(0.3), width: 1.5),
              ),
              child: Column(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: _green.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: _green, size: 30),
                ),
                const SizedBox(height: 12),
                const Text('ایجاد محصول جدید',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onQueryChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'جستجوی نام محصول یا مدل…',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 22),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onQueryChanged('');
                      },
                    ),
              filled: true,
              fillColor: _surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (!_loading && _total > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${faDigits('$_total')} محصول${_query.isNotEmpty ? ' — جستجو' : ''}',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _green))
              : _error != null && _groups.isEmpty
                  ? _buildErrorState()
                  : _groups.isEmpty
                      ? Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.inventory_2_rounded, size: 48, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            Text(
                              _query.isEmpty ? 'هیچ محصولی ثبت نشده' : 'نتیجه‌ای یافت نشد',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                            ),
                          ]),
                        )
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _groups.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _groups.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: _green),
                                  ),
                                ),
                              );
                            }
                            return _buildProductCard(_groups[index]);
                          },
                        ),
        ),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_off_rounded, size: 44, color: Colors.white.withOpacity(0.25)),
          const SizedBox(height: 12),
          Text(
            _error ?? 'خطا در بارگذاری',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13.5),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loadProducts,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _green.withValues(alpha: 0.3)),
              ),
              child: const Text('تلاش مجدد', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  void _toggleExpand(String productId) {
    setState(() {
      if (!_expandedProductIds.remove(productId)) {
        _expandedProductIds.add(productId);
      }
    });
  }

  Widget _buildProductCard(_ProductGroup g) {
    final expanded = _expandedProductIds.contains(g.id);
    final allModels = g.models;
    final visibleModels =
        expanded || allModels.length <= _collapsedModelLimit ? allModels : allModels.take(_collapsedModelLimit).toList();
    final hiddenCount = allModels.length - visibleModels.length;

    return GestureDetector(
      onTap: () => _toggleExpand(g.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: expanded ? _green.withValues(alpha: 0.35) : Colors.white.withOpacity(0.05),
            width: expanded ? 1.2 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.inventory_2_rounded, color: _green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(text: g.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    TextSpan(text: ' [${g.unit}]', style: const TextStyle(color: _green, fontSize: 11.5, fontWeight: FontWeight.w500)),
                    if (allModels.isNotEmpty)
                      TextSpan(
                        text: ' — ${faDigits('${allModels.length}')} مدل',
                        style: const TextStyle(color: Colors.white38, fontSize: 11.5, fontWeight: FontWeight.w400),
                      ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProductScreen(productId: g.id)),
                );
                _loadProducts();
              },
              child: const Icon(Icons.edit_outlined, color: _green, size: 20),
            ),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: () => _deleteProduct(g.id, g.name),
              child: const Icon(Icons.delete_outline_rounded, color: _red, size: 20),
            ),
            const SizedBox(width: 6),
            Icon(
              expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: Colors.white38,
              size: 20,
            ),
          ]),
          if (allModels.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in visibleModels) _buildModelChip(g, m),
                if (hiddenCount > 0) _buildToggleChip('و ${faDigits('$hiddenCount')} مدل دیگر', Icons.expand_more_rounded),
                if (expanded) _buildToggleChip('بستن مدل‌ها', Icons.expand_less_rounded),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'برای این محصول مدلی ثبت نشده است',
                style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildToggleChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _green),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: _green, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildModelChip(_ProductGroup g, _ModelRow m) {
    final parts = <String>[m.name];
    if (m.unitsPerBox != null && m.packageType != null && m.packageType!.trim().isNotEmpty) {
      parts.add('${faDigits('${m.unitsPerBox}')} ${g.unit}/${m.packageType}');
    } else if (m.unitsPerBox != null) {
      parts.add(faDigits('${m.unitsPerBox}'));
    }
    if (m.price != null) {
      parts.add('قیمت: ${formatNumber(m.price!)}');
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF22262D),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            parts.join(' · '),
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11.5),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _deleteModel(m.id, m.name),
            child: Icon(Icons.close_rounded, size: 14, color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}
