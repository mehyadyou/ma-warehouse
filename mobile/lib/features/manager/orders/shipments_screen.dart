import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../data/manager_api_service.dart';
import '../providers/manager_api_provider.dart';
import '../models/order_model.dart';
import 'edit_order_screen.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _blue = Color(0xFF60A5FA);
const _red = Color(0xFFF87171);
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

String _date(String iso) {
  try {
    final j = Jalali.fromDateTime(DateTime.parse(iso));
    final time = DateTime.parse(iso).toLocal();
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '${j.year}/${j.month}/${j.day} — $hh:$mm';
  } catch (_) {
    return '—';
  }
}

/// صفحهٔ «ارسال» — لیست دقیق و حرفه‌ای همهٔ سفارش‌های ثبت‌شده توسط مدیریت
class ShipmentsScreen extends ConsumerStatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  ConsumerState<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends ConsumerState<ShipmentsScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  final _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;
  List<OrderModel> _orders = [];
  String _query = '';
  String? _statusFilter; // null = همه

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await _api.getOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'خطا در دریافت ارسالی‌ها';
      });
    }
  }

  List<OrderModel> get _filtered {
    final q = _query.trim();
    return _orders.where((o) {
      // فیلتر وضعیت
      if (_statusFilter != null && _statusKey(o) != _statusFilter) return false;
      // فیلتر جستجو
      if (q.isEmpty) return true;
      final text = [
        o.senderName,
        o.receiverName,
        o.city,
        o.carrier,
        o.shippingMethod,
        ...o.items.map((i) => i.productName),
      ].whereType<String>().join(' ');
      return text.contains(q);
    }).toList();
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
          'ارسالی‌ها',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_filtered.length} سفارش',
                style: const TextStyle(
                  color: _green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStats(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'جستجو: فرستنده، گیرنده، شهر، کالا…',
                hintStyle: const TextStyle(color: _textDim, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: _textDim, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, color: _textDim, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _green, width: 1.2),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final total = _orders.length;
    final pending = _orders.where((o) => _statusKey(o) == 'pending').length;
    final transit = _orders.where((o) => _statusKey(o) == 'in_transit').length;
    final delivered = _orders.where((o) => _statusKey(o) == 'delivered').length;

    Widget card({
      required String label,
      required int value,
      required Color color,
      required String? key,
    }) {
      final active = _statusFilter == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _statusFilter = active ? null : key),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? color.withOpacity(0.12) : _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? color : _border,
                width: active ? 1.6 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? color : _textDim,
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          card(label: 'کل سفارش‌ها', value: total, color: Colors.white, key: null),
          const SizedBox(width: 8),
          card(label: 'در انتظار', value: pending, color: _blue, key: 'pending'),
          const SizedBox(width: 8),
          card(label: 'در حال ارسال', value: transit, color: _amber, key: 'in_transit'),
          const SizedBox(width: 8),
          card(label: 'تحویل شده', value: delivered, color: _green, key: 'delivered'),
        ],
      ),
    );
  }

  Future<void> _editOrder(OrderModel order) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditOrderScreen(orderId: order.id, order: order),
      ),
    );
    if (changed == true) _load();
  }

  Future<void> _deleteOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'حذف سفارش',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'سفارش «${order.senderName ?? '—'} → ${order.receiverName ?? '—'}» حذف شود؟\nبرای انباردار مربوطه هم بلافاصله حذف میشود.',
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deleteOrder(order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سفارش حذف شد'), backgroundColor: Colors.green),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_apiError(e)}'), backgroundColor: Colors.red),
      );
    }
  }

  String _apiError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
    }
    return 'خطا در عملیات';
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _green, strokeWidth: 2.5),
      );
    }
    if (_error != null) {
      return _buildMessage(_error!, isError: true);
    }
    final orders = _filtered;
    if (orders.isEmpty) {
      if (_statusFilter != null) {
        return _buildMessage('سفارشی در این وضعیت یافت نشد', clearFilter: true);
      }
      return _buildMessage(_query.isEmpty ? 'هنوز سفارشی ثبت نشده است' : 'نتیجه‌ای یافت نشد');
    }
    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            onEdit: () => _editOrder(order),
            onDelete: () => _deleteOrder(order),
          );
        },
      ),
    );
  }

  Widget _buildMessage(String message, {bool isError = false, bool clearFilter = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.cloud_off_rounded : Icons.local_shipping_rounded,
            color: isError ? _red : _textDim,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: _textDim, fontSize: 13)),
          if (clearFilter) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => setState(() => _statusFilter = null),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('نمایش همه'),
            ),
          ],
          if (isError) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: const BorderSide(color: _green, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('تلاش مجدد'),
            ),
          ],
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// کارت سفارش — نمایش دقیق همهٔ جزئیات
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrderCard({
    required this.order,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final sender = order.senderName ?? 'فرستنده نامشخص';
    final receiver = order.receiverName ?? 'گیرنده نامشخص';
    final items = order.items;
    final delivered = order.deliveryStatus == 'DELIVERED';

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── سربرگ: فرستنده → گیرنده + وضعیت ───
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sender,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'به $receiver',
                        style: const TextStyle(
                          color: _textDim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(order).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _statusColor(order).withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        delivered
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: _statusColor(order),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(order),
                        style: TextStyle(
                          color: _statusColor(order),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          // ─── جزئیات ───
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.apartment_rounded,
                  text: order.warehouseName ?? '—',
                ),
                if (order.city != null)
                  _InfoRow(icon: Icons.location_on_rounded, text: order.city),
                if (order.shippingMethod != null)
                  _InfoRow(
                    icon: Icons.local_shipping_rounded,
                    text: [
                      order.shippingMethod!,
                      if (order.carrier != null) order.carrier!,
                    ].join(' — '),
                  ),
                if (order.customerPhone != null)
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    text: order.customerPhone,
                  ),
                if (order.driverName != null)
                  _InfoRow(
                    icon: Icons.verified_user_rounded,
                    text: 'راننده: ${order.driverName}',
                    accent: _blue,
                  ),
              ],
            ),
          ),
          // ─── اقلام ───
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in items)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.productName} ×${item.quantity}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // ─── پانوشت: تاریخ + بیجک ───
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                const Icon(Icons.event_rounded, color: _textDim, size: 14),
                const SizedBox(width: 4),
                Text(
                  _date(order.createdAt ?? ''),
                  style: const TextStyle(color: _textDim, fontSize: 11),
                ),
                const Spacer(),
                if ((order.badgeCount ?? 0) > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sell_rounded,
                          color: _green,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${order.badgeCount} بیجک',
                          style: const TextStyle(
                            color: _green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // ─── اکشن‌ها: ویرایش / حذف ───
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'ویرایش',
                  color: _amber,
                  onTap: onEdit,
                ),
                const SizedBox(width: 6),
                Container(
                  width: 1,
                  height: 18,
                  color: _border,
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  label: 'حذف',
                  color: _red,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Color? accent;

  const _InfoRow({required this.icon, required this.text, this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: accent ?? _textDim, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text ?? '',
              style: TextStyle(
                color: accent ?? Colors.white70,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
