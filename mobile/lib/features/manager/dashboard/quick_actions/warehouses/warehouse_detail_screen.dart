import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../shared/widgets/jalali_month_picker.dart';
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
  String? _detailError;
  String? _txError;
  Jalali? _selectedDate;

  bool get _showRetry => _detailError != null && _detail == null && !_loading;

  String get _dateStr => _selectedDate != null
      ? '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
      : '';

  String get _dateLabel => _selectedDate != null
      ? '${_selectedDate!.year.toString().padLeft(4, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}'
      : 'انتخاب تاریخ';

  bool get _isToday {
    final today = Jalali.now();
    final j = _selectedDate;
    return j != null && j.year == today.year && j.month == today.month && j.day == today.day;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = Jalali.now();
    _loadDetail();
    _loadTransactions();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _detailError = null;
    });
    try {
      final data = await _api.getWarehouseDetail(widget.warehouse.id);
      if (!mounted) return;
      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (e) {
      String msg = 'خطا در دریافت اطلاعات انبار';
      if (e is DioException &&
          e.response?.data is Map &&
          e.response?.data['error'] != null) {
        msg = '${e.response?.data['error']}';
      }
      if (!mounted) return;
      setState(() {
        _detailError = msg;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadDetail(), _loadTransactions()]);
  }

  Future<void> _loadTransactions() async {
    if (_selectedDate == null) return;
    setState(() {
      _loadingTx = true;
      _txError = null;
    });
    try {
      _transactions =
          await _api.getTransactionsByDate(widget.warehouse.id, _dateStr);
    } catch (_) {
      _txError = 'خطا در دریافت تراکنش‌ها';
      _transactions = [];
    }
    if (!mounted) return;
    setState(() => _loadingTx = false);
  }

  Future<void> _pickDate() async {
    final today = Jalali.now();
    final picked = await showJalaliMonthPicker(
      context,
      initial: _selectedDate ?? today,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadTransactions();
    }
  }

  void _shiftDay(int delta) {
    final j = _selectedDate;
    if (j == null) return;
    if (delta > 0 && _isToday) return;
    setState(() => _selectedDate = j.addDays(delta));
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: Text(
          widget.warehouse.name,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                  Text(widget.warehouse.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('انباردار: $_keeperName', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                  if (widget.warehouse.address?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(widget.warehouse.address!.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
                  ],
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
                        Text(_detailError ?? 'خطا در دریافت اطلاعات انبار', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
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
                _StatCard(icon: Icons.download_rounded, label: 'ورودی', count: '${_detail?.stats.inUnits.toInt() ?? 0}', sub: 'واحد', color: _green),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.upload_rounded, label: 'خروجی', count: '${_detail?.stats.outUnits.toInt() ?? 0}', sub: 'واحد', color: _orange),
              ]),

            if (_detail != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                _StatCard(icon: Icons.inventory_2_rounded, label: 'واحد موجود', count: '${_detail!.stats.totalUnits.toInt()}', sub: 'واحد', color: _blue),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.all_inbox_rounded, label: 'کارتن موجود', count: '${_detail!.stats.totalCartons.toInt()}', sub: 'کارتن', color: _purple),
              ]),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: 'تراکنش‌ها', value: '${_detail!.stats.transactionCount.toInt()}', color: _blue),
                  _MiniBadge(label: 'مرجوعی', value: '${_detail!.stats.returnedUnits.toInt()} واحد', color: _orange),
                  _MiniBadge(label: 'سفارش فعال', value: '${_detail!.stats.activeOrderCount.toInt()}', color: _purple),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // ── Inventory Summary ──────────────────
            if (_detail != null)
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
                  if (_inventoryItems.isEmpty)
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

                // Date Navigation
                Row(children: [
                  IconButton(
                    onPressed: () => _shiftDay(-1),
                    icon: const Icon(Icons.chevron_right_rounded, color: _green, size: 26),
                    tooltip: 'روز قبل',
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.calendar_month_rounded, color: _green, size: 18),
                          const SizedBox(width: 8),
                          Flexible(child: Text(_dateLabel, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600))),
                        ]),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isToday ? null : () => _shiftDay(1),
                    icon: Icon(Icons.chevron_left_rounded, color: _isToday ? Colors.white.withValues(alpha: 0.15) : _green, size: 26),
                    tooltip: 'روز بعد',
                  ),
                ]),
                if (!_isToday) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _selectedDate = Jalali.now());
                        _loadTransactions();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                        side: BorderSide(color: _green.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('امروز', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Transactions List
                if (_loadingTx)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _green)))
                else if (_txError != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _danger.withValues(alpha: 0.3)),
                    ),
                    child: Column(children: [
                      Icon(Icons.cloud_off_rounded, color: _danger.withValues(alpha: 0.8), size: 26),
                      const SizedBox(height: 8),
                      Text(_txError!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _loadTransactions,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _green,
                          side: BorderSide(color: _green.withValues(alpha: 0.4)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('تلاش مجدد', style: TextStyle(fontSize: 12.5)),
                      ),
                    ]),
                  )
                else if (_selectedDate == null)
                  Center(child: Text('تاریخ را انتخاب کنید', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)))
                else if (_transactions.isEmpty)
                  Center(child: Text('تراکنشی در این تاریخ ثبت نشده', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)))
                else
                  ..._groupedTransactions.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GroupHeader(label: entry.key.label, count: entry.value.length, color: entry.key.color),
                      ...entry.value.map((t) => _TransactionRow(transaction: t)),
                      const SizedBox(height: 8),
                    ],
                  )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  String get _keeperName => _detail?.keeperName ?? widget.warehouse.keeperName ?? '---';

  List<WarehouseProductStockModel> get _inventoryItems => _detail?.products ?? const [];

  Map<TransactionGroup, List<TransactionEntryModel>> get _groupedTransactions {
    final map = <TransactionGroup, List<TransactionEntryModel>>{
      for (final g in TransactionGroup.values) g: [],
    };
    for (final t in _transactions) {
      map[TransactionGroup.fromType(t.type)]!.add(t);
    }
    map.removeWhere((_, list) => list.isEmpty);
    return map;
  }
}

