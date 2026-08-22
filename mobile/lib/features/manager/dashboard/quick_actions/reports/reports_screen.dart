import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:math' as math;
import '../../../../../core/network/api_error.dart';
import '../../../../../shared/utils/numbers.dart';
import '../../../../../shared/widgets/jalali_month_picker.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/warehouse_model.dart';
import '../../../models/transaction_entry_model.dart';
import '../../../models/warehouse_inventory_row_model.dart';
import '../../../models/user_model.dart';
import '../../../models/shipment_report_model.dart';
import 'user_report_screen.dart';

// ──────────────────────────────────────────
// Theme Constants
// ──────────────────────────────────────────
const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceLight = Color(0xFF22262C);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _red = Color(0xFFF87171);
const _amber = Color(0xFFFBBF24);
const _blue = Color(0xFF60A5FA);
const _purple = Color(0xFFA78BFA);
const _textGrey = Color(0xFF94A3B8);

/// جمعِ یک محصول در یک روز، به تفکیک جهت (ورود/خروج/مرجوعی)
class _ProductTxSummary {
  final String name;
  final String? unit;
  int inQty = 0;
  int outQty = 0;
  int returnQty = 0;

  _ProductTxSummary({required this.name, this.unit});

  int get total => inQty + outQty + returnQty;
}

