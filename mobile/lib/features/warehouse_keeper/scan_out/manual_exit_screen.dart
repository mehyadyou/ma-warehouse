import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/client_keys.dart';
import '../../offline/pending_ops.dart';
import '../../../shared/widgets/search_picker.dart';
import '../models/keeper_driver_model.dart';
import '../models/keeper_product_model.dart';
import '../models/scan_out_result_model.dart';
import '../providers/warehouse_keeper_provider.dart';
import 'target_picker_sheet.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _border = Color(0xFF2A2D33);
const _green = Color(0xFF4ADE80);
const _red = Color(0xFFEF4444);
const _orange = Color(0xFFFB923C);

/// خروج دستی (بدون QR) برای محصولاتی که برچسب/QR ندارند:
/// انتخاب محصول → انتخاب مدل → تعداد → تأیید مطابق سفارش/دستور خروج مدیر
class ManualExitScreen extends ConsumerStatefulWidget {
  const ManualExitScreen({super.key});

  @override
  ConsumerState<ManualExitScreen> createState() => _ManualExitScreenState();
}

class _ManualExitScreenState extends ConsumerState<ManualExitScreen> {
  KeeperProductModel? _product;
  KeeperProductVariantModel? _model;
  int _quantity = 1;
  /// راننده‌ای که این بار (سفارش) برایش تعریف می‌شود — اختیاری
  KeeperDriverModel? _driver;
  bool _submitting = false;

