import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../providers/manager_api_provider.dart';
import '../../models/product_model.dart';
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
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController unitsPerBox = TextEditingController();
  String? packageType;

  void dispose() {
    name.dispose();
    price.dispose();
    unitsPerBox.dispose();
  }
}

class _ArchivedAction {
  final bool useSuggested;
  final String? restoreId;

  const _ArchivedAction._({required this.useSuggested, this.restoreId});

  const _ArchivedAction.suggested() : this._(useSuggested: true);

  const _ArchivedAction.restore(String id)
    : this._(useSuggested: false, restoreId: id);
}

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameCtrl = TextEditingController();
  final List<_ModelRow> _rows = [];
  List<ProductModel> _suggestionResults = [];
  Timer? _searchDebounce;
  int _searchSeq = 0;
  bool _loadingSuggestions = false;
  String? _suggestionsError;
  bool _showSuggestions = false;
  String _unit = 'عدد';
  List<String> _unitItems = _baseUnits;

  @override
  void initState() {
    super.initState();
    _addModelRow();
  }

  /// جستجوی پیشنهادها روی سرور — صفحهٔ اول، بدون بارگذاری کل کاتالوگ
  Future<void> _searchSuggestions(String q) async {
    final seq = ++_searchSeq;
    setState(() {
      _loadingSuggestions = true;
      _suggestionsError = null;
    });
    try {
      final page = await ref
          .read(managerApiServiceProvider)
          .getProductsPage(
            q: q.trim().isEmpty ? null : q.trim(),
            page: 1,
            pageSize: 20,
          );
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _suggestionResults = page.products;
        _loadingSuggestions = false;
      });
    } catch (e) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _loadingSuggestions = false;
        _suggestionsError = friendlyError(e);
      });
    }
  }

  void _scheduleSearch(String q) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _searchSuggestions(q),
    );
  }

  /// محصول پیشنهادی‌ها از نتایج جستجوی سرور
  List<ProductModel> get _suggestions => _suggestionResults;

  /// محصول موجود که نام دقیقاً با متن برابر است
  ProductModel? get _exactMatch {
    final q = _nameCtrl.text.trim();
    if (q.isEmpty) return null;
    for (final p in _suggestionResults) {
      if (p.name == q) return p;
    }
    return null;
  }

  void _addModelRow() => setState(() => _rows.add(_ModelRow()));

  void _removeModelRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nameCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showError('نام محصول را وارد کنید');
      return;
    }

    final models = <Map<String, String?>>[];
    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      final modelName = row.name.text.trim();
      if (modelName.isEmpty) {
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
      models.add({
        'name': modelName,
        'price': priceRaw.isEmpty ? null : priceRaw,
        'packageType': row.packageType,
        'unitsPerBox': unitsRaw.isEmpty ? null : unitsRaw,
      });
    }

    try {
      await ref.read(managerApiServiceProvider).createProduct({
        'name': name,
        'unit': _unit,
        'models': models,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('محصول با مدل‌ها ثبت شد'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      if (e.response?.statusCode == 409 &&
          data is Map &&
          data['code'] == 'ARCHIVED_CONFLICT' &&
          data['data'] is Map) {
        await _handleArchivedConflict(
          name,
          models,
          Map<String, dynamic>.from(data['data'] as Map),
        );
        return;
      }
      var msg = '$e';
      if (data is Map && data['error'] != null) {
        msg = '${data['error']}';
      }
      _showError(msg);
    } catch (e) {
      if (!mounted) return;
      _showError(friendlyError(e));
    }
  }

  /// دیالوگ برخورد با محصول بایگانیشدهٔ همنام — بازگردانی یا استفاده از نام پیشنهادی
  Future<void> _handleArchivedConflict(
    String name,
    List<Map<String, String?>> models,
    Map<String, dynamic> conflict,
  ) async {
    final archivedId = conflict['id'] as String?;
    final suggestedName = conflict['suggestedName'] as String?;
    final action = await showDialog<_ArchivedAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        title: const Text(
          'محصول در بایگانی است',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'محصول «$name» قبلاً بایگانیشده است. آن را بازگردانی میکنید یا با نام پیشنهادی ثبت میکنید؟',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, const _ArchivedAction.suggested()),
            child: Text(
              suggestedName == null || suggestedName.isEmpty
                  ? 'نام جدید'
                  : 'نام پیشنهادی: $suggestedName',
              style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12.5),
            ),
          ),
          if (archivedId != null) ...[
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, _ArchivedAction.restore(archivedId)),
              child: const Text(
                'بازگردانی و ثبت مدل‌ها',
                style: TextStyle(color: Color(0xFF4ADE80)),
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text(
              'انصراف',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;

    if (action.restoreId != null) {
      try {
        await ref
            .read(managerApiServiceProvider)
            .restoreProduct(action.restoreId!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('محصول بازگردانده شد؛ در حال ثبت مدل‌ها…'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        _showError(friendlyError(e));
        return;
      }
      await _submit();
      return;
    }

    if (action.useSuggested) {
      final suggested = suggestedName;
      if (suggested != null && suggested.isNotEmpty) {
        setState(() {
          _nameCtrl.text = suggested;
          _nameCtrl.selection = TextSelection.collapsed(
            offset: suggested.length,
          );
          _showSuggestions = false;
        });
      }
      await _submit();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('محصول جدید', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
              decoration: _inputDecoration('مثال: اسپیکر پرتابل').copyWith(
                suffixIcon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: _green,
                ),
              ),
              onTap: () {
                _searchSuggestions(_nameCtrl.text);
                setState(() => _showSuggestions = true);
              },
              onChanged: (v) {
                setState(() => _showSuggestions = true);
                _scheduleSearch(v);
              },
              onTapOutside: (_) {
                // تأخیر تا لمسِ یک پیشنهاد کامل شود؛ وگرنه لیست قبل از onTap حذف می‌شود
                Future.delayed(const Duration(milliseconds: 120), () {
                  if (mounted) setState(() => _showSuggestions = false);
                });
              },
            ),
            if (_exactMatch != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.merge_rounded, color: _green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'این مدل به محصول «${_exactMatch!.name}» اضافه خواهد شد',
                        style: const TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_nameCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.add_box_rounded,
                    color: Colors.white38,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'محصول جدید ساخته خواهد شد',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (_showSuggestions) _suggestionList(),
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
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: _green, size: 20),
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
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'ثبت محصول',
                style: TextStyle(
                  color: Colors.white,
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
            onTap: () => _removeModelRow(index),
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

  /// منوی کشویی پیشنهاد محصولات ثبت‌شده
  Widget _suggestionList() {
    if (_loadingSuggestions) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4ADE80),
            ),
          ),
        ),
      );
    }
    if (_suggestionsError != null) {
      return GestureDetector(
        onTap: () => _searchSuggestions(_nameCtrl.text),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'خطا در بارگذاری پیشنهادها — لمس برای تلاش مجدد',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final list = _suggestions;
    if (list.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.04)),
        itemBuilder: (context, i) {
          final p = list[i];
          final name = p.name;
          final models = p.models;
          final isExact = name == _nameCtrl.text.trim();
          return InkWell(
            onTap: () {
              setState(() {
                _nameCtrl.text = name;
                _nameCtrl.selection = TextSelection.collapsed(
                  offset: name.length,
                );
                _showSuggestions = false;
                final existingUnit = p.unit;
                if (existingUnit != null && existingUnit.trim().isNotEmpty) {
                  _unit = existingUnit;
                  _unitItems = _baseUnits.contains(existingUnit)
                      ? _baseUnits
                      : [..._baseUnits, existingUnit];
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    isExact
                        ? Icons.check_circle_rounded
                        : Icons.inventory_2_rounded,
                    size: 16,
                    color: isExact ? _green : Colors.white38,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: isExact ? _green : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (models.isNotEmpty)
                          Text(
                            models.take(3).map((m) => m.name).join('، '),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${models.length} مدل',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
