import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/palette.dart';
import '../core/printer_settings.dart';
import '../core/socket_client.dart';
import '../widgets/app_widgets.dart';
import '../widgets/checkin_dialog.dart';
import '../widgets/printer_settings_dialog.dart';
import 'tabs/badges_tab.dart';
import 'tabs/cartons_tab.dart';
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

  final GlobalKey<CartonsTabState> _recentKey = GlobalKey();
  final GlobalKey<CartonsTabState> _printedKey = GlobalKey();
  final GlobalKey<CartonsTabState> _shippedKey = GlobalKey();
  final GlobalKey<TransactionsTabState> _transactionsKey = GlobalKey();
  final GlobalKey<BadgesTabState> _badgesKey = GlobalKey();

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

  late final CartonsTab _printedTab = CartonsTab(
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

  late final CartonsTab _shippedTab = CartonsTab(
    key: _shippedKey,
    fetch: widget.api.getShippedCartons,
    initialSummary: 'کارتن‌های تکمیل شده و ارسال شده',
    emptySummary: 'هیچ کارتن ارسال شده‌ای موجود نیست.',
    emptyState: 'هیچ کارتن ارسالی ثبت نشده است.',
    summary: (groups, total) => '$groups گروه کالا | $total کارتن ارسال شده',
    errorSummary: 'خطا در دریافت اطلاعات',
  );

  late final TransactionsTab _transactionsTab = TransactionsTab(
    key: _transactionsKey,
    api: widget.api,
  );
  late final BadgesTab _badgesTab = BadgesTab(key: _badgesKey, api: widget.api);

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
    // بارگذاری تنظیمات چاپ قبل از اولین دستور چاپ
    PrinterSettingsHolder.instance.load();
    loadData();
  }

  @override
  void dispose() {
    widget.socket.onScanoutDone = null;
    widget.socket.onCheckinCompleted = null;
    super.dispose();
  }

  Future<void> loadData() async {
    _loadWarehouse();
    _recentKey.currentState?.reload();
    _printedKey.currentState?.reload();
    _shippedKey.currentState?.reload();
    _transactionsKey.currentState?.reloadLatest();
    _badgesKey.currentState?.load();
  }

  /// بعد از موفقیت چاپ: کارتن‌ها سمت سرور علامت چاپ می‌خورند و هر دو تب
  /// «محصولات» و «چاپ شده‌ها» به‌روز می‌شوند
  Future<void> _handlePrinted(List<String> cartonIds) async {
    if (cartonIds.isEmpty) return;
    try {
      await widget.api.markCartonsPrinted(cartonIds);
    } catch (exc) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ثبت چاپ روی سرور ناموفق بود: $exc'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
    _recentKey.currentState?.reload();
    _printedKey.currentState?.reload();
  }

  Future<void> _openSettings() async {
    await showPrinterSettingsDialog(context);
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
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'تنظیمات چاپگر',
                        child: Material(
                          color: Palette.surfaceHover,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: _openSettings,
                            borderRadius: BorderRadius.circular(10),
                            hoverColor: Palette.surfaceAlt,
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
    'تکمیل شده‌ها',
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
