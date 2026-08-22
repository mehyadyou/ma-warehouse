import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/shared/widgets/dashboard_header.dart';
import '../../providers/warehouse_keeper_provider.dart';

/// هدر انباردار — کروم (منو/زنگ/آواتار) همیشه ثابت است؛ تنها متنِ عنوان
/// با وضعیت بارگذاری انبار تغییر می‌کند (لود → «در حال بارگذاری…»،
/// خطا → پیام دوستانه که با لمس دوباره تلاش می‌کند).
class WarehouseHeader extends ConsumerWidget {
  final String? avatarUrl;
  const WarehouseHeader({super.key, this.avatarUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseAsync = ref.watch(warehouseProvider);

    final (title, subtitle, onRetry) = warehouseAsync.when(
      loading: () => ('انبار', 'در حال بارگذاری…', null),
      error: (_, _) => (
            'انبار',
            'خطا در دریافت انبار — لمس برای تلاش مجدد',
            () => ref.invalidate(warehouseProvider)
          ),
      data: (warehouse) => (
            warehouse.name.isEmpty ? 'انبار' : warehouse.name,
            'انباردار: ${warehouse.keeperName.isEmpty ? '---' : warehouse.keeperName}',
            null,
          ),
    );

    return DashboardHeader(
      title: title,
      subtitle: subtitle,
      showDate: true,
      avatarUrl: avatarUrl,
      onTextTap: onRetry,
    );
  }
}