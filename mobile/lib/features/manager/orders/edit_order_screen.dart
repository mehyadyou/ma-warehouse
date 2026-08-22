import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ma_app/features/manager/data/manager_api_service.dart';
import 'package:ma_app/features/manager/providers/manager_api_provider.dart';
import 'package:ma_app/features/manager/models/order_model.dart';
import 'package:ma_app/features/manager/models/product_model.dart';
import 'package:ma_app/features/manager/models/carrier_model.dart';
import 'package:ma_app/shared/widgets/search_picker.dart';
import 'package:ma_app/core/network/api_error.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _warning = Color(0xFFFBBF24);
const _red = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);
const _faDigits = '۰۱۲۳۴۵۶۷۸۹';

String _fa(String? s) => s == null
    ? ''
    : s.replaceAllMapped(
        RegExp(r'[0-9]'),
        (m) => _faDigits[m.group(0)!.codeUnitAt(0) - 48],
      );

String _format(num n) {
  final s = n.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return _fa(buf.toString());
}

/// نرمال‌سازی ارقام فارسی/عربی + حذف جداکننده‌ها قبل از parse
String _enDigits(String s) => s.replaceAllMapped(
      RegExp(r'[۰-۹٠-٩]'),
      (m) {
        final c = m.group(0)!.codeUnitAt(0);
        final d = (c >= 0x06F0 && c <= 0x06F9) ? c - 0x06F0 : c - 0x0660;
        return '$d';
      },
    );

int? _parseQty(String s) =>
    int.tryParse(_enDigits(s.trim().replaceAll(',', '').replaceAll('،', '')));

double? _parseDouble(String s) => double.tryParse(
  _enDigits(s.trim().replaceAll(',', '').replaceAll('،', '')),
);

String _statusLabel(String? s) => switch (s) {
  'PENDING' => 'در انتظار',
  'IN_TRANSIT' => 'در مسیر',
  'DELIVERED' => 'تحویل‌شده',
  _ => (s ?? '—').isEmpty ? '—' : s!,
};

/// صفحهٔ ویرایش سفارش — بر اساس دادهٔ موجود پیش‌پر می‌شود
class EditOrderScreen extends ConsumerStatefulWidget {
  final String orderId;
  final OrderModel order;

  const EditOrderScreen({
    super.key,
    required this.orderId,
    required this.order,
  });

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  final _shippingMethods = ['باربری', 'تیپاکس', 'شهری'];

  List<CarrierModel> _carriers = [];

  List<String> get _carrierValues =>
      _carriers.map((c) => (c.id ?? c.name ?? '').toString()).toList();
  List<String> get _carrierLabels =>
      _carriers.map((c) => (c.name ?? '').toString()).toList();
  final List<_EditItemRow> _rows = [];
  bool _saving = false;
  bool _loading = true;
  String? _loadError;
  double? _dollarRate;

  String _shippingMethod = 'باربری';
  String? _selectedCarrier;

  /// در وضعیت‌های غیر از «در انتظار» اقلام قفل هستند و فقط فیلدهای ارسال ویرایش می‌شوند
  bool get _canEditItems => widget.order.status == 'PENDING';

  final _senderCtrl = TextEditingController();
  final _receiverCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _shippingMethod = o.shippingMethod ?? 'باربری';
    _selectedCarrier = o.carrier;
    _senderCtrl.text = o.senderName ?? '';
    _receiverCtrl.text = o.receiverName ?? '';
    _phoneCtrl.text = o.customerPhone ?? '';
    _cityCtrl.text = o.city ?? '';
    _addressCtrl.text = o.address ?? '';
    _postalCtrl.text = o.postalCode ?? '';
    _load();
  }

  @override
  void dispose() {
    _senderCtrl.dispose();
    _receiverCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _postalCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    // باربری‌ها و نرخ دلار اختیاری‌اند؛ شکستشان نباید بارگذاری را بشکند
    final cRes = await _api
        .getCarriers()
        .then<List<CarrierModel>>((v) => v)
        .catchError((_) => <CarrierModel>[]);
    final rate = await _api
        .getDollarRate()
        .then<double?>((v) => v)
        .catchError((_) => null);
    if (!mounted) return;
    setState(() {
      _carriers = cRes;
      _dollarRate = rate;

      // ساخت ردیف‌های اقلام از داده سفارش (همیشه از داده‌ی پیش‌فرض widget.order)
      _rows.clear();
      final items = widget.order.items;
      for (final item in items) {
        final row = _EditItemRow(
          productId: item.productId ?? '',
          productName: item.productName ?? '',
          quantity: item.quantity.toInt(),
          modelName: item.model,
          price: item.price?.toDouble(),
          exchangeRate: item.exchangeRate?.toDouble(),
        );
        _rows.add(row);
      }
      if (_rows.isEmpty) _rows.add(_EditItemRow());

      // یافتن باربری بر اساس نام ذخیره‌شده
      final carrierName = _selectedCarrier;
      if (carrierName != null && carrierName.isNotEmpty) {
        final match = _carriers.firstWhere(
          (c) => (c.name ?? '') == carrierName,
          orElse: () => CarrierModel(),
        );
        if (match.name != null || match.id != null)
          _selectedCarrier = (match.id ?? carrierName).toString();
      }

      _loading = false;
    });
  }

  void _addRow() {
    setState(() => _rows.add(_EditItemRow()));
  }

  void _removeRow(int i) {
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
    });
  }

  Future<void> _save() async {
    final canEditItems = _canEditItems;
    if (canEditItems) {
      if (_rows.isEmpty) {
        _snack('حداقل یک محصول اضافه کنید', error: true);
        return;
      }

      for (int i = 0; i < _rows.length; i++) {
        final r = _rows[i];
        if (r.productId.isEmpty) {
          _snack('ردیف ${i + 1}: محصول انتخاب نشده', error: true);
          return;
        }
        if (_parseQty(r.qtyCtrl.text) == null ||
            _parseQty(r.qtyCtrl.text)! <= 0) {
          _snack('ردیف ${i + 1}: تعداد معتبر نیست', error: true);
          return;
        }
        final priceVal = _parseDouble(r.priceCtrl.text);
        if (priceVal != null &&
            priceVal > 0 &&
            r.priceUnit == 'دلار' &&
            _dollarRate == null) {
          _snack(
            'ردیف ${i + 1}: نرخ لحظه‌ای دلار در دسترس نیست؛ واحد قیمت را به تومان تغییر دهید',
            error: true,
          );
          return;
        }
      }
    }
    if (_senderCtrl.text.trim().isEmpty) {
      _snack('نام فرستنده الزامی است', error: true);
      return;
    }
    if (_receiverCtrl.text.trim().isEmpty) {
      _snack('نام گیرنده الزامی است', error: true);
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _snack('شماره تماس الزامی است', error: true);
      return;
    }
    if (_cityCtrl.text.trim().isEmpty) {
      _snack('شهر الزامی است', error: true);
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      _snack('آدرس الزامی است', error: true);
      return;
    }
    if (_shippingMethod != 'باربری' && _postalCtrl.text.trim().isEmpty) {
      _snack('کد پستی الزامی است', error: true);
      return;
    }
    if (_shippingMethod == 'باربری' && _selectedCarrier == null) {
      _snack('باربری را انتخاب کنید', error: true);
      return;
    }

    final carrierName = _selectedCarrier != null && _carriers.isNotEmpty
        ? (_carriers
                  .firstWhere(
                    (c) =>
                        (c.id ?? c.name ?? '').toString() == _selectedCarrier,
                    orElse: () => CarrierModel(name: _selectedCarrier),
                  )
                  .name ??
              _selectedCarrier)
        : _selectedCarrier;

    setState(() => _saving = true);
    try {
      await _api.updateOrder(widget.orderId, {
        if (canEditItems)
          'items': [
            for (final r in _rows)
              {
                'productId': r.productId,
                'quantity': _parseQty(r.qtyCtrl.text) ?? 1,
                'model': r.modelName,
                'price': r.priceToman(_dollarRate),
                // نرخ ارز فقط برای ردیف‌های دلاری ذخیره می‌شود
                if (r.priceUnit == 'دلار')
                  'exchangeRate': r.exchangeRate(_dollarRate),
              },
          ],
        'shippingMethod': _shippingMethod,
        'carrier': carrierName,
        'city': _cityCtrl.text,
        'postalCode': _postalCtrl.text,
        'address': _addressCtrl.text,
        'customerPhone': _enDigits(_phoneCtrl.text),
        'senderName': _senderCtrl.text.isEmpty ? null : _senderCtrl.text,
        'receiverName': _receiverCtrl.text.isEmpty ? null : _receiverCtrl.text,
        'version': widget.order.version,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سفارش ویرایش شد'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      if (e is DioException && e.response?.statusCode == 409) {
        _snack(
          'این سفارش هم‌زمان توسط شخص دیگری ویرایش شده است؛ صفحه را ببندید و دوباره باز کنید',
          error: true,
        );
      } else {
        _snack('خطا در ذخیره: ${friendlyError(e)}', error: true);
      }
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ? '$msg' : msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ویرایش سفارش',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _green, strokeWidth: 2.5),
      );
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: const BorderSide(color: _green),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              // ─── انبار مقصد (فقط نمایشی) ───
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _green.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      color: _green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'انبار مقصد',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.order.warehouseName ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── وضعیت سفارش ───
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_canEditItems ? _green : _warning).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _canEditItems
                          ? Icons.pending_actions_rounded
                          : Icons.lock_outline_rounded,
                      color: _canEditItems ? _green : _warning,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'وضعیت: ',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _statusLabel(widget.order.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (!_canEditItems) ...[
                            const SizedBox(height: 3),
                            Text(
                              'در این وضعیت اقلام سفارش قابل ویرایش نیست؛ فقط اطلاعات ارسال قابل تغییر است',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اقلام سفارش',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _rows.length; i++) _buildRow(i),
              if (_canEditItems)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: OutlinedButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(Icons.add_rounded, color: _green),
                    label: const Text(
                      'افزودن محصول',
                      style: TextStyle(color: _green),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _green),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'اطلاعات فرستنده و گیرنده',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _textField(_senderCtrl, 'نام فرستنده *'),
              const SizedBox(height: 8),
              _textField(_receiverCtrl, 'نام گیرنده *'),
              const SizedBox(height: 8),
              _textField(_phoneCtrl, 'شماره تماس *'),
              const SizedBox(height: 8),
              _textField(_cityCtrl, 'شهر *'),
              const SizedBox(height: 8),
              _textField(_addressCtrl, 'آدرس *'),
              const SizedBox(height: 8),
              _textField(
                _postalCtrl,
                _shippingMethod == 'باربری' ? 'کد پستی (اختیاری)' : 'کد پستی *',
              ),
              const SizedBox(height: 16),
              const Text(
                'نحوه ارسال',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _dropdown(_shippingMethod, _shippingMethods, _shippingMethods, (
                v,
              ) {
                setState(() {
                  _shippingMethod = v!;
                  _selectedCarrier = null;
                });
              }),
              if (_shippingMethod == 'باربری' && _carriers.isNotEmpty) ...[
                const SizedBox(height: 8),
                _dropdown(
                  _carrierValues.contains(_selectedCarrier)
                      ? _selectedCarrier
                      : null,
                  _carrierValues,
                  _carrierLabels,
                  (v) => setState(() => _selectedCarrier = v),
                ),
              ] else if (_shippingMethod == 'باربری') ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Text(
                    _selectedCarrier ?? 'باربری',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: _surface,
            border: Border(top: BorderSide(color: _border)),
          ),
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 20),
            label: Text(
              _saving ? 'در حال ذخیره…' : 'ذخیره تغییرات',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(int index) {
    final row = _rows[index];
    final canEdit = _canEditItems;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                'محصول ${index + 1}',
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (canEdit)
                GestureDetector(
                  onTap: () => _removeRow(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded, color: _red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'حذف',
                          style: TextStyle(
                            color: _red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _section('محصول', _productField(row, canEdit)),
          const SizedBox(height: 10),
          _textField(
            row.qtyCtrl,
            'تعداد',
            number: true,
            readOnly: !canEdit,
          ),
          const SizedBox(height: 8),
          _priceField(row, canEdit),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: row.priceCtrl,
            builder: (_, v, __) {
              final d = _parseDouble(v.text);
              final rate = _dollarRate;
              String label;
              Color color;
              if (row.priceUnit == 'دلار') {
                if (d != null && rate != null) {
                  label = '≈ ${_format(d * rate)} تومان';
                  color = _green;
                } else if (d != null) {
                  label =
                      'نرخ لحظه‌ای در دسترس نیست؛ مبلغ دلار قابل تبدیل نیست';
                  color = _warning;
                } else if (rate != null) {
                  label = 'نرخ لحظه‌ای دلار: ${_format(rate)} تومان';
                  color = _green;
                } else {
                  label = 'نرخ لحظه‌ای دلار در دسترس نیست';
                  color = _surfaceAlt;
                }
              } else {
                if (d != null && rate != null) {
                  label = '≈ ${_format((d / rate).round())} دلار';
                  color = _green;
                } else if (d != null) {
                  label = 'مبلغ تومان مستقیم ثبت می‌شود';
                  color = _warning;
                } else if (rate != null) {
                  label = 'نرخ لحظه‌ای دلار: ${_format(rate)} تومان';
                  color = _green;
                } else {
                  label = 'نرخ لحظه‌ای دلار در دسترس نیست';
                  color = _surfaceAlt;
                }
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
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
      const SizedBox(height: 4),
      child,
    ],
  );

  Widget _textField(
    TextEditingController c,
    String h, {
    bool number = false,
    bool readOnly = false,
  }) => TextField(
    controller: c,
    keyboardType: number ? TextInputType.number : TextInputType.text,
    readOnly: readOnly,
    style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: h,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
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
      );

  /// پیکر جستجوشوندهٔ محصولات — داده فقط صفحه به صفحه از سرور می‌آید
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

  Widget _productField(_EditItemRow row, bool canEdit) {
    return GestureDetector(
      onTap: canEdit
          ? () async {
              final picked = await _pickProduct();
              if (picked == null || !mounted) return;
              setState(() {
                row.productId = picked.id;
                row.productName = picked.name;
                row.modelName = '';
              });
            }
          : null,
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
                row.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: row.productName.isNotEmpty
                      ? Colors.white
                      : Colors.white38,
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

  Widget _priceField(_EditItemRow row, bool canEdit) => Container(
    decoration: BoxDecoration(
      color: _surfaceAlt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        // قسمت واحد
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  'واحد',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: row.priceUnit,
                      isExpanded: true,
                      dropdownColor: _surfaceAlt,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'دلار', child: Text('دلار')),
                        DropdownMenuItem(value: 'تومان', child: Text('تومان')),
                      ],
                      onChanged: canEdit
                          ? (v) =>
                                setState(() => row.priceUnit = v ?? 'دلار')
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // جداکننده
        Container(width: 1, height: 26, color: _border),
        // قسمت مبلغ
        Expanded(
          flex: 7,
          child: TextField(
            controller: row.priceCtrl,
            keyboardType: TextInputType.number,
            readOnly: !canEdit,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'قیمت',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _dropdown(
    String? v,
    List<String> values,
    List<String> labels,
    Function(String?) onChanged,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _surfaceAlt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: v,
        isExpanded: true,
        dropdownColor: _surfaceAlt,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        hint: const Text(
          'انتخاب کنید...',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white.withOpacity(0.4),
        ),
        items: List.generate(
          values.length,
          (i) => DropdownMenuItem(
            value: values[i],
            child: Text(labels[i], overflow: TextOverflow.ellipsis),
          ),
        ),
        onChanged: onChanged,
      ),
    ),
  );
}

class _EditItemRow {
  String productId;
  String productName;
  String? modelName;

  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();

  String priceUnit = 'دلار'; // واحد قیمت: دلار یا تومان

  _EditItemRow({
    this.productId = '',
    this.productName = '',
    int? quantity,
    this.modelName,
    double? price,
    double? exchangeRate,
  }) {
    qtyCtrl.text = '${quantity ?? 1}';
    if (price != null) {
      // قیمت ذخیره‌شده تومانی است؛ مستقیماً نمایش داده می‌شود (واحد تومان)
      priceCtrl.text = '${price.round()}';
      priceUnit = 'تومان';
    }
  }

  /// قیمت واردشده → تومان؛ تومان مستقیم، دلار با نرخ لحظه‌ای (اگر نرخ نباشد null)
  double? priceToman(double? rate) {
    final d = _parseDouble(priceCtrl.text);
    if (d == null) return null;
    if (priceUnit == 'تومان') return d;
    if (rate == null) return null;
    return d * rate;
  }

  double? exchangeRate(double? rate) => rate;

  void dispose() {
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }
}
