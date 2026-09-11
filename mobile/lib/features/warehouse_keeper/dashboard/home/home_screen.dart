import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'activity_section.dart';
import 'inventory_chart_card.dart';
import 'unreviewed_orders_card.dart';
import '../../../offline/pending_ops_card.dart';

const _green = Color(0xFF4ADE80);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onOpenOrders});

  /// لمس کارت «سفارش‌های بررسی‌نشده» → رفتن به فهرست سفارش‌ها (تب سفارش)
  final VoidCallback? onOpenOrders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    Future<void> refreshDashboard() async {
      ref.invalidate(inventorySummaryProvider);
      ref.invalidate(keeperInventoryListProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(ordersProvider);
      // صبر برای یک دور رفت‌وبرگشت تا نشانگر بیهوده محو نشود
      var failed = false;
      await ref.read(ordersProvider.future).then((_) {}, onError: (_) {
        failed = true;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failed
                  ? 'خطا در به‌روزرسانی — اینترنت را بررسی کنید'
                  : 'به‌روزرسانی شد',
            ),
            backgroundColor: failed ? Colors.redAccent : Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }

    return RefreshIndicator(
      color: _green,
      backgroundColor: const Color(0xFF1A1D22),
      onRefresh: refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}
