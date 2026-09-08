import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'activity_section.dart';
import 'inventory_chart_card.dart';
import 'unreviewed_orders_card.dart';
import '../../../offline/pending_ops_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onOpenOrders});

  /// لمس کارت «سفارش‌های بررسی‌نشده» → رفتن به فهرست سفارش‌ها (تب سفارش)
  final VoidCallback? onOpenOrders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عملیات ثبت‌شده در قطعی اینترنت — با بازگشت اتصال ارسال می‌شوند
          const PendingOpsCard(),
          UnreviewedOrdersCard(onTap: onOpenOrders),
          const InventoryChartCard(),
          const SizedBox(height: 22),
          ActivitySection(
            ordersAsync: ordersAsync,
            transactionsAsync: transactionsAsync,
          ),
        ],
      ),
    );
  }
}
