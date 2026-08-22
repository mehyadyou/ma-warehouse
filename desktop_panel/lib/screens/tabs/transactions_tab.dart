import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/api_service.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';

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
      final raw = await widget.api.getTransactions(date: dateFilter);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _rows.addAll(raw.whereType<Map<String, dynamic>>());
        _status = dateFilter != null
            ? '${_rows.length} تراکنش برای تاریخ $dateFilter نمایش داده شد.'
            : '${_rows.length} تراکنش اخیر نمایش داده شد.';
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
                    _BodyCell(_rows[i]['type'] == 'IN' ? 'ورود' : 'خروج'),
                    _BodyCell(_rows[i]['productName']?.toString() ?? '—'),
                    _BodyCell(_rows[i]['quantity']?.toString() ?? '0'),
                    _BodyCell(_rows[i]['userName']?.toString() ?? '—'),
                    _BodyCell(_dateOnly(_rows[i]['createdAt'])),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  String _dateOnly(dynamic value) {
    final raw = value?.toString() ?? '';
    return raw.length > 10 ? raw.substring(0, 10) : (raw.isEmpty ? '—' : raw);
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
