import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_order_model.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_transaction_model.dart';
import 'stat_card.dart';

const _card = Color(0xFF1E2128);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _blue = Color(0xFF60A5FA);

class ActivitySection extends StatelessWidget {
  final AsyncValue<List<KeeperOrderModel>> ordersAsync;
  final AsyncValue<List<KeeperTransactionModel>> transactionsAsync;

  const ActivitySection({
    super.key,
    required this.ordersAsync,
    required this.transactionsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = ordersAsync.isLoading || transactionsAsync.isLoading;
    final hasError = ordersAsync.hasError && transactionsAsync.hasError;

    if (isLoading) {
      return const LoadingCard(height: 220);
    }

    if (hasError) {
      return const MessageCard(message: 'بارگذاری فعالیت‌های اخیر ناموفق بود');
    }

    final activities = [
      ..._buildOrderActivities(ordersAsync.asData?.value ?? const []),
      ..._buildTransactionActivities(transactionsAsync.asData?.value ?? const []),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'فعالیت‌های اخیر',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (activities.isEmpty)
          const MessageCard(message: 'فعالیتی ثبت نشده')
        else
          ...activities.take(5).map((activity) => ActivityTile(item: activity)),
      ],
    );
  }

  List<RecentActivityItem> _buildOrderActivities(List<KeeperOrderModel> orders) {
    return orders.map((order) {
      final status = order.status;
      final statusColor = status == 'PENDING' ? _orange : _green;
      final statusLabel = status == 'PENDING'
          ? 'در انتظار'
          : status == 'SHIPPED'
              ? 'ارسال شده'
              : 'ثبت شده';
      return RecentActivityItem(
        title: 'سفارش جدید',
        subtitle: '${order.createdByName.isEmpty ? 'نامشخص' : order.createdByName} • ${_formatDate(order.createdAt)}',
        status: statusLabel,
        statusColor: statusColor,
        icon: Icons.receipt_long_rounded,
        iconBg: statusColor,
        createdAt: _parseDate(order.createdAt),
      );
    }).toList();
  }

  List<RecentActivityItem> _buildTransactionActivities(List<KeeperTransactionModel> transactions) {
    return transactions.map((tx) {
      final type = tx.type;
      final color = _transactionColor(type);
      return RecentActivityItem(
        title: '${_transactionLabel(type)} ${tx.productName}',
        subtitle: '${tx.userName.isEmpty ? 'نامشخص' : tx.userName} • ${_formatDate(tx.createdAt)}',
        status: '${tx.quantity} عدد',
        statusColor: color,
        icon: _transactionIcon(type),
        iconBg: color,
        createdAt: _parseDate(tx.createdAt),
      );
    }).toList();
  }
}

class RecentActivityItem {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color iconBg;
  final DateTime createdAt;

  const RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.iconBg,
    required this.createdAt,
  });
}

class ActivityTile extends StatelessWidget {
  final RecentActivityItem item;
  const ActivityTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.iconBg.withValues(alpha: 0.15),
            ),
            child: Icon(item.icon, color: item.iconBg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                color: item.statusColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
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

DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value.toLocal();
  final parsed = DateTime.tryParse('$value');
  if (parsed == null) return DateTime.fromMillisecondsSinceEpoch(0);
  return parsed.toLocal();
}

String _formatDate(dynamic value) {
  final date = _parseDate(value);
  if (date.millisecondsSinceEpoch == 0) return '';
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}  $hh:$mm';
}
