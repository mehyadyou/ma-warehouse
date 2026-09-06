import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/api_service.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';

/// فیلترهای نوع تراکنش در تب تاریخچه — هر کدام به یک TransactionType سرور نگاشت می‌شود
class TypeFilter {
  const TypeFilter(this.label, this.value);
  final String label;
  final String? value; // null یعنی بدون فیلتر (همه)
}

const _typeFilters = <TypeFilter>[
  TypeFilter('همه', null),
  TypeFilter('ورودی‌ها', 'IN'),
  TypeFilter('خروجی‌ها', 'OUT'),
  TypeFilter('مرجوعی‌ها', 'RETURN'),
];

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key, required this.api});

  final ApiService api;

  @override
  State<TransactionsTab> createState() => TransactionsTabState();
}

class TransactionsTabState extends State<TransactionsTab> {
  int _year = Jalali.now().year;
  int _month = Jalali.now().month;
  int _day = Jalali.now().day;
  String? _type; // مقدار TransactionType یا null

  String _status = '';
  final List<Map<String, dynamic>> _rows = [];
  bool _loading = false;

  List<int> get _years {
    final now = Jalali.now().year;
    return [for (var y = now - 15; y <= now + 1; y++) y];
  }

  int _daysInMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return Jalali(year, 12, 1).isLeapYear() ? 30 : 29;
  }

  String get _selectedGregorianDate {
    final jalali = Jalali(_year, _month, _day);
    final dt = jalali.toDateTime();
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    reloadLatest();
  }

  Future<void> reloadLatest() => _load(null);

  Future<void> _load(String? dateFilter) async {
    setState(() {
      _loading = true;
      _rows.clear();
    });
    try {
      final raw = await widget.api.getTransactions(
        date: dateFilter,
        type: _type,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _rows.addAll(raw.whereType<Map<String, dynamic>>());
        final typeLabel =
            _typeFilters.firstWhere((f) => f.value == _type).label;
        _status = dateFilter != null
            ? '${_rows.length} تراکنش $typeLabel برای تاریخ $_selectedGregorianDate'
            : '${_rows.length} تراکنش $typeLabel اخیر';
      });
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _rows.clear();
        _status = 'خطا در بارگذاری تاریخچه: $exc';
      });
    }
  }

  void _search() {
    if (_day > _daysInMonth(_year, _month)) {
      _day = _daysInMonth(_year, _month);
    }
    _load(_selectedGregorianDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'تاریخ:',
                  style: TextStyle(color: Palette.textMuted, fontSize: 13),
                ),
                const SizedBox(width: 8),
                _dateDropdown(
                  value: _day,
                  values: [for (var d = 1; d <= 31; d++) d],
                  onChanged: (v) => setState(() => _day = v),
                ),
                _dateDropdown(
                  value: _month,
                  values: [for (var m = 1; m <= 12; m++) m],
                  onChanged: (v) => setState(() => _month = v),
                ),
                _dateDropdown(
                  value: _year,
                  values: _years,
                  onChanged: (v) => setState(() => _year = v),
                ),
                const SizedBox(width: 8),
                AppButton(label: 'جستجو', onPressed: _search),
                const SizedBox(width: 8),
                AppButton(
                  label: 'آخرین 50 تراکنش',
                  variant: AppButtonVariant.secondary,
                  onPressed: reloadLatest,
                ),
                const SizedBox(width: 12),
                Divider(
                  height: 20,
                  thickness: 1,
                  color: Palette.border,
                ),
                const SizedBox(width: 8),
                for (final f in _typeFilters) ...[
                  _typeChip(
                    label: f.label,
                    active: _type == f.value,
                    onTap: () {
                      setState(() => _type = f.value);
                      reloadLatest();
                    },
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _status,
              style: const TextStyle(color: Palette.textMuted, fontSize: 12),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Palette.primary),
                  )
                : _buildTable(),
          ),
        ),
      ],
    );
  }

  Widget _typeChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active ? Palette.primary : Palette.surfaceAlt,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Palette.surfaceHover,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Palette.textMuted,
              fontSize: 12,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateDropdown({
    required int value,
    required List<int> values,
    required ValueChanged<int> onChanged,
  }) {
    return Material(
      color: Palette.surfaceAlt,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Palette.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            dropdownColor: Palette.surfaceAlt,
            style: const TextStyle(color: Palette.text, fontSize: 13),
            items: [
              for (final v in values)
                DropdownMenuItem(value: v, child: Text('$v')),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Palette.surfaceHover),
              children: [
                _HeaderCell('نوع'),
                _HeaderCell('محصول'),
                _HeaderCell('تعداد'),
                _HeaderCell('توسط'),
                _HeaderCell('تاریخ'),
              ],
            ),
            if (_rows.isEmpty)
              const TableRow(
                children: [
                  _BodyCell('—'),
                  _BodyCell('—'),
                  _BodyCell('—'),
                  _BodyCell('—'),
                  _BodyCell('—'),
                ],
              )
            else
              for (var i = 0; i < _rows.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    color: i.isOdd
                        ? Palette.text.withValues(alpha: 0.03)
                        : Colors.transparent,
                  ),
                  children: [
                    _BodyCell(_typeLabel(_rows[i]['type'])),
                    _BodyCell(_rows[i]['productName']?.toString() ?? '—'),
                    _BodyCell(_rows[i]['quantity']?.toString() ?? '0'),
                    _BodyCell(_rows[i]['userName']?.toString() ?? '—'),
                    _BodyCell(_toJalali(_rows[i]['createdAt'])),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(dynamic type) {
    switch (type?.toString()) {
      case 'IN':
        return 'ورودی';
      case 'OUT':
        return 'خروجی';
      case 'RETURN':
        return 'مرجوعی';
      default:
        return type?.toString() ?? '—';
    }
  }

  /// تاریخ میلادی (ISO) را به شمسی تبدیل و با ارقام فارسی دو رقمِ اول را حذف نمی‌کند؛
  /// در قالب «۱۴۰۴/۰۵/۲۵» نمایش می‌دهد
  String _toJalali(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '—';
    // createdAt اغلب ISO با میکروثانیه و Z است — بخش تاریخ را جدا می‌کنیم
    final datePart = raw.contains('T') ? raw.substring(0, 10) : raw;
    final parts = datePart.split('-');
    if (parts.length != 3) return datePart;
    final yr = int.tryParse(parts[0]);
    final mo = int.tryParse(parts[1]);
    final dy = int.tryParse(parts[2]);
    if (yr == null || mo == null || dy == null) return datePart;
    final j = Jalali.fromDateTime(DateTime(yr, mo, dy));
    return '${_faDigits('${j.year}')}/${_faDigits(_two(j.month))}/${_faDigits(_two(j.day))}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  String _faDigits(String s) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    return s.split('').map((c) {
      final i = int.tryParse(c);
      return i == null ? c : fa[i];
    }).join();
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Palette.textMuted, fontSize: 13),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Palette.text, fontSize: 13),
      ),
    );
  }
}