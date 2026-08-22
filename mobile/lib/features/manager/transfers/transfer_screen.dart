import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/network/api_error.dart';
import '../../../shared/utils/numbers.dart';
import '../../../shared/widgets/search_picker.dart';
import '../data/manager_api_service.dart';
import '../models/product_model.dart';
import '../models/transfer_model.dart';
import '../models/warehouse_model.dart';
import '../providers/manager_api_provider.dart';
import '../providers/warehouses_provider.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _red = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

String _jDate(String iso) {
  try {
    final j = Jalali.fromDateTime(DateTime.parse(iso));
    return '${j.year}/${j.month}/${j.day}';
  } catch (_) {
    return '—';
  }
}

/// جابه‌جایی/خروج محصول: مدیر تعیین می‌کند چه محصول و مدلی از کدام انبار
/// خارج شود یا به انبار دیگری منتقل شود — ثبت‌شده در بک‌اند روی کارتن‌ها
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);

  // فرم
  String? _fromId;
  bool _isTransfer = false;
  String? _toId;
  ProductModel? _product;
  String? _modelId;
  final _qtyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _submitting = false;

  // موجودی نمایشی (راهنمایی — اعتبارسنجی نهایی با سرور است)
  num? _available;
  bool _stockLoading = false;
  int _stockSeq = 0;

  // تاریخچه
  List<TransferModel> _transfers = [];
  bool _histLoading = true;
  String? _histError;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _histLoading = true;
      _histError = null;
    });
    try {
      final list = await _api.getTransfers(limit: 20);
      if (!mounted) return;
      setState(() {
        _transfers = list;
        _histLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _histLoading = false;
        _histError = 'خطا در دریافت آخرین جابه‌جایی‌ها';
      });
    }
  }

  Future<void> _loadAvailability() async {
    final product = _product;
    final fromId = _fromId;
    if (product == null || fromId == null) {
      setState(() => _available = null);
      return;
    }
    final seq = ++_stockSeq;
    setState(() => _stockLoading = true);
    try {
      final data = await _api.getProductModels(product.id);
      if (!mounted || seq != _stockSeq) return;
      final model = data.models
          .where((m) => (m.modelId ?? '') == (_modelId ?? ''))
          .firstOrNull;
      final count =
          model?.warehouses
              .where((w) => w.warehouseId == fromId)
              .fold<num>(0, (sum, w) => sum + w.count) ??
          0;
      setState(() {
        _available = count;
        _stockLoading = false;
      });
    } catch (_) {
      if (!mounted || seq != _stockSeq) return;
      setState(() {
        _available = null;
        _stockLoading = false;
      });
    }
  }

  Future<ProductModel?> _pickProduct() {
    return showSearchPicker<ProductModel>(
      context: context,
      title: 'انتخاب محصول',
      loader: (q, page) async {
        final r = await _api.getProductsPage(
          q: q.isEmpty ? null : q,
          page: page,
          pageSize: 50,
        );
        return (items: r.products, total: r.total);
      },
      labelOf: (p) => p.name,
      subtitleOf: (p) =>
          (p.unit ?? '').trim().isNotEmpty ? 'واحد: ${p.unit}' : null,
    );
  }

  void _onFromChanged(String? id) {
    setState(() {
      _fromId = id;
      if (_isTransfer && _toId == id) _toId = null;
    });
    _loadAvailability();
  }

  void _onProductPicked(ProductModel picked) {
    setState(() {
      _product = picked;
      _modelId = null;
    });
    _loadAvailability();
  }

  void _onModelChanged(String? id) {
    setState(() => _modelId = id);
    _loadAvailability();
  }

  int? _parseQty(String text) {
    final digits = normalizeDigits(text.trim());
    if (digits.isEmpty) return null;
    final value = int.tryParse(digits);
    return (value == null || value <= 0) ? null : value;
  }

  Future<void> _submit() async {
    if (_fromId == null) {
      _snack('انبار مبدأ را انتخاب کنید');
      return;
    }
    if (_isTransfer && _toId == null) {
      _snack('برای جابه‌جایی، انبار مقصد را انتخاب کنید');
      return;
    }
    if (_isTransfer && _toId == _fromId) {
      _snack('انبار مبدأ و مقصد نمی‌توانند یکی باشند');
      return;
    }
    if (_product == null) {
      _snack('محصول را انتخاب کنید');
      return;
    }
    final qty = _parseQty(_qtyCtrl.text);
    if (qty == null) {
      _snack('تعداد را به‌صورت عدد صحیح وارد کنید');
      return;
    }
    final available = _available;
    if (available != null && qty > available) {
      _snack('موجودی کافی نیست (موجودی: ${formatNumber(available)})');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.createTransfer(
        fromWarehouseId: _fromId!,
        toWarehouseId: _isTransfer ? _toId : null,
        productId: _product!.id,
        modelId: _modelId,
        quantity: qty,
        description: _descCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isTransfer
                ? 'دستور جابه‌جایی ثبت شد و برای اجرا به انباردار ابلاغ شد'
                : 'دستور خروج ثبت شد و برای اجرا به انباردار ابلاغ شد',
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _product = null;
        _modelId = null;
        _qtyCtrl.clear();
        _descCtrl.clear();
        _available = null;
      });
      _loadHistory();
    } catch (e) {
      if (mounted) _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _red));
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehousesProvider);
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
          'جابه‌جایی محصول',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              children: [
                _headerHint(),
                const SizedBox(height: 14),
                _section(
                  'انبار مبدأ',
                  _warehousesAsyncWidget(
                    warehousesAsync,
                    (list) => _dropdown(
                      value: _fromId,
                      items: list,
                      hint: 'انبار مبدأ را انتخاب کنید',
                      onChanged: _onFromChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _transferSwitch(),
                if (_isTransfer) ...[
                  const SizedBox(height: 12),
                  _section(
                    'انبار مقصد',
                    _warehousesAsyncWidget(
                      warehousesAsync,
                      (list) => _dropdown(
                        value: _toId,
                        items: list.where((w) => w.id != _fromId).toList(),
                        hint: 'انبار مقصد را انتخاب کنید',
                        onChanged: (id) => setState(() => _toId = id),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _section('محصول', _productField()),
                if (_product != null) ...[
                  const SizedBox(height: 12),
                  _section('مدل', _modelField()),
                ],
                const SizedBox(height: 12),
                _section('مقدار (تعداد)', _qtyField()),
                const SizedBox(height: 12),
                _section('توضیحات (اختیاری)', _descField()),
                const SizedBox(height: 20),
                _historyHeader(),
                _historySection(),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _headerHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horizontal_circle_rounded,
              color: _green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'محصول و مدل موردنظر را از انبار مبدأ انتخاب کنید؛ با تیک «جابه‌جایی» مقصد تعیین می‌شود، در غیر این صورت کالا از انبار خارج می‌شود. دستور ثبت می‌شود و انباردار با اسکن کارتن‌ها آن را اجرا می‌کند.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transferSwitch() {
    return Material(
      color: _surfaceAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _border),
      ),
      child: SwitchListTile(
        value: _isTransfer,
        onChanged: (v) => setState(() {
          _isTransfer = v;
          if (!v) _toId = null;
        }),
        activeThumbColor: _green,
        activeTrackColor: _green.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'جابه‌جایی به انبار دیگر',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          _isTransfer
              ? 'کالا به انبار مقصد منتقل می‌شود'
              : 'کالا از انبار خارج می‌شود',
          style: const TextStyle(color: _textDim, fontSize: 11.5),
        ),
      ),
    );
  }

  Widget _warehousesAsyncWidget(
    AsyncValue<List<WarehouseModel>> async,
    Widget Function(List<WarehouseModel> list) builder,
  ) {
    return async.when(
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _green),
          ),
        ),
      ),
      error: (_, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: _textDim, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'خطا در دریافت انبارها',
                style: TextStyle(color: _textDim, fontSize: 12.5),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(warehousesProvider.notifier).refresh(),
              child: const Text(
                'تلاش دوباره',
                style: TextStyle(color: _green, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
      data: (list) => builder(list),
    );
  }

  Widget _dropdown({
    required String? value,
    required List<WarehouseModel> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'انباری ثبت نشده است',
          style: TextStyle(color: _textDim, fontSize: 13),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: value != null ? _green : _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _surfaceAlt,
          hint: Text(
            hint,
            style: const TextStyle(color: _textDim, fontSize: 13),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textDim),
          items: [
            for (final w in items)
              DropdownMenuItem(value: w.id, child: Text(w.name)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _productField() {
    final product = _product;
    return GestureDetector(
      onTap: () async {
        final picked = await _pickProduct();
        if (picked != null && mounted) _onProductPicked(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: product != null ? _green : _border),
        ),
        child: Row(
          children: [
            Icon(
              product != null
                  ? Icons.inventory_2_rounded
                  : Icons.search_rounded,
              color: product != null ? _green : _textDim,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                product?.name ?? 'انتخاب محصول...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: product != null ? Colors.white : _textDim,
                  fontSize: 13,
                  fontWeight: product != null
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: _textDim, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _modelField() {
    final models = _product?.models ?? const [];
    final noModel = models.isEmpty;
    if (noModel) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'بدون مدل',
          style: TextStyle(color: _textDim, fontSize: 13),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _modelId != null ? _green : _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _modelId,
          isExpanded: true,
          dropdownColor: _surfaceAlt,
          hint: const Text(
            'انتخاب مدل...',
            style: TextStyle(color: _textDim, fontSize: 13),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textDim),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('بدون مدل'),
            ),
            for (final m in models)
              DropdownMenuItem(value: m.id, child: Text(m.name)),
          ],
          onChanged: _onModelChanged,
        ),
      ),
    );
  }

  Widget _qtyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _qtyCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'مثلاً ۱۰',
            hintStyle: const TextStyle(color: _textDim, fontSize: 13),
            filled: true,
            fillColor: _surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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
            isDense: true,
          ),
        ),
        const SizedBox(height: 6),
        _availabilityLabel(),
      ],
    );
  }

  Widget _availabilityLabel() {
    if (_stockLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: _green),
          ),
          SizedBox(width: 6),
          Text(
            'در حال بررسی موجودی...',
            style: TextStyle(color: _textDim, fontSize: 11),
          ),
        ],
      );
    }
    final available = _available;
    if (available != null) {
      return Text(
        'موجودی این مدل در انبار مبدأ: ${formatNumber(available)} واحد',
        style: TextStyle(
          color: available > 0 ? _green : _textDim,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return const Text(
      'پس از انتخاب انبار، محصول و مدل، موجودی نمایش داده می‌شود',
      style: TextStyle(color: _textDim, fontSize: 11),
    );
  }

  Widget _descField() {
    return TextField(
      controller: _descCtrl,
      maxLines: 2,
      maxLength: 500,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'توضیح اختیاری برای این خروج/جابه‌جایی...',
        hintStyle: const TextStyle(color: _textDim, fontSize: 13),
        filled: true,
        fillColor: _surfaceAlt,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
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
        isDense: true,
      ),
    );
  }

  Widget _historyHeader() {
    return Row(
      children: [
        const Icon(Icons.history_rounded, color: _textDim, size: 18),
        const SizedBox(width: 6),
        const Text(
          'آخرین جابه‌جایی‌ها',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (!_histLoading && _histError == null)
          GestureDetector(
            onTap: _loadHistory,
            child: const Icon(Icons.refresh_rounded, color: _textDim, size: 18),
          ),
      ],
    );
  }

  Widget _historySection() {
    if (_histLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: _green),
          ),
        ),
      );
    }
    if (_histError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: _textDim, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _histError!,
                style: const TextStyle(color: _textDim, fontSize: 12.5),
              ),
            ),
            TextButton(
              onPressed: _loadHistory,
              child: const Text(
                'تلاش دوباره',
                style: TextStyle(color: _green, fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }
    if (_transfers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'هنوز جابه‌جایی یا خروجی ثبت نشده است',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textDim, fontSize: 12.5),
        ),
      );
    }
    return Column(
      children: [
        for (final t in _transfers) ...[
          _transferCard(t),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Future<void> _cancelTransfer(TransferModel t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceAlt,
        title: const Text(
          'لغو دستور',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Text(
          'دستور «${t.productName}» (${formatNumber(t.quantity)} واحد) لغو شود؟',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('بازگشت', style: TextStyle(color: _textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('لغو دستور', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _api.cancelTransfer(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دستور لغو شد'), backgroundColor: _amber),
      );
      _loadHistory();
    } catch (e) {
      if (mounted) _snack(friendlyError(e));
    }
  }

  Widget _transferCard(TransferModel t) {
    final isTransfer = t.toWarehouseId != null;
    final status = t.status;
    final color = status == 'DONE'
        ? _green
        : status == 'CANCELED'
        ? Colors.white38
        : _amber;
    final statusLabel = status == 'DONE'
        ? 'تکمیل‌شده'
        : status == 'CANCELED'
        ? 'لغوشده'
        : 'در انتظار اجرا';
    final progress =
        t.quantity > 0 ? (t.executedUnits / t.quantity).clamp(0.0, 1.0) : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'DONE' ? _green.withValues(alpha: 0.35) : _border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  status == 'CANCELED'
                      ? Icons.cancel_rounded
                      : isTransfer
                      ? Icons.swap_horizontal_circle_rounded
                      : Icons.logout_rounded,
                  color: color,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        t.productName,
                        if ((t.modelName ?? '').trim().isNotEmpty)
                          t.modelName!.trim(),
                      ].where((p) => p.isNotEmpty).join(' — '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isTransfer
                          ? '${t.fromWarehouseName} ← ${t.toWarehouseName}'
                          : 'خروج از ${t.fromWarehouseName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.9),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((t.description.trim().isNotEmpty)) ...[
                      const SizedBox(height: 3),
                      Text(
                        t.description.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _textDim, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatNumber(t.quantity)} واحد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(color: color, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _jDate(t.createdAt.toIso8601String()),
                    style: const TextStyle(color: _textDim, fontSize: 10.5),
                  ),
                ],
              ),
            ],
          ),
          if (status == 'PENDING') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'اجرا شده ${formatNumber(t.executedUnits)} از ${formatNumber(t.quantity)} واحد',
                  style: const TextStyle(color: _textDim, fontSize: 10.5),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _cancelTransfer(t),
                  child: const Text(
                    'لغو دستور',
                    style: TextStyle(color: _red, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      child,
    ],
  );

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(color: _surface),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Icon(
                    _isTransfer
                        ? Icons.swap_horizontal_circle_rounded
                        : Icons.logout_rounded,
                    size: 19,
                  ),
            label: Text(
              _submitting
                  ? 'در حال ثبت...'
                  : _isTransfer
                  ? 'ثبت جابه‌جایی'
                  : 'ثبت خروج',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
