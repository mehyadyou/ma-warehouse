import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/product_history_model.dart';
import '../../../models/warehouse_model.dart';
import '../../../../../shared/utils/numbers.dart';
import '../../../../../shared/widgets/jalali_month_picker.dart';
import 'product_history_detail_screen.dart';

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

const _pageSize = 20;

const _exitTypeLabel = <String, String>{
  'any': 'همه',
  'carton': 'خروج کارتنی',
  'individual': 'خروج تکی',
  'none': 'بدون کارتن',
};

/// «سابقهٔ محصولات» — هر محصولی که از ابتدا وارد سیستم شده + فیلترهای فوق دقیق
class ProductHistoryScreen extends ConsumerStatefulWidget {
  const ProductHistoryScreen({super.key});

  @override
  ConsumerState<ProductHistoryScreen> createState() =>
      _ProductHistoryScreenState();
}

class _ProductHistoryScreenState extends ConsumerState<ProductHistoryScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _serialCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  Timer? _debounce;

  // فیلترهای فعال
  String _query = '';
  String? _warehouseId;
  String _exitType = 'any';
  String _serial = '';
  String _customerPhone = '';
  DateTime? _from;
  DateTime? _to;
  Jalali? _activityDay; // تاریخِ دقیقِ فعالیت (شمسی)

  List<WarehouseModel> _warehouses = [];

  // داده
  final List<ProductHistoryRow> _rows = [];
  int _page = 1;
  int _gen = 0;
  bool _hasMore = true;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _loadWarehouses();
    _loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _serialCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  ManagerApiService get _api => ref.read(managerApiServiceProvider);

  int get _activeFilterCount {
    var n = 0;
    if (_warehouseId != null) n++;
    if (_exitType != 'any') n++;
    if (_serial.trim().isNotEmpty) n++;
    if (_customerPhone.trim().isNotEmpty) n++;
    if (_from != null || _to != null) n++;
    if (_activityDay != null) n++;
    return n;
  }

  // ─── داده ───────────────────────────────────────────

  Future<void> _loadWarehouses() async {
    try {
      final list = await _api.getWarehouses();
      if (mounted) setState(() => _warehouses = list);
    } catch (_) {}
  }

  Map<String, String?> get _currentFilters => {
        'q': _query,
        'warehouseId': _warehouseId,
        'exitType': _exitType,
        'serial': _serial.trim(),
        'customerPhone': _customerPhone.trim(),
        'from': _from == null ? null : _iso(_from!),
        'to': _to == null ? null : _iso(_to!),
        'activityDate': _activityDay == null ? null : _jIso(_activityDay!),
      };

  Future<ProductHistoryPage> _fetch(int page) {
    final f = _currentFilters;
    return _api.getProductHistory(
      page: page,
      pageSize: _pageSize,
      q: f['q'],
      warehouseId: f['warehouseId'],
      exitType: f['exitType'] ?? 'any',
      serial: f['serial'],
      customerPhone: f['customerPhone'],
      from: f['from'],
      to: f['to'],
      activityDate: f['activityDate'],
    );
  }

  Future<void> _loadFirstPage({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _initialLoading = true;
        _error = '';
      });
    }
    final gen = ++_gen;
    try {
      final result = await _fetch(1);
      if (!mounted || gen != _gen) return;
      setState(() {
        _rows
          ..clear()
          ..addAll(result.rows);
        _page = 1;
        _hasMore = result.hasMore;
        _error = '';
        _initialLoading = false;
      });
    } catch (_) {
      if (!mounted || gen != _gen) return;
      setState(() {
        _error = 'اتصال به سرور برقرار نشد';
        _initialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _initialLoading || _rows.isEmpty) return;
    final gen = _gen;
    setState(() => _loadingMore = true);
    try {
      final result = await _fetch(_page + 1);
      if (!mounted || gen != _gen) return;
      setState(() {
        _rows.addAll(result.rows);
        _page += 1;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || gen != _gen) return;
      setState(() => _loadingMore = false);
    }
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

  // ─── تاریخ ──────────────────────────────────────────

  String _iso(DateTime d) => d.toIso8601String().substring(0, 10);

  String _jIso(Jalali j) =>
      '${j.year}-${j.month.toString().padLeft(2, '0')}-${j.day.toString().padLeft(2, '0')}';

  String _jalaliShort(DateTime? dt) {
    if (dt == null) return '—';
    try {
      final j = Jalali.fromDateTime(dt.toLocal());
      return faDigits(
          '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');
    } catch (_) {
      return '—';
    }
  }

  String _fmtJ(Jalali j) => faDigits(
      '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');

  /// انتخاب روزِ دقیقِ فعالیت (شمسی)
  Future<void> _pickActivityDay() async {
    final picked = await showJalaliMonthPicker(
      context,
      initial: _activityDay ?? Jalali.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _activityDay = picked);
    _loadFirstPage();
  }

  void _clearActivityDay() {
    setState(() => _activityDay = null);
    _loadFirstPage();
  }

  Future<void> _pickFrom() async {
    final picked = await showJalaliMonthPicker(
      context,
      initial: _from == null ? null : Jalali.fromDateTime(_from!),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _from = picked.toDateTime();
      if (_to != null && _to!.isBefore(_from!)) _to = _from;
    });
    _loadFirstPage();
  }

  Future<void> _pickTo() async {
    final picked = await showJalaliMonthPicker(
      context,
      initial: _to == null ? null : Jalali.fromDateTime(_to!),
    );
    if (picked == null || !mounted) return;
    final day = picked.toDateTime();
    setState(() {
      _to = day;
      if (_from != null && day.isBefore(_from!)) _from = day;
    });
    _loadFirstPage();
  }

  void _setQuickRange(int days) {
    final now = DateTime.now();
    setState(() {
      _from = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: days - 1));
      _to = now;
    });
    _loadFirstPage();
  }

  void _setThisMonth() {
    final j = Jalali.now();
    setState(() {
      _from = Jalali(j.year, j.month, 1).toDateTime();
      _to = DateTime.now();
    });
    _loadFirstPage();
  }

  void _clearAllFilters() {
    setState(() {
      _warehouseId = null;
      _exitType = 'any';
      _serial = '';
      _customerPhone = '';
      _from = null;
      _to = null;
      _activityDay = null;
      _serialCtrl.clear();
      _phoneCtrl.clear();
    });
    _loadFirstPage();
  }

  /// نوارِ نمایشِ فیلترِ روزِ فعال — بالای لیست
  Widget _activityDayBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _green.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded, color: _green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'فعالیتِ روزِ ${_fmtJ(_activityDay!)} — فقط تراکنش‌ها/ورود/خروجِ همین روز',
              style: const TextStyle(
                color: _green,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearActivityDay,
            child: const Icon(Icons.close_rounded, color: _green, size: 16),
          ),
        ],
      ),
    );
  }

  // ─── UI ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          'سابقهٔ محصولات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          _filterButton(),
        ],
      ),
      body: Column(
        children: [
          _searchField(),
          if (_activityDay != null) _activityDayBanner(),
          Expanded(
            child: RefreshIndicator(
              color: _green,
              backgroundColor: _surface,
              onRefresh: () => _loadFirstPage(quiet: true),
              child: _initialLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _green))
                  : _error.isNotEmpty && _rows.isEmpty
                      ? _errorView()
                      : _rows.isEmpty
                          ? _emptyView()
                          : _list(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: _textDim, size: 24),
          tooltip: 'فیلترها',
          onPressed: _openFilterSheet,
        ),
        if (_activeFilterCount > 0)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
              ),
              child: Text(
                faDigits('$_activeFilterCount'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'جستجوی نام محصول...',
          hintStyle: const TextStyle(color: _textDim, fontSize: 13),
          prefixIcon:
              const Icon(Icons.search_rounded, color: _textDim, size: 20),
          filled: true,
          fillColor: _surfaceAlt,
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
            borderSide: const BorderSide(color: _green),
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: _textDim, size: 40),
          const SizedBox(height: 12),
          Text(_error, style: const TextStyle(color: _textDim, fontSize: 13)),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => _loadFirstPage(),
            child: const Text('تلاش دوباره', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _activeFilterCount > 0 || _query.isNotEmpty
                ? Icons.filter_alt_off_rounded
                : Icons.inventory_2_outlined,
            color: _textDim,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            _activeFilterCount > 0 || _query.isNotEmpty
                ? 'محصولی با این فیلترها پیدا نشد'
                : 'هنوز محصولی وارد سیستم نشده است',
            style: const TextStyle(color: _textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      controller: _scrollCtrl,
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _rows.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _rows.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: _green, strokeWidth: 2),
              ),
            ),
          );
        }
        return _productCard(_rows[i]);
      },
    );
  }

  Widget _productCard(ProductHistoryRow r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductHistoryDetailScreen(
                  productId: r.productId,
                  productName: r.productName,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (r.archived)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'بایگانی',
                          style: TextStyle(color: _red, fontSize: 10.5),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_left_rounded,
                        color: _textDim, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip('کارتن: ${faDigits('${r.cartonTotal}')}', _blue),
                    _chip('موجود: ${faDigits('${r.inStock}')}', _green),
                    if (r.shipped > 0)
                      _chip('ارسال‌شده: ${faDigits('${r.shipped}')}', _amber),
                    if (r.individualTotal > 0)
                      _chip('تکی: ${faDigits('${r.individualTotal}')}', _orange),
                  ],
                ),
                if (r.txIn != null || r.txOut != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'واحد — ورود: ${faDigits('${r.txIn ?? 0}')}'
                    ' • خروج: ${faDigits('${r.txOut ?? 0}')}'
                    '${r.txReturn != null && r.txReturn! > 0 ? ' • مرجوعی: ${faDigits('${r.txReturn!}')}' : ''}',
                    style: const TextStyle(color: _textDim, fontSize: 11.5),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'اولین ورود: ${_jalaliShort(r.firstEntryAt)}'
                  ' • آخرین فعالیت: ${_jalaliShort(r.lastActivityAt)}',
                  style: const TextStyle(color: _textDim, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─── شیت فیلتر ──────────────────────────────────────

  void _openFilterSheet() {
    String? warehouseId = _warehouseId;
    String exitType = _exitType;
    // کنترلرها از state فعلی پر می‌شوند — در dispose صفحه هم پاک می‌شوند
    _serialCtrl.text = _serial;
    _phoneCtrl.text = _customerPhone;

    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'فیلترهای دقیق',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // انبار
                const Text('انبار',
                    style: TextStyle(color: _textDim, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: warehouseId,
                  isDense: true,
                  dropdownColor: _surfaceAlt,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _sheetInput('همهٔ انبارها'),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('همهٔ انبارها')),
                    ..._warehouses.map(
                      (w) => DropdownMenuItem<String>(
                          value: w.id, child: Text(w.name)),
                    ),
                  ],
                  onChanged: (v) => setSheet(() => warehouseId = v),
                ),
                const SizedBox(height: 14),

                // نوع خروج
                const Text('نوع خروج',
                    style: TextStyle(color: _textDim, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _exitTypeLabel.entries.map((e) {
                    final selected = exitType == e.key;
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: selected,
                      onSelected: (_) => setSheet(() => exitType = e.key),
                      labelStyle: TextStyle(
                        color: selected ? Colors.black : _textDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedColor: _green,
                      backgroundColor: _surfaceAlt,
                      side: BorderSide(color: selected ? _green : _border),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // سریال
                TextField(
                  controller: _serialCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _sheetInput('بخشی از شمارهٔ سریال کارتن...'),
                ),
                const SizedBox(height: 10),

                // شمارهٔ مشتری
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _sheetInput('شمارهٔ تماس مشتری...'),
                ),
                const SizedBox(height: 14),

                // تاریخِ دقیقِ فعالیت — همان روز
                const Text(
                  'فعالیت در تاریخِ دقیق (تراکنش، ورود یا خروج همان روز)',
                  style: TextStyle(color: _textDim, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _dateButton(
                        _activityDay == null
                            ? 'انتخاب روز — شمسی'
                            : _fmtJ(_activityDay!),
                        () async {
                          Navigator.pop(ctx);
                          await _pickActivityDay();
                        },
                      ),
                    ),
                    if (_activityDay != null) ...[
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'حذف فیلترِ روز',
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _clearActivityDay();
                          },
                          icon: const Icon(Icons.highlight_off_rounded,
                              color: _red, size: 22),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // بازهٔ تاریخ
                const Text('اولین ورود بین',
                    style: TextStyle(color: _textDim, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _dateButton(
                        _from == null ? 'از تاریخ' : _jalaliShort(_from),
                        () async {
                          Navigator.pop(ctx);
                          await _pickFrom();
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('تا',
                          style: TextStyle(color: _textDim, fontSize: 12)),
                    ),
                    Expanded(
                      child: _dateButton(
                        _to == null ? 'تا تاریخ' : _jalaliShort(_to),
                        () async {
                          Navigator.pop(ctx);
                          await _pickTo();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _rangeChip('امروز', () {
                      Navigator.pop(ctx);
                      _setQuickRange(1);
                    }),
                    _rangeChip('۷ روز', () {
                      Navigator.pop(ctx);
                      _setQuickRange(7);
                    }),
                    _rangeChip('۳۰ روز', () {
                      Navigator.pop(ctx);
                      _setQuickRange(30);
                    }),
                    _rangeChip('این ماه', () {
                      Navigator.pop(ctx);
                      _setThisMonth();
                    }),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearAllFilters();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('حذف فیلترها',
                            style:
                                TextStyle(color: _textDim, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _warehouseId = warehouseId;
                            _exitType = exitType;
                            _serial = _serialCtrl.text;
                            _customerPhone = _phoneCtrl.text;
                          });
                          _loadFirstPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('اعمال فیلتر',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _sheetInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textDim, fontSize: 12.5),
      filled: true,
      fillColor: _surfaceAlt,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _green),
      ),
      isDense: true,
    );
  }

  Widget _dateButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12.5),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _rangeChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: const TextStyle(color: _green, fontSize: 11.5),
      backgroundColor: _surfaceAlt,
      side: const BorderSide(color: _border),
    );
  }
}
