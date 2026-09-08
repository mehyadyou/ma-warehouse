import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../core/palette.dart';

/// دراپ‌داون انتخاب چاپگر ذخیره‌شده — فهرست واقعی چاپگرهای ویندوز.
/// مقدار خالی یعنی «دیالوگ سیستمی» (رفتار قبلی).
class PrinterDropdown extends StatelessWidget {
  const PrinterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'چاپگر',
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Printer>>(
      future: Printing.listPrinters(),
      builder: (context, snapshot) {
        final printers = snapshot.data ?? const <Printer>[];
        // نام ذخیره‌شده‌ای که دیگر نصب نیست هم در لیست بماند تا کاربر بفهمد
        final names = <String>{
          for (final p in printers) p.name,
          if (value.isNotEmpty) value,
        }.toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Palette.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Palette.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Palette.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value.isEmpty ? null : value,
                  hint: Text(
                    snapshot.connectionState == ConnectionState.waiting
                        ? 'در حال یافتن چاپگرها…'
                        : 'پیش‌فرض ویندوز (دیالوگ چاپ)',
                    style: const TextStyle(
                        color: Palette.textMuted, fontSize: 13),
                  ),
                  isExpanded: true,
                  dropdownColor: Palette.surfaceAlt,
                  style:
                      const TextStyle(color: Palette.text, fontSize: 13),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('پیش‌فرض ویندوز (دیالوگ چاپ)'),
                    ),
                    for (final n in names)
                      DropdownMenuItem<String>(
                        value: n,
                        child: Text(
                          n,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => onChanged(v ?? ''),
                ),
              ),
            ),
            if (snapshot.hasError)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'فهرست چاپگرها خوانده نشد — نام را دستی در نظر بگیرید',
                  style: TextStyle(color: Palette.textMuted, fontSize: 11),
                ),
              ),
          ],
        );
      },
    );
  }
}
