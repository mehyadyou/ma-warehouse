import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/archive_models.dart';
import '../../../../../core/network/api_error.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _textDim = Color(0xFF8A8F98);

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  List<ArchivedProductModel> _products = [];
  List<ArchivedWarehouseModel> _warehouses = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final archivedProducts = await _api.getArchivedProducts();
      final archivedWarehouses = await _api.getArchivedWarehouses();
      if (!mounted) return;
      setState(() {
        _products = archivedProducts;
        _warehouses = archivedWarehouses;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _restoreProduct(ArchivedProductModel product) async {
    final id = product.id;
    final name = product.name ?? 'محصول';
    if (id.isEmpty) return;
    try {
      await _api.restoreProduct(id);
      if (!mounted) return;
      setState(() => _products.removeWhere((p) => p.id == id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '«$name» با آخرین داده‌ها بازگردانده شد',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بازیابی ناموفق بود: ${friendlyError(e)}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _restoreWarehouse(ArchivedWarehouseModel warehouse) async {
    final id = warehouse.id;
    final name = warehouse.name ?? 'انبار';
    if (id.isEmpty) return;
    try {
      await _api.restoreWarehouse(id);
      if (!mounted) return;
      setState(() => _warehouses.removeWhere((w) => w.id == id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'انبار «$name» با کارتن‌ها، سوابق و انباردار بازگردانده شد',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بازیابی ناموفق بود: ${friendlyError(e)}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _surface,
          title: const Text('بایگانی', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            indicatorColor: _green,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'محصولات (${_products.length})'),
              Tab(text: 'انبارها (${_warehouses.length})'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : _error
                ? _buildError()
                : TabBarView(
                    children: [
                      _buildProductsTab(),
                      _buildWarehousesTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_products.isEmpty) {
      return const _EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'هیچ محصولی در بایگانی نیست',
        subtitle: 'محصولات حذف‌شده اینجا نگهداری و قابل بازگرداندن هستند',
      );
    }
    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (_, i) => _ProductArchiveCard(
          product: _products[i],
          onRestore: () => _restoreProduct(_products[i]),
        ),
      ),
    );
  }

  Widget _buildWarehousesTab() {
    if (_warehouses.isEmpty) {
      return const _EmptyState(
        icon: Icons.warehouse_outlined,
        title: 'هیچ انباری در بایگانی نیست',
        subtitle: 'انبارهای بایگانی‌شده اینجا قابل بازگرداندن هستند',
      );
    }
    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _warehouses.length,
        itemBuilder: (_, i) => _WarehouseArchiveCard(
          warehouse: _warehouses[i],
          onRestore: () => _restoreWarehouse(_warehouses[i]),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white38, size: 44),
          const SizedBox(height: 12),
          Text('خطا در بارگذاری بایگانی', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            child: const Text('تلاش دوباره', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: Colors.white.withValues(alpha: 0.18)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductArchiveCard extends StatelessWidget {
  final ArchivedProductModel product;
  final VoidCallback onRestore;

  const _ProductArchiveCard({required this.product, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final models = product.models;
    final cartons = product.cartonCount.toInt();
    final unit = (product.unit ?? '').trim().isNotEmpty ? product.unit! : 'عدد';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.archive_rounded, color: _amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.name ?? ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${models.length} مدل • $cartons کارتن • واحد: $unit',
                      style: const TextStyle(color: _textDim, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (models.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              models.map((m) => m.name).join('، '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11.5),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.restore_rounded, color: _green, size: 18),
              label: const Text('بازگردانی محصول', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: BorderSide(color: _green.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarehouseArchiveCard extends StatelessWidget {
  final ArchivedWarehouseModel warehouse;
  final VoidCallback onRestore;

  const _WarehouseArchiveCard({required this.warehouse, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final name = warehouse.name ?? '';
    final cartons = warehouse.cartonCount.toInt();
    final orders = warehouse.orderCount.toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warehouse_outlined, color: _amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$cartons کارتن • $orders سفارش',
                      style: const TextStyle(color: _textDim, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.restore_rounded, color: _green, size: 18),
              label: const Text('بازگردانی انبار', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: BorderSide(color: _green.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}