import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/badge_print_settings.dart';
import '../core/palette.dart';
import '../core/pending_prints.dart';
import '../core/printer_settings.dart';
import '../core/socket_client.dart';
import '../widgets/app_widgets.dart';
import '../widgets/badge_print_settings_dialog.dart';
import '../widgets/checkin_dialog.dart';
import '../widgets/printer_settings_dialog.dart';
import 'tabs/badges_tab.dart';
import 'tabs/cartons_tab.dart';
import 'tabs/printed_tab.dart';
import 'tabs/transactions_tab.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.api,
    required this.socket,
    required this.userName,
    required this.onLogout,
  });

  final ApiService api;
  final SocketClient socket;
  final String userName;
  final VoidCallback onLogout;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  int _selectedIndex = 0;
  String _warehouseName = 'نامشخص';
  String _keeperName = '';
  String _subtitle = 'در حال بارگذاری اطلاعات...';
  int _pendingPrints = 0;

  final GlobalKey<CartonsTabState> _recentKey = GlobalKey();
  final GlobalKey<CartonsTabState> _printedKey = GlobalKey();
  final GlobalKey<CartonsTabState> _shippedKey = GlobalKey();
  final GlobalKey<TransactionsTabState> _transactionsKey = GlobalKey();
  final GlobalKey<BadgesTabState> _badgesKey = GlobalKey();
  final GlobalKey<BadgesTabState> _printedBadgesKey = GlobalKey();

  late final CartonsTab _recentTab = CartonsTab(
    key: _recentKey,
    fetch: widget.api.getCartons,
    initialSummary: 'محصولات وارد شده به انبار',
    emptySummary: 'هنوز محصولی وارد نشده است.',
    emptyState: 'محصولی وارد نشده است. با دکمه «افزودن محصول» کالا را وارد کنید.',
    summary: (groups, total) => '$groups گروه کالا | $total برچسب آماده چاپ',
    errorSummary: 'خطا در دریافت اطلاعات',
    // بدون تاریخ: اگر مدل یک محصول دوباره وارد شود، در همان ستون جمع می‌شود
    groupByDate: false,
    onAddProduct: _openCheckIn,
    onPrinted: _handlePrinted,
  );

  late final CartonsTab _printedLabelsTab = CartonsTab(
    key: _printedKey,
    fetch: widget.api.getPrintedCartons,
    initialSummary: 'لیبل‌های چاپ‌شده',
    emptySummary: 'هنوز لیبلی چاپ نشده است.',
    emptyState: 'لیبل‌های چاپ‌شدهٔ کارتن‌ها اینجا نمایش داده می‌شوند.',
    summary: (groups, total) => '$groups گروه کالا | $total لیبل چاپ‌شده',
    errorSummary: 'خطا در دریافت اطلاعات',
    // بدون تاریخ: مدل تکراریِ همان محصول در همان ستون جمع می‌شود
    groupByDate: false,
    onPrinted: _handlePrinted,
  );

  // بیجک‌های چاپ‌شده در تب «چاپ شده‌ها» (فیلتر بیجک)
  late final BadgesTab _printedBadgesTab = BadgesTab(
    key: _printedBadgesKey,
    api: widget.api,
    printed: true,
    onPrinted: _handleBadgesPrinted,
  );

  // تب «چاپ شده‌ها»: فیلتر لیبل / بیجک
  late final PrintedTab _printedTab = PrintedTab(
    labelsTab: _printedLabelsTab,
    badgesTab: _printedBadgesTab,
  );

  late final CartonsTab _shippedTab = CartonsTab(
    key: _shippedKey,
    fetch: widget.api.getShippedCartons,
    initialSummary: 'محصولات خارج‌شده از انبار',
    emptySummary: 'هنوز محصولی از انبار خارج نشده است.',
    emptyState: 'هر محصولی که با خروج (اسکن یا دستی) از انبار خارج شود اینجا نمایش داده می‌شود.',
    summary: (groups, total) => '$groups گروه کالا | $total خروجی',
    errorSummary: 'خطا در دریافت اطلاعات',
    // بدون تاریخ: محصول تکراری در همان ستون جمع می‌شود و کل خروجی‌هایش نمایش داده می‌شود
    groupByDate: false,
    showExitedBadge: true,
  );

  late final TransactionsTab _transactionsTab = TransactionsTab(
    key: _transactionsKey,
    api: widget.api,
  );
  late final BadgesTab _badgesTab = BadgesTab(
    key: _badgesKey,
    api: widget.api,
    onPrinted: _handleBadgesPrinted,
  );

  @override
  void initState() {
    super.initState();
    widget.socket.onScanoutDone = (data) {
      _recentKey.currentState?.reload();
      _shippedKey.currentState?.reload();
    };
    widget.socket.onCheckinCompleted = (data) {
      _recentKey.currentState?.reload();
    };
    // ثبت/ویرایش/حذف سفارش توسط مدیریت → بیجکِ همان انبار فوراً در منوی «بیجک» می‌آید
    widget.socket.onOrderCreated = (data) {
      _badgesKey.currentState?.load();
      _printedBadgesKey.currentState?.load();
    };
    widget.socket.onOrderUpdated = (data) {
      _badgesKey.currentState?.load();
      _printedBadgesKey.currentState?.load();
    };
    widget.socket.onOrderDeleted = (data) {
      _badgesKey.currentState?.load();
      _printedBadgesKey.currentState?.load();
    };
    // بارگذاری تنظیمات چاپ قبل از اولین دستور چاپ
    PrinterSettingsHolder.instance.load();
    BadgePrintSettingsHolder.instance.load();
    loadData();
  }

  @override
  void dispose() {
    widget.socket.onScanoutDone = null;
    widget.socket.onCheckinCompleted = null;
    widget.socket.onOrderCreated = null;
    widget.socket.onOrderUpdated = null;
    widget.socket.onOrderDeleted = null;
    super.dispose();
  }

  Future<void> loadData() async {
    _loadWarehouse();
    _recentKey.currentState?.reload();
    _printedKey.currentState?.reload();
    _shippedKey.currentState?.reload();
    _transactionsKey.currentState?.reloadLatest();
    _badgesKey.currentState?.load();
    _printedBadgesKey.currentState?.load();
    _syncPending();
  }

  /// فلاش صف ثبت‌های چاپِ جامانده (حادثه BR 116) — قدیمی‌ترین اول.
  Future<void> _syncPending() async {
    int left;
    try {
      left = await PendingPrints.flush(widget.api.markCartonsPrinted);
    } catch (_) {
      left = await PendingPrints.count();
    }
    if (!mounted) return;
    setState(() => _pendingPrints = left);
  }

  /// بعد از موفقیت چاپ: کارتن‌ها سمت سرور علامت چاپ می‌خورند و هر دو تب
  /// «محصولات» و «چاپ شده‌ها» به‌روز می‌شوند.
  /// اگر ثبت ناموفق بود، آیدی‌ها در صف مقاوم می‌مانند تا با وصل‌شدن ثبت شوند
  /// (بدون این صف، چاپ فیزیکی انجام می‌شد ولی دیتابیس بی‌خبر می‌ماند).
  Future<void> _handlePrinted(List<String> cartonIds) async {
    if (cartonIds.isEmpty) return;
    try {
      await widget.api.markCartonsPrinted(cartonIds);
      await _syncPending();
    } catch (exc) {
      final left = await PendingPrints.enqueue(cartonIds);
      if (!mounted) return;
      setState(() => _pendingPrints = left);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ثبت چاپ روی سرور ناموفق بود — در صف ماند ($left دسته). '
              'با وصل‌شدن خودکار ثبت می‌شود.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
    _recentKey.currentState?.reload();
    _printedKey.currentState?.reload();
  }

  /// بعد از موفقیت چاپ بیجک: سرور علامت چاپ می‌زند و بیجک از منوی «بیجک»
  /// حذف و در تب «چاپ شده‌ها» (فیلتر بیجک) نمایش داده می‌شود
  Future<void> _handleBadgesPrinted(List<String> badgeIds) async {
    if (badgeIds.isEmpty) return;
    try {
      await widget.api.markBadgesPrinted(badgeIds);
    } catch (exc) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ثبت چاپ بیجک روی سرور ناموفق بود: $exc'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
    _badgesKey.currentState?.load();
    _printedBadgesKey.currentState?.load();
  }

  Future<void> _openPrinterSettings() async {
    await showPrinterSettingsDialog(context);
  }

  Future<void> _openBadgeSettings() async {
    await showBadgePrintSettingsDialog(context);
  }

  Future<void> _openCheckIn() async {
    await showDialog<void>(
      context: context,
      builder: (context) => CheckInDialog(
        api: widget.api,
        onSuccess: () => _recentKey.currentState?.reload(),
      ),
    );
  }

  Future<void> _loadWarehouse() async {
    try {
      final warehouse = await widget.api.getMyWarehouse();
      if (!mounted) return;
      setState(() {
        _warehouseName = warehouse['name']?.toString() ?? 'انبار نامشخص';
        _keeperName = warehouse['keeperName']?.toString() ?? '';
      });
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _warehouseName = 'انبار';
        _subtitle = 'عدم دریافت اطلاعات انبار: $exc';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _keeperName.isEmpty
        ? _subtitle
        : 'کاربر فعال: ${widget.userName}${_keeperName == widget.userName ? '' : ' ($_keeperName)'}';

    return Scaffold(
      backgroundColor: Palette.appBg,
      body: Row(
        children: [
          // در RTL اولین فرزند Row سمت راست می‌نشیند؛ پس سایدبار اول است تا کنار راست پنجره باشد
          _Sidebar(
            userName: widget.userName,
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
            onLogout: widget.onLogout,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: Palette.surfaceAlt,
                    border: Border(bottom: BorderSide(color: Palette.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'داشبورد $_warehouseName',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Palette.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Palette.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: 'بروزرسانی',
                        variant: AppButtonVariant.secondary,
                        onPressed: loadData,
                      ),
                      if (_pendingPrints > 0) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () async {
                            await _syncPending();
                            _recentKey.currentState?.reload();
                            _printedKey.currentState?.reload();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cloud_off_outlined,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$_pendingPrints ثبت‌نشده',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        tooltip: 'تنظیمات',
                        onSelected: (value) {
                          switch (value) {
                            case 'printer':
                              _openPrinterSettings();
                            case 'badge':
                              _openBadgeSettings();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'printer',
                            child: Row(
                              children: [
                                Icon(Icons.print_outlined,
                                    size: 18, color: Palette.textMuted),
                                SizedBox(width: 8),
                                Text('تنظیمات چاپگر (لیبل)'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'badge',
                            child: Row(
                              children: [
                                Icon(Icons.badge_outlined,
                                    size: 18, color: Palette.textMuted),
                                SizedBox(width: 8),
                                Text('تنظیمات چاپ بیجک'),
                              ],
                            ),
                          ),
                        ],
                        child: Material(
                          color: Palette.surfaceHover,
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(9),
                            child: Icon(
                              Icons.settings_rounded,
                              color: Palette.text,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _recentTab,
                      _printedTab,
                      _shippedTab,
                      _transactionsTab,
                      _badgesTab,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.userName,
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
  });

  static const _navItems = [
    'محصولات',
    'چاپ شده‌ها',
    'خروجی‌ها',
    'تاریخچه تراکنش‌ها',
    'بیجک',
  ];

  final String userName;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Palette.surface,
        border: Border(left: BorderSide(color: Palette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      child: Column(
        children: [
          const Text(
            'MA WAREHOUSE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Palette.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            userName.isEmpty ? 'انباردار' : userName,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Palette.border,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          for (var i = 0; i < _navItems.length; i++)
            _NavItem(
              label: _navItems[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'خروج از حساب',
              variant: AppButtonVariant.danger,
              onPressed: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        key: ValueKey('navItem_$label'),
        color: selected ? Palette.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Palette.surfaceHover,
          // تمام‌عرض: همهٔ آیتم‌های منو هم‌سایز می‌شوند و هایلایت انتخاب
          // هم کل ردیف را می‌گیرد، نه فقط دور متن
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.black : Palette.textMuted,
                  fontSize: 13,
                  // ارتفاع خط ثابت تا آیتم انتخاب‌شده (bold) هم‌قد بقیه باشد
                  height: 1.4,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
