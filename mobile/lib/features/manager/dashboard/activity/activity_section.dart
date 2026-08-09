import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'activity_model.dart';
import 'activity_tile.dart';
import '../../providers/activity_provider.dart';
import '../../models/recent_activity_model.dart';

const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _blue = Color(0xFF60A5FA);
const _red = Color(0xFFF87171);

class ActivitySection extends ConsumerStatefulWidget {
  const ActivitySection({super.key});

  @override
  ConsumerState<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends ConsumerState<ActivitySection> {
  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('فعالیت‌های اخیر', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          GestureDetector(
            onTap: () {
              ref.invalidate(recentActivitiesProvider);
              final items = activitiesAsync.asData == null
                  ? <ActivityItem>[]
                  : _buildItems(activitiesAsync.asData!.value);
              Navigator.push(context, MaterialPageRoute(builder: (_) => AllActivitiesScreen(activities: items)));
            },
            child: Row(children: [
              Text('همه', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _green),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        if (activitiesAsync.isLoading || activitiesAsync.asData == null)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _green)))
        else if (activitiesAsync.hasError ||
            (_buildItems(activitiesAsync.asData!.value).isEmpty))
          Center(child: Text('فعالیتی ثبت نشده', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)))
        else
          ...(_buildItems(activitiesAsync.asData!.value).take(5).map((item) => ActivityTile(item: item))),
      ]),
    );
  }

  List<ActivityItem> _buildItems(RecentActivityData data) {
    final items = <ActivityItem>[];

    for (final t in data.transactions) {
      final type = t.type;
      final color = _transactionColor(type);
      items.add(ActivityItem(
        id: t.createdAt ?? '',
        title: '${_transactionLabel(type)} ${t.title ?? ''}',
        subtitle: '${t.warehouseName ?? ''} • ${t.userName ?? ''}',
        status: '${t.quantity.toInt()} عدد',
        statusColor: color,
        icon: _transactionIcon(type),
        iconBg: color,
        createdAt: t.createdAt,
      ));
    }

    for (final log in data.activityLog) {
      final type = log.type ?? '';
      final color = _logColor(type);
      final icon = _logIcon(type);
      items.add(ActivityItem(
        id: log.createdAt ?? '',
        title: _logTitle(type),
        subtitle: '${log.label ?? ''} • ${log.userName ?? ''}',
        status: _logStatus(type),
        statusColor: color,
        icon: icon,
        iconBg: color,
        createdAt: log.createdAt,
      ));
    }

    items.sort((a, b) => b.id.compareTo(a.id));
    return items;
  }

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
        return 'ثبت';
      case 'user_role_changed':
      case 'user_warehouse_changed':
      case 'product_updated':
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
        return _orange;
      case 'order_deleted':
      case 'user_deleted':
        return _red;
      case 'product_checkin':
      case 'user_warehouse_changed':
      case 'order_shipped':
        return _blue;
      case 'return_received':
        return _blue;
      case 'product_updated':
        return _orange;
      case 'user_created':
      case 'product_created':
      case 'order_created':
      case 'order_completed':
      case 'product_restored':
      case 'model_restored':
      case 'warehouse_restored':
        return _green;
      case 'product_archived':
      case 'model_archived':
      case 'warehouse_archived':
        return _orange;
      default:
        return _green;
    }
  }

  IconData _logIcon(String type) {
    switch (type) {
      case 'order_updated':
      case 'product_updated':
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
}

// ═══════════════════════════════════════════
// صفحه همه فعالیت‌ها با فیلتر
// ═══════════════════════════════════════════
class AllActivitiesScreen extends StatefulWidget {
  final List<ActivityItem> activities;
  const AllActivitiesScreen({super.key, required this.activities});

  @override
  State<AllActivitiesScreen> createState() => _AllActivitiesScreenState();
}

class _AllActivitiesScreenState extends State<AllActivitiesScreen> {
  String _filter = 'all';

  List<ActivityItem> get _filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool inDay(DateTime t, DateTime day) =>
        DateTime(t.year, t.month, t.day) == day;

    switch (_filter) {
      case 'today':
        return widget.activities
            .where((a) => inDay(DateTime.tryParse(a.id) ?? today, today))
            .toList();
      case 'yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        return widget.activities
            .where((a) => inDay(DateTime.tryParse(a.id) ?? yesterday, yesterday))
            .toList();
      case 'week':
        final weekAgo = today.subtract(const Duration(days: 7));
        return widget.activities
            .where((a) => !(DateTime.tryParse(a.id) ?? today).isBefore(weekAgo))
            .toList();
      case 'month':
        final monthAgo = today.subtract(const Duration(days: 30));
        return widget.activities
            .where((a) => !(DateTime.tryParse(a.id) ?? today).isBefore(monthAgo))
            .toList();
      default:
        return widget.activities;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D22),
        title: const Text('همه فعالیت‌ها', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        // فیلترها
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterChip(label: 'همه', selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
              const SizedBox(width: 8),
              _FilterChip(label: 'امروز', selected: _filter == 'today', onTap: () => setState(() => _filter = 'today')),
              const SizedBox(width: 8),
              _FilterChip(label: 'دیروز', selected: _filter == 'yesterday', onTap: () => setState(() => _filter = 'yesterday')),
              const SizedBox(width: 8),
              _FilterChip(label: 'هفته قبل', selected: _filter == 'week', onTap: () => setState(() => _filter = 'week')),
              const SizedBox(width: 8),
              _FilterChip(label: 'ماه قبل', selected: _filter == 'month', onTap: () => setState(() => _filter = 'month')),
            ]),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Text('فعالیتی یافت نشد', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) => ActivityTile(item: _filtered[index]),
                ),
        ),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green.withValues(alpha: 0.15) : const Color(0xFF1A1D22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _green : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(label, style: TextStyle(color: selected ? _green : Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}