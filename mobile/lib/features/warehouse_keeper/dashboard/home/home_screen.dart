import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'activity_section.dart';
import 'inventory_chart_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
