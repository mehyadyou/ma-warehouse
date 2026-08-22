import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/manager_api_service.dart';
import '../../providers/manager_api_provider.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../shared/utils/numbers.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);

/// واحدهای پایهٔ شمارش (موجودی و ظرفیت بسته بر این مبنا سنجیده می‌شود)
const _baseUnits = [
  'عدد',
  'کیلوگرم',
  'گرم',
  'متر',
  'لیتر',
  'شاخه',
  'جفت',
  'دستگاه',
];

/// انواع بسته‌بندی فیزیکی — فقط فرمت بسته، نه واحد اندازه‌گیری
const _packageTypes = [
  'کارتن',
  'جعبه',
  'پالت',
  'کیسه',
  'بسته',
  'ساک',
  'رول',
  'حلقه',
];

class _ModelRow {
  final String? id;
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController unitsPerBox = TextEditingController();
  String? packageType;
  bool isNew;

  _ModelRow({this.id, required this.isNew});

  void dispose() {
    name.dispose();
    price.dispose();
    unitsPerBox.dispose();
  }
}

class EditProductScreen extends ConsumerStatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  final _nameCtrl = TextEditingController();
  final List<_ModelRow> _rows = [];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String _unit = 'عدد';
  List<String> _unitItems = _baseUnits;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final product = await _api.getProduct(widget.productId);
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = product.name;
        final unit = product.unit?.trim().isNotEmpty == true
            ? product.unit!
            : 'عدد';
        _unit = unit;
        _unitItems = _baseUnits.contains(unit)
            ? _baseUnits
            : [..._baseUnits, unit];
        for (final m in product.models) {
          final row = _ModelRow(id: m.id, isNew: false);
          row.name.text = m.name;
          row.price.text = m.price != null ? _priceDisplay(m.price!) : '';
          row.packageType = m.packageType;
          row.unitsPerBox.text = m.unitsPerBox != null
              ? '${m.unitsPerBox}'
              : '';
          _rows.add(row);
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = friendlyError(e);
      });
    }
  }

  /// قیمت اعشاری را بدون صفرهای اضافی نمایش میدهد (مثلاً «1234.00» → «1234»)
  String _priceDisplay(double price) {
    return price == price.roundToDouble() ? price.toInt().toString() : '$price';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addModelRow() => setState(() => _rows.add(_ModelRow(isNew: true)));

  void _removeModelRow(int index) {
    final row = _rows[index];
    setState(() {
      row.dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _deleteModelRow(int index) async {
    final row = _rows[index];
    if (row.isNew || row.id == null) {
      _removeModelRow(index);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('حذف مدل', style: TextStyle(color: Colors.white)),
        content: Text(
          'مدل «${row.name.text}» حذف شود؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'انصراف',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteModel(row.id!);
      _removeModelRow(index);
    } catch (e) {
      _showError('حذف مدل ناموفق بود');
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showError('نام محصول را وارد کنید');
      return;
    }

    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      if (row.name.text.trim().isEmpty) {
        _showError('نام مدل ردیف ${i + 1} را وارد کنید');
        return;
      }
      final unitsRaw = normalizeDigits(row.unitsPerBox.text.trim());
      if (row.packageType != null && unitsRaw.isEmpty) {
        _showError('ظرفیت بسته ردیف ${i + 1} را وارد کنید');
        return;
      }
      if (unitsRaw.isNotEmpty) {
        final v = int.tryParse(unitsRaw);
        if (v == null || v <= 0) {
          _showError('ظرفیت بسته ردیف ${i + 1} باید عدد بزرگتر از صفر باشد');
          return;
        }
      }
      final priceRaw = normalizeDigits(row.price.text.trim());
      if (priceRaw.isNotEmpty) {
        final p = double.tryParse(priceRaw);
        if (p == null || p < 0) {
          _showError('قیمت ردیف ${i + 1} باید عدد باشد');
          return;
        }
      }
    }

    setState(() => _saving = true);
    try {
      // ۱) ویرایش نام/واحد شمارش محصول
      await _api.updateProduct(widget.productId, {'name': name, 'unit': _unit});

      // ۲) ویرایش مدل‌های موجود
      final newModels = <Map<String, dynamic>>[];
      for (final row in _rows) {
        final unitsRaw = normalizeDigits(row.unitsPerBox.text.trim());
        final priceRaw = normalizeDigits(row.price.text.trim());
        final modelData = {
          'name': row.name.text.trim(),
          'price': priceRaw.isEmpty ? null : priceRaw,
          'packageType': row.packageType,
          'unitsPerBox': unitsRaw.isEmpty ? null : unitsRaw,
        };
        if (row.id != null) {
          await _api.updateModel(row.id!, modelData);
        } else {
          newModels.add(modelData);
        }
      }

      // ۳) مدل‌های جدید — یک درخواست اتمی (اگر وسط کار خطا بخورد، مدل‌های قبلی سالم‌اند و retry تداخلی ندارد)
      if (newModels.isNotEmpty) {
        await _api.addProductModels(widget.productId, newModels);
      }

      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('محصول ویرایش شد'),
          backgroundColor: _green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      var msg = '$e';
      if (e is DioException &&
          e.response?.data is Map &&
          e.response?.data['error'] != null) {
        msg = '${e.response?.data['error']}';
      }
      _showError(msg);
    }
  }

  Future<void> _archiveProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text(
          'بایگانی محصول',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '«${_nameCtrl.text.trim()}» و تمام مدل‌هایش بایگانی خواهد شد. هیچ داده‌ای حذف نمی‌شود؛ هر زمان قابل بازگرداندن است.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'انصراف',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بایگانی', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await _api.deleteProduct(widget.productId);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('محصول بایگانی شد'),
          backgroundColor: _green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(friendlyError(e));
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Colors.white.withOpacity(0.25),
            ),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadProduct,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'تلاش مجدد',
                  style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'ویرایش محصول',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _saving ? null : _archiveProduct,
            tooltip: 'بایگانی محصول',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFF87171),
              size: 22,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _loadError != null
          ? _buildErrorState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نام محصول',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('نام محصول'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'واحد شمارش',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _unit,
                          isExpanded: true,
                          dropdownColor: _bg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration('واحد پایه'),
                          items: _unitItems
                              .map(
                                (u) => DropdownMenuItem<String>(
                                  value: u,
                                  child: Text(u),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _unit = v ?? 'عدد'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مدل‌ها',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...(_rows.asMap().entries.map(
                    (entry) => _buildModelRow(entry.key, entry.value),
                  )),
                  const SizedBox(height: 4),
                  // دکمهٔ افزودن مدل — پایین فیلدها، در مرکز
                  Center(
                    child: GestureDetector(
                      onTap: _addModelRow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: _green,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'افزودن مدل',
                              style: TextStyle(
                                color: _green,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          )
                        : const Text(
                            'ذخیره تغییرات',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModelRow(int index, _ModelRow row) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: row.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: _inputDecoration('نام مدل'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: row.price,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: _inputDecoration('قیمت'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: row.packageType,
                        isExpanded: true,
                        dropdownColor: _bg,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: _inputDecoration('نوع بسته'),
                        items: _packageTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => row.packageType = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: row.unitsPerBox,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: _inputDecoration('ظرفیت ($_unit)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // دکمهٔ حذف — کنار فیلد، خارج از کارت
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _deleteModelRow(index),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    filled: true,
    fillColor: _bg,
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _green, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
