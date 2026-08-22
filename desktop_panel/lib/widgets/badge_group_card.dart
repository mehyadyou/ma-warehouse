import 'package:flutter/material.dart';

import '../core/label_data.dart';
import '../core/palette.dart';
import '../printing/pdf_labels.dart';
import 'app_widgets.dart';
import 'badge_sheet_widget.dart';

class BadgeSheetCard extends StatefulWidget {
  const BadgeSheetCard({
    super.key,
    required this.badge,
    required this.groupTotal,
    required this.onSelectionChanged,
  });

  final Map<String, dynamic> badge;
  final int groupTotal;
  final VoidCallback onSelectionChanged;

  @override
  State<BadgeSheetCard> createState() => _BadgeSheetCardState();
}

class _BadgeSheetCardState extends State<BadgeSheetCard> {
  bool _selected = false;
  late final BadgeData _data = BadgeData.fromBadge(
    widget.badge,
    total: widget.groupTotal,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _selected,
                onChanged: (value) {
                  setState(() => _selected = value ?? false);
                  widget.onSelectionChanged();
                },
                activeColor: Palette.primary,
                checkColor: Colors.black,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Flexible(
                child: Text(
                  'انتخاب برای چاپ',
                  style: TextStyle(color: Palette.text, fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              AppButton(
                label: 'چاپ تکی',
                variant: AppButtonVariant.secondary,
                compact: true,
                onPressed: _printSingle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          BadgeSheetWidget(data: _data),
        ],
      ),
    );
  }

  void _printSingle() {
    if (_data.missingReceiver) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Palette.surfaceAlt,
          title: const Text(
            'چاپ بیجک',
            style: TextStyle(color: Palette.text, fontSize: 15),
          ),
          content: const Text(
            'اطلاعات گیرنده این بیجک کامل نیست.',
            style: TextStyle(color: Palette.textMuted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'باشه',
                style: TextStyle(color: Palette.primary),
              ),
            ),
          ],
        ),
      );
      return;
    }
    PdfLabels.printBadges([_data]);
  }

  void setSelected(bool selected) {
    if (_selected != selected) {
      setState(() => _selected = selected);
    }
  }

  bool isSelected() => _selected;
}

class BadgeGroupCard extends StatefulWidget {
  const BadgeGroupCard({
    super.key,
    required this.orderId,
    required this.badges,
  });

  final String orderId;
  final List<Map<String, dynamic>> badges;

  @override
  State<BadgeGroupCard> createState() => _BadgeGroupCardState();
}

class _BadgeGroupCardState extends State<BadgeGroupCard> {
  final List<GlobalKey<_BadgeSheetCardState>> _cardKeys = [];

  @override
  Widget build(BuildContext context) {
    final order =
        widget.badges.isNotEmpty &&
            widget.badges.first['order'] is Map<String, dynamic>
        ? widget.badges.first['order'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final warehouse = order['warehouse'] is Map<String, dynamic>
        ? order['warehouse'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final warehouseName = warehouse['name'] is String
        ? warehouse['name'] as String
        : 'انبار نامشخص';
    final status = order['status'] is String
        ? order['status'] as String
        : 'PENDING';
    final statusLabel = orderStatusLabels[status] ?? status;
    final createdAt = widget.badges.isNotEmpty
        ? _first10String(widget.badges.first['createdAt'])
        : 'نامشخص';

    return Container(
      decoration: BoxDecoration(
        color: Palette.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${shortOrderId(widget.orderId)} — سفارش $warehouseName',
                      style: const TextStyle(
                        color: Palette.text,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'وضعیت: $statusLabel | تاریخ ثبت: $createdAt',
                      style: const TextStyle(
                        color: Palette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              CountBadge('${widget.badges.length} بیجک'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AppButton(
                label: 'انتخاب همه',
                variant: AppButtonVariant.secondary,
                onPressed: () => _setAllSelected(true),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'لغو انتخاب',
                variant: AppButtonVariant.secondary,
                onPressed: () => _setAllSelected(false),
              ),
              const SizedBox(width: 8),
              AppButton(label: 'چاپ انتخاب‌شده‌ها', onPressed: _printSelected),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedCount()} از ${widget.badges.length} بیجک انتخاب شده',
            style: const TextStyle(color: Palette.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < widget.badges.length; i++)
                BadgeSheetCard(
                  key: _cardKeyFor(i),
                  badge: widget.badges[i],
                  groupTotal: widget.badges.length,
                  onSelectionChanged: () => setState(() {}),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _first10String(dynamic value) {
    final str = value is String ? value : (value?.toString() ?? '');
    if (str.isEmpty) return 'نامشخص';
    return str.length > 10 ? str.substring(0, 10) : str;
  }

  GlobalKey<_BadgeSheetCardState> _cardKeyFor(int index) {
    while (_cardKeys.length <= index) {
      _cardKeys.add(GlobalKey<_BadgeSheetCardState>());
    }
    return _cardKeys[index];
  }

  void _setAllSelected(bool selected) {
    for (final key in _cardKeys) {
      key.currentState?.setSelected(selected);
    }
    setState(() {});
  }

  int _selectedCount() =>
      _cardKeys.where((key) => key.currentState?.isSelected() ?? false).length;

  void _printSelected() {
    final selected = _cardKeys
        .where((key) => key.currentState?.isSelected() ?? false)
        .map((key) => key.currentState!._data)
        .toList();
    if (selected.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Palette.surfaceAlt,
          title: const Text(
            'چاپ بیجک',
            style: TextStyle(color: Palette.text, fontSize: 15),
          ),
          content: const Text(
            'ابتدا حداقل یک بیجک را انتخاب کنید.',
            style: TextStyle(color: Palette.textMuted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'باشه',
                style: TextStyle(color: Palette.primary),
              ),
            ),
          ],
        ),
      );
      return;
    }
    PdfLabels.printBadges(selected);
  }
}
