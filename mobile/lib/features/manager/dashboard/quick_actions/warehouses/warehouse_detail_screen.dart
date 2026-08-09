import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../models/warehouse_model.dart';
import '../../../models/warehouse_detail_model.dart';
import '../../../models/transaction_entry_model.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _card = Color(0xFF1E2128);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _blue = Color(0xFF60A5FA);
const _purple = Color(0xFFA78BFA);
const _danger = Color(0xFFF87171);

class WarehouseDetailScreen extends ConsumerStatefulWidget {
  final WarehouseModel warehouse;
  const WarehouseDetailScreen({super.key, required this.warehouse});

  @override
  ConsumerState<WarehouseDetailScreen> createState() => _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends ConsumerState<WarehouseDetailScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  WarehouseDetailModel? _detail;
  List<TransactionEntryModel> _transactions = [];
  bool _loading = true;
  bool _loadingTx = false;
  Jalali? _selectedDate;

  bool get _showRetry => _detail == null && !_loading;

  String get _dateStr => _selectedDate != null
      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
      : '';

  @override
  void initState() {
    super.initState();
    _loadDetail();
    // تاریخچه امروز به‌صورت پیش‌فرض نمایش داده می‌شود
    _selectedDate = Jalali.now();
    _loadTransactions();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getWarehouseDetail(widget.warehouse.id);
      if (!mounted) return;
      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadDetail(), _loadTransactions()]);
  }

  Future<void> _loadTransactions() async {
    if (_selectedDate == null) return;
    setState(() => _loadingTx = true);
    try {
      _transactions = await _api.getTransactionsByDate(widget.warehouse.id, _dateStr);
    } catch (_) {
      _transactions = [];
    }
    if (!mounted) return;
    setState(() => _loadingTx = false);
  }

  Future<void> _pickDate() async {
    final today = Jalali.now();
    final picked = await showDialog<Jalali>(
      context: context,
      builder: (_) => _MonthPickerDialog(initial: _selectedDate ?? today),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: Text(widget.warehouse.name, style: const TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        color: _green,
        backgroundColor: _surface,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // ── Info Card ──────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: Row(children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.warehouse_rounded, color: _green, size: 28)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.warehouse.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('انباردار: $_keeperName', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text('${_detail?.stats.productCount.toInt() ?? 0} محصول', style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600))),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Stats Row ──────────────────────────
            if (_loading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: _green)))
            else if (_showRetry)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _danger.withValues(alpha: 0.3))),
                      child: Column(children: [
                        const Icon(Icons.cloud_off_rounded, color: _danger, size: 28),
                        const SizedBox(height: 8),
                        Text('خطا در دریافت اطلاعات انبار', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadDetail,
                          style: ElevatedButton.styleFrom(backgroundColor: _green),
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          label: const Text('تلاش مجدد', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                  ),
                ]),
              )
            else
              Row(children: [
                _StatCard(icon: Icons.download_rounded, label: 'ورودی‌ها', count: '${_detail?.stats.inCount.toInt() ?? 0}', color: _green),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.upload_rounded, label: 'خروجی‌ها', count: '${_detail?.stats.outCount.toInt() ?? 0}', color: _orange),
              ]),

            if (_detail != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                _StatCard(icon: Icons.inventory_2_rounded, label: 'واحد موجود', count: '${_detail!.stats.totalUnits.toInt()}', color: _blue),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.all_inbox_rounded, label: 'کارتن موجود', count: '${_detail!.stats.totalCartons.toInt()}', color: _purple),
              ]),
            ],
            const SizedBox(height: 24),

            // ── Inventory Summary ──────────────────
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('موجودی انبار', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (_inventoryItems.isNotEmpty)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text('${_detail?.stats.totalUnits.toInt() ?? 0} واحد', style: const TextStyle(color: _green, fontSize: 11.5, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: _green)))
                else if (_inventoryItems.isEmpty)
                  Center(child: Text('موجودی در این انبار ثبت نشده', style: TextStyle(color: Colors.grey, fontSize: 14)))
                else
                  ..._inventoryItems.map((product) => _ProductInventoryCard(product: product)),
              ]),
            ),
            const SizedBox(height: 24),

            // ── تاریخچه ────────────────────────────
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('تاریخچه ورود و خروج', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),

                // Date Picker
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.calendar_month_rounded, color: _green, size: 20),
                      const SizedBox(width: 8),
                      Text(_selectedDate != null ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}' : 'انتخاب تاریخ', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // Transactions List
                if (_loadingTx)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _green)))
                else if (_selectedDate == null)
                  Center(child: Text('تاریخ را انتخاب کنید', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)))
                else if (_transactions.isEmpty)
                  Center(child: Text('تراکنشی در این تاریخ ثبت نشده', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)))
                else
                  ...(_transactions.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(_transactionIcon(t.type), color: _transactionColor(t.type), size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${_transactionLabel(t.type)} ${t.productName ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
                      Text('${t.quantity.toInt()} عدد', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ]),
                  )).toList()),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  String get _keeperName => _detail?.keeperName ?? widget.warehouse.keeperName ?? '---';

  List<WarehouseProductStockModel> get _inventoryItems => _detail?.products ?? const [];
}

