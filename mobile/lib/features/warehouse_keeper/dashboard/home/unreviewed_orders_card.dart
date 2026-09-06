import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/shared/utils/numbers.dart';
import '../../providers/warehouse_keeper_provider.dart';

const _card = Color(0xFF1E2128);
const _orange = Color(0xFFFB923C);

/// کارت «سفارش‌های بررسی‌نشده» بالای صفحهٔ خانهٔ انباردار — شمار سفارش‌های
/// در انتظار (PENDING) همین انبار که هنوز کارتنی برایشان خروج نرفته.
///
/// مینیمال: فقط وقتی عدد بزرگ‌تر از صفر است نمایش داده می‌شود (در حالت
/// بارگذاری/خطا/صفر کاملاً جمع می‌شود)؛ لمس → فهرست سفارش‌ها.
class UnreviewedOrdersCard extends ConsumerWidget {
  const UnreviewedOrdersCard({super.key, this.onTap});

  /// با لمس کارت صدا زده می‌شود (در داشبورد: رفتن به تب سفارش‌ها)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider).value;
    if (orders == null) return const SizedBox.shrink();

    final pendingCount = orders.where((o) => o.status == 'PENDING').length;
    if (pendingCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _orange.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _orange.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: _orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${faDigits('$pendingCount')}  ',
                            style: const TextStyle(
                              color: _orange,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: 'سفارش بررسی‌نشده',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'برای بررسی به فهرست سفارش‌ها بروید',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
