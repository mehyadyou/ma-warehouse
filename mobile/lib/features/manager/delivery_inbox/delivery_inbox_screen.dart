import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/api_error.dart';
import '../../../shared/utils/numbers.dart';
import '../../../shared/widgets/auth_network_image.dart';
import '../data/manager_api_service.dart';
import '../models/delivery_inbox_item.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

const _monthNames = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
];

/// تشخیص نوع و پسوند فایل از روی آدرس عکس
(String mime, String ext) _mimeExtOf(String url) {
  final lower = url.toLowerCase();
  if (lower.endsWith('.png')) return ('image/png', 'png');
  if (lower.endsWith('.webp')) return ('image/webp', 'webp');
  return ('image/jpeg', 'jpg');
}

/// دانلود عکس بیجک و باز کردن شیت اشتراک‌گذاری سیستم‌عامل — فقط تصویر، بدون هیچ متنی
/// اگر عکسی موجود نباشد false برمی‌گرداند؛ خطای دانلود به بیرون propagate می‌شود
Future<bool> shareReceiptImage({
  required ManagerApiService api,
  required DeliveryInboxItem item,
}) async {
  final url = item.receiptUrl;
  if (url == null || url.isEmpty) return false;

  final bytes = await api.downloadFileBytes(ApiConstants.fullUrl(url));
  final (mime, ext) = _mimeExtOf(url);
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          bytes,
          mimeType: mime,
          name: 'bijak-${item.orderNumber ?? 'receipt'}.$ext',
        ),
      ],
    ),
  );
  return true;
}

/// صندوق تحویل — تمام عکس‌های بیجک باربری که راننده‌ها هنگام تحویل آپلود کرده‌اند
/// با فیلتر راننده و روز/ماه/سال شمسی
class DeliveryInboxScreen extends StatefulWidget {
  const DeliveryInboxScreen({super.key});

  @override
  State<DeliveryInboxScreen> createState() => _DeliveryInboxScreenState();
}

class _DeliveryInboxScreenState extends State<DeliveryInboxScreen> {
  final _api = ManagerApiService();

  List<DeliveryInboxDriver> _drivers = [];
  String? _driverId;
  int? _year;
  int? _month;
  int? _day;

  /// null = در حال بارگذاری
  List<DeliveryInboxItem>? _items;
  String? _error;

  /// شناسهٔ رکوردی که عکسش در حال دانلود برای اشتراک‌گذاری است
  String? _sharingId;