String _transactionLabel(String? type) {
  switch (type) {
    case 'RETURN':
      return 'مرجوعی';
    case 'OUT':
      return 'خروج';
    default:
      return 'ورود';
  }
}

Color _transactionColor(String? type) {
  switch (type) {
    case 'RETURN':
      return _blue;
    case 'OUT':
      return _orange;
    default:
      return _green;
  }
}

IconData _transactionIcon(String? type) {
  switch (type) {
    case 'RETURN':
      return Icons.assignment_return_rounded;
    case 'OUT':
      return Icons.upload_rounded;
    default:
      return Icons.download_rounded;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String count; final Color color;
  const _StatCard({required this.icon, required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
        child: Column(children: [
          Icon(icon, color: color, size: 28), const SizedBox(height: 8),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        ]),
      ),
    );
  }
}

class _ProductInventoryCard extends StatelessWidget {
  final WarehouseProductStockModel product;
  const _ProductInventoryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final models = product.models;
    final total = product.totalCount.toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: _green,
          collapsedIconColor: _green,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_rounded, color: _green, size: 20),
          ),
          title: Text('${product.name ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(label: 'کل', value: '$total ${product.unit ?? 'عدد'}', color: total > 0 ? _green : _orange),
                _MiniBadge(label: 'کارتن', value: '${product.cartonCount.toInt()}', color: _blue),
                _MiniBadge(label: 'تکی', value: '${product.individualCount.toInt()}', color: _purple),
                _MiniBadge(label: 'مدل', value: '${product.modelCount.toInt()}', color: _orange),
              ],
            ),
          ),
          children: [
            if (models.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12)),
                child: Text('برای این محصول مدلی ثبت نشده است.', style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
              )
            else
              ...models.map((m) => _ModelTile(model: m, unit: '${product.unit ?? 'عدد'}')),
          ],
        ),
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  final WarehouseModelStockModel model;
  final String unit;
  const _ModelTile({required this.model, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${model.name ?? 'بدون مدل'}', style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricLine(label: 'موجودی مدل', value: '${model.totalCount.toInt()} $unit', color: _green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricLine(label: 'کارتن', value: '${model.cartonCount.toInt()}', color: _blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MetricLine(label: 'تکی', value: '${model.individualCount.toInt()}', color: _purple),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.58), fontSize: 11.5)),
        ),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text('$label: $value', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// Simple Month Picker
class _MonthPickerDialog extends StatefulWidget {
  final Jalali initial;
  const _MonthPickerDialog({required this.initial});
  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year, _month;
  @override
  void initState() { super.initState(); _year = widget.initial.year; _month = widget.initial.month; }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surface,
      title: Text('$_year/${_month.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Wrap(spacing: 6, runSpacing: 6, children: List.generate(_monthLength(), (i) {
          final day = i + 1;
          return GestureDetector(
            onTap: () => Navigator.pop(context, Jalali(_year, _month, day)),
            child: Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: _green.withValues(alpha: 0.3))), child: Text('$day', style: const TextStyle(color: Colors.white, fontSize: 14))),
          );
        })),
      ),
      actions: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.chevron_right, color: _green), onPressed: () => setState(() { _month--; if (_month < 1) { _month = 12; _year--; } })),
          IconButton(icon: const Icon(Icons.chevron_left, color: _green), onPressed: () => setState(() { _month++; if (_month > 12) { _month = 1; _year++; } })),
        ]),
      ],
    );
  }
  int _monthLength() => Jalali(_year, _month, 1).monthLength;
}