import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:ma_app/core/network/api_constants.dart';
import 'package:ma_app/shared/widgets/notification_bell.dart';
import '../../providers/warehouse_keeper_provider.dart';

const _green = Color(0xFF4ADE80);

class WarehouseHeader extends ConsumerWidget {
  final String? avatarUrl;
  const WarehouseHeader({super.key, this.avatarUrl});

  String _todayShamsi() {
    final now = DateTime.now();
    final jalali = Jalali.fromDateTime(now);
    return 'امروز ${jalali.year}/${jalali.month}/${jalali.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseAsync = ref.watch(warehouseProvider);

    return warehouseAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: CircularProgressIndicator(color: _green),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Text('خطا', style: TextStyle(color: Colors.red)),
      ),
      data: (warehouse) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Row(children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFF22262D), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.menu_rounded, color: Colors.white.withValues(alpha: 0.7), size: 22),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const NotificationBell(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(warehouse.name.isEmpty ? 'انبار' : warehouse.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
              Text('انباردار: ${warehouse.keeperName.isEmpty ? '---' : warehouse.keeperName}', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12.5)),
              Text(_todayShamsi(), style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22262D),
              border: Border.all(color: _green.withValues(alpha: 0.5), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? Image.network(
                    ApiConstants.fullUrl(avatarUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person_rounded, color: _green),
                  )
                : const Icon(Icons.person_rounded, color: _green),
          ),
        ]),
      ),
    );
  }
}