  Future<void> _pickProduct() async {
    final picked = await showSearchPicker<KeeperProductModel>(
      context: context,
      title: 'انتخاب محصول',
      loader: (q, page) async {
        final r = await ref
            .read(wkApiProvider)
            .getProductsPage(q: q, page: page, pageSize: 50);
        return (items: r.products, total: r.total);
      },
      labelOf: (p) => p.name,
      subtitleOf: (p) =>
          (p.unit ?? '').trim().isNotEmpty ? 'واحد: ${p.unit}' : null,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _product = picked;
      _model = null;
    });
  }

  /// انتخاب راننده از بین رانندگان تیک‌خوردهٔ همین انبار
  Future<void> _pickDriver() async {
    List<KeeperDriverModel> drivers;
    try {
      ref.invalidate(driversProvider);
      drivers = await ref.read(driversProvider.future);
    } catch (_) {
      if (mounted) _snack('خطا در دریافت رانندگان');
      return;
    }
    if (!mounted) return;
    final ticked = drivers.where((d) => d.assignedToMe && !d.assignedToOther).toList();
    if (ticked.isEmpty) {
      _snack('راننده‌ای تیک نخورده — از منوی مدیریت رانندگان انتخاب کنید');
      return;
    }

    final picked = await showModalBottomSheet<KeeperDriverModel>(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('انتخاب راننده',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('فقط رانندگانی که تیک خورده‌اند نمایش داده می‌شوند',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: ticked.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final d = ticked[i];
                    return Material(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(sheetContext, d),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(children: [
                            const Icon(Icons.local_shipping_rounded, color: _green, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                  if (d.phone.isNotEmpty)
                                    Text(d.phone,
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_outline_rounded, color: _green, size: 20),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _driver = picked);
  }

  Future<void> _submit() async {
    if (_product == null) {
      _snack('محصول را انتخاب کنید');
      return;
    }
    if (_product!.models.isNotEmpty && _model == null) {
      _snack('مدل محصول را انتخاب کنید');
      return;
    }
    if (_quantity < 1) {
      _snack('تعداد باید حداقل ۱ باشد');
      return;
    }
    setState(() => _submitting = true);
    // کلید ایدمپوتنسی این خروج: بین تلاش اول و تلاش بعد از انتخاب هدف (پیکر) ثابت می‌ماند
    final clientKey = newClientKey();
    try {
      await _sendExitRequest(clientKey: clientKey);
    } on DioException catch (e) {
      // چند هدف فعال — لیست هدف‌های ممکن برای انتخاب صریح انباردار
      final body = e.response?.data;
      final candidates = (body is Map && body['candidates'] is List)
          ? (body['candidates'] as List)
              .whereType<Map>()
              .map((m) => ScanOutTargetModel.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : <ScanOutTargetModel>[];
      if (candidates.isNotEmpty && mounted) {
        String productLabel = '';
        final transfer = candidates.where((c) => c.kind == 'transfer').firstOrNull;
        if (transfer != null) {
          final modelName = transfer.modelName;
          productLabel = [
            if (transfer.productName.isNotEmpty) transfer.productName,
            if ((modelName ?? '').isNotEmpty) '($modelName)',
          ].join(' ');
        }
        final picked = await showModalBottomSheet<ScanOutTargetModel>(
          context: context,
          backgroundColor: _surface,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => TargetPickerSheet(
            candidates: candidates,
            productLabel: productLabel.isNotEmpty ? productLabel : 'این کالا',
          ),
        );
        if (picked != null && mounted) {
          try {
            await _sendExitRequest(
              clientKey: clientKey,
              orderId: picked.kind == 'order' ? picked.id : null,
              transferId: picked.kind == 'transfer' ? picked.id : null,
            );
          } on DioException catch (retryError) {
            if (isNetworkError(retryError)) {
              await _enqueueManualOffline(
                clientKey,
                orderId: picked.kind == 'order' ? picked.id : null,
                transferId: picked.kind == 'transfer' ? picked.id : null,
              );
            } else {
              _snack(friendlyError(retryError));
            }
          }
        }
        return;
      }
      if (isNetworkError(e)) {
        await _enqueueManualOffline(clientKey);
      } else {
        _snack(friendlyError(e));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// ذخیره خروج دستی در صف آفلاین (قطعی شبکه) + پیام مناسب
  Future<void> _enqueueManualOffline(
    String clientKey, {
    String? orderId,
    String? transferId,
  }) async {
    await ref.read(pendingOpsProvider.notifier).enqueue(PendingOp(
          key: clientKey,
          type: PendingOpType.manualExit,
          payload: {
            'productId': _product!.id,
            if (_model?.id != null) 'modelId': _model!.id,
            'quantity': _quantity,
            if (_driver?.id != null) 'driverId': _driver!.id,
            if (orderId != null) 'orderId': orderId,
            if (transferId != null) 'transferId': transferId,
          },
          createdAt: DateTime.now(),
          label: 'خروج دستی ${_product!.name} (×$_quantity)',
        ));
    if (mounted) {
      final pending = ref.read(pendingOpsProvider).length;
      _snack('اینترنت قطع است — خروج در صف آفلاین ذخیره شد ($pending در صف)');
    }
  }

  /// ارسال درخواست خروج دستی — [orderId]/[transferId] وقتی انباردار از پیکر
  /// «کدام هدف؟» انتخاب کرده باشد (چند سفارش/دستور فعال برای همین کالا/مدل).
  Future<void> _sendExitRequest({required String clientKey, String? orderId, String? transferId}) async {
    final result = await ref.read(wkApiProvider).manualExit(
          productId: _product!.id,
          modelId: _model?.id,
          quantity: _quantity,
          driverId: _driver?.id,
          orderId: orderId,
          transferId: transferId,
          clientKey: clientKey,
        );
    if (!mounted) return;
    final transfer = result.carton?.transfer;
    final isTransfer = transfer != null;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'خروج ثبت شد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_product!.name}${_model != null ? ' — ${_model!.name}' : ''}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'تعداد: $_quantity ${(_product!.unit ?? '').trim().isNotEmpty ? _product!.unit! : 'عدد'}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              isTransfer
                  ? (transfer.toWarehouseName != null
                      ? 'مطابق دستور جابه‌جایی — انتقال به ${transfer.toWarehouseName}'
                      : 'مطابق دستور خروج مدیر')
                  : 'مطابق سفارش ثبت شد',
              style: TextStyle(
                color: isTransfer ? _orange : _green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isTransfer && _driver != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.local_shipping_rounded, color: _green, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('راننده: ${_driver!.name}',
                      style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ]),
            ],
            if (!isTransfer && _driver == null) ...[
              const SizedBox(height: 8),
              Text('راننده‌ای انتخاب نشد — بار بدون راننده ثبت شد',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('باشه', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasModels = (_product?.models ?? []).isNotEmpty;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'خروج دستی (بدون QR)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── انتخاب محصول ───
          _fieldLabel('۱. نام محصول'),
          const SizedBox(height: 6),
          _pickerField(
            value: _product?.name,
            placeholder: 'انتخاب محصول...',
            icon: Icons.search_rounded,
            onTap: _pickProduct,
          ),
          const SizedBox(height: 14),

          // ─── انتخاب مدل ───
          _fieldLabel('۲. مدل محصول'),
          const SizedBox(height: 6),
          if (!hasModels)
            _infoBox('این محصول مدلی ندارد — مستقیم با نام محصول خروج می‌گیرد')
          else
            _dropdownField(),
          const SizedBox(height: 14),

          // ─── تعداد ───
          _fieldLabel('۳. تعداد خروج'),
          const SizedBox(height: 6),
          _quantityField(),

          // ─── راننده بار (اختیاری) ───
          _fieldLabel('۴. راننده بار (اختیاری)'),
          const SizedBox(height: 6),
          _pickerField(
            value: _driver?.name,
            placeholder: 'انتخاب راننده...',
            icon: Icons.local_shipping_rounded,
            onTap: _pickDriver,
          ),
          if (_driver != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _driver = null),
                child: Text('حذف انتخاب راننده',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Text(
            'خروج فقط در صورتی ثبت می‌شود که دقیقاً مطابق سفارش یا دستور خروج/جابه‌جایی مدیر باشد.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: const Color(0xFF0B0F0C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0B0F0C),
                      ),
                    )
                  : const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                'ثبت خروج',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String t) => Text(
        t,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      );

  Widget _pickerField({
    required String? value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value != null
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            ),
            Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String t) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
      );

  Widget _dropdownField() {
    final unit = (_product?.unit ?? '').trim().isNotEmpty
        ? _product!.unit!
        : 'عدد';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _model?.id,
          hint: Text(
            'انتخاب مدل...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
          isExpanded: true,
          dropdownColor: _surfaceAlt,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          items: [
            for (final m in _product?.models ?? const <KeeperProductVariantModel>[])
              DropdownMenuItem<String>(
                value: m.id,
                child: Text(
                  m.unitsPerBox != null
                      ? '${m.name} (${m.unitsPerBox} $unit/${m.packageType ?? 'کارتن'})'
                      : m.name,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _model = (_product?.models ?? const <KeeperProductVariantModel>[])
                  .where((m) => m.id == v)
                  .firstOrNull;
            });
          },
        ),
      ),
    );
  }

  Widget _quantityField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _quantity > 1
                ? () => setState(() => _quantity--)
                : null,
            icon: const Icon(Icons.remove_rounded, color: Colors.white),
          ),
          Expanded(
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: const Icon(Icons.add_rounded, color: _green),
          ),
        ],
      ),
    );
  }
}
