import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/shared/utils/numbers.dart';
import 'package:ma_app/shared/widgets/inventory_donut_card.dart';
import '../../providers/warehouse_keeper_provider.dart';
import '../inventory/inventory_detail_screen.dart';

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

/// کارت نمودار دایره‌ای موجودی انباردار — ویجت مشترک با دادهٔ انبارِ خود کاربر
/// (سمت سرور فقط موجودی انبار متصل به کاربر برمی‌گردد)
class InventoryChartCard extends ConsumerWidget {
  const InventoryChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(inventorySummaryProvider);
    final loading = summaryAsync.isLoading && summaryAsync.value == null;
    final error = summaryAsync.hasError ? 'خطا در بارگذاری' : null;

    final items = <InventoryItem>[];
    final stats = <InventoryStat>[];
    final summary = summaryAsync.value;
    if (summary != null) {
      final data = summary.products;
      for (final e in data.asMap().entries) {
        final unit = (e.value.unit ?? '').trim();
        items.add(
          InventoryItem(
            name: e.value.name,
            count: e.value.totalCount.toInt(),
            unit: unit.isNotEmpty ? unit : 'عدد',
            color: _colors[e.key % _colors.length],
          ),
        );
      }
      stats.addAll([
        InventoryStat(
          label: 'محصول ثبت شده',
          value: faDigits(summary.totalProducts.toInt().toString()),
          color: _green,
        ),
        InventoryStat(
          label: 'موجودی فعلی',
          value: formatNumber(summary.totalUnits.toInt()),
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
      padding: const EdgeInsets.only(bottom: 16),
      loading: loading,
      error: error,
      onRetry: () => ref.invalidate(inventorySummaryProvider),
      items: cappedDonutItems(items),
      stats: stats,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InventoryDetailScreen()),
      ),
    );
  }
}
