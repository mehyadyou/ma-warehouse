import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../shared/utils/numbers.dart';
import 'activity_model.dart';
import 'activity_tile.dart';
import '../../providers/activity_provider.dart';
import '../../models/recent_activity_model.dart';

const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _blue = Color(0xFF60A5FA);
const _red = Color(0xFFF87171);
const _amber = Color(0xFFFBBF24);

/// تبدیل فید فعالیت‌ها به آیتم‌های نمایشی — مشترک بین سکشن داشبورد و صفحهٔ «همه»
List<ActivityItem> buildActivityItems(RecentActivityData data) {
  final items = <ActivityItem>[];

  for (final a in data.activities) {
    final createdAt = a.createdAt;
    if (a.activityType == 'transaction') {
      final type = a.type;
      final color = _transactionColor(type);
      items.add(
        ActivityItem(
          id: createdAt ?? '',
          title: '${_transactionLabel(type)} ${a.title ?? ''}',
          subtitle: '${a.warehouseName ?? ''} • ${a.userName ?? ''}',
          status: '${formatNumber(a.quantity.toInt())} ${a.unit ?? 'عدد'}',
          statusColor: color,
          icon: _transactionIcon(type),
          iconBg: color,
          createdAt: createdAt,
        ),
      );
    } else {
      final type = a.type ?? '';
      final color = _logColor(type);
      items.add(
        ActivityItem(
          id: createdAt ?? '',
          title: _logTitle(type),
          subtitle: '${a.label ?? ''} • ${a.userName ?? ''}',
          status: _logStatus(type),
          statusColor: color,
          icon: _logIcon(type),
          iconBg: color,
          createdAt: createdAt,
        ),
      );
    }
  }

  items.sort((a, b) => b.id.compareTo(a.id));
  return items;
}

class ActivitySection extends ConsumerStatefulWidget {
  const ActivitySection({super.key});

  @override
  ConsumerState<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends ConsumerState<ActivitySection> {
  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final items = activitiesAsync.asData == null
        ? <ActivityItem>[]
        : buildActivityItems(activitiesAsync.asData!.value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فعالیت‌های اخیر',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.invalidate(recentActivitiesProvider);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllActivitiesScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'همه',
                      style: TextStyle(
                        color: _green,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: _green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (activitiesAsync.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: _green),
              ),
            )
          else if (activitiesAsync.hasError)
            _ActivityErrorBox(
              message: friendlyError(activitiesAsync.error!),
              onRetry: () => ref.invalidate(recentActivitiesProvider),
            )
          else if (items.isEmpty)
            Center(
              child: Text(
                'فعالیتی ثبت نشده',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            )
          else
            ...(items.take(5).map((item) => ActivityTile(item: item))),
        ],
      ),
    );
  }
}

