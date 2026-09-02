import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/driver_provider.dart';
import '../../../core/network/api_error.dart';

const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _border = Color(0xFF2A2D33);

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(myDeliveriesProvider(null));

    return deliveriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _green)),
      error: (err, _) => _buildError(friendlyError(err)),
      data: (deliveries) {
        if (deliveries.isEmpty) return _buildEmpty();

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myDeliveriesProvider(null)),
          color: _green,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deliveries.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return _buildHeader(deliveries.length);
              final d = deliveries[i - 1] as Map<String, dynamic>;
              return _buildHistoryCard(d);
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green.withOpacity(0.15)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: _green, size: 18),
        const SizedBox(width: 8),
        Text('$total تحویل انجام شده',
            style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 13)),
        const Spacer(),
        Text('امروز',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ]),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> delivery) {
    final id = delivery['id'] ?? '';
    final orderNumber = delivery['orderNumber'];
    final carrier = delivery['carrier'] ?? (delivery['order']?['carrier'] ?? 'نامشخص');
    final updatedAt = delivery['updatedAt'] ?? delivery['deliveredAt'] ?? '';
    final items = (delivery['order']?['items'] ?? delivery['items'] ?? []) as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Check icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded, color: _green, size: 20),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(orderNumber != null && orderNumber.toString().isNotEmpty
                    ? 'سفارش شماره $orderNumber'
                    : 'سفارش #${id.toString().substring(0, 8).toUpperCase()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                if (updatedAt.toString().isNotEmpty)
                  Text(_formatDate(updatedAt.toString()),
                      style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ]),
              if (carrier.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(carrier.toString(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
            ]),
          ),
        ]),
        // Items summary
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 5, runSpacing: 5,
            children: items.take(4).map((item) {
              final name = item['product']?['name'] ?? item['productName'] ?? '';
              final qty = item['quantity'] ?? 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$name × $qty',
                    style: const TextStyle(color: Colors.white54, fontSize: 10)),
              );
            }).toList(),
          ),
        ],
      ]),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}  ${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.history_rounded, size: 64, color: Colors.white12),
        SizedBox(height: 16),
        Text('هنوز تحویلی ثبت نشده',
            style: TextStyle(color: Colors.white38, fontSize: 15)),
        SizedBox(height: 6),
        Text('تحویل‌های شما اینجا نمایش داده می‌شود',
            style: TextStyle(color: Colors.white24, fontSize: 12)),
      ]),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withOpacity(0.4)),
        const SizedBox(height: 12),
        Text('خطا: $msg', style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
      ]),
    );
  }
}