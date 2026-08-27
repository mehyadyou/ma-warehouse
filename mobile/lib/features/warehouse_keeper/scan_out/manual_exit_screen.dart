import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../shared/widgets/search_picker.dart';
import '../models/keeper_product_model.dart';
import '../providers/warehouse_keeper_provider.dart';

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
    try {
      final result = await ref.read(wkApiProvider).manualExit(
            productId: _product!.id,
            modelId: _model?.id,
            quantity: _quantity,
          );
      if (!mounted) return;
      if (!result.valid) {
        _snack(result.error.isEmpty ? 'خروج ثبت نشد' : result.error);
        return;
      }
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
    } on DioException catch (e) {
      _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
