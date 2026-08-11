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

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  final List<Map<String, dynamic>> _products = [];
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  int _page = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String _query = '';

  static const int _pageSize = 100;

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
      _loadProducts(reset: true);
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _api.getProductsPage(
        q: _query.isEmpty ? null : _query,
        page: _page + 1,
        pageSize: _pageSize,
      );
      _addRows(result.products);
      _page += 1;
      _hasMore = _products.length < result.total;
      _total = result.total;
    } catch (_) {}
    if (mounted) setState(() => _loadingMore = false);
  }

  Future<void> _loadProducts({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _products.clear();
        _page = 1;
        _hasMore = true;
      });
    }
    try {
      final result = await _api.getProductsPage(
        q: _query.isEmpty ? null : _query,
        page: reset ? 1 : _page,
        pageSize: _pageSize,
      );
      if (reset) _products.clear();
      _addRows(result.products);
      if (reset) _page = 1;
      _total = result.total;
      _hasMore = _products.length < result.total;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _addRows(List<ProductModel> rawProducts) {
    for (var p in rawProducts) {
      final unit = (p.unit ?? '').trim().isNotEmpty ? p.unit! : 'عدد';
      final models = p.models;
      if (models.isEmpty) {
        _products.add({
          'productId': p.id,
          'productName': p.name,
          'unit': unit,
          'modelId': '',
          'modelName': '',
          'price': null,
        });
      } else {
        for (var m in models) {
          _products.add({
            'productId': p.id,
            'productName': p.name,
            'unit': unit,
            'modelId': m.id,
            'modelName': m.name,
            'price': m.price,
          });
        }
      }
    }
  }

  void _deleteProduct(String productId, String productName) async {
    final confirmed = await _confirmArchive(
      '«$productName» بایگانی خواهد شد. هیچ داده‌ای حذف نمی‌شود؛ کارتن‌ها و QRها سالم می‌مانند و هر زمان قابل بازگرداندن است.',
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
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: _green.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: _green, size: 30),
                ),
                const SizedBox(height: 12),
                const Text('ایجاد محصول جدید', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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
                '${_products.length} از $_total',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _green))
              : _products.isEmpty
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
                      itemCount: _products.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _products.length) {
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
                        final p = _products[index];
                        final pId = p['productId'] ?? '';
                        final pName = p['productName'] ?? '';
                        final mId = p['modelId'] ?? '';
                        final mName = p['modelName'] ?? '';
                        final unit = p['unit'] ?? 'عدد';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.05))),
                          child: Row(children: [
                            Container(width: 44, height: 44, decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.inventory_2_rounded, color: _green, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: pName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                    TextSpan(text: ' [$unit]', style: const TextStyle(color: _green, fontSize: 11.5, fontWeight: FontWeight.w500)),
                                    if (mName.isNotEmpty) ...[
                                      const TextSpan(text: '  '),
                                      TextSpan(text: mName, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w300)),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                            // ویرایش + حذف
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EditProductScreen(productId: pId)),
                                );
                                _loadProducts();
                              },
                              child: const Icon(Icons.edit_outlined, color: _green, size: 20),
                            ),
                            const SizedBox(width: 14),
                            if (mId.isNotEmpty)
                              GestureDetector(
                                onTap: () => _deleteModel(mId, mName),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              )
                            else
                              GestureDetector(
                                onTap: () => _deleteProduct(pId, pName),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              ),
                          ]),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}