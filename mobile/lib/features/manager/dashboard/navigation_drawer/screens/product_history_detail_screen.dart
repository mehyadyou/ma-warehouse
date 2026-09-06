import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../providers/manager_api_provider.dart';
import '../../../models/product_history_model.dart';
import '../../../../../shared/utils/numbers.dart';
import '../../../../../shared/widgets/jalali_month_picker.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _blue = Color(0xFF60A5FA);
const _orange = Color(0xFFFB923C);
const _red = Color(0xFFF87171);
const _purple = Color(0xFFA78BFA);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

/// «سابقهٔ محصول» — همهٔ اتفاقاتی که برای یک محصول از ابتدا افتاده:
/// کارت‌ها با سریال (کارتن/تکی)، سفارش مشتری، تراکنش‌ها، جابه‌جایی/خروج
class ProductHistoryDetailScreen extends ConsumerStatefulWidget {
  const ProductHistoryDetailScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  ConsumerState<ProductHistoryDetailScreen> createState() =>
      _ProductHistoryDetailScreenState();
}

class _ProductHistoryDetailScreenState
    extends ConsumerState<ProductHistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  ProductHistoryDetailModel? _data;
  bool _loading = true;
  String _error = '';
  Jalali? _day; // فیلترِ روزِ دقیقِ شمسی — null یعنی همهٔ سابقه

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final d = await ref
          .read(managerApiServiceProvider)
          .getProductHistoryDetail(
            widget.productId,
            activityDate: _day == null ? null : _jIso(_day!),
          );
      if (!mounted) return;
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'دریافت سابقهٔ محصول ناموفق بود';
        _loading = false;
      });
    }
  }

  String _jIso(Jalali j) =>
      '${j.year}-${j.month.toString().padLeft(2, '0')}-${j.day.toString().padLeft(2, '0')}';

  String _fmtJ(Jalali j) => faDigits(
      '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');

  Future<void> _pickDay() async {
    final picked = await showJalaliMonthPicker(
      context,
      initial: _day ?? Jalali.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _day = picked);
    _load();
  }

  void _clearDay() {
    setState(() => _day = null);
    _load();
  }

  String _jalali(DateTime? dt, {bool withTime = false}) {
    if (dt == null) return '—';
    try {
      final j = Jalali.fromDateTime(dt.toLocal());
      final d =
          '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
      if (!withTime) return faDigits(d);
      final h = dt.toLocal().hour.toString().padLeft(2, '0');
      final m = dt.toLocal().minute.toString().padLeft(2, '0');
      return faDigits('$d — $h:$m');
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.productName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month_rounded,
              color: _day != null ? _green : _textDim,
              size: 22,
            ),
            tooltip: 'فیلترِ روزِ دقیق (شمسی)',
            onPressed: _pickDay,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _error.isNotEmpty
              ? _errorView()
              : _body(),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: _textDim, size: 40),
          const SizedBox(height: 12),
          Text(_error, style: const TextStyle(color: _textDim, fontSize: 13)),
          const SizedBox(height: 14),
          TextButton(
            onPressed: _load,
            child: const Text('تلاش دوباره', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    final d = _data!;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          if (_day != null) _dayBanner(),
          _summaryHeader(d),
          TabBar(
            controller: _tabs,
            indicatorColor: _green,
            labelColor: Colors.white,
            unselectedLabelColor: _textDim,
            labelStyle:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'کارتن‌ها'),
              Tab(text: 'تراکنش‌ها'),
              Tab(text: 'جابه‌جایی/خروج'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _cartonsTab(d),
                _transactionsTab(d),
                _transfersTab(d),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// نوارِ روزِ فیلترشده — بالای هدر
  Widget _dayBanner() {
    return Container(
      width: double.infinity,
      color: _green.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded, color: _green, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'نمایش رخدادهای روزِ ${_fmtJ(_day!)}',
              style: const TextStyle(
                color: _green,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearDay,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close_rounded, color: _green, size: 14),
                SizedBox(width: 3),
                Text(
                  'همهٔ سابقه',
                  style: TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── هدر خلاصه ──────────────────────────────────────

  Widget _summaryHeader(ProductHistoryDetailModel d) {
    final c = d.counts;
    return Container(
      width: double.infinity,
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip('کارتن‌ها: ${faDigits('${c.cartons}')}', _blue),
              _chip('موجود: ${faDigits('${c.inStock}')}', _green),
              _chip('ارسال‌شده: ${faDigits('${c.shipped}')}', _amber),
              if (c.returned > 0) _chip('مرجوع: ${faDigits('${c.returned}')}', _orange),
              if (c.exited > 0) _chip('خارج‌شده: ${faDigits('${c.exited}')}', _red),
              if (c.individuals > 0)
                _chip('تکی: ${faDigits('${c.individuals}')}', _purple),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'واحد — ورود: ${faDigits('${c.txIn}')} • خروج: ${faDigits('${c.txOut}')}'
            '${c.txReturn > 0 ? ' • مرجوعی: ${faDigits('${c.txReturn}')}' : ''}'
            ' • واحد شمارش: ${d.unit}',
            style: const TextStyle(color: _textDim, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─── تب کارتن‌ها ────────────────────────────────────

  Widget _cartonsTab(ProductHistoryDetailModel d) {
    if (d.cartons.isEmpty) {
      return _tabEmpty(_day != null
          ? 'در این روز کارتنی وارد یا خارج نشده'
          : 'هیچ کارتنی برای این محصول ثبت نشده (لِگاسی/تراکنشی)');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: d.cartons.length + (d.truncatedCartons ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= d.cartons.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'نمایش آخرین ۲۰۰ کارتن...',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textDim, fontSize: 11),
            ),
          );
        }
        return _cartonCard(d.cartons[i]);
      },
    );
  }

  Widget _cartonCard(ProductHistoryCarton c) {
    final statusColor = switch (c.status) {
      'IN_STOCK' => _green,
      'SHIPPED' => _amber,
      'RETURNED' => _orange,
      'EXITED' => _red,
      _ => _textDim,
    };
    final statusLabel = switch (c.status) {
      'IN_STOCK' => 'موجود در انبار',
      'SHIPPED' => 'ارسال‌شده',
      'RETURNED' => 'مرجوع‌شده',
      'EXITED' => 'خارج‌شده از سیستم',
      _ => c.status,
    };
    final o = c.order;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (c.isIndividual ? _purple : _blue)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c.isIndividual ? 'تکی' : 'کارتن',
                    style: TextStyle(
                      color: c.isIndividual ? _purple : _blue,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'ورود: ${_jalali(c.createdAt)}',
                  style: const TextStyle(color: _textDim, fontSize: 10.5),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, color: _textDim, size: 15),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    c.serialNumber ?? 'بدون سریال',
                    style: TextStyle(
                      color: c.serialNumber != null ? Colors.white : _textDim,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (c.serialNumber != null)
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: c.serialNumber!),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سریال کپی شد'),
                          backgroundColor: _surfaceAlt,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(Icons.copy_rounded,
                        color: _textDim, size: 15),
                  ),
              ],
            ),
            if (c.modelName != null) ...[
              const SizedBox(height: 5),
              Text('مدل: ${c.modelName}',
                  style: const TextStyle(color: _textDim, fontSize: 11.5)),
            ],
            if (c.scannedOutAt != null) ...[
              const SizedBox(height: 5),
              Text('خروج از انبار: ${_jalali(c.scannedOutAt, withTime: true)}',
                  style: const TextStyle(color: _textDim, fontSize: 11.5)),
            ],
            if (o != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: _amber, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'سفارش شمارهٔ ${faDigits('${o.orderNumber}')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _orderStatusLabel(o.status),
                          style: TextStyle(
                            color: _orderStatusColor(o.status),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _infoRow('مشتری', o.receiverName ?? '—'),
                    if (o.customerPhone != null)
                      _infoRow('شمارهٔ مشتری', faDigits(o.customerPhone!)),
                    if (o.city != null) _infoRow('شهر', o.city!),
                    if (o.carrier != null) _infoRow('باربری', o.carrier!),
                    if (o.driverName != null) _infoRow('راننده', o.driverName!),
                    _infoRow('تاریخ سفارش', _jalali(o.createdAt)),
                    if (o.deliveredAt != null)
                      _infoRow('تحویل داده‌شده', _jalali(o.deliveredAt, withTime: true)),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                c.isIndividual
                    ? 'خروج تکی — بدون سفارش'
                    : 'هنوز به سفارشی وصل نشده',
                style: const TextStyle(color: _textDim, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(label,
                style: const TextStyle(color: _textDim, fontSize: 11)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  String _orderStatusLabel(String s) => switch (s) {
        'PENDING' => 'در انتظار',
        'SHIPPED' => 'ارسال‌شده',
        'DELIVERED' => 'تحویل‌شده',
        'CANCELED' => 'لغو‌شده',
        _ => s,
      };

  Color _orderStatusColor(String s) => switch (s) {
        'PENDING' => _textDim,
        'SHIPPED' => _amber,
        'DELIVERED' => _green,
        'CANCELED' => _red,
        _ => _textDim,
      };

  // ─── تب تراکنش‌ها ───────────────────────────────────

  Widget _transactionsTab(ProductHistoryDetailModel d) {
    if (d.transactions.isEmpty) {
      return _tabEmpty(_day != null ? 'در این روز تراکنشی ثبت نشده' : 'تراکنشی ثبت نشده');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: d.transactions.length,
      itemBuilder: (context, i) => _txCard(d.transactions[i]),
    );
  }

  Widget _txCard(ProductHistoryTransaction t) {
    final isIn = t.type == 'IN';
    final isReturn = t.type == 'RETURN';
    final color = isIn ? _green : (isReturn ? _orange : _red);
    final label = isIn ? 'ورود کالا' : (isReturn ? 'مرجوعی' : 'خروج کالا');
    final icon = isIn
        ? Icons.south_west_rounded
        : (isReturn ? Icons.replay_rounded : Icons.north_east_rounded);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label — ${faDigits('${t.quantity}')} $_unitSuffix',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${t.warehouseName} • ${t.userName}',
                  style: const TextStyle(color: _textDim, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            _jalali(t.createdAt, withTime: true),
            style: const TextStyle(color: _textDim, fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  String get _unitSuffix => _data?.unit ?? '';

  // ─── تب جابه‌جایی/خروج ──────────────────────────────

  Widget _transfersTab(ProductHistoryDetailModel d) {
    if (d.transfers.isEmpty) {
      return _tabEmpty(
          _day != null ? 'در این روز جابه‌جایی یا خروجی ثبت نشده' : 'جابه‌جایی یا خروجی ثبت نشده');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: d.transfers.length,
      itemBuilder: (context, i) => _transferCard(d.transfers[i]),
    );
  }

  Widget _transferCard(ProductHistoryTransfer t) {
    final color = t.isExit ? _red : _blue;
    final icon = t.isExit
        ? Icons.logout_rounded
        : Icons.swap_horizontal_circle_rounded;
    final destination = t.isExit
        ? 'خروج از سیستم'
        : 'به ${t.toWarehouseName ?? '—'}';
    final statusLabel = switch (t.status) {
      'PENDING' => 'در انتظار',
      'DONE' => 'انجام‌شده',
      'CANCELED' => 'لغو‌شده',
      _ => t.status,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: t.isExit ? _red.withValues(alpha: 0.25) : _border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$destination — ${faDigits('${t.quantity}')} $_unitSuffix',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: t.status == 'DONE'
                            ? _green
                            : (t.status == 'CANCELED' ? _red : _amber),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'از ${t.fromWarehouseName} • توسط ${t.createdByName}',
                  style: const TextStyle(color: _textDim, fontSize: 11),
                ),
                if (t.description != null && t.description!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      t.description!,
                      style:
                          const TextStyle(color: _textDim, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  _jalali(t.createdAt, withTime: true),
                  style: const TextStyle(color: _textDim, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, color: _textDim, size: 40),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: _textDim, fontSize: 13)),
        ],
      ),
    );
  }
}
