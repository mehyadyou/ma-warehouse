import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../providers/activity_provider.dart';
import '../../../models/history_entry_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _blue = Color(0xFF60A5FA);
const _orange = Color(0xFFFB923C);
const _red = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

/// دسته‌بندی رویدادها
const _categoryByType = <String, String>{
  'product_created': 'products',
  'product_updated': 'products',
  'product_checkin': 'products',
  'product_archived': 'products',
  'product_restored': 'products',
  'model_archived': 'products',
  'model_restored': 'products',
  'warehouse_archived': 'warehouses',
  'warehouse_restored': 'warehouses',
  'user_created': 'users',
  'user_role_changed': 'users',
  'user_warehouse_changed': 'users',
  'user_deleted': 'users',
  'order_created': 'shipments',
  'order_updated': 'shipments',
  'order_deleted': 'shipments',
  'order_shipped': 'shipments',
  'order_completed': 'shipments',
  'return_received': 'returns',
};

const _categoryOrder = ['all', 'products', 'warehouses', 'users', 'shipments', 'returns'];
const _categoryLabel = <String, String>{
  'all': 'همه',
  'products': 'محصولات',
  'warehouses': 'انبارها',
  'users': 'کاربران',
  'shipments': 'ارسالی‌ها',
  'returns': 'مرجوعی‌ها',
};

/// صفحهٔ «تاریخچه» مدیر — تاریخچهٔ کامل و دقیق وقایع سیستم
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'تاریخچه',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: historyAsync.isLoading && historyAsync.asData == null
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _HistoryBody(
              entries: historyAsync.asData?.value ?? [],
              hasError: historyAsync.hasError,
              onRefresh: () => ref.invalidate(historyProvider),
            ),
    );
  }
}

class _HistoryBody extends ConsumerStatefulWidget {
  final List<HistoryEntryModel> entries;
  final bool hasError;
  final VoidCallback onRefresh;

  const _HistoryBody({
    required this.entries,
    required this.hasError,
    required this.onRefresh,
  });

  @override
  ConsumerState<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends ConsumerState<_HistoryBody> {
  String _category = 'all';

  List<HistoryEntryModel> get _filtered {
    final all = widget.entries;
    if (_category == 'all') return all;
    return all
        .where((e) => _categoryByType[e.type] == _category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: () async => widget.onRefresh(),
      child: Column(
        children: [
          // ─── فیلترها ───
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: _categoryOrder.map((key) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _CategoryChip(
                    label: _categoryLabel[key]!,
                    selected: _category == key,
                    onTap: () => setState(() => _category = key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // ─── لیست ───
          Expanded(
            child: widget.hasError && widget.entries.isEmpty
                ? const _CenterMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'خطا در دریافت تاریخچه',
                    subtitle: 'اتصال به سرور را بررسی کنید',
                  )
                : items.isEmpty
                    ? _CenterMessage(
                        icon: _categoryIcon(_category),
                        title: 'موردی ثبت نشده است',
                        subtitle:
                            'با انجام اولین فعالیت، تاریخچهٔ آن اینجا نمایش داده می‌شود',
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _HistoryTile(entry: items[index]),
                      ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'products':
        return Icons.inventory_2_rounded;
      case 'users':
        return Icons.group_rounded;
      case 'shipments':
        return Icons.local_shipping_rounded;
      case 'returns':
        return Icons.assignment_return_rounded;
      default:
        return Icons.history_rounded;
    }
  }
}

// ═══════════════════════════════════════════
// چیپ فیلتر
// ═══════════════════════════════════════════
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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
          color: selected ? _green.withValues(alpha: 0.12) : _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _green : _border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _green : _textDim,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ردیف تاریخچه
// ═══════════════════════════════════════════
class _HistoryTile extends StatelessWidget {
  final HistoryEntryModel entry;

  const _HistoryTile({required this.entry});

  String get _type => entry.type ?? '';

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(_type);
    final date = _dateTime(entry.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // آیکون
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(_type), color: color, size: 21),
          ),
          const SizedBox(width: 12),
          // اطلاعات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _typeTitle(_type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: _textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  entry.label ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 13,
                      color: _textDim,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.userName ?? '',
                      style: const TextStyle(color: _textDim, fontSize: 11.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// متادیتای نوع رویداد
// ═══════════════════════════════════════════
String _typeTitle(String type) {
  switch (type) {
    case 'product_created':
      return 'ثبت محصول جدید';
    case 'product_updated':
      return 'افزودن مدل به محصول';
    case 'product_checkin':
      return 'ورود کالا به انبار';
    case 'user_created':
      return 'ساخت کاربر';
    case 'user_role_changed':
      return 'تغییر نقش کاربر';
    case 'user_warehouse_changed':
      return 'تغییر انبار کاربر';
    case 'user_deleted':
      return 'حذف کاربر';
    case 'order_created':
      return 'ثبت سفارش';
    case 'order_updated':
      return 'ویرایش سفارش';
    case 'order_deleted':
      return 'حذف سفارش';
    case 'order_shipped':
      return 'خروج سفارش از انبار';
    case 'order_completed':
      return 'تکمیل سفارش';
    case 'return_received':
      return 'ورود مرجوعی';
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
      return 'رویداد';
  }
}

Color _typeColor(String type) {
  switch (type) {
    case 'product_created':
    case 'order_completed':
      return _green;
    case 'product_updated':
    case 'user_role_changed':
    case 'order_updated':
      return _orange;
    case 'product_checkin':
    case 'user_warehouse_changed':
    case 'order_shipped':
      return _blue;
    case 'return_received':
      return _amber;
    case 'user_created':
    case 'order_created':
      return _green;
    case 'product_archived':
    case 'model_archived':
    case 'warehouse_archived':
      return _amber;
    case 'product_restored':
    case 'model_restored':
    case 'warehouse_restored':
      return _green;
    default:
      return _red;
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'product_created':
      return Icons.add_box_rounded;
    case 'product_updated':
      return Icons.edit_note_rounded;
    case 'product_checkin':
      return Icons.download_rounded;
    case 'product_archived':
    case 'model_archived':
    case 'warehouse_archived':
      return Icons.archive_rounded;
    case 'product_restored':
    case 'model_restored':
    case 'warehouse_restored':
      return Icons.unarchive_rounded;
    case 'user_created':
      return Icons.person_add_rounded;
    case 'user_role_changed':
      return Icons.manage_accounts_rounded;
    case 'user_warehouse_changed':
      return Icons.swap_horiz_rounded;
    case 'user_deleted':
      return Icons.person_off_rounded;
    case 'order_created':
      return Icons.receipt_long_rounded;
    case 'order_updated':
      return Icons.edit_rounded;
    case 'order_deleted':
      return Icons.delete_rounded;
    case 'order_shipped':
      return Icons.local_shipping_rounded;
    case 'order_completed':
      return Icons.check_circle_rounded;
    case 'return_received':
      return Icons.assignment_return_rounded;
    default:
      return Icons.event_rounded;
  }
}

// ═══════════════════════════════════════════
// فرمت تاریخ شمسی دقیق
// ═══════════════════════════════════════════
String _dateTime(String? iso) {
  try {
    final dt = DateTime.parse(iso!).toLocal();
    final j = Jalali.fromDateTime(dt);
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}  $hh:$mm';
  } catch (_) {
    return '—';
  }
}

// ═══════════════════════════════════════════
// پیام مرکزی (خطا / خالی)
// ═══════════════════════════════════════════
class _CenterMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CenterMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _textDim, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: _textDim, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
