import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/manager_api_service.dart';
import '../providers/manager_api_provider.dart';
import '../models/warehouse_model.dart';
import '../models/product_model.dart';
import '../models/carrier_model.dart';
import '../../../core/network/api_error.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _warning = Color(0xFFFBBF24);
const _border = Color(0xFF2A2D33);
const _faDigits = '۰۱۲۳۴۵۶۷۸۹';

String _fa(String? s) => s == null
    ? ''
    : s.replaceAllMapped(RegExp(r'[0-9]'), (m) => _faDigits[m.group(0)!.codeUnitAt(0) - 48]);

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
  List<ProductModel> _products = [];
  List<CarrierModel> _carriers = [];
  String? _selectedWarehouseId;
  final List<_OrderRow> _rows = [];
  bool _submitting = false;
  double? _dollarRate;

  final _shippingMethods = ['باربری', 'تیپاکس', 'شهری'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _api.getWarehouses().then<List<WarehouseModel>>((v) => v).catchError((_) => <WarehouseModel>[]),
      _api.getProducts().then<List<ProductModel>>((v) => v).catchError((_) => <ProductModel>[]),
      _api.getCarriers().then<List<CarrierModel>>((v) => v).catchError((_) => <CarrierModel>[]),
      _api.getDollarRate().then<double?>((v) => v).catchError((_) => null),
    ]);
    if (!mounted) return;
    setState(() {
      _warehouses = results[0] as List<WarehouseModel>;
      _products = results[1] as List<ProductModel>;
      _carriers = results[2] as List<CarrierModel>;
      _dollarRate = results[3] as double?;
    });
  }

  void _addRow() => setState(() => _rows.add(_OrderRow()));

  void _removeRow(int i) => setState(() {
    _rows[i].dispose();
    _rows.removeAt(i);
  });

  Future<void> _submit() async {
    if (_selectedWarehouseId == null) { _snack('انبار مقصد را انتخاب کنید'); return; }
    if (_rows.isEmpty) { _snack('حداقل یک محصول اضافه کنید'); return; }

    for (int i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      if (r.productId == null) { _snack('ردیف ${i + 1}: محصول انتخاب نشده'); return; }
      final qty = int.tryParse(r.qtyCtrl.text) ?? 1;
      if (r.qtyCtrl.text.trim().isEmpty || qty <= 0) { _snack('ردیف ${i + 1}: تعداد معتبر نیست'); return; }
      if (r.senderNameCtrl.text.trim().isEmpty) { _snack('ردیف ${i + 1}: نام فرستنده الزامی است'); return; }
      if (r.receiverNameCtrl.text.trim().isEmpty) { _snack('ردیف ${i + 1}: نام گیرنده الزامی است'); return; }
      if (r.phoneCtrl.text.trim().isEmpty) { _snack('ردیف ${i + 1}: شماره تماس الزامی است'); return; }
      if (r.cityCtrl.text.trim().isEmpty) { _snack('ردیف ${i + 1}: شهر الزامی است'); return; }
      if (r.addressCtrl.text.trim().isEmpty) { _snack('ردیف ${i + 1}: آدرس الزامی است'); return; }
      if (r.shippingMethod != 'باربری' && r.postalCodeCtrl.text.trim().isEmpty) {
        _snack('ردیف ${i + 1}: کد پستی الزامی است'); return;
      }
      if (r.shippingMethod == 'باربری' && r.selectedCarrier == null) {
        _snack('ردیف ${i + 1}: باربری را انتخاب کنید'); return;
      }
      final priceVal = double.tryParse(r.priceCtrl.text);
      if (priceVal != null && priceVal > 0 && r.priceUnit == 'دلار' && _dollarRate == null) {
        _snack('ردیف ${i + 1}: نرخ لحظه‌ای دلار در دسترس نیست؛ واحد قیمت را به تومان تغییر دهید'); return;
      }
    }

    setState(() => _submitting = true);
    try {
      for (final row in _rows) {
        final carrierName = row.selectedCarrier != null && _carriers.isNotEmpty
            ? (_carriers.firstWhere(
                (c) => (c.id ?? c.name ?? '').toString() == row.selectedCarrier,
                orElse: () => CarrierModel(),
              ).name ?? '')
            : null;

        await _api.createOrder({
          'warehouseId': _selectedWarehouseId,
          'items': [
            {
              'productId': row.productId,
              'quantity': int.tryParse(row.qtyCtrl.text) ?? 1,
              'model': row.modelId != null 
                  ? (row.models.firstWhere((m) => m.id == row.modelId, orElse: () => ProductVariantModel(id: '', name: '')).name)
                  : (row.modelCtrl.text.isEmpty ? null : row.modelCtrl.text),
              'price': row.priceToman(_dollarRate),
              'exchangeRate': row.exchangeRate(_dollarRate),
            }
          ],
          'shippingMethod': row.shippingMethod,
          'carrier': carrierName,
          'city': row.cityCtrl.text,
          'postalCode': row.postalCodeCtrl.text,
          'address': row.addressCtrl.text,
          'customerPhone': row.phoneCtrl.text,
          'senderName': row.senderNameCtrl.text.isEmpty ? null : row.senderNameCtrl.text,
          'receiverName': row.receiverNameCtrl.text.isEmpty ? null : row.receiverNameCtrl.text,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سفارش ثبت شد'), backgroundColor: Colors.green),
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
        title: const Text('ثبت سفارش جدید', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: _section('انبار مقصد', _dropdown(
            _selectedWarehouseId,
            _warehouses.map((w) => w.id).toList(),
            _warehouses.map((w) => w.name).toList(),
            (v) => setState(() => _selectedWarehouseId = v),
          )),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _rows.length + 1,
            itemBuilder: (_, i) {
              if (i == _rows.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(Icons.add_rounded, color: _green),
                    label: const Text('افزودن محصول', style: TextStyle(color: _green)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _green),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              }
              return _buildRow(i);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(color: _surface, border: Border(top: BorderSide(color: _border))),
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _submitting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('ثبت سفارش', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _buildRow(int index) {
    final row = _rows[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Text('محصول ${index + 1}', style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 14)),
          const Spacer(),
          if (_rows.length > 1)
            GestureDetector(
              onTap: () => _removeRow(index),
              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.3), size: 18),
            ),
        ]),
        const SizedBox(height: 10),

        //محصول
        _section('محصول', _dropdown(row.productId,
          _products.map((p) => p.id).toList(),
          _products.map((p) => p.name).toList(),
          (v) => setState(() {
            row.productId = v;
            final p = _products.firstWhere((p) => p.id == v, orElse: () => ProductModel(id: '', name: ''));
            row.models = p.models;
            row.modelId = null;
            row.modelCtrl.clear();
          }),
        )),
        const SizedBox(height: 8),

        //مدل
        if (row.models.isNotEmpty)
          _section('مدل', _dropdown(row.modelId,
            row.models.map((m) => m.id).toList(),
            row.models.map((m) {
              final cap = m.unitsPerBox;
              final unit = _products.firstWhere((p) => p.id == row.productId, orElse: () => ProductModel(id: '', name: '')).unit ?? 'عدد';
              final pkg = m.packageType ?? 'کارتن';
              return cap != null ? '${m.name} ($cap $unit/$pkg)' : '${m.name}';
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
          )),
        const SizedBox(height: 8),

        // تعداد
        _textField(row.qtyCtrl, 'تعداد', keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        // قیمت — واحد + مبلغ
        _priceField(row),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: row.priceCtrl,
          builder: (_, v, __) {
            final d = double.tryParse(v.text);
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
                style: TextStyle(color: color.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Divider
        Container(height: 1, color: _border.withOpacity(0.5)),
        const SizedBox(height: 10),

        //اطلاعات ارسال
        const Text('اطلاعات فرستنده و گیرنده', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _textField(row.senderNameCtrl, 'نام فرستنده *'),
        const SizedBox(height: 8),
        _textField(row.receiverNameCtrl, 'نام گیرنده *'),
        const SizedBox(height: 8),
        _textField(row.phoneCtrl, 'شماره تماس *'),
        const SizedBox(height: 8),
        _textField(row.cityCtrl, 'شهر *'),
        const SizedBox(height: 8),
        _textField(row.addressCtrl, 'آدرس *'),
        const SizedBox(height: 8),
        _textField(
          row.postalCodeCtrl,
          row.shippingMethod == 'باربری' ? 'کد پستی (اختیاری)' : 'کد پستی *',
        ),
        const SizedBox(height: 10),

        // Divider
        Container(height: 1, color: _border.withOpacity(0.5)),
        const SizedBox(height: 10),

        //نحوه ارسال
        const Text('نحوه ارسال', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _dropdown(row.shippingMethod, _shippingMethods, _shippingMethods, (v) => setState(() {
          row.shippingMethod = v!;
          row.selectedCarrier = null;
        })),
        if (row.shippingMethod == 'باربری' && _carriers.isNotEmpty) ...[
          const SizedBox(height: 8),
          _dropdown(
            row.selectedCarrier,
            _carriers.map((c) => (c.id ?? c.name ?? '').toString()).toList(),
            _carriers.map((c) => (c.name ?? '').toString()).toList(),
            (v) => setState(() => row.selectedCarrier = v),
          ),
        ],
      ]),
    );
  }

  Widget _section(String title, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    child,
  ]);

  Widget _textField(TextEditingController c, String h, {TextInputType? keyboardType}) => TextField(
    controller: c,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      hintText: h,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
      filled: true,
      fillColor: _surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _green)),
      isDense: true,
    ),
  );

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
                Text('واحد', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: row.priceUnit,
                      isExpanded: true,
                      dropdownColor: _surfaceAlt,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.4)),
                      items: const [
                        DropdownMenuItem(value: 'دلار', child: Text('دلار')),
                        DropdownMenuItem(value: 'تومان', child: Text('تومان')),
                      ],
                      onChanged: (v) => setState(() => row.priceUnit = v ?? 'دلار'),
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
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _dropdown(String? v, List<String> values, List<String> labels, Function(String?) onChanged) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: _surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: v,
        isExpanded: true,
        dropdownColor: _surfaceAlt,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        hint: Text('انتخاب کنید...', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.4)),
        items: List.generate(values.length, (i) => DropdownMenuItem(value: values[i], child: Text(labels[i]))),
        onChanged: onChanged,
      ),
    ),
  );
}

class _OrderRow {
  String? productId;
  String? modelId;
  List<ProductVariantModel> models = [];
  int quantity = 1;
  String shippingMethod = 'باربری';
  String? selectedCarrier;

  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();
  final senderNameCtrl = TextEditingController();
  final receiverNameCtrl = TextEditingController();

  String priceUnit = 'دلار'; // واحد قیمت: دلار یا تومان

  /// تبدیل قیمت واردشده به تومان؛ تومان مستقیم، دلار با نرخ لحظه‌ای (اگر نرخ نباشد null)
  double? priceToman(double? rate) {
    final d = double.tryParse(priceCtrl.text);
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
    phoneCtrl.dispose();
    cityCtrl.dispose();
    addressCtrl.dispose();
    postalCodeCtrl.dispose();
    senderNameCtrl.dispose();
    receiverNameCtrl.dispose();
  }
}