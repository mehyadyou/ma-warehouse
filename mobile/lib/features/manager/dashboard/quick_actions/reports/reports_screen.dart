import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:math' as math;
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';
import '../../../models/warehouse_model.dart';
import '../../../models/transaction_entry_model.dart';
import '../../../models/warehouse_inventory_row_model.dart';
import '../../../models/user_model.dart';
import 'user_report_screen.dart';

// ──────────────────────────────────────────
// Theme Constants
// ──────────────────────────────────────────
const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceLight = Color(0xFF22262C);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _red = Color(0xFFF87171);
const _blue = Color(0xFF60A5FA);
const _purple = Color(0xFFA78BFA);
const _textGrey = Color(0xFF94A3B8);

// ──────────────────────────────────────────
// Main Reports Screen
// ──────────────────────────────────────────
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  List<WarehouseModel> _warehouses = [];
  String? _selectedWarehouseId;
  Jalali? _selectedDate;
  List<TransactionEntryModel> _transactions = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    try {
      final warehouses = await _api.getWarehouses();
      if (!mounted) return;
      setState(() => _warehouses = warehouses);
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final today = Jalali.now();
    final picked = await showDialog<Jalali>(
      context: context,
      builder: (_) => MonthPickerDialog(initial: _selectedDate ?? today),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    if (_selectedWarehouseId == null || _selectedDate == null) return;
    setState(() => _loading = true);
    try {
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      _transactions = await _api.getTransactionsByDate(_selectedWarehouseId!, dateStr);
    } catch (_) {
      _transactions = [];
    }
    setState(() => _loading = false);
  }

  Map<String, int> get _productSummary {
    final map = <String, int>{};
    for (var t in _transactions) {
      final name = t.productName ?? 'نامشخص';
      map[name] = (map[name] ?? 0) + t.quantity.toInt();
    }
    return map;
  }

  String get _dateStr => _selectedDate != null
      ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
      : 'انتخاب تاریخ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('گزارش‌ها', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_surface, _bg],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ──────── Section 1: ورود و خروج ────────
            _buildInOutSection(),
            const SizedBox(height: 24),
            
            // ──────── Section 2: وضعیت انبارها (نسخه حرفه‌ای) ────────
            _buildWarehouseStatusSection(),
            const SizedBox(height: 24),
            
            // ──────── Section 3: گزارش کاربران ────────
            _buildUserReportsSection(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //بخش ورود و خروج (طراحی مدرن)
  // ─────────────────────────────────────────
  Widget _buildInOutSection() {
    return _GlassMorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.swap_horiz_rounded, title: 'ورود و خروج کالا'),
          const SizedBox(height: 20),
          
          // Dropdown انتخاب انبار
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: _surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: _selectedWarehouseId,
              dropdownColor: _surfaceLight,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _green),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'انتخاب انبار',
                hintStyle: TextStyle(color: _textGrey.withOpacity(0.6)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              ),
              items: _warehouses
                  .map<DropdownMenuItem<String>>((w) => DropdownMenuItem(
                        value: w.id,
                        child: Row(children: [
                          const Icon(Icons.warehouse_rounded, size: 18, color: _green),
                          const SizedBox(width: 8),
                          Text(w.name),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedWarehouseId = v);
                _loadTransactions();
              },
            ),
          ),
          const SizedBox(height: 14),

          // دکمه انتخاب تاریخ
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: _green, size: 22),
                  const SizedBox(width: 12),
                  Text(_dateStr, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('تغییر', style: TextStyle(color: _green, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // نمایش لیست تراکنش‌ها
          if (_selectedWarehouseId == null || _selectedDate == null)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('انبار و تاریخ را انتخاب کنید', style: TextStyle(color: _textGrey))))
          else if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: _green)))
          else if (_productSummary.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('تراکنشی در این روز یافت نشد', style: TextStyle(color: _textGrey))))
          else
            Column(
              children: [
                ..._productSummary.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_green.withOpacity(0.2), Colors.transparent]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _green.withOpacity(0.3)),
                        ),
                        child: Text('${e.value} عدد', style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )).toList(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('مجموع کل', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_productSummary.values.fold(0, (a, b) => a + b)} عدد',
                        style: const TextStyle(color: _green, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //وضعیت انبارها (UI کاملاً مدرن و حرفه‌ای)
  // ─────────────────────────────────────────
  Widget _buildWarehouseStatusSection() {
    return FutureBuilder<List<WarehouseInventoryRowModel>>(
      future: _api.getWarehouseInventory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: _green)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _GlassMorphismCard(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.inventory_2_outlined, size: 48, color: _textGrey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text('انباری ثبت نشده است', style: TextStyle(color: _textGrey, fontSize: 16)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        // ساختاردهی دیتا به فرمت مدرن
        final Map<String, Map<String, int>> inventoryMap = {};
        final Set<String> allProducts = {};
        
        for (var row in data) {
          final whName = row.warehouseName ?? '';
          final prodName = row.productName ?? '';
          final count = row.count.toInt();
          
          allProducts.add(prodName);
          inventoryMap.putIfAbsent(whName, () => {});
          inventoryMap[whName]![prodName] = count;
        }

        // محاسبه آمار کلی
        final int totalWarehouses = inventoryMap.length;
        final int totalProducts = allProducts.length;
        final int grandTotal = inventoryMap.values.fold(0, (sum, warehouse) => sum + warehouse.values.fold(0, (ws, cnt) => ws + cnt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(icon: Icons.factory, title: 'وضعیت لحظه‌ای انبارها'),
            const SizedBox(height: 16),
            
            //کارت‌های آماری کلی (مدرن و مینیمال)
            _buildSummaryStats(totalWarehouses, totalProducts, grandTotal),
            const SizedBox(height: 20),
            
            //لیست انبارها به صورت کارت‌های قابل گسترش
            ...inventoryMap.entries.map((entry) => _buildWarehouseCard(entry.key, entry.value, allProducts.toList())),
          ],
        );
      },
    );
  }

  // کارت‌های آمار کلی
  Widget _buildSummaryStats(int warehouses, int products, int total) {
    return Row(
      children: [
        Expanded(child: _MiniStatCard(title: 'تعداد انبارها', value: '$warehouses', color: _blue, icon: Icons.warehouse_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStatCard(title: 'نوع کالا', value: '$products', color: _purple, icon: Icons.category_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStatCard(title: 'موجودی کل', value: '$total', color: _orange, icon: Icons.inventory_rounded)),
      ],
    );
  }

  // کارت انبار (طراحی حرفه‌ای شده)
  Widget _buildWarehouseCard(String warehouseName, Map<String, int> products, List<String> allProductNames) {
    final int warehouseTotal = products.values.fold(0, (a, b) => a + b);
    // پیدا کردن بالاترین موجودی برای محاسبه درصد پیشرفت
    final int maxCountInThisWarehouse = products.values.isNotEmpty ? products.values.fold(0, math.max) : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: _blue.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warehouse_rounded, color: _blue, size: 24),
          ),
          title: Text(
            warehouseName,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: _textGrey),
                const SizedBox(width: 4),
                Text(
                  '$warehouseTotal عدد کالا',
                  style: const TextStyle(color: _textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded, color: _green, size: 20),
          ),
          // نمایش محصولات داخل انبار با طراحی چشمنواز
          children: products.entries.map((entry) {
            final String productName = entry.key;
            final int count = entry.value;
            
            // رفع مشکل: اگر maxCountInThisWarehouse صفر باشد، progress را صفر قرار می‌دهیم
            final double progress = maxCountInThisWarehouse > 0 
                ? (count / maxCountInThisWarehouse).clamp(0.0, 1.0) 
                : 0.0;
            
            // انتخاب رنگ تصادفی بر اساس محصول (برای تنوع بصری)
            final Color barColor = _getProductColor(productName);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(productName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Text(
                        '$count عدد',
                        style: TextStyle(color: barColor, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // نوار پیشرفت مدرن
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: _surfaceLight,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,  // اکنون بین 0.0 و 1.0 خواهد بود
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [barColor.withOpacity(0.8), barColor]),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // تابع کمکی برای رنگ‌بندی کالاها
  Color _getProductColor(String name) {
    final colors = [_green, _orange, _blue, _purple, _red];
    return colors[name.hashCode.abs() % colors.length];
  }

  // ─────────────────────────────────────────
  //گزارش کاربران
  // ─────────────────────────────────────────
  Widget _buildUserReportsSection() {
    return _GlassMorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.people_alt_rounded, title: 'گزارش کاربران'),
          const SizedBox(height: 16),
          FutureBuilder<List<UserModel>>(
            future: _api.getUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator(color: _green)),
                );
              }
              final List<UserModel> users = snapshot.data ?? [];
              if (users.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('کاربری ثبت نشده', style: TextStyle(color: _textGrey.withOpacity(0.8), fontSize: 13)),
                  ),
                );
              }
              return Column(
                children: users.map((u) => _UserReportTile(user: u)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ویجت‌های کمکی reusable با طراحی حرفه‌ای
// ─────────────────────────────────────────────

/// تایل یک کاربر در لیست گزارش کاربران
class _UserReportTile extends StatelessWidget {
  final UserModel user;
  const _UserReportTile({required this.user});

  (String, Color) _roleInfo() {
    final role = user.role ?? '';
    return switch (role) {
      'MANAGER' => ('مدیر سیستم', _purple),
      'WAREHOUSE_KEEPER' => ('انباردار', _green),
      'DRIVER' => ('راننده', _blue),
      _ => (role, _textGrey),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (roleLabel, roleColor) = _roleInfo();
    final name = user.name ?? '';
    final warehouseName = user.warehouseName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _surfaceLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserReportScreen(
                  userId: user.id,
                  userName: name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(
                    name.isEmpty ? '?' : name.characters.first,
                    style: TextStyle(color: roleColor, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(
                        warehouseName != null ? '$roleLabel — انبار $warehouseName' : roleLabel,
                        style: TextStyle(color: _textGrey.withValues(alpha: 0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// کارت شیشه‌ای (Glassmorphism) برای یکپارچگی ظاهر
class _GlassMorphismCard extends StatelessWidget {
  final Widget child;
  const _GlassMorphismCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

/// عنوان سکشن‌ها
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _green, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// ویجت آمار کوچک (برای بخش خلاصه وضعیت انبار)
class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _MiniStatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: _textGrey, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ویجت انتخاب تاریخ (طراحی بازسازی شده)
// ─────────────────────────────────────────────
class MonthPickerDialog extends StatefulWidget {
  final Jalali initial;
  const MonthPickerDialog({super.key, required this.initial});
  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _year, _month;
  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _month = widget.initial.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        '${_year.toString().padLeft(2, '0')}/${_month.toString().padLeft(2, '0')}',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // روزهای هفته
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'].map((day) => SizedBox(
                width: 30,
                child: Text(day, textAlign: TextAlign.center, style: const TextStyle(color: _textGrey, fontSize: 12)),
              )).toList(),
            ),
            const SizedBox(height: 8),
            // شبکه تاریخ‌ها
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(_monthLength(), (i) {
                final day = i + 1;
                final isSelected = (widget.initial.day == day && widget.initial.month == _month);
                return GestureDetector(
                  onTap: () => Navigator.pop(context, Jalali(_year, _month, day)),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? _green.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? _green : Colors.white.withOpacity(0.05)),
                    ),
                    child: Center(
                      child: Text('$day', style: TextStyle(
                        color: isSelected ? _green : Colors.white,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      )),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: _green),
          onPressed: () => setState(() {
            _month--;
            if (_month < 1) { _month = 12; _year--; }
          }),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: _green),
          onPressed: () => setState(() {
            _month++;
            if (_month > 12) { _month = 1; _year++; }
          }),
        ),
      ],
    );
  }
  int _monthLength() => Jalali(_year, _month, 1).monthLength;
}