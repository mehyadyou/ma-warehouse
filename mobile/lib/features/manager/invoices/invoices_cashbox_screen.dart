import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../shared/utils/numbers.dart';
import '../data/manager_api_service.dart';
import '../models/order_model.dart';
import '../providers/manager_api_provider.dart';
import 'invoice_builder_screen.dart';
import 'invoice_order_converter.dart';
import 'invoice_repository_provider.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _blue = Color(0xFF60A5FA);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

String _statusKey(OrderModel o) {
  final ds = o.deliveryStatus;
  final os = o.status;
  if (ds == 'DELIVERED' || os == 'DELIVERED') return 'delivered';
  if (ds == 'IN_TRANSIT' || os == 'SHIPPED') return 'in_transit';
  if (os == 'PENDING' || ds == 'PENDING') return 'pending';
  return 'other';
}

String _statusLabel(OrderModel o) {
  final ds = o.deliveryStatus;
  final order = o.status;
  if (ds == 'DELIVERED' || order == 'DELIVERED') return 'تحویل شده';
  if (ds == 'IN_TRANSIT' || order == 'SHIPPED') return 'در حال ارسال';
  if (order == 'PENDING') return 'در انتظار';
  return 'در جریان';
}

Color _statusColor(OrderModel o) {
  final key = _statusKey(o);
  if (key == 'delivered') return _green;
  if (key == 'in_transit') return _amber;
  return _blue;
}

IconData _statusIcon(OrderModel o) {
  final key = _statusKey(o);
  if (key == 'delivered') return Icons.verified_rounded;
  if (key == 'in_transit') return Icons.local_shipping_rounded;
  if (key == 'pending') return Icons.schedule_rounded;
  return Icons.more_horiz_rounded;
}

String _jDate(String iso) {
  try {
    final j = Jalali.fromDateTime(DateTime.parse(iso));
    return '${j.year}/${j.month}/${j.day}';
  } catch (_) {
    return '—';
  }
}

/// صندوق: همهٔ سفارش‌های ثبت‌شده، دسته‌بندی‌شده بر اساس وضعیت ارسال —
/// فیلدهای فاکتور هر سفارش از قبل آماده می‌شود اما خروجی فقط با اقدام مدیر ساخته می‌شود
class InvoicesCashboxScreen extends ConsumerStatefulWidget {
  const InvoicesCashboxScreen({super.key});

  @override
  ConsumerState<InvoicesCashboxScreen> createState() =>
      _InvoicesCashboxScreenState();
}

class _InvoicesCashboxScreenState extends ConsumerState<InvoicesCashboxScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  late final _repo = ref.read(invoiceRepositoryProvider);
  final _scrollCtrl = ScrollController();

  bool _loading = true;
  String? _error;
  List<OrderModel> _orders = [];
  OrderCountsModel _counts = const OrderCountsModel();

  // صفحه‌بندی
  bool _hasMore = false;
  int _nextPage = 2;
  bool _loadingMore = false;

  /// شناسه سفارش‌هایی که قبلاً فاکتور شده‌اند
  late Set<String> _convertedIds = _loadConvertedIds();

  Set<String> _loadConvertedIds() => _repo
      .loadHistory()
      .map((invoice) => invoice.sourceOrderId)
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toSet();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = _orders.isEmpty;
      _error = null;
      _hasMore = false;
      _nextPage = 2;
    });
    try {
      final page = await _api.getOrders(
        page: 1,
        pageSize: 50,
      );
      if (!mounted) return;
      setState(() {
        _orders = page.orders;
        _counts = page.counts;
        _hasMore = page.hasMore;
        _nextPage = 2;
        _loading = false;
        _convertedIds = _loadConvertedIds();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'خطا در دریافت سفارش‌ها';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _api.getOrders(
        page: _nextPage,
        pageSize: 50,
      );
      if (!mounted) return;
      setState(() {
        _orders = [..._orders, ...page.orders];
        _counts = page.counts;
        _hasMore = page.hasMore;
        _nextPage++;
      });
    } catch (_) {
      // خطای صفحه‌بندی بی‌صدا — کاربر می‌تواند دوباره اسکرول کند
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// باز کردن فاکتور مرتبط با سفارش در فاکتورساز (برای ویرایش)
  Future<void> _openInvoice(OrderModel order) async {
    final initial = _repo
            .loadHistory()
            .where((invoice) => invoice.sourceOrderId == order.id)
            .firstOrNull ??
        convertOrderToInvoice(
          order,
          seller: _repo.loadSellerProfile(),
        );
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceBuilderScreen(initialDraft: initial),
      ),
    );
    // پس از بازگشت، وضعیت «فاکتور شده» به‌روز می‌شود
    if (mounted) setState(() => _convertedIds = _loadConvertedIds());
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
        title: const Text(
          'صندوق',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
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
        child: CircularProgressIndicator(color: _green),
      );
    }
    if (_error != null && _orders.isEmpty) {
      return _errorState();
    }
    if (_orders.isEmpty) {
      return _emptyState();
    }
    return _buildList();
  }

  Widget _buildList() {
    final children = <Widget>[];

    for (final group in _groups()) {
      children.add(_sectionHeader(group));
      for (final order in group.orders) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _orderCard(order),
        ));
      }
    }

    if (_loadingMore) {
      children.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _green,
            ),
          ),
        ),
      ));
    }

    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: _load,
      child: ListView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }

  List<_OrderGroup> _groups() {
    final byKey = <String, List<OrderModel>>{
      for (final order in _orders) _statusKey(order): [],
    };
    for (final order in _orders) {
      byKey[_statusKey(order)]!.add(order);
    }

    int count(String key) => switch (key) {
          'delivered' => _counts.delivered,
          'in_transit' => _counts.inTransit,
          'pending' => _counts.pending,
          _ => (_counts.total - _counts.pending - _counts.inTransit - _counts.delivered)
              .clamp(0, 1 << 31),
        };

    final spec = [
      ('pending', 'در انتظار', _blue),
      ('in_transit', 'در حال ارسال', _amber),
      ('delivered', 'تحویل شده', _green),
      ('other', 'در جریان', _blue),
    ];

    return [
      for (final (key, label, color) in spec)
        if ((byKey[key] ?? const []).isNotEmpty)
          _OrderGroup(
            key: key,
            label: label,
            color: color,
            count: count(key),
            orders: byKey[key]!,
          ),
    ];
  }

  Widget _sectionHeader(_OrderGroup group) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: group.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              group.key == 'pending'
                  ? Icons.schedule_rounded
                  : group.key == 'in_transit'
                      ? Icons.local_shipping_rounded
                      : group.key == 'delivered'
                          ? Icons.verified_rounded
                          : Icons.more_horiz_rounded,
              color: group.color,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            group.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: group.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formatNumber(group.count),
              style: TextStyle(
                color: group.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          Container(height: 1, width: 44, color: _border),
        ],
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final converted = _convertedIds.contains(order.id);
    final statusColor = _statusColor(order);
    final draft = convertOrderToInvoice(
      order,
      seller: _repo.loadSellerProfile(),
    );
    final buyerName = draft.buyer.name.trim().isNotEmpty
        ? draft.buyer.name.trim()
        : 'بدون نام خریدار';
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openInvoice(order),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _statusIcon(order),
                      color: statusColor,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.receiverName?.trim().isNotEmpty == true
                              ? order.receiverName!.trim()
                              : 'بدون نام خریدار',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          [
                            if ((order.city?.trim() ?? '').isNotEmpty)
                              order.city!.trim(),
                            _jDate(order.createdAt ?? ''),
                            '${formatNumber(order.items.length)} قلم',
                          ].join(' — '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textDim,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatNumber(orderTotal(order))} تومان',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(order),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          converted
                              ? Icons.check_circle_rounded
                              : Icons.receipt_long_rounded,
                          color: converted ? _green : _amber,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          converted ? 'فاکتور ثبت شده — ویرایش آماده است' : 'فاکتور آماده — قابل ویرایش',
                          style: TextStyle(
                            color: converted ? _green : _amber,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _infoItem(
                          label: 'خریدار',
                          value: buyerName,
                          flex: 2,
                        ),
                        _infoItem(
                          label: 'قلم‌ها',
                          value: formatNumber(draft.items.length),
                        ),
                        _infoItem(
                          label: 'جمع',
                          value: '${formatNumber(draft.grandTotal)} تومان',
                          flex: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _openInvoice(order),
                        icon: Icon(
                          converted
                              ? Icons.edit_rounded
                              : Icons.add_chart_rounded,
                          size: 17,
                        ),
                        label: Text(
                          converted ? 'ویرایش فاکتور' : 'ادیت و ساخت فاکتور',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem({
    required String label,
    required String value,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: _textDim, fontSize: 10.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, size: 52, color: Color(0x33FFFFFF)),
          const SizedBox(height: 14),
          Text(
            'سفارشی برای فاکتور وجود ندارد',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 52, color: Color(0x33FFFFFF)),
          const SizedBox(height: 14),
          Text(
            _error ?? 'خطا در دریافت سفارش‌ها',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.black,
            ),
            onPressed: _load,
            child: const Text(
              'تلاش دوباره',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderGroup {
  const _OrderGroup({
    required this.key,
    required this.label,
    required this.color,
    required this.count,
    required this.orders,
  });

  final String key;
  final String label;
  final Color color;
  final int count;
  final List<OrderModel> orders;
}