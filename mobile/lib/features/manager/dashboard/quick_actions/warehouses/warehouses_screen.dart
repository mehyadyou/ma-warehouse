import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../models/warehouse_model.dart';
import 'create_warehouse_dialog.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../providers/warehouses_provider.dart';
import 'warehouse_detail_screen.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _blue = Color(0xFF60A5FA);
const _danger = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);

class WarehousesScreen extends ConsumerWidget {
  const WarehousesScreen({super.key});

  void _showCreateWarehouseDialog(BuildContext context, WidgetRef ref) async {
    final result = await showCreateWarehouseDialog(context);
    if (result == null || !context.mounted) return;

    try {
      final apiService = ref.read(managerApiServiceProvider);
      final response = await apiService.createWarehouseWithKeeper(
        warehouseName: result['warehouseName']!,
        keeperName: result['keeperName']!,
        keeperPhone: result['keeperPhone']!,
        keeperPassword: result['keeperPassword']!,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('انبار «${response.name}» ساخته شد'), backgroundColor: Colors.green),
        );
        ref.read(warehousesProvider.notifier).refresh();
      }
    } catch (e) {
      String msg = 'خطا در ساخت انبار';
      if (e is DioException && e.response?.data != null && e.response?.data['error'] != null) {
        msg = '${e.response?.data['error']}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ═══════════ EDIT WAREHOUSE ═══════════
  void _showEditWarehouseDialog(BuildContext context, WidgetRef ref, WarehouseModel w) {
    final nameCtrl = TextEditingController(text: w.name);
    final addressCtrl = TextEditingController(text: w.address ?? '');
    String? selectedKeeperId = w.keeperId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('ویرایش انبار', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'نام انبار',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: _surfaceAlt,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _green)),
              ),
            ),
            const SizedBox(height: 12),
            //انتخاب انباردار
            SizedBox(
              width: double.infinity,
              child: FutureBuilder<List<dynamic>>(
                future: ref.read(managerApiServiceProvider).getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
                      child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _green)),
                    );
                  }
                  final users = (snapshot.data ?? []).where((u) => u['role'] != 'MANAGER').toList();
                  final keeperInList = w.keeperId != null && users.any((u) => u['id'] == w.keeperId);
                  final items = <DropdownMenuItem<String?>>[
                    if (w.keeperId != null && !keeperInList && w.keeperName != null)
                      DropdownMenuItem(
                        value: w.keeperId,
                        child: Text('${w.keeperName} (انباردار فعلی)', style: const TextStyle(color: Colors.white)),
                      ),
                    ...users.map((u) => DropdownMenuItem(
                          value: u['id'] as String,
                          child: Text('${u['name']} (${_roleLabel(u['role'] as String? ?? '')})', style: const TextStyle(color: Colors.white)),
                        )),
                  ];
                  return DropdownButtonFormField<String?>(
                    value: selectedKeeperId,
                    isExpanded: true,
                    dropdownColor: _surfaceAlt,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'انباردار',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: _surfaceAlt,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _green)),
                    ),
                    items: items,
                    onChanged: (v) {
                      selectedKeeperId = v;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'آدرس (اختیاری)',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: _surfaceAlt,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _green)),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام انبار الزامی است'), backgroundColor: _danger));
                return;
              }
              try {
                final apiService = ref.read(managerApiServiceProvider);
                await apiService.updateWarehouse(
                  id: w.id,
                  name: nameCtrl.text.trim(),
                  address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                  keeperId: selectedKeeperId,
                );
                Navigator.pop(ctx);
                ref.read(warehousesProvider.notifier).refresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('انبار ویرایش شد'), backgroundColor: _green, behavior: SnackBarBehavior.floating),
                  );
                }
              } catch (e) {
                String msg = 'خطا در ویرایش';
                if (e is DioException && e.response?.data != null && e.response?.data['error'] != null) {
                  msg = '${e.response?.data['error']}';
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _danger));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'MANAGER': return 'مدیر';
      case 'WAREHOUSE_KEEPER': return 'انباردار';
      case 'DRIVER': return 'راننده';
      default: return role;
    }
  }

  // ═══════════ ARCHIVE WAREHOUSE ═══════════
  Future<void> _deleteWarehouse(BuildContext context, WidgetRef ref, WarehouseModel w) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('بایگانی انبار', style: TextStyle(color: Colors.white)),
        content: Text(
          'انبار «${w.name}» بایگانی خواهد شد.\nهیچ داده‌ای حذف یا جابه‌جا نمی‌شود؛ کارتن‌ها، سفارش‌ها، تراکنش‌ها و انباردار سر جای خود می‌مانند و با بازگردانی همه‌چیز دقیقاً برمی‌گردد.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBBF24)),
            child: const Text('بایگانی', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final apiService = ref.read(managerApiServiceProvider);
      await apiService.deleteWarehouse(w.id);
      ref.read(warehousesProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('انبار «${w.name}» بایگانی شد', style: const TextStyle(color: Colors.white)),
            backgroundColor: _surfaceAlt,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'بازگردانی',
              textColor: _green,
              onPressed: () async {
                try {
                  await apiService.restoreWarehouse(w.id);
                  ref.read(warehousesProvider.notifier).refresh();
                } catch (_) {}
              },
            ),
          ),
        );
      }
    } catch (e) {
      String msg = 'خطا در بایگانی انبار';
      if (e is DioException && e.response?.data != null && e.response?.data['error'] != null) {
        msg = '${e.response?.data['error']}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: _danger, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('مدیریت انبارها', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: warehousesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _green)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withOpacity(0.6)),
              const SizedBox(height: 12),
              Text('خطا در بارگذاری', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15)),
            ],
          ),
        ),
        data: (warehouses) => warehouses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warehouse_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('هنوز هیچ انباری ساخته نشده', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
                  ],
                ),
              )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: warehouses.length,
                    itemBuilder: (context, index) {
                      final w = warehouses[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => WarehouseDetailScreen(warehouse: w)));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(width: 44, height: 44, decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.warehouse_rounded, color: _green, size: 22)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(w.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('انباردار: ${w.keeperName ?? "---"}', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                                ]),
                              ),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text('${w.productCount} محصول', style: const TextStyle(color: _green, fontSize: 11.5, fontWeight: FontWeight.w600))),
                              const SizedBox(width: 8),
                              // Edit button
                              GestureDetector(
                                onTap: () => _showEditWarehouseDialog(context, ref, w),
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.edit_rounded, color: _blue, size: 18),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Archive button
                              GestureDetector(
                                onTap: () => _deleteWarehouse(context, ref, w),
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: const Color(0xFFFBBF24).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.archive_outlined, color: Color(0xFFFBBF24), size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        onPressed: () => _showCreateWarehouseDialog(context, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('ایجاد انبار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
