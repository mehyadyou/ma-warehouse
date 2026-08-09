import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_order_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);

class OrdersScreen extends ConsumerWidget {
  OrdersScreen({super.key});  // ← const برداشتیم

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(ordersProvider).when(
      loading: () => const Center(child: CircularProgressIndicator(color: _green)),
      error: (e, _) => Center(child: Text('خطا: $e', style: const TextStyle(color: Colors.red))),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(child: Text('سفارشی ثبت نشده', style: TextStyle(color: Colors.white.withOpacity(0.4))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final o = orders[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: _orange.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_rounded, color: _orange, size: 22)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('سفارش #${o.id.substring(0, 8)}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${o.createdByName} • ${_formatDate(o.createdAt)}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  ])),
                  _StatusBadge(status: o.status),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try { final d = DateTime.parse(date); return '${d.year}/${d.month}/${d.day}'; } catch (_) { return date; }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'PENDING' ? _orange : status == 'SHIPPED' ? _green : Colors.blue;
    final label = status == 'PENDING' ? 'در انتظار' : status == 'SHIPPED' ? 'ارسال شده' : 'در حال پردازش';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontSize: 12)));
  }
}

class OrderDetailScreen extends StatelessWidget {
  final KeeperOrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _surface, title: Text('سفارش #${order.id.substring(0, 8)}', style: const TextStyle(color: Colors.white)), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14)), child: Row(children: [_StatusBadge(status: order.status), const SizedBox(width: 12), Text(order.warehouseName, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13))])),
        const SizedBox(height: 24),
        if (order.shippingMethod.isNotEmpty) ...[
          const Text('اطلاعات ارسال', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
          if (order.senderName.isNotEmpty) _infoRow('فرستنده', order.senderName),
          if (order.receiverName.isNotEmpty) _infoRow('گیرنده', order.receiverName),
          _infoRow('نحوه ارسال', order.shippingMethod),
          if (order.carrier.isNotEmpty) _infoRow('باربری', order.carrier),
          if (order.city.isNotEmpty) _infoRow('شهر', order.city),
          if (order.postalCode.isNotEmpty) _infoRow('کد پستی', order.postalCode),
          if (order.address.isNotEmpty) _infoRow('آدرس', order.address),
          if (order.customerPhone.isNotEmpty) _infoRow('شماره تماس', order.customerPhone),
          const SizedBox(height: 24),
        ],
        const Text('اقلام سفارش', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
        ...order.items.map(_itemCard),
      ])),
    );
  }

  Widget _itemCard(KeeperOrderItemModel item) {
    final price = item.price;
    final rate = item.exchangeRate;
    final dollars = price != null && rate != null && rate > 0 ? (price / rate).round() : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(
          child: Text(
            '${item.productName} ${item.model.isNotEmpty ? '(${item.model})' : ''}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Text('${item.quantity} عدد', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        if (price != null) ...[
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$price تومان', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
            if (dollars != null)
              Text('≈ $dollars دلار', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10)),
          ]),
        ],
      ]),
    );
  }

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13))), Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)))]));
}