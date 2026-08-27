import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/palette.dart';
import 'app_widgets.dart';

/// جستجوی محصولات تعریف‌شده توسط مدیر — با جستجوی سمت سرور
class ProductPickerDialog extends StatefulWidget {
  const ProductPickerDialog({super.key, required this.api});

  final ApiService api;

  @override
  State<ProductPickerDialog> createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<ProductPickerDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<dynamic> _results = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final result = await widget.api.getProducts(q: q, page: 1, pageSize: 50);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _results = result.products;
      });
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = exc.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.surfaceAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'انتخاب محصول',
                      style: TextStyle(
                        color: Palette.text,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: Palette.textMuted,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onQueryChanged,
                style: const TextStyle(color: Palette.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'جستجوی محصول یا مدل...',
                  hintStyle: const TextStyle(color: Palette.textMuted),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Palette.textMuted,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: Palette.appBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Palette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Palette.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Palette.primary),
                    )
                  : _error.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Palette.danger,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : _results.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'محصولی یافت نشد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Palette.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final product = _results[index];
                        final models = product is Map<String, dynamic>
                            ? (product['models'] as List<dynamic>? ?? [])
                            : const <dynamic>[];
                        final unit = product is Map<String, dynamic>
                            ? ((product['unit']?.toString() ?? '').trim().isEmpty
                                  ? 'عدد'
                                  : product['unit'].toString())
                            : 'عدد';
                        final name = product is Map<String, dynamic>
                            ? (product['name']?.toString() ?? '—')
                            : '—';
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            hoverColor: Palette.surfaceHover,
                            onTap: () => Navigator.of(context).pop(product),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Palette.text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'واحد: $unit | ${models.length} مدل',
                                    style: const TextStyle(
                                      color: Palette.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInRow {
  Map<String, dynamic>? product;
  String? modelId;
  String entryType = 'NEW';
  bool withoutQr = false;
  final TextEditingController serialCtrl = TextEditingController();
  int cartonCount = 0;
  int individualCount = 1;

  List<dynamic> get models =>
      (product?['models'] as List<dynamic>?) ?? const [];

  void dispose() => serialCtrl.dispose();
}

/// فرم ورود کالا به انبار — مثل سیستم شمارش موبایل: محصول + مدل + کارتن/تکی
class CheckInDialog extends StatefulWidget {
  const CheckInDialog({super.key, required this.api, required this.onSuccess});

  final ApiService api;

  /// بعد از ثبت موفق ورود صدا زده می‌شود (برای بارگذاری مجدد لیست)
  final VoidCallback onSuccess;

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  final List<_CheckInRow> _rows = [_CheckInRow()];
  bool _submitting = false;
  String _error = '';

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.surfaceAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ورود کالا به انبار',
                      style: TextStyle(
                        color: Palette.text,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: Palette.textMuted,
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (var i = 0; i < _rows.length; i++) ...[
                    _buildRow(i),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _rows.add(_CheckInRow())),
                    icon: const Icon(Icons.add_rounded, color: Palette.primary),
                    label: const Text(
                      'افزودن ردیف',
                      style: TextStyle(color: Palette.primary, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Palette.primary),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error.isNotEmpty) ...[
                    Text(
                      _error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Palette.danger,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: _submitting ? 'در حال ثبت...' : 'ثبت ورود کالا',
                      height: 46,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    final row = _rows[index];
    final unit = (row.product?['unit']?.toString() ?? '').trim().isEmpty
        ? 'عدد'
        : row.product!['unit'].toString();
    final isReturned = row.entryType == 'RETURNED';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Palette.appBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ردیف ${index + 1}',
                style: const TextStyle(
                  color: Palette.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_rows.length > 1)
                GestureDetector(
                  onTap: () => setState(() => _rows.removeAt(index)),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Palette.textMuted,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // نوع ورود: کالای نو / مرجوعی
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Palette.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Palette.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: row.entryType,
                isExpanded: true,
                dropdownColor: Palette.surfaceAlt,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Palette.textMuted,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'NEW',
                    child: Text('کالای نو',
                        style: TextStyle(color: Palette.text, fontSize: 13)),
                  ),
                  DropdownMenuItem(
                    value: 'RETURNED',
                    child: Text('مرجوعی',
                        style: TextStyle(color: Palette.text, fontSize: 13)),
                  ),
                ],
                onChanged: _submitting
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() {
                          row.entryType = v;
                          if (v == 'RETURNED') {
                            row.cartonCount = 0;
                            row.individualCount = 1;
                          }
                        });
                      },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // انتخاب محصول
          Material(
            color: Palette.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              hoverColor: Palette.surfaceHover,
              onTap: _submitting ? null : () => _pickProduct(row),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Palette.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.product?['name']?.toString() ?? 'انتخاب محصول...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: row.product != null
                              ? Palette.text
                              : Palette.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.search_rounded,
                      color: Palette.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // انتخاب مدل
          Material(
            color: Palette.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Palette.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: row.modelId,
                  hint: const Text(
                    'انتخاب مدل',
                    style: TextStyle(color: Palette.textMuted, fontSize: 13),
                  ),
                  isExpanded: true,
                  dropdownColor: Palette.surfaceAlt,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Palette.textMuted,
                  ),
                  items: [
                    for (final model in row.models)
                      DropdownMenuItem<String>(
                        value: model['id']?.toString(),
                        child: Text(
                          _modelLabel(model, unit),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Palette.text,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                  onChanged: row.product == null || _submitting
                      ? null
                      : (v) => setState(() => row.modelId = v),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // تیک بدون QRcode — همیشه نمایش داده می‌شود؛ فقط در حالت مرجوعی فعال است
          Row(
            children: [
              Checkbox(
                value: row.withoutQr,
                activeColor: Palette.primary,
                onChanged: !isReturned || _submitting
                    ? null
                    : (v) => setState(() => row.withoutQr = v ?? false),
              ),
              Text(
                'بدون QRcode',
                style: TextStyle(
                  color: isReturned ? Palette.text : Palette.textMuted,
                  fontSize: 13,
                ),
              ),
              if (isReturned) ...[
                const SizedBox(width: 8),
                const Text(
                  '(بدون سریال و برچسب)',
                  style: TextStyle(
                    color: Palette.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
          // مرجوعی با سریال: فیلد سریال / اسکن
          if (isReturned && !row.withoutQr)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: row.serialCtrl,
                enabled: !_submitting,
                style: const TextStyle(color: Palette.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'سریال یا اسکن QR',
                  hintStyle: const TextStyle(color: Palette.textMuted),
                  filled: true,
                  fillColor: Palette.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Palette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Palette.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          // شمارنده کارتن/تکی
          Row(
            children: [
              Expanded(
                child: _Counter(
                  label: 'کارتن',
                  value: row.cartonCount,
                  incKey: Key('row-$index-carton-inc'),
                  decKey: Key('row-$index-carton-dec'),
                  onDec: row.cartonCount > 0 && !_submitting && !isReturned
                      ? () => setState(() => row.cartonCount--)
                      : null,
                  onInc: _submitting || isReturned
                      ? null
                      : () => setState(() => row.cartonCount++),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Counter(
                  label: 'تکی',
                  value: row.individualCount,
                  incKey: Key('row-$index-tak-inc'),
                  decKey: Key('row-$index-tak-dec'),
                  onDec: row.individualCount > 0 && !_submitting && !isReturned
                      ? () => setState(() => row.individualCount--)
                      : null,
                  onInc: _submitting || isReturned
                      ? null
                      : () => setState(() => row.individualCount++),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _modelLabel(Map<String, dynamic> model, String unit) {
    final name = model['name']?.toString() ?? '—';
    final cap = model['unitsPerBox'];
    if (cap is num && cap > 0) {
      final pkg = (model['packageType']?.toString() ?? '').trim().isEmpty
          ? 'کارتن'
          : model['packageType'].toString();
      return '$name ($cap $unit/$pkg)';
    }
    return name;
  }

  /// اگر متن خام USB اسکنر با MA|SN| شروع شود، سریال را استخراج کن
  /// وگرنه همان متن خام = سریال
  String _extractSerial(String raw) {
    if (raw.startsWith('MA|SN|')) {
      final parts = raw.split('|');
      if (parts.length >= 3) return parts[2];
    }
    return raw;
  }

  Future<void> _pickProduct(_CheckInRow row) async {
    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductPickerDialog(api: widget.api),
    );
    if (picked == null || !mounted) return;
    setState(() {
      row.product = picked;
      row.modelId = null;
    });
  }

  Future<void> _submit() async {
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      if (r.product == null) {
        setState(() => _error = 'ردیف ${i + 1}: محصول انتخاب نشده');
        return;
      }
      if (r.modelId == null) {
        setState(() => _error = 'ردیف ${i + 1}: مدل انتخاب نشده');
        return;
      }
      if (r.cartonCount + r.individualCount == 0) {
        setState(
          () => _error = 'ردیف ${i + 1}: حداقل یک کارتن یا تکی وارد کنید',
        );
        return;
      }
      if (r.entryType == 'RETURNED') {
        final raw = r.serialCtrl.text.trim();
        if (raw.isEmpty && !r.withoutQr) {
          setState(
            () => _error =
                'ردیف ${i + 1}: برای مرجوعی سریال وارد کنید یا تیک بدون QRcode را بزنید',
          );
          return;
        }
      }
    }
    setState(() {
      _submitting = true;
      _error = '';
    });
    try {
      final items = [
        for (final r in _rows)
          {
            'productId': r.product!['id'].toString(),
            'modelId': r.modelId,
            'entryType': r.entryType,
            if (r.entryType == 'RETURNED' && !r.withoutQr)
              'serialNumber': _extractSerial(r.serialCtrl.text.trim()),
            if (r.entryType == 'RETURNED')
              'withoutQr': r.withoutQr,
            'cartonCount': r.cartonCount,
            'individualCount': r.individualCount,
          },
      ];
      // کلید ایدمپوتنسی: با یک کلید تکراری، ورود دوباره ثبت نمی‌شود
      final clientKey =
          '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 31)}';
      final cartons = await widget.api.submitCheckin(
        items,
        clientKey: clientKey,
      );
      if (!mounted) return;
      final serials = cartons
          .map(
            (c) => c is Map<String, dynamic>
                ? c['serialNumber']?.toString()
                : null,
          )
          .whereType<String>()
          .toList();
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Palette.surfaceAlt,
          title: const Text(
            'ورود ثبت شد',
            style: TextStyle(color: Palette.text, fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cartons.length} QR Code تولید شد',
                style: const TextStyle(
                  color: Palette.textMuted,
                  fontSize: 13,
                ),
              ),
              if (serials.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'سریال‌ها: ${serials.take(6).join('، ')}${serials.length > 6 ? '، ...' : ''}',
                  style: const TextStyle(
                    color: Palette.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'باشه',
                style: TextStyle(color: Palette.primary),
              ),
            ),
          ],
        ),
      );
      if (ok == true && mounted) {
        Navigator.of(context).pop(); // بستن دیالوگ ورود کالا
        widget.onSuccess();
      }
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = exc.toString();
      });
    }
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
    required this.incKey,
    required this.decKey,
  });

  final String label;
  final int value;
  final VoidCallback? onDec;
  final VoidCallback? onInc;
  final Key incKey;
  final Key decKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Palette.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Palette.textMuted, fontSize: 12),
          ),
          const Spacer(),
          _CountBtn(
            key: decKey,
            icon: Icons.remove_rounded,
            enabled: onDec != null,
            onTap: onDec,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Palette.text,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _CountBtn(
            key: incKey,
            icon: Icons.add_rounded,
            enabled: onInc != null,
            onTap: onInc,
          ),
        ],
      ),
    );
  }
}

class _CountBtn extends StatelessWidget {
  const _CountBtn({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: enabled
              ? Palette.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          color: enabled ? Palette.primary : Colors.white.withValues(alpha: 0.2),
          size: 15,
        ),
      ),
    );
  }
}