// ──────────────────────────────────────────
// Main Reports Screen
// ──────────────────────────────────────────
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);

  // سکشن ۱ — ورود و خروج
  List<WarehouseModel> _warehouses = [];
  bool _warehousesLoading = false;
  String? _warehousesError;
  String? _selectedWarehouseId;
  Jalali? _selectedDate;
  List<TransactionEntryModel> _transactions = [];
  bool _loading = false;
  String? _transactionsError;
  int _txSeq = 0;

  // سکشن ۲ و ۳ — futureها فقط یک بار ساخته می‌شوند (نه در هر build)
  Future<List<WarehouseInventoryRowModel>>? _inventoryFuture;
  Future<List<UserModel>>? _usersFuture;
  Future<ShipmentReportModel>? _shipmentsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = Jalali.now();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    setState(() {
      _warehousesLoading = true;
      _warehousesError = null;
    });
    try {
      final warehouses = await _api.getWarehouses();
      if (!mounted) return;
      setState(() {
        _warehouses = warehouses;
        _warehousesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _warehousesLoading = false;
        _warehousesError = friendlyError(e);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showJalaliMonthPicker(
      context,
      initial: _selectedDate ?? Jalali.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadTransactions();
    }
  }

  void _resetToToday() {
    setState(() => _selectedDate = Jalali.now());
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final warehouseId = _selectedWarehouseId;
    final date = _selectedDate;
    if (warehouseId == null || date == null) return;
    final seq = ++_txSeq;
    setState(() {
      _loading = true;
      _transactionsError = null;
    });
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final result = await _api.getTransactionsByDate(warehouseId, dateStr);
      if (!mounted || seq != _txSeq) return;
      setState(() {
        _transactions = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || seq != _txSeq) return;
      setState(() {
        _loading = false;
        _transactionsError = friendlyError(e);
      });
    }
  }

  /// خلاصهٔ محصولات به تفکیک جهت — خروجی‌ها و مرجوعی‌ها با ورودی‌ها قاطی نمی‌شوند
  List<_ProductTxSummary> get _productSummary {
    final map = <String, _ProductTxSummary>{};
    for (final t in _transactions) {
      final name = t.productName ?? 'نامشخص';
      final s = map.putIfAbsent(
        name,
        () => _ProductTxSummary(name: name, unit: t.unit),
      );
      final q = t.quantity.toInt();
      switch (t.type) {
        case 'OUT':
          s.outQty += q;
          break;
        case 'RETURN':
          s.returnQty += q;
          break;
        default:
          s.inQty += q;
      }
    }
    return map.values.toList()..sort((a, b) => b.total - a.total);
  }

  String get _dateStr {
    final date = _selectedDate;
    if (date == null) return 'انتخاب تاریخ';
    return faDigits(
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('گزارش‌ها', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_surface, _bg],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ──────── Section 1: ورود و خروج ────────
            _buildInOutSection(),
            const SizedBox(height: 24),

            // ──────── Section 2: وضعیت انبارها (نسخه حرفه‌ای) ────────
            _buildWarehouseStatusSection(),
            const SizedBox(height: 24),

            // ──────── Section 3: گزارش ارسالی‌ها ────────
            _buildShipmentsSection(),
            const SizedBox(height: 24),

            // ──────── Section 4: گزارش کاربران ────────
            _buildUserReportsSection(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //بخش ورود و خروج (طراحی مدرن)
  // ─────────────────────────────────────────
  Widget _buildInOutSection() {
    return _GlassMorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.swap_horiz_rounded, title: 'ورود و خروج کالا'),
          const SizedBox(height: 20),

          // Dropdown انتخاب انبار — با حالت خطا و تلاش مجدد
          if (_warehousesError != null && _warehouses.isEmpty)
            _ErrorRetryBox(message: _warehousesError!, onRetry: _loadWarehouses)
          else if (_warehousesLoading && _warehouses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(color: _green, strokeWidth: 2.5),
                ),
              ),
            )
          else
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: _surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedWarehouseId,
                dropdownColor: _surfaceLight,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _green),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'انتخاب انبار',
                  hintStyle: TextStyle(color: _textGrey.withValues(alpha: 0.6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                ),
                items: _warehouses
                    .map<DropdownMenuItem<String>>((w) => DropdownMenuItem(
                          value: w.id,
                          child: Row(children: [
                            const Icon(Icons.warehouse_rounded, size: 18, color: _green),
                            const SizedBox(width: 8),
                            Text(w.name),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedWarehouseId = v);
                  _loadTransactions();
                },
              ),
            ),
          const SizedBox(height: 14),

          // دکمه انتخاب تاریخ + بازگشت به امروز
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: _green, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_dateStr, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  _dateActionChip('امروز', _resetToToday),
                  const SizedBox(width: 8),
                  _dateActionChip('تغییر', _pickDate),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // نمایش لیست تراکنش‌ها
          if (_selectedWarehouseId == null || _selectedDate == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('انبار و تاریخ را انتخاب کنید', style: TextStyle(color: _textGrey)),
              ),
            )
          else if (_loading)
            const Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: _green)),
            )
          else if (_transactionsError != null)
            _ErrorRetryBox(message: _transactionsError!, onRetry: _loadTransactions)
          else if (_productSummary.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('تراکنشی در این روز یافت نشد', style: TextStyle(color: _textGrey)),
              ),
            )
          else
            _buildTransactionSummary(),
        ],
      ),
    );
  }

  Widget _dateActionChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(color: _green, fontSize: 12)),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    final summary = _productSummary;
    final inTotal = summary.fold(0, (sum, s) => sum + s.inQty);
    final outTotal = summary.fold(0, (sum, s) => sum + s.outQty);
    final returnTotal = summary.fold(0, (sum, s) => sum + s.returnQty);
    final grandTotal = inTotal + outTotal + returnTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...summary.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          s.unit ?? 'عدد',
                          style: const TextStyle(color: _textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (s.inQty > 0) _directionChip('ورود', s.inQty, _green, Icons.arrow_downward_rounded),
                        if (s.outQty > 0) _directionChip('خروج', s.outQty, _red, Icons.arrow_upward_rounded),
                        if (s.returnQty > 0) _directionChip('مرجوعی', s.returnQty, _orange, Icons.restore_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.white10),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('مجموع جابه‌جایی', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            Text(
              formatNumber(grandTotal),
              style: const TextStyle(color: _green, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'ورود ${formatNumber(inTotal)} · خروج ${formatNumber(outTotal)} · مرجوعی ${formatNumber(returnTotal)}',
          style: const TextStyle(color: _textGrey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _directionChip(String label, int qty, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$label ${formatNumber(qty)}',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //وضعیت انبارها (UI کاملاً مدرن و حرفه‌ای)
  // ─────────────────────────────────────────
  Widget _buildWarehouseStatusSection() {
    // future در state نگه‌داری می‌شود تا هر rebuild درخواست تکراری نفرستد
    _inventoryFuture ??= _api.getWarehouseInventory();

    return FutureBuilder<List<WarehouseInventoryRowModel>>(
      future: _inventoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: _green)),
          );
        }
        if (snapshot.hasError) {
          return _GlassMorphismCard(
            child: _ErrorRetryBox(
              message: friendlyError(snapshot.error!),
              onRetry: () => setState(() => _inventoryFuture = _api.getWarehouseInventory()),
            ),
          );
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return _GlassMorphismCard(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.inventory_2_outlined, size: 48, color: _textGrey.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('انباری ثبت نشده است', style: TextStyle(color: _textGrey, fontSize: 16)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        // ساختاردهی دیتا: نام انبار → (نام محصول → (تعداد، واحد))
        // ردیف‌های جایگزین انبارهای خالی (productName خالی) فقط انبار را ثبت می‌کنند
        final Map<String, Map<String, (int, String?)>> inventoryMap = {};
        for (final row in data) {
          final whName = row.warehouseName ?? '';
          final map = inventoryMap.putIfAbsent(whName, () => {});
          final prodName = row.productName;
          if (prodName == null || prodName.isEmpty) continue;
          map[prodName] = (row.count.toInt(), row.unit);
        }
        // انبارهای بدون موجودی هم باید دیده شوند
        for (final w in _warehouses) {
          inventoryMap.putIfAbsent(w.name, () => {});
        }

        final allProducts = <String>{};
        var grandTotal = 0;
        for (final map in inventoryMap.values) {
          allProducts.addAll(map.keys);
          for (final (count, _) in map.values) {
            grandTotal += count;
          }
        }
        final totalWarehouses = _warehouses.isNotEmpty ? _warehouses.length : inventoryMap.length;
        final totalProducts = allProducts.length;
        final entries = inventoryMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: _SectionTitle(icon: Icons.factory, title: 'وضعیت لحظه‌ای انبارها')),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: _textGrey, size: 20),
                  tooltip: 'تازه‌سازی',
                  onPressed: () => setState(() => _inventoryFuture = _api.getWarehouseInventory()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // کارت‌های آماری کلی (مدرن و مینیمال)
            _buildSummaryStats(totalWarehouses, totalProducts, grandTotal),
            const SizedBox(height: 20),

            // لیست انبارها به صورت کارت‌های قابل گسترش
            ...entries.map((entry) => _buildWarehouseCard(entry.key, entry.value)),
          ],
        );
      },
    );
  }

  // کارت‌های آمار کلی
  Widget _buildSummaryStats(int warehouses, int products, int total) {
    return Row(
      children: [
        Expanded(child: _MiniStatCard(title: 'تعداد انبارها', value: formatNumber(warehouses), color: _blue, icon: Icons.warehouse_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStatCard(title: 'نوع کالا', value: formatNumber(products), color: _purple, icon: Icons.category_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStatCard(title: 'موجودی کل', value: formatNumber(total), color: _orange, icon: Icons.inventory_rounded)),
      ],
    );
  }

  // کارت انبار (طراحی حرفه‌ای شده)
  Widget _buildWarehouseCard(String warehouseName, Map<String, (int, String?)> products) {
    final warehouseTotal = products.values.fold(0, (a, b) => a + b.$1);
    // پیدا کردن بالاترین موجودی برای محاسبه درصد پیشرفت
    final maxCountInThisWarehouse = products.values.fold<int>(0, (m, v) => math.max(m, v.$1));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: _blue.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warehouse_rounded, color: _blue, size: 24),
          ),
          title: Text(
            warehouseName,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: _textGrey),
                const SizedBox(width: 4),
                Text(
                  products.isEmpty ? 'بدون موجودی' : 'جمع ${formatNumber(warehouseTotal)}',
                  style: const TextStyle(color: _textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded, color: _green, size: 20),
          ),
          // نمایش محصولات داخل انبار با طراحی چشم‌نواز
          children: products.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text('بدون موجودی', style: TextStyle(color: _textGrey, fontSize: 13))),
                  ),
                ]
              : products.entries.map((entry) {
                  final productName = entry.key;
                  final (count, unit) = entry.value;

                  // اگر maxCountInThisWarehouse صفر باشد، progress صفر می‌ماند
                  final double progress = maxCountInThisWarehouse > 0
                      ? (count / maxCountInThisWarehouse).clamp(0.0, 1.0)
                      : 0.0;

                  // انتخاب رنگ بر اساس محصول (برای تنوع بصری)
                  final Color barColor = _getProductColor(productName);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(productName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                            Text(
                              '${formatNumber(count)} ${unit ?? 'عدد'}',
                              style: TextStyle(color: barColor, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // نوار پیشرفت مدرن
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 6,
                            width: double.infinity,
                            color: _surfaceLight,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [barColor.withValues(alpha: 0.8), barColor]),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }

  // تابع کمکی برای رنگ‌بندی کالاها
  Color _getProductColor(String name) {
    final colors = [_green, _orange, _blue, _purple, _red];
    return colors[name.hashCode.abs() % colors.length];
  }

  // ─────────────────────────────────────────
  //گزارش ارسالی‌ها
  // ─────────────────────────────────────────
  Widget _buildShipmentsSection() {
    // future در state نگه‌داری می‌شود تا هر rebuild درخواست تکراری نفرستد
    _shipmentsFuture ??= _api.getShipmentsReport();

    return FutureBuilder<ShipmentReportModel>(
      future: _shipmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: _green)),
          );
        }
        if (snapshot.hasError) {
          return _GlassMorphismCard(
            child: _ErrorRetryBox(
              message: friendlyError(snapshot.error!),
              onRetry: () => setState(() => _shipmentsFuture = _api.getShipmentsReport()),
            ),
          );
        }
        final report = snapshot.data;
        if (report == null || report.totalShipments == 0) {
          return _GlassMorphismCard(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.local_shipping_outlined, size: 48, color: _textGrey.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('ارسالی‌ای ثبت نشده است', style: TextStyle(color: _textGrey, fontSize: 16)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: _SectionTitle(icon: Icons.local_shipping_rounded, title: 'گزارش ارسالی‌ها')),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: _textGrey, size: 20),
                  tooltip: 'تازه‌سازی',
                  onPressed: () => setState(() => _shipmentsFuture = _api.getShipmentsReport()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // آخرین ارسالی — کارت هایلایت
            if (report.lastShipment != null) ...[
              _buildLastShipmentCard(report.lastShipment!),
              const SizedBox(height: 16),
            ],

            // آمار کلی
            Row(
              children: [
                Expanded(child: _MiniStatCard(title: 'کل ارسالی‌ها', value: formatNumber(report.totalShipments), color: _blue, icon: Icons.local_shipping_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStatCard(title: 'مجموع واحد', value: formatNumber(report.totalUnits), color: _orange, icon: Icons.inventory_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStatCard(title: 'انبار فعال', value: formatNumber(report.totalWarehouses), color: _purple, icon: Icons.warehouse_rounded)),
              ],
            ),
            const SizedBox(height: 20),

            // کارت هر انبار: شمار ارسالی + تاریخچهٔ روزانه
            ...report.warehouses.map((w) => _buildShipmentWarehouseCard(w)),
          ],
        );
      },
    );
  }

  /// کارت هایلایت «آخرین ارسالی»
  Widget _buildLastShipmentCard(ShipmentOrderModel s) {
    final itemsSummary = s.items.isEmpty
        ? '—'
        : s.items.map((i) => '${i.productName} (${formatNumber(i.quantity)} ${i.unit ?? 'عدد'})').join('، ');
    final (statusLabel, statusColor) = _shipmentStatus(s.status);
    final when = _formatJalaliDateTime(s.createdAt);
    final receiverPart = s.receiverName != null ? 'به ${s.receiverName}' : '';
    final cityPart = s.city != null ? ' — ${s.city}' : '';
    final byPart = s.createdByName != null ? ' · ${s.createdByName}' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_green.withValues(alpha: 0.14), _surfaceLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bolt_rounded, color: _green, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('آخرین ارسالی', style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w800))),
              _shipmentStatusChip(statusLabel, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(itemsSummary, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'از ${s.warehouseName ?? '—'}${receiverPart.isNotEmpty ? ' $receiverPart' : ''}$cityPart',
            style: TextStyle(color: _textGrey.withValues(alpha: 0.95), fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Text(
            '$when$byPart',
            style: TextStyle(color: _textGrey.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// کارت یک انبار با تاریخچهٔ روزانهٔ ارسالی‌ها
  Widget _buildShipmentWarehouseCard(ShipmentWarehouseModel w) {
    final lastAt = w.lastShipmentAt != null ? _formatJalaliShort(DateTime.parse(w.lastShipmentAt!)) : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: _blue.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_shipping_rounded, color: _purple, size: 24),
          ),
          title: Text(
            w.warehouseName ?? '—',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${formatNumber(w.totalCount)} ارسالی · آخرین: $lastAt',
              style: const TextStyle(color: _textGrey, fontSize: 13),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _purple.withValues(alpha: 0.3)),
            ),
            child: Text(
              formatNumber(w.totalCount),
              style: const TextStyle(color: _purple, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          children: w.daily.map((day) => _buildShipmentDay(day)).toList(),
        ),
      ),
    );
  }

  /// یک روز از تاریخچه: سربرگ تاریخ + ردیف‌های ارسالی
  Widget _buildShipmentDay(ShipmentDayModel day) {
    final dateText = day.date != null ? _jalaliDateText(day.date!) : '—';
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 16, color: _green.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(dateText, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${formatNumber(day.count)} ارسالی', style: const TextStyle(color: _green, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...day.items.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildShipmentOrderRow(o),
              )),
        ],
      ),
    );
  }

  /// ردیف یک ارسالی: کالاها + وضعیت + زمان + گیرنده
  Widget _buildShipmentOrderRow(ShipmentOrderModel o) {
    final itemsSummary = o.items.isEmpty
        ? '—'
        : o.items.map((i) => '${i.productName} × ${formatNumber(i.quantity)} ${i.unit ?? 'عدد'}').join('، ');
    final (statusLabel, statusColor) = _shipmentStatus(o.status);
    final when = _formatJalaliTime(o.createdAt);
    final receiverPart = o.receiverName != null ? 'به ${o.receiverName}' : '';
    final cityPart = o.city != null ? ' — ${o.city}' : '';
    final byPart = o.createdByName != null ? ' · ${o.createdByName}' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  itemsSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              _shipmentStatusChip(statusLabel, statusColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$when$byPart',
            style: TextStyle(color: _textGrey.withValues(alpha: 0.75), fontSize: 11.5),
          ),
          if (receiverPart.isNotEmpty || cityPart.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              '$receiverPart$cityPart',
              style: TextStyle(color: _textGrey.withValues(alpha: 0.85), fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }

  /// وضعیت سفارش → (برچسب فارسی، رنگ)
  (String, Color) _shipmentStatus(String? status) {
    return switch (status) {
      'SHIPPED' => ('ارسال‌شده', _green),
      'DELIVERED' => ('تحویل‌شده', _blue),
      'CANCELED' => ('لغوشده', _red),
      'PENDING' => ('در انتظار', _amber),
      _ => ('ثبت‌شده', _textGrey),
    };
  }

  Widget _shipmentStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }

  /// تاریخ شمسی + ساعت از ISO — «۲۷ مرداد ۱۴۰۵ - ۱۲:۳۰»
  String _formatJalaliDateTime(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.parse(iso).toLocal();
    final j = Jalali.fromDateTime(dt);
    String two(int n) => n.toString().padLeft(2, '0');
    return faDigits('${j.day} ${j.formatter.mN} ${j.year} - ${two(dt.hour)}:${two(dt.minute)}');
  }

  /// تاریخ شمسی کوتاه از ISO — «۲۷ مرداد ۱۴۰۵»
  String _formatJalaliShort(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return faDigits('${j.day} ${j.formatter.mN} ${j.year}');
  }

  /// فقط ساعت از ISO — «۱۲:۳۰»
  String _formatJalaliTime(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.parse(iso).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return faDigits('${two(dt.hour)}:${two(dt.minute)}');
  }

  /// تاریخ روزانهٔ میلادی («2026-08-18») → «۱۸ مرداد ۱۴۰۵»
  String _jalaliDateText(String dateStr) {
    final p = dateStr.split('-');
    if (p.length != 3) return dateStr;
    final j = Jalali.fromDateTime(DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2])));
    return faDigits('${j.day} ${j.formatter.mN} ${j.year}');
  }

  // ─────────────────────────────────────────
  //گزارش کاربران
  // ─────────────────────────────────────────
  Widget _buildUserReportsSection() {
    // future در state نگه‌داری می‌شود تا هر rebuild درخواست تکراری نفرستد
    _usersFuture ??= _api.getUsers();

    return _GlassMorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.people_alt_rounded, title: 'گزارش کاربران'),
          const SizedBox(height: 16),
          FutureBuilder<List<UserModel>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator(color: _green)),
                );
              }
              if (snapshot.hasError) {
                return _ErrorRetryBox(
                  message: friendlyError(snapshot.error!),
                  onRetry: () => setState(() => _usersFuture = _api.getUsers()),
                );
              }
              final List<UserModel> users = snapshot.data ?? [];
              if (users.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('کاربری ثبت نشده', style: TextStyle(color: _textGrey.withValues(alpha: 0.8), fontSize: 13)),
                  ),
                );
              }
              return Column(
                children: users.map((u) => _UserReportTile(user: u)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ویجت‌های کمکی reusable با طراحی حرفه‌ای
// ─────────────────────────────────────────────

/// باکس خطا با دکمهٔ تلاش مجدد
class _ErrorRetryBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetryBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: _red, size: 32),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textGrey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, color: _green, size: 18),
            label: const Text('تلاش مجدد', style: TextStyle(color: _green)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _green.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

/// تایل یک کاربر در لیست گزارش کاربران
class _UserReportTile extends StatelessWidget {
  final UserModel user;
  const _UserReportTile({required this.user});

  (String, Color) _roleInfo() {
    final role = user.role ?? '';
    return switch (role) {
      'MANAGER' => ('مدیر سیستم', _purple),
      'WAREHOUSE_KEEPER' => ('انباردار', _green),
      'DRIVER' => ('راننده', _blue),
      _ => (role, _textGrey),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (roleLabel, roleColor) = _roleInfo();
    final name = user.name ?? '';
    final warehouseName = user.warehouseName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _surfaceLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserReportScreen(
                  userId: user.id,
                  userName: name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(
                    name.isEmpty ? '?' : name.characters.first,
                    style: TextStyle(color: roleColor, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(
                        warehouseName != null ? '$roleLabel — انبار $warehouseName' : roleLabel,
                        style: TextStyle(color: _textGrey.withValues(alpha: 0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// کارت شیشه‌ای (Glassmorphism) برای یکپارچگی ظاهر
class _GlassMorphismCard extends StatelessWidget {
  final Widget child;
  const _GlassMorphismCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

/// عنوان سکشن‌ها
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _green, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// ویجت آمار کوچک (برای بخش خلاصه وضعیت انبار)
class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _MiniStatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: _textGrey, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}