/// باکس خطای کوچک سکشن با دکمهٔ تلاش مجدد
class _ActivityErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ActivityErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: _red, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _textGrey, fontSize: 12.5),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'تلاش مجدد',
              style: TextStyle(color: _green, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

const _textGrey = Color(0xFF94A3B8);

String _logTitle(String type) {
  switch (type) {
    case 'order_updated':
      return 'ویرایش سفارش';
    case 'order_deleted':
      return 'حذف سفارش';
    case 'order_shipped':
      return 'خروج سفارش از انبار';
    case 'order_completed':
      return 'تکمیل سفارش';
    case 'product_created':
      return 'ثبت محصول';
    case 'product_updated':
      return 'افزودن مدل به محصول';
    case 'product_checkin':
      return 'ورود کالا به انبار';
    case 'return_received':
      return 'ورود مرجوعی';
    case 'user_created':
      return 'ساخت کاربر';
    case 'user_role_changed':
      return 'تغییر نقش کاربر';
    case 'user_warehouse_changed':
      return 'تغییر انبار کاربر';
    case 'user_deleted':
      return 'حذف کاربر';
    case 'product_archived':
      return 'بایگانی محصول';
    case 'product_restored':
      return 'بازگردانی محصول';
    case 'model_archived':
      return 'بایگانی مدل';
    case 'model_restored':
      return 'بازگردانی مدل';
    case 'warehouse_archived':
      return 'بایگانی انبار';
    case 'warehouse_restored':
      return 'بازگردانی انبار';
    case 'warehouse_created':
      return 'ساخت انبار';
    case 'warehouse_updated':
      return 'ویرایش انبار';
    case 'warehouse_keeper_changed':
      return 'تغییر انباردار';
    default:
      return 'ثبت سفارش';
  }
}

String _logStatus(String type) {
  switch (type) {
    case 'order_updated':
      return 'ویرایش';
    case 'order_deleted':
      return 'حذف';
    case 'order_shipped':
      return 'خروج';
    case 'order_completed':
      return 'تکمیل';
    case 'user_created':
    case 'product_created':
    case 'order_created':
    case 'product_checkin':
    case 'return_received':
    case 'warehouse_created':
      return 'ثبت';
    case 'user_role_changed':
    case 'user_warehouse_changed':
    case 'product_updated':
    case 'warehouse_updated':
    case 'warehouse_keeper_changed':
      return 'تغییر';
    case 'user_deleted':
      return 'حذف';
    case 'product_archived':
    case 'model_archived':
    case 'warehouse_archived':
      return 'بایگانی';
    case 'product_restored':
    case 'model_restored':
    case 'warehouse_restored':
      return 'بازگردانی';
    default:
      return 'ثبت';
  }
}

Color _logColor(String type) {
  switch (type) {
    case 'order_updated':
    case 'user_role_changed':
    case 'product_updated':
    case 'product_archived':
    case 'model_archived':
    case 'warehouse_archived':
    case 'warehouse_updated':
      return _orange;
    case 'order_deleted':
    case 'user_deleted':
      return _red;
    case 'product_checkin':
    case 'user_warehouse_changed':
    case 'order_shipped':
    case 'return_received':
    case 'warehouse_keeper_changed':
      return _blue;
    case 'user_created':
    case 'product_created':
    case 'order_created':
    case 'order_completed':
    case 'product_restored':
    case 'model_restored':
    case 'warehouse_restored':
    case 'warehouse_created':
      return _green;
    default:
      return _green;
  }
}

IconData _logIcon(String type) {
  switch (type) {
    case 'order_updated':
    case 'product_updated':
    case 'warehouse_updated':
      return Icons.edit_rounded;
    case 'order_deleted':
    case 'user_deleted':
      return Icons.delete_rounded;
    case 'order_shipped':
      return Icons.local_shipping_rounded;
    case 'order_completed':
      return Icons.check_circle_rounded;
    case 'product_created':
      return Icons.add_box_rounded;
    case 'product_archived':
      return Icons.archive_rounded;
    case 'product_restored':
    case 'model_restored':
    case 'warehouse_restored':
      return Icons.unarchive_rounded;
    case 'model_archived':
    case 'warehouse_archived':
      return Icons.archive_rounded;
    case 'product_checkin':
      return Icons.download_rounded;
    case 'return_received':
      return Icons.assignment_return_rounded;
    case 'user_created':
      return Icons.person_add_rounded;
    case 'user_role_changed':
      return Icons.manage_accounts_rounded;
    case 'user_warehouse_changed':
      return Icons.swap_horiz_rounded;
    case 'warehouse_created':
      return Icons.add_business_rounded;
    case 'warehouse_keeper_changed':
      return Icons.manage_accounts_rounded;
    default:
      return Icons.receipt_long_rounded;
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
      return _amber;
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

// ═══════════════════════════════════════════
// صفحه همه فعالیت‌ها با فیلتر — دادهٔ تازه از پرووایدر
// ═══════════════════════════════════════════
class AllActivitiesScreen extends ConsumerStatefulWidget {
  const AllActivitiesScreen({super.key});

  @override
  ConsumerState<AllActivitiesScreen> createState() =>
      _AllActivitiesScreenState();
}

class _AllActivitiesScreenState extends ConsumerState<AllActivitiesScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    ref.invalidate(recentActivitiesProvider);
  }

  List<ActivityItem> _applyFilter(List<ActivityItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // زمان محلی — ISO دریافتی از سرور UTC است
    DateTime? parseLocal(String? s) =>
        s == null ? null : DateTime.tryParse(s)?.toLocal();

    bool inDay(DateTime? t, DateTime day) =>
        t != null && DateTime(t.year, t.month, t.day) == day;

    switch (_filter) {
      case 'today':
        return items.where((a) => inDay(parseLocal(a.id), today)).toList();
      case 'yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        return items.where((a) => inDay(parseLocal(a.id), yesterday)).toList();
      case 'week':
        final weekAgo = today.subtract(const Duration(days: 7));
        return items
            .where((a) => !(parseLocal(a.id) ?? today).isBefore(weekAgo))
            .toList();
      case 'month':
        final monthAgo = today.subtract(const Duration(days: 30));
        return items
            .where((a) => !(parseLocal(a.id) ?? today).isBefore(monthAgo))
            .toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final allItems = activitiesAsync.asData == null
        ? <ActivityItem>[]
        : buildActivityItems(activitiesAsync.asData!.value);
    final filtered = _applyFilter(allItems);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D22),
        title: const Text(
          'همه فعالیت‌ها',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // فیلترها
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'همه',
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'امروز',
                    selected: _filter == 'today',
                    onTap: () => setState(() => _filter = 'today'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'دیروز',
                    selected: _filter == 'yesterday',
                    onTap: () => setState(() => _filter = 'yesterday'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'هفته قبل',
                    selected: _filter == 'week',
                    onTap: () => setState(() => _filter = 'week'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'ماه قبل',
                    selected: _filter == 'month',
                    onTap: () => setState(() => _filter = 'month'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildBody(filtered, activitiesAsync)),
        ],
      ),
    );
  }

  Widget _buildBody(
    List<ActivityItem> filtered,
    AsyncValue<RecentActivityData> activitiesAsync,
  ) {
    if (activitiesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (activitiesAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: _textGrey, size: 44),
              const SizedBox(height: 12),
              Text(
                friendlyError(activitiesAsync.error!),
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey, fontSize: 13.5),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(recentActivitiesProvider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: _green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _filter == 'all'
              ? 'فعالیتی ثبت نشده'
              : 'در این بازه فعالیتی یافت نشد',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        ),
      );
    }
    return RefreshIndicator(
      color: _green,
      backgroundColor: const Color(0xFF1A1D22),
      onRefresh: () async => ref.invalidate(recentActivitiesProvider),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: filtered.length,
        itemBuilder: (context, index) => ActivityTile(item: filtered[index]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _green.withValues(alpha: 0.15)
              : const Color(0xFF1A1D22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _green : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _green : Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
