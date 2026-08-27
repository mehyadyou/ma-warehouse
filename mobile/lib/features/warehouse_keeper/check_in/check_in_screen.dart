import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/warehouse_keeper_provider.dart';
import '../models/keeper_product_model.dart';
import '../../../core/network/api_error.dart';
import '../../../shared/widgets/search_picker.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _border = Color(0xFF2A2D33);

class _Row {
  String? productId;
  KeeperProductModel? product;
  String? modelId;
  String entryType = 'NEW';
  bool withoutQr = false;
  int cartonCount = 0;
  int individualCount = 1;
  List<KeeperProductVariantModel> models = [];
  final TextEditingController serialCtrl = TextEditingController();

  void dispose() {
    serialCtrl.dispose();
  }
}

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final List<_Row> _rows = [_Row()];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
  }

  /// مدل انتخاب‌شدهٔ ردیف — null اگر هنوز مدلی انتخاب نشده
  KeeperProductVariantModel? _selectedModel(_Row row) {
    for (final m in row.models) {
      if (m.id == row.modelId) return m;
    }
    return null;
  }

  /// اگر مدل تک‌عددی باشد (هر کارتن = یک عدد) شمارندهٔ «تکی» معنی ندارد —
  /// تعدادش صفر می‌شود تا کاربر گیج نشود.
  void _normalizeIndividual(_Row row) {
    if (_selectedModel(row)?.unitsPerBox == 1) {
      row.individualCount = 0;
    } else if (row.individualCount == 0) {
      row.individualCount = 1;
    }
  }

  /// پیکر جستجوشوندهٔ محصولات — داده فقط صفحه به صفحه از سرور می‌آید
  Future<KeeperProductModel?> _pickProduct() {
    return showSearchPicker<KeeperProductModel>(
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
  }

  /// فیلد محصول با پیکر جستجوشونده
  Widget _productField(_Row row) {
    return GestureDetector(
      onTap: () async {
        final picked = await _pickProduct();
        if (picked == null || !mounted) return;
        setState(() {
          row.product = picked;
          row.productId = picked.id;
          row.modelId = null;
          row.models = picked.models;
        });
      },
      child: Container(
        width: double.infinity,
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
                row.product?.name ?? 'انتخاب محصول...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: row.product != null
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    for (int i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      if (r.productId == null) {
        _snack('ردیف ${i + 1}: محصول انتخاب نشده');
        return;
      }
      if (r.modelId == null) {
        _snack('ردیف ${i + 1}: مدل انتخاب نشده');
        return;
      }
      if (r.entryType == 'RETURNED' && r.serialCtrl.text.trim().isEmpty && !r.withoutQr) {
        _snack('ردیف ${i + 1}: سریال کالا برای مرجوعی الزامی است یا تیک بدون QRcode را بزنید');
        return;
      }
      if (r.cartonCount + r.individualCount == 0) {
        _snack('ردیف ${i + 1}: حداقل یک کارتن یا تکی وارد کنید');
        return;
      }
    }
    setState(() => _submitting = true);
    try {
      final items = _rows
          .map(
            (r) => {
              'productId': r.productId!,
              'modelId': r.modelId!,
              'entryType': r.entryType,
              if (r.entryType == 'RETURNED' && !r.withoutQr)
                'serialNumber': r.serialCtrl.text.trim(),
              if (r.entryType == 'RETURNED')
                'withoutQr': r.withoutQr,
              'cartonCount': r.cartonCount,
              'individualCount': r.individualCount,
            },
          )
          .toList();
      final result = await ref.read(wkApiProvider).submitCheckin(items);
      final cartons = result.cartons.length;
      if (mounted) {
        final serials = result.cartons
            .map((c) => c['serialNumber'] as String?)
            .whereType<String>()
            .toList();
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'ورود ثبت شد',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cartons QR Code تولید شد',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (serials.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'سریال‌ها: ${serials.take(6).join('، ')}${serials.length > 6 ? '، ...' : ''}',
                    style: const TextStyle(color: _green, fontSize: 12),
                  ),
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // اسکن QR مرجوعی: سریال از محتوای QR جدید (MA|SN|...) استخراج می‌شود
  Future<void> _scanReturnSerial(_Row row) async {
    final serial = await showDialog<String>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => const _SerialScannerDialog(),
    );
    if (serial == null || !mounted) return;
    if (serial.isEmpty) {
      _snack('این QR سریال ندارد؛ لطفاً سریال را دستی وارد کنید');
      return;
    }
    setState(() => row.serialCtrl.text = serial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'ورود کالا',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rows.length + 1,
              itemBuilder: (_, i) {
                if (i == _rows.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _rows.add(_Row())),
                      icon: const Icon(Icons.add_rounded, color: _green),
                      label: const Text(
                        'افزودن ردیف',
                        style: TextStyle(color: _green),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _green),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }
                return _buildRow(i);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: _surface,
              border: Border(top: BorderSide(color: _border)),
            ),
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'ثبت ورود کالا',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int i) {
    final row = _rows[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ردیف ${i + 1}',
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (_rows.length > 1)
                GestureDetector(
                  onTap: () => setState(() {
                    final removed = _rows.removeAt(i);
                    removed.dispose();
                  }),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _productField(row),
          _Dropdown(
            value: row.entryType,
            hint: 'نوع ورود',
            items: const [
              DropdownMenuItem<String>(
                value: 'NEW',
                child: Text(
                  'جدید',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              DropdownMenuItem<String>(
                value: 'RETURNED',
                child: Text(
                  'مرجوعی',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                row.entryType = v;
                if (v == 'RETURNED') {
                  row.cartonCount = 0;
                  row.individualCount = 1;
                } else {
                  row.serialCtrl.clear();
                  row.withoutQr = false;
                  _normalizeIndividual(row);
                }
              });
            },
          ),
          const SizedBox(height: 8),
          _productField(row),
          const SizedBox(height: 8),
          _Dropdown(
            value: row.modelId,
            hint: 'انتخاب مدل',
            items: row.models.map((m) {
              final cap = m.unitsPerBox;
              final unit = row.product?.unit?.trim().isNotEmpty == true
                  ? row.product!.unit!
                  : 'عدد';
              final pkg = m.packageType ?? 'کارتن';
              return DropdownMenuItem<String>(
                value: m.id,
                child: Text(
                  cap != null ? '${m.name} ($cap $unit/$pkg)' : m.name,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: row.productId == null
                ? null
                : (v) => setState(() {
                    row.modelId = v;
                    _normalizeIndividual(row);
                  }),
          ),
          const SizedBox(height: 10),
          if (row.entryType == 'RETURNED') ...[
            Row(
              children: [
                Checkbox(
                  value: row.withoutQr,
                  activeColor: _green,
                  onChanged: (v) =>
                      setState(() => row.withoutQr = v ?? false),
                ),
                const Text(
                  'بدون QRcode',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(width: 8),
                const Text(
                  '(بدون سریال و برچسب)',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
            if (!row.withoutQr) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _TextField(
                      controller: row.serialCtrl,
                      label: 'سریال کالا',
                      hint: 'سریال یکتای کالا را وارد کنید',
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _scanReturnSerial(row),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: _green.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: _green,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _green.withValues(alpha: 0.18)),
              ),
              child: Text(
                row.withoutQr
                    ? 'مرجوعی بدون QR: سریال جدید ساخته می‌شود و کالا به عنوان مرجوعی ثبت می‌گردد.'
                    : 'مرجوعی به صورت یک عدد تکی با سریال یکتا ثبت می‌شود.',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ] else
            Builder(
              builder: (context) {
                final isSingleUnit = _selectedModel(row)?.unitsPerBox == 1;
                return Row(
                  children: [
                    Expanded(
                      child: _Counter(
                        label: 'کارتن',
                        value: row.cartonCount,
                        onDec: row.cartonCount > 0
                            ? () => setState(() => row.cartonCount--)
                            : null,
                        onInc: () => setState(() => row.cartonCount++),
                      ),
                    ),
                    if (!isSingleUnit) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Counter(
                          label: 'تکی',
                          value: row.individualCount,
                          onDec: row.individualCount > 0
                              ? () => setState(() => row.individualCount--)
                              : null,
                          onInc: () => setState(() => row.individualCount++),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String? value, hint;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;
  const _Dropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _surfaceAlt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint!,
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
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 13,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 13,
      ),
      filled: true,
      fillColor: _surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _green),
      ),
    ),
  );
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onDec;
  final VoidCallback onInc;
  const _Counter({
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: _surfaceAlt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const Spacer(),
        _Btn(icon: Icons.remove_rounded, enabled: onDec != null, onTap: onDec),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _Btn(icon: Icons.add_rounded, enabled: true, onTap: onInc),
      ],
    ),
  );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  const _Btn({required this.icon, required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: enabled
            ? _green.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(
        icon,
        color: enabled ? _green : Colors.white.withValues(alpha: 0.2),
        size: 15,
      ),
    ),
  );
}

// استخراج سریال از QR جدید (MA|SN|<serial>|...)؛ null یعنی QR سریال ندارد
String? serialFromQr(String raw) {
  final parts = raw.split('|');
  if (parts.length >= 4 && parts[0] == 'MA' && parts[1] == 'SN') {
    return parts[2];
  }
  return null;
}

class _SerialScannerDialog extends StatefulWidget {
  const _SerialScannerDialog();
  @override
  State<_SerialScannerDialog> createState() => _SerialScannerDialogState();
}

class _SerialScannerDialogState extends State<_SerialScannerDialog> {
  final _controller = MobileScannerController();
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || !raw.startsWith('MA|')) return;
    _done = true;
    Navigator.pop(context, serialFromQr(raw) ?? '');
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(24),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 340,
        child: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomCenter,
              color: Colors.black54,
              child: const Text(
                'QR کارتن را اسکن کنید — سریال به صورت خودکار وارد می‌شود',
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, null),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