  bool get _hasFilter =>
      _driverId != null || _year != null || _month != null || _day != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final drivers = await _api.getDeliveryInboxDrivers();
      if (!mounted) return;
      setState(() => _drivers = drivers);
    } catch (_) {
      // فیلتر راننده اختیاری است — بدون آن هم صفحه کار می‌کند
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _items = null;
    });
    try {
      final items = await _api.getDeliveryInbox(
        driverId: _driverId,
        year: _year,
        month: _month,
        day: _day,
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _items = [];
      });
    }
  }

  /// انتخاب ماه/روز بدون سال نامعتبر است — سال (و ماه) جاری را خودکار پر می‌کنیم
  void _onMonthChanged(int? month) {
    setState(() {
      _month = month;
      if (_month != null && _year == null) {
        _year = Jalali.fromDateTime(DateTime.now()).year;
      }
      if (_month == null) _day = null;
    });
    _load();
  }

  void _onDayChanged(int? day) {
    setState(() {
      _day = day;
      if (_day != null && _month == null) {
        final now = Jalali.fromDateTime(DateTime.now());
        _month ??= now.month;
        _year ??= now.year;
      }
    });
    _load();
  }

  void _setToday() {
    final now = Jalali.fromDateTime(DateTime.now());
    setState(() {
      _year = now.year;
      _month = now.month;
      _day = now.day;
    });
    _load();
  }

  void _clearFilters() {
    setState(() {
      _driverId = null;
      _year = null;
      _month = null;
      _day = null;
    });
    _load();
  }

  String _shamsiLabel(DateTime? dt) {
    if (dt == null) return '';
    final j = Jalali.fromDateTime(dt);
    return '${j.year}/${j.month}/${j.day}';
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'صندوق تحویل',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          if (items != null && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    items.isEmpty ? 'عکسی یافت نشد' : '${faDigits('${items.length}')} عکس بیجک',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    _hasFilter ? 'با فیلترهای اعمال‌شده' : 'همهٔ تحویل‌ها',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ─── فیلترها: راننده + روز/ماه/سال ───
  Widget _buildFilterBar() {
    final now = Jalali.fromDateTime(DateTime.now());
    final isToday = _year == now.year && _month == now.month && _day == now.day;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasFilter ? _green.withValues(alpha: 0.35) : _border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // هدر: عنوان + شمارندهٔ فیلترهای فعال + پاک کردن
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                size: 15,
                color: _hasFilter ? _green : Colors.white54,
              ),
              const SizedBox(width: 6),
              const Text(
                'فیلترها',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_hasFilter) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    faDigits('$_activeFilterCount'),
                    style: const TextStyle(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: _hasFilter ? _clearFilters : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: _hasFilter ? Colors.white70 : Colors.white24,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'پاک کردن فیلترها',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _hasFilter ? Colors.white70 : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // راننده — تمام‌عرض
          _fieldLabel('راننده'),
          const SizedBox(height: 6),
          _buildFilterDropdown<String>(
            value: _driverId,
            hint: 'همهٔ رانندگان',
            items: [
              for (final d in _drivers)
                DropdownMenuItem(
                  value: d.id,
                  child: Text(
                    d.name ?? d.phone ?? 'راننده',
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
            onChanged: (v) {
              setState(() => _driverId = v);
              _load();
            },
          ),
          const SizedBox(height: 14),
          // تاریخ تحویل — سه ستون هم‌عرض
          _fieldLabel('تاریخ تحویل (شمسی)'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown<int>(
                  value: _year,
                  hint: 'سال',
                  items: [
                    for (var y = now.year; y >= now.year - 4; y--)
                      DropdownMenuItem(
                        value: y,
                        child: Text(faDigits('$y'),
                            style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() => _year = v);
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown<int>(
                  value: _month,
                  hint: 'ماه',
                  items: [
                    for (var m = 0; m < 12; m++)
                      DropdownMenuItem(
                        value: m + 1,
                        child: Text(_monthNames[m],
                            style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                      ),
                  ],
                  onChanged: _onMonthChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown<int>(
                  value: _day,
                  hint: 'روز',
                  items: [
                    for (var d = 1; d <= 31; d++)
                      DropdownMenuItem(
                        value: d,
                        child: Text(faDigits('$d'),
                            style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                      ),
                  ],
                  onChanged: _onDayChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // میانبر امروز
          Row(
            children: [
              _chipButton(
                icon: isToday ? Icons.check_rounded : Icons.today_rounded,
                label: 'امروز',
                selected: isToday,
                onTap: _setToday,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int get _activeFilterCount =>
      (_driverId != null ? 1 : 0) +
      (_year != null ? 1 : 0) +
      (_month != null ? 1 : 0) +
      (_day != null ? 1 : 0);

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: _textDim,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _buildFilterDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          isExpanded: true,
          dropdownColor: _surfaceAlt,
          hint: Text(hint,
              style: TextStyle(color: _textDim.withValues(alpha: 0.7), fontSize: 12.5)),
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white38),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text(hint,
                  style: const TextStyle(color: Colors.white54, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            ...items,
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _chipButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final fg = selected ? const Color(0xFF0B1F10) : _green;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green : _green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _green : _green.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 15),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }

  // ─── بدنه: گرید عکس‌ها / لودینگ / خطا / خالی ───
  Widget _buildBody() {
    final items = _items;
    if (items == null) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('خطا: $_error',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 16),
          const Text('عکسی در صندوق تحویل نیست',
              style: TextStyle(color: Colors.white38, fontSize: 15)),
          if (_hasFilter) ...[
            const SizedBox(height: 6),
            const Text('فیلترها را تغییر دهید یا پاک کنید',
                style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ]),
      );
    }

    return RefreshIndicator(
      color: _green,
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildCard(items[i]),
      ),
    );
  }

  Widget _buildCard(DeliveryInboxItem item) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                InkWell(
                  onTap: () => _openViewer(item),
                  child: AuthNetworkImage(
                    path: item.receiptUrl ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : const Center(child: CircularProgressIndicator(color: _green)),
                    errorBuilder: (_) => Container(
                      color: _surfaceAlt,
                      child: const Icon(Icons.broken_image_outlined,
                          color: Colors.white24, size: 40),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: _shareButton(item),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.orderNumber != null
                      ? 'سفارش شماره ${faDigits('${item.orderNumber}')}'
                      : 'سفارش',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.carrier ?? 'باربری نامشخص'}${item.city != null ? ' • ${item.city}' : ''}',
                  style: const TextStyle(color: _textDim, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'راننده: ${item.driverName ?? '-'}',
                  style: const TextStyle(color: _textDim, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  faDigits(_shamsiLabel(item.deliveredAt)),
                  style: const TextStyle(color: _green, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openViewer(DeliveryInboxItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ReceiptViewerScreen(item: item)),
    );
  }

  Future<void> _shareItem(DeliveryInboxItem item) async {
    if (_sharingId != null) return;
    setState(() => _sharingId = item.id);
    try {
      final shared = await shareReceiptImage(api: _api, item: item);
      if (!shared && mounted) {
        _showSnack('عکسی برای اشتراک‌گذاری موجود نیست');
      }
    } catch (_) {
      if (mounted) {
        _showSnack('دریافت عکس ناموفق بود؛ اتصال اینترنت را بررسی کنید');
      }
    } finally {
      if (mounted) setState(() => _sharingId = null);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: _surfaceAlt,
          content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// دکمهٔ اشتراک‌گذاری شناور روی گوشهٔ عکس — با حالت در حال دانلود
  Widget _shareButton(DeliveryInboxItem item) {
    final busy = _sharingId == item.id;
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: busy ? null : () => _shareItem(item),
        child: SizedBox(
          width: 36,
          height: 36,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2, color: _green),
                )
              : const Icon(Icons.ios_share_rounded, color: Colors.white, size: 17),
        ),
      ),
    );
  }
}

/// نمایش تمام‌صفحهٔ عکس بیجک — بزرگ‌نمایی با دو انگشت + اطلاعات سفارش
class _ReceiptViewerScreen extends StatefulWidget {
  final DeliveryInboxItem item;

  const _ReceiptViewerScreen({required this.item});

  @override
  State<_ReceiptViewerScreen> createState() => _ReceiptViewerScreenState();
}

class _ReceiptViewerScreenState extends State<_ReceiptViewerScreen> {
  bool _sharing = false;

  DeliveryInboxItem get item => widget.item;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final shared =
          await shareReceiptImage(api: ManagerApiService(), item: item);
      if (!shared && mounted) {
        _showSnack('عکسی برای اشتراک‌گذاری موجود نیست');
      }
    } catch (_) {
      if (mounted) {
        _showSnack('دریافت عکس ناموفق بود؛ اتصال اینترنت را بررسی کنید');
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF22262D),
          content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.orderNumber != null
              ? 'سفارش شماره ${faDigits('${item.orderNumber}')}'
              : 'عکس بیجک',
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: IconButton(
              tooltip: 'اشتراک‌گذاری عکس',
              onPressed: _sharing ? null : _share,
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    )
                  : const Icon(Icons.ios_share_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                maxScale: 6,
                child: Center(
                  child: AuthNetworkImage(
                    path: item.receiptUrl ?? '',
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : const Center(child: CircularProgressIndicator(color: _green)),
                    errorBuilder: (_) => const Icon(Icons.broken_image_outlined,
                        color: Colors.white24, size: 56),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF16181C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _infoRow('باربری', item.carrier ?? 'نامشخص'),
                  _infoRow('گیرنده', item.receiverName ?? '-'),
                  if (item.city != null) _infoRow('شهر', item.city!),
                  if (item.address != null) _infoRow('آدرس', item.address!),
                  if (item.customerPhone != null) _infoRow('تلفن مشتری', item.customerPhone!),
                  _infoRow('راننده', '${item.driverName ?? '-'}${item.driverPhone != null ? ' — ${item.driverPhone}' : ''}'),
                  _infoRow('تاریخ تحویل', item.deliveredAt != null
                      ? faDigits(_shamsiOf(item.deliveredAt!))
                      : '-'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shamsiOf(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return '${j.year}/${j.month}/${j.day}';
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text('$label:', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}