import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/history_entry_model.dart';
import '../../../../../core/realtime/socket_service.dart';
import '../../../../warehouse_keeper/providers/warehouse_keeper_provider.dart';

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

const _categoryOrder = ['all', 'products', 'warehouses', 'users', 'shipments', 'returns'];
const _categoryLabel = <String, String>{
  'all': 'همه',
  'products': 'محصولات',
  'warehouses': 'انبارها',
  'users': 'کاربران',
  'shipments': 'ارسالی‌ها',
  'returns': 'مرجوعی‌ها',
};

/// رویدادهایی که تاریخچه را تحت تأثیر قرار می‌دهند — با آمدن هرکدام، لیست بی‌صدا رفرش می‌شود
const _liveEvents = [
  'checkin:completed',
  'scanout:done',
  'delivery:completed',
  'order:created',
  'order:updated',
  'order:deleted',
];

const _pageSize = 50;

/// صفحهٔ «تاریخچه» مدیر — صفحه‌بندی سمت سرور + جستجو + فیلتر دسته + به‌روزرسانی realtime
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final List<HistoryEntryModel> _entries = [];
  final List<Object> _items = [];
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  Timer? _debounce;
  SocketService? _socket;

  String _category = 'all';
  String _query = '';
  int _page = 1;
  int _gen = 0;
  bool _hasMore = true;
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _refreshing = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _socket = ref.read(socketServiceProvider);
    for (final e in _liveEvents) {
      _socket?.on(e, _onLiveEvent);
    }
    _loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    if (_socket != null) {
      for (final e in _liveEvents) {
        _socket!.offEvent(e, _onLiveEvent);
      }
    }
    super.dispose();
  }

  // ─── داده ───────────────────────────────────────────

  Future<void> _loadFirstPage({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _initialLoading = true;
        _error = '';
      });
    }
    final gen = ++_gen;
    try {
      final result = await _api().getHistoryPage(
        page: 1,
        pageSize: _pageSize,
        category: _category,
        q: _query,
      );
      if (!mounted || gen != _gen) return;
      setState(() {
        _entries
          ..clear()
          ..addAll(result.entries);
        _page = 1;
        _hasMore = _entries.length < result.total;
        _error = '';
        _rebuildItems();
      });
    } catch (_) {
      if (!mounted || gen != _gen) return;
      setState(() {
        _error = 'اتصال به سرور برقرار نشد';
        _rebuildItems();
      });
    } finally {
      if (mounted && gen == _gen) {
        setState(() {
          _initialLoading = false;
          _refreshing = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore ||
        !_hasMore ||
        _initialLoading ||
        _refreshing ||
        _entries.isEmpty) {
      return;
    }
    final gen = _gen;
    setState(() => _loadingMore = true);
    try {
      final result = await _api().getHistoryPage(
        page: _page + 1,
        pageSize: _pageSize,
        category: _category,
        q: _query,
      );
      if (!mounted || gen != _gen) return;
      setState(() {
        _entries.addAll(result.entries);
        _page += 1;
        _hasMore = _entries.length < result.total;
        _rebuildItems();
      });
    } catch (_) {
      if (!mounted || gen != _gen) return;
      setState(() => _error = 'بارگذاری موارد بعدی ناموفق بود');
    } finally {
      if (mounted && gen == _gen) {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _onLiveEvent(dynamic data) {
    if (!mounted) return;
    _loadFirstPage(quiet: true);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final q = value.trim();
      if (q == _query) return;
      _query = q;
      _loadFirstPage();
    });
  }

  void _setCategory(String key) {
    if (key == _category) return;
    setState(() => _category = key);
    _loadFirstPage();
  }

  void _rebuildItems() {
    final items = <Object>[];
    String? prevDay;
    for (final e in _entries) {
      final day = _dayLabel(e.createdAt);
      if (day != prevDay) {
        items.add(day);
        prevDay = day;
      }
      items.add(e);
    }
    _items
      ..clear()
      ..addAll(items);
  }

  ManagerApiService _api() => ref.read(managerApiServiceProvider);

  String _dayLabel(String? iso) {
    try {
      final j = Jalali.fromDateTime(DateTime.parse(iso!).toLocal());
      final now = Jalali.fromDateTime(DateTime.now());
      if (j.year == now.year && j.month == now.month && j.day == now.day) {
        return 'امروز';
      }
      final yest = Jalali.fromDateTime(DateTime.now().subtract(const Duration(days: 1)));
      if (j.year == yest.year && j.month == yest.month && j.day == yest.day) {
        return 'دیروز';
      }
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '—';
    }
  }

  // ─── UI ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : Column(
              children: [
                _buildFilters(),
                if (_error.isNotEmpty && _entries.isNotEmpty) _buildErrorBanner(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categoryOrder.map((key) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _CategoryChip(
                    label: _categoryLabel[key]!,
                    selected: _category == key,
                    onTap: () => _setCategory(key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: (value) {
              setState(() {});
              _onSearchChanged(value);
            },
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'جستجو در رویدادها و کاربران…',
              hintStyle: const TextStyle(color: _textDim, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: _textDim, size: 20),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, color: _textDim, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                        _onSearchChanged('');
                      },
                    ),
              isDense: true,
              filled: true,
              fillColor: _surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1215),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _red.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: _red, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => _loadFirstPage(),
              child: const Text(
                'تلاش مجدد',
                style: TextStyle(color: _red, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_error.isNotEmpty && _entries.isEmpty) {
      return _CenterMessage(
        icon: Icons.cloud_off_rounded,
        title: 'خطا در دریافت تاریخچه',
        subtitle: _error,
        onRetry: () => _loadFirstPage(),
      );
    }
    if (_items.isEmpty) {
      return _CenterMessage(
        icon: _categoryIcon(_category),
        title: 'موردی ثبت نشده است',
        subtitle: _query.isNotEmpty
            ? 'برای جستجوی «$_query» نتیجه‌ای پیدا نشد'
            : 'با انجام اولین فعالیت، تاریخچهٔ آن اینجا نمایش داده می‌شود',
      );
    }
    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: () => _loadFirstPage(quiet: true),
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _green,
                  ),
                ),
              ),
            );
          }
          final item = _items[index];
          if (item is String) return _DayHeader(label: item);
          return _HistoryTile(entry: item as HistoryEntryModel);
        },
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
// سربرگ گروه‌بندی روز
// ═══════════════════════════════════════════
class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
  final VoidCallback? onRetry;

  const _CenterMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
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
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
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
          ],
        ),
      ),
    );
  }
}