enum TransactionGroup {
  checkin('ورود کالا', _green, Icons.download_rounded),
  checkout('خروج کالا', _orange, Icons.upload_rounded),
  returned('مرجوعی', _blue, Icons.assignment_return_rounded);

  const TransactionGroup(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;

  static TransactionGroup fromType(String? type) {
    switch (type) {
      case 'OUT':
        return TransactionGroup.checkout;
      case 'RETURN':
        return TransactionGroup.returned;
      default:
        return TransactionGroup.checkin;
    }
  }
}

String _formatTime(TransactionEntryModel t) {
  final raw = t.createdAt;
  if (raw == null || raw.isEmpty) return '';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return '';
  final j = dt.toLocal().toJalali();
  return '${j.hour.toString().padLeft(2, '0')}:${j.minute.toString().padLeft(2, '0')}';
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _GroupHeader({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text('$label ($count)', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionEntryModel transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final group = TransactionGroup.fromType(transaction.type);
    final time = _formatTime(transaction);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(group.icon, color: group.color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(transaction.productName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            [if (time.isNotEmpty) time, if (transaction.userName != null) transaction.userName!].join(' — '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
          ),
        ])),
        const SizedBox(width: 8),
        Text('${transaction.quantity.toInt()} ${transaction.unit ?? 'عدد'}', style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String count; final String sub; final Color color;
  const _StatCard({required this.icon, required this.label, required this.count, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
        child: Column(children: [
          Icon(icon, color: color, size: 28), const SizedBox(height: 8),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 4),
          Text('$label ($sub)', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
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
