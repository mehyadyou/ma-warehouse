import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
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
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final rawProducts = await _api.getProducts();

      final List<Map<String, dynamic>> flattenedList = [];
      for (var p in rawProducts) {
        final unit = (p.unit ?? '').trim().isNotEmpty ? p.unit! : 'عدد';
        final models = p.models;
        if (models.isEmpty) {
          flattenedList.add({
            'productId': p.id,
            'productName': p.name,
            'unit': unit,
            'modelId': '',
            'modelName': '',
            'price': null,
          });
        } else {
          for (var m in models) {
            flattenedList.add({
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

      setState(() => _products = flattenedList);
    } catch (_) {}
    setState(() => _loading = false);
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
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _green))
              : _products.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.inventory_2_rounded, size: 48, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text('هیچ محصولی ثبت نشده', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
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