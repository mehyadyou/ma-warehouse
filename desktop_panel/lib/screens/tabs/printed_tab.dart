import 'package:flutter/material.dart';

import '../../core/palette.dart';

/// تب «چاپ شده‌ها» — بالای آن فیلتری بین لیبل‌های چاپ‌شده و بیجک‌های چاپ‌شده دارد
class PrintedTab extends StatefulWidget {
  const PrintedTab({
    super.key,
    required this.labelsTab,
    required this.badgesTab,
  });

  /// نمای لیبل‌های چاپ‌شده (CartonsTab با fetch چاپ‌شده‌ها)
  final Widget labelsTab;

  /// نمای بیجک‌های چاپ‌شده (BadgesTab با printed=true)
  final Widget badgesTab;

  @override
  State<PrintedTab> createState() => _PrintedTabState();
}

class _PrintedTabState extends State<PrintedTab> {
  bool _showBadges = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              const Text(
                'نمایش:',
                style: TextStyle(color: Palette.textMuted, fontSize: 13),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'لیبل',
                active: !_showBadges,
                onTap: () => setState(() => _showBadges = false),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'بیجک',
                active: _showBadges,
                onTap: () => setState(() => _showBadges = true),
              ),
            ],
          ),
        ),
        Expanded(child: _showBadges ? widget.badgesTab : widget.labelsTab),
      ],
    );
  }

  Widget _chip({
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? Palette.primary : Palette.border,
            ),
          ),
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
}
