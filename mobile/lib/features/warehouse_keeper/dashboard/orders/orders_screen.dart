import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_order_model.dart';
import 'package:ma_app/features/warehouse_keeper/dashboard/home/activity_section.dart'
    show orderStatusStyle;
import 'package:ma_app/features/warehouse_keeper/scan_out/scan_out_screen.dart';
import 'package:ma_app/shared/utils/numbers.dart';
import 'package:shamsi_date/shamsi_date.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);

class OrdersScreen extends ConsumerWidget {
  OrdersScreen({super.key}); // ← const برداشتیم

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(ordersProvider)
        .when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: _green)),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  'خطا در دریافت سفارشها — اتصال اینترنت را بررسی کنید',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(ordersProvider),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: _green,
                    size: 18,
                  ),
                  label: const Text(
                    'تلاش دوباره',
                    style: TextStyle(color: _green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (orders) {
            Future<void> refreshOrders() async {
              ref.invalidate(ordersProvider);
              await ref.read(ordersProvider.future).then((_) {}, onError: (_) {});
            }

            if (orders.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => RefreshIndicator(
                  color: _green,
                  backgroundColor: _surface,
                  onRefresh: refreshOrders,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Text(
                          'سفارشی ثبت نشده',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.4)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              color: _green,
              backgroundColor: _surface,
              onRefresh: refreshOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                final o = orders[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: o),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: _orange,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.orderNumber > 0
                                    ? 'سفارش شماره ${faDigits('${o.orderNumber}')}'
                                    : 'سفارش #${o.id.substring(0, 8)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${o.createdByName} • ${_formatDate(o.createdAt)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(status: o.status),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
                },
              ),
            );
          },
        );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date).toLocal();
      final jalali = Jalali.fromDateTime(d);
      return faDigits(
        '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}',
      );
    } catch (_) {
      return faDigits(date);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final style = orderStatusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label,
        style: TextStyle(color: style.color, fontSize: 12),
      ),
    );
  }
}

class OrderDetailScreen extends ConsumerStatefulWidget {
  final KeeperOrderModel order;
  const OrderDetailScreen({super.key, required this.order});
  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late final KeeperOrderModel order = widget.order;

  List<Map<String, dynamic>> _cartons = [];
  bool _loadingCartons = true;
  String? _cartonsError;

  int get _totalUnits => order.items.fold(
        0,
        (sum, i) => sum + (i.quantity > 0 ? i.quantity : 1),
      );

  /// اسکن خروج فقط وقتی هنوز کارتنی برای این سفارش باقی مانده است:
  /// - PENDING: هنوز خروجی شروع نشده
  /// - SHIPPED: اولین کارتن خروج داده شده ولی بقیه باقی مانده‌اند
  /// وقتی همهٔ کارتن‌ها خروج داده شده‌اند (سفارش ارسال شده) دکمه بی‌معنی است و حذف می‌شود
  bool get _scannable =>
      !_loadingCartons &&
      (order.status == 'PENDING' || order.status == 'SHIPPED') &&
      _cartons.length < _totalUnits;

  @override
  void initState() {
    super.initState();
    _loadCartons();
  }

  Future<void> _loadCartons() async {
    setState(() {
      _loadingCartons = true;
      _cartonsError = null;
    });
    try {
      final cartons = await ref.read(wkApiProvider).getOrderCartons(order.id);
      if (!mounted) return;
      setState(() {
        _cartons = cartons;
        _loadingCartons = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCartons = false;
        _cartonsError = 'خطا در دریافت کارتن‌های خروج‌یافته';
      });
    }
  }

  Future<void> _openScan() async {
    final receiver = order.receiverName.isNotEmpty ? ' — ${order.receiverName}' : '';
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanOutScreen(
          orderId: order.id,
          orderLabel:
              '${order.orderNumber > 0 ? 'سفارش شماره ${faDigits('${order.orderNumber}')}' : 'سفارش #${order.id.substring(0, 8)}'}$receiver',
        ),
      ),
    );
    _loadCartons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: Text(
          order.orderNumber > 0
              ? 'سفارش شماره ${faDigits('${order.orderNumber}')}'
              : 'سفارش #${order.id.substring(0, 8)}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _StatusBadge(status: order.status),
                  const SizedBox(width: 12),
                  Text(
                    order.warehouseName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (order.shippingMethod.isNotEmpty) ...[
              const Text(
                'اطلاعات ارسال',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (order.senderName.isNotEmpty)
                _infoRow('فرستنده', order.senderName),
              if (order.receiverName.isNotEmpty)
                _infoRow('گیرنده', order.receiverName),
              _infoRow('نحوه ارسال', order.shippingMethod),
              if (order.carrier.isNotEmpty) _infoRow('باربری', order.carrier),
              if (order.city.isNotEmpty) _infoRow('شهر', order.city),
              if (order.postalCode.isNotEmpty)
                _infoRow('کد پستی', order.postalCode),
              if (order.address.isNotEmpty) _infoRow('آدرس', order.address),
              if (order.customerPhone.isNotEmpty)
                _infoRow('شماره تماس', order.customerPhone),
              const SizedBox(height: 24),
            ],
            const Text(
              'اقلام سفارش',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map(_itemCard),

            // ─── پیشرفت خروج: کارتن‌های اسکن‌شده برای این سفارش ───
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'کارتن‌های خروج‌یافته',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${faDigits(_cartons.length.toString())} از ${faDigits(_totalUnits.toString())}',
                  style: TextStyle(
                    color: _cartons.length >= _totalUnits ? _green : _orange,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loadingCartons)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: _green,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_cartonsError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _cartonsError!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadCartons,
                      child: const Text(
                        'تلاش مجدد',
                        style: TextStyle(color: _green, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else if (_cartons.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'هنوز کارتنی برای این سفارش خروج داده نشده است',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              )
            else
              ..._cartons.map(_cartonCard),

            if (_scannable) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openScan,
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  label: const Text(
                    'اسکن خروج برای این سفارش',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ] else if (!_loadingCartons &&
                order.status == 'SHIPPED' &&
                _cartons.length >= _totalUnits) ...[
              // سفارش ارسال شده — همهٔ کارتن‌ها خروج داده شده‌اند؛ دکمهٔ اسکن دیگر معنی ندارد
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _green.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: _green, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'تمام کارتن‌های این سفارش خروج داده شده و سفارش ارسال شده است',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cartonCard(Map<String, dynamic> c) {
    final product = (c['product'] as Map?) ?? const {};
    final model = (c['model'] as Map?) ?? const {};
    final scannedAt = c['scannedOutAt'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: _green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product['name'] ?? ''}${(model['name'] as String? ?? '').isNotEmpty ? ' (${model['name']})' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (c['serialNumber'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'سریال: ${c['serialNumber']}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (scannedAt != null)
            Text(
              _formatTime(scannedAt),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final t = DateTime.parse(iso).toLocal();
      final j = Jalali.fromDateTime(t);
      return faDigits(
        '${j.month}/${j.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
      );
    } catch (_) {
      return '';
    }
  }

  Widget _itemCard(KeeperOrderItemModel item) {
    final price = item.price;
    final rate = item.exchangeRate;
    final dollars = price != null && rate != null && rate > 0
        ? (price / rate).round()
        : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.productName} ${item.model.isNotEmpty ? '(${item.model})' : ''}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.quantity} عدد',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          if (price != null) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$price تومان',
                  style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (dollars != null)
                  Text(
                    '≈ $dollars دلار',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
