import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/manager_api_service.dart';
import '../providers/manager_api_provider.dart';
import '../models/warehouse_model.dart';
import '../models/product_model.dart';
import '../models/carrier_model.dart';
import '../../../core/network/api_error.dart';
import '../../../shared/widgets/search_picker.dart';

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

String _format(num n) {
  final s = n.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return _fa(buf.toString());
}

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});
  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  List<WarehouseModel> _warehouses = [];
  List<CarrierModel> _carriers = [];
  String? _selectedWarehouseId;
  final List<_OrderRow> _rows = [];
  bool _submitting = false;
  double? _dollarRate;

  bool _warehousesFailed = false;
  bool _carriersFailed = false;
  bool _dollarFailed = false;

  /// هر منبع به‌صورت مستقل ردیابی می‌شود تا خطای یکی، بقیه را گمراه نکند
  bool get _loadFailed => _warehousesFailed || _carriersFailed || _dollarFailed;

  /// موجودی قابل سفارش هر محصول در انبار انتخاب‌شده (کارتن + لِگاسی)
  final Map<String, int> _stock = {};
  bool _stockLoading = false;

  String _shippingMethod = 'باربری';
  String? _selectedCarrier;

  List<String> get _carrierValues =>
      _carriers.map((c) => (c.id ?? c.name ?? '').toString()).toList();
  List<String> get _carrierLabels =>
      _carriers.map((c) => (c.name ?? '').toString()).toList();

  final _senderCtrl = TextEditingController();
  final _receiverCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  final _shippingMethods = ['باربری', 'تیپاکس', 'شهری'];

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<void> _loadData() async {
    setState(() {
      _warehousesFailed = false;
      _carriersFailed = false;
      _dollarFailed = false;
    });
    final results = await Future.wait([
      _api
          .getWarehouses()
          .then<List<WarehouseModel>>((v) => v)
          .catchError((_) {
        _warehousesFailed = true;
        return <WarehouseModel>[];
      }),
      _api
          .getCarriers()
          .then<List<CarrierModel>>((v) => v)
          .catchError((_) {
        _carriersFailed = true;
        return <CarrierModel>[];
      }),
      _api.getDollarRate().then<double?>((v) => v).catchError((_) {
        _dollarFailed = true;
        return null;
      }),
    ]);
    if (!mounted) return;
    setState(() {
      _warehouses = results[0] as List<WarehouseModel>;
      _carriers = results[1] as List<CarrierModel>;
      _dollarRate = results[2] as double?;
    });
  }

  /// موجودی ردیف‌ها در انبار انتخاب‌شده — بعد از انتخاب انبار یا محصول
  Future<void> _refreshStock() async {
    final warehouseId = _selectedWarehouseId;
    final ids = _rows.map((r) => r.productId).whereType<String>().toList();
    if (warehouseId == null || ids.isEmpty) {
      setState(() => _stock.clear());
      return;
    }
    final seq = ++_stockSeq;
    setState(() => _stockLoading = true);
    try {
      final map = await _api.getOrderStock(warehouseId, ids);
      if (!mounted || seq != _stockSeq) return;
      setState(() {
        _stock
          ..clear()
          ..addAll(map);
        _stockLoading = false;
      });
    } catch (_) {
      if (!mounted || seq != _stockSeq) return;
      setState(() {
        _stock.clear();
        _stockLoading = false;
      });
    }
  }

  int _stockSeq = 0;

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

  void _addRow() => setState(() => _rows.add(_OrderRow()));

  void _removeRow(int i) {
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
    });
    _refreshStock();
  }

  void _onWarehouseChanged(String? v) {
    setState(() => _selectedWarehouseId = v);
    _refreshStock();
  }

  void _onProductPicked(_OrderRow row, ProductModel picked) {
    setState(() {
      row.product = picked;
      row.productId = picked.id;
      row.models = picked.models;
      row.modelId = null;
      row.modelCtrl.clear();
    });
    _refreshStock();
  }

  Future<void> _submit() async {
    if (_selectedWarehouseId == null) {
      _snack('انبار مقصد را انتخاب کنید');
      return;
    }
    if (_rows.isEmpty) {
      _snack('حداقل یک محصول اضافه کنید');
      return;
    }

    for (int i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      if (r.productId == null) {
        _snack('ردیف ${i + 1}: محصول انتخاب نشده');
        return;
      }
      final qty = _parseQty(r.qtyCtrl.text);
      if (qty == null || qty <= 0) {
        _snack('ردیف ${i + 1}: تعداد معتبر نیست');
        return;
      }
      // بلاک پیش از ارسال با موجودی انبار انتخاب‌شده
      final available = _stock[r.productId];
      if (available != null && qty > available) {
        _snack('ردیف ${i + 1}: موجودی کافی نیست (موجودی: ${_format(available)})');
        return;
      }
      final priceVal = _parseDouble(r.priceCtrl.text);
      if (priceVal != null &&
          priceVal > 0 &&
          r.priceUnit == 'دلار' &&
          _dollarRate == null) {
        _snack(
          'ردیف ${i + 1}: نرخ لحظه‌ای دلار در دسترس نیست؛ واحد قیمت را به تومان تغییر دهید',
        );
        return;
      }
    }

    if (_senderCtrl.text.trim().isEmpty) {
      _snack('نام فرستنده الزامی است');
      return;
    }
    if (_receiverCtrl.text.trim().isEmpty) {
      _snack('نام گیرنده الزامی است');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _snack('شماره تماس الزامی است');
      return;
    }
    if (_cityCtrl.text.trim().isEmpty) {
      _snack('شهر الزامی است');
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      _snack('آدرس الزامی است');
      return;
    }
    if (_shippingMethod != 'باربری' && _postalCtrl.text.trim().isEmpty) {
      _snack('کد پستی الزامی است');
      return;
    }
    if (_shippingMethod == 'باربری' && _selectedCarrier == null && _carriers.isNotEmpty) {
      _snack('باربری را انتخاب کنید');
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

    setState(() => _submitting = true);
    try {
      // ثبت اتمی: همهٔ ردیف‌ها یک سفارش با چند قلم می‌شوند
      final created = await _api.createOrder({
        'warehouseId': _selectedWarehouseId,
        'items': [
          for (final row in _rows)
            {
              'productId': row.productId,
              'quantity': _parseQty(row.qtyCtrl.text) ?? 1,
              'model': row.modelId != null
                  ? (row.models
                        .firstWhere(
                          (m) => m.id == row.modelId,
                          orElse: () => ProductVariantModel(id: '', name: ''),
                        )
                        .name)
                  : (row.modelCtrl.text.isEmpty ? null : row.modelCtrl.text),
              'modelId': row.modelId,
              'price': row.priceToman(_dollarRate),
              // نرخ ارز فقط برای ردیف‌های دلاری ذخیره می‌شود (ردیف تومانی نویز ندارد)
              if (row.priceUnit == 'دلار')
                'exchangeRate': row.exchangeRate(_dollarRate),
            },
        ],
        'shippingMethod': _shippingMethod,
        'carrier': carrierName,
        'city': _cityCtrl.text,
        'postalCode': _postalCtrl.text,
        'address': _addressCtrl.text,
        'customerPhone': _enDigits(_phoneCtrl.text),
        'senderName': _senderCtrl.text.trim().isEmpty
            ? null
            : _senderCtrl.text,
        'receiverName': _receiverCtrl.text.trim().isEmpty
            ? null
            : _receiverCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              created.orderNumber > 0
                  ? 'سفارش شماره ${_fa('${created.orderNumber}')} ثبت شد'
                  : 'سفارش ثبت شد',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$msg'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'ثبت سفارش جدید',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(
                  'انبار مقصد',
                  _dropdown(
                    _selectedWarehouseId,
                    _warehouses.map((w) => w.id).toList(),
                    _warehouses.map((w) => w.name).toList(),
                    _onWarehouseChanged,
                  ),
                ),
                if (_loadFailed) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'خطا در دریافت: ${[
                              if (_warehousesFailed) 'انبارها',
                              if (_carriersFailed) 'باربری‌ها',
                              if (_dollarFailed) 'نرخ دلار',
                            ].join('، ')}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadData,
                          child: const Text(
                            'تلاش مجدد',
                            style: TextStyle(color: _warning, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_warehouses.isEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'هنوز انباری ساخته نشده است',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                for (int i = 0; i < _rows.length; i++) _buildRow(i),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(Icons.add_rounded, color: _green),
                    label: const Text(
                      'افزودن محصول',
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
                ),
                const SizedBox(height: 8),

                // ─── اطلاعات فرستنده و گیرنده (سطح سفارش) ───
                const Text(
                  'اطلاعات فرستنده و گیرنده',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
                const SizedBox(height: 14),

                // ─── نحوه ارسال ───
                const Text(
                  'نحوه ارسال',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
                      'ثبت سفارش',
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

  Widget _buildRow(int index) {
    final row = _rows[index];
    final qty = _parseQty(row.qtyCtrl.text);
    final available = row.productId != null ? _stock[row.productId] : null;
    final insufficient = qty != null && available != null && qty > available;
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
          // Header
          Row(
            children: [
              Text(
                'محصول ${index + 1}',
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
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

          //محصول
          _section('محصول', _productField(row)),
          const SizedBox(height: 8),

          //مدل
          if (row.models.isNotEmpty)
            _section(
              'مدل',
              _dropdown(
                row.modelId,
                row.models.map((m) => m.id).toList(),
                row.models.map((m) {
                  final cap = m.unitsPerBox;
                  final unit = row.product?.unit ?? 'عدد';
                  final pkg = m.packageType ?? 'کارتن';
                  return cap != null
                      ? '${m.name} ($cap $unit/$pkg)'
                      : '${m.name}';
                }).toList(),
                (v) => setState(() {
                  row.modelId = v;
                  if (v != null) {
                    final selectedModel = row.models.firstWhere(
                      (m) => m.id == v,
                      orElse: () => ProductVariantModel(id: '', name: ''),
                    );
                    row.modelCtrl.text = selectedModel.name;
                  }
                }),
              ),
            ),
          const SizedBox(height: 8),

          // تعداد + موجودی انبار انتخاب‌شده
          _textField(row.qtyCtrl, 'تعداد', keyboardType: TextInputType.number),
          if (available != null || _stockLoading) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                if (_stockLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      color: _green,
                    ),
                  )
                else ...[
                  Icon(
                    insufficient
                        ? Icons.error_outline_rounded
                        : Icons.inventory_2_outlined,
                    size: 13,
                    color: insufficient ? _red : _green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'موجودی: ${_format(available!)}',
                    style: TextStyle(
                      color: insufficient ? _red : _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (insufficient) ...[
                  const SizedBox(width: 6),
                  Text(
                    '— بیشتر از موجودی است',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 8),
          // قیمت — واحد + مبلغ
          _priceField(row),
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
                  label = 'نرخ لحظه‌ای در دسترس نیست؛ مبلغ دلار قابل تبدیل نیست';
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
    TextInputType? keyboardType,
  }) => TextField(
    controller: c,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      hintText: h,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
      filled: true,
      fillColor: _surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _productField(_OrderRow row) {
    final name = row.product?.name;
    return GestureDetector(
      onTap: () async {
        final picked = await _pickProduct();
        if (picked == null || !mounted) return;
        _onProductPicked(row, picked);
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
                name ?? 'انتخاب کنید...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: name != null
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

  Widget _priceField(_OrderRow row) => Container(
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
                      onChanged: (v) =>
                          setState(() => row.priceUnit = v ?? 'دلار'),
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
        hint: Text(
          'انتخاب کنید...',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white.withOpacity(0.4),
        ),
        items: List.generate(
          values.length,
          (i) => DropdownMenuItem(value: values[i], child: Text(labels[i])),
        ),
        onChanged: onChanged,
      ),
    ),
  );
}

class _OrderRow {
  String? productId;
  ProductModel? product;
  String? modelId;
  List<ProductVariantModel> models = [];

  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
  final modelCtrl = TextEditingController();

  String priceUnit = 'دلار'; // واحد قیمت: دلار یا تومان

  /// تبدیل قیمت واردشده به تومان؛ تومان مستقیم، دلار با نرخ لحظه‌ای (اگر نرخ نباشد null)
  double? priceToman(double? rate) {
    final d = _parseDouble(priceCtrl.text);
    if (d == null) return null;
    if (priceUnit == 'تومان') return d;
    if (rate == null) return null;
    return d * rate;
  }

  /// نرخ ارز لحظهٔ ثبت (برای ذخیره‌سازی کنار قیمت دلار)
  double? exchangeRate(double? rate) => rate;

  void dispose() {
    qtyCtrl.dispose();
    priceCtrl.dispose();
    modelCtrl.dispose();
  }
}