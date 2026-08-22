import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _textGrey = Color(0xFF94A3B8);

/// دیالوگ انتخاب تاریخ شمسی (ماه‌نمای ساده) — مشترک بین صفحات مدیر.
/// امروز هایلایت می‌شود و انتخاب تاریخ آینده ممکن نیست.
Future<Jalali?> showJalaliMonthPicker(
  BuildContext context, {
  Jalali? initial,
}) {
  return showDialog<Jalali>(
    context: context,
    builder: (_) => JalaliMonthPicker(initial: initial ?? Jalali.now()),
  );
}

class JalaliMonthPicker extends StatefulWidget {
  final Jalali initial;
  const JalaliMonthPicker({super.key, required this.initial});

  @override
  State<JalaliMonthPicker> createState() => _JalaliMonthPickerState();
}

class _JalaliMonthPickerState extends State<JalaliMonthPicker> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _month = widget.initial.month;
  }

  int get _monthLength => Jalali(_year, _month, 1).monthLength;

  bool _isToday(int day) {
    final today = Jalali.now();
    return today.year == _year &&
        today.month == _month &&
        today.day == day;
  }

  bool _isFuture(int day) {
    final today = Jalali.now();
    if (_year != today.year) return _year > today.year;
    if (_month != today.month) return _month > today.month;
    return day > today.day;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month < 1) {
        _month = 12;
        _year--;
      } else if (_month > 12) {
        _month = 1;
        _year++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        '${_year.toString().padLeft(2, '0')}/${_month.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                  .map(
                    (day) => SizedBox(
                      width: 30,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _textGrey, fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(_monthLength, (i) {
                final day = i + 1;
                final isToday = _isToday(day);
                final isFuture = _isFuture(day);
                return GestureDetector(
                  onTap: isFuture
                      ? null
                      : () => Navigator.pop(context, Jalali(_year, _month, day)),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday
                          ? _green.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? _green
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isFuture
                              ? Colors.white.withValues(alpha: 0.15)
                              : isToday
                                  ? _green
                                  : Colors.white,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
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
        // نگه‌داشتن بلند: پرش ۱۲ ماه به عقب
        GestureDetector(
          onLongPress: () => _shiftMonth(-12),
          child: IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: _green),
            onPressed: () => _shiftMonth(-1),
          ),
        ),
        // نگه‌داشتن بلند: پرش ۱۲ ماه به جلو
        GestureDetector(
          onLongPress: () => _shiftMonth(12),
          child: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: _green),
            onPressed: () => _shiftMonth(1),
          ),
        ),
      ],
    );
  }
}