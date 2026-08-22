import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/features/manager/providers/warehouses_provider.dart';
import 'package:ma_app/shared/utils/numbers.dart';
import 'package:ma_app/shared/widgets/inventory_donut_card.dart';
import 'product_inventory_screen.dart';

const _green = Color(0xFF4ADE80);
const _blue = Color(0xFF60A5FA);
const _orange = Color(0xFFFB923C);

const _colors = <Color>[
  Color(0xFF4ADE80),
  Color(0xFFFB923C),
  Color(0xFF60A5FA),
  Color(0xFFF472B6),
  Color(0xFFA78BFA),
  Color(0xFFFBBF24),
];

/// کارت نمودار دایره‌ای موجودی پنل مدیر — ویجت مشترک با دادهٔ خلاصهٔ کل سیستم
class InventoryChartCard extends ConsumerWidget {
  const InventoryChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(managerInventorySummaryProvider);
    final loading = summaryAsync.isLoading && summaryAsync.value == null;
    final error = summaryAsync.hasError ? 'خطا در بارگذاری' : null;

    final items = <InventoryItem>[];
    final stats = <InventoryStat>[];
    final summary = summaryAsync.value;
    if (summary != null) {
      final data = summary.inventory;
      for (final e in data.asMap().entries) {
        items.add(
          InventoryItem(
            name: e.value.name ?? '',
            count: e.value.totalCount.toInt(),
            unit: (e.value.unit ?? '').trim().isNotEmpty
                ? e.value.unit!
                : 'عدد',
            color: _colors[e.key % _colors.length],
          ),
        );
      }
      final totalRegistered = summary.totalRegisteredProducts.toInt();
      stats.addAll([
        InventoryStat(
          label: 'محصول ثبت شده',
          value: faDigits('$totalRegistered'),
          color: _green,
        ),
        InventoryStat(
          label: 'موجودی فعلی',
          value: formatNumber(summary.totalInventoryUnits.toInt()),
          color: _blue,
        ),
        InventoryStat(
          label: 'مرجوعی‌ها',
          value: formatNumber(summary.returnedUnits.toInt()),
          color: _orange,
        ),
      ]);
    }

    return InventoryDonutCard(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      loading: loading,
      error: error,
      onRetry: () => ref.invalidate(managerInventorySummaryProvider),
      items: cappedDonutItems(items),
      stats: stats,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductInventoryScreen()),
      ),
    );
  }
}
