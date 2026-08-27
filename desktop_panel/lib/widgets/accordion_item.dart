import 'package:flutter/material.dart';

import '../core/label_data.dart';
import '../core/palette.dart';
import '../printing/pdf_labels.dart';
import 'app_widgets.dart';
import 'qr_label_widget.dart';

class LabelCard extends StatefulWidget {
  const LabelCard({
    super.key,
    required this.carton,
    required this.onSelectionChanged,
    this.onPrinted,
  });

  final Map<String, dynamic> carton;
  final VoidCallback onSelectionChanged;

  /// بعد از موفقیت چاپ صدا زده می‌شود تا کارتن به «چاپ شده‌ها» منتقل شود
  final void Function(List<String> cartonIds)? onPrinted;

  @override
  State<LabelCard> createState() => _LabelCardState();
}

class _LabelCardState extends State<LabelCard> {
  bool _selected = false;
  late final LabelData _data = LabelData.fromCarton(widget.carton);

  String get cartonId => widget.carton['id']?.toString() ?? '';

  Future<void> _printSingle() async {
    final ok = await PdfLabels.printLabels([_data]);
    if (ok) widget.onPrinted?.call([cartonId]);
  }

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
          QRLabelWidget(data: _data),
        ],
      ),
    );
  }

  void setSelected(bool selected) {
    if (_selected != selected) {
      setState(() => _selected = selected);
    }
  }

  bool isSelected() => _selected;
}

class AccordionItem extends StatefulWidget {
  const AccordionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cartons,
    this.onPrinted,
  });

  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> cartons;

  /// بعد از موفقیت چاپ صدا زده می‌شود تا کارتن‌ها به «چاپ شده‌ها» منتقل شوند
  final void Function(List<String> cartonIds)? onPrinted;

  @override
  State<AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<AccordionItem> {
  bool _isOpen = false;
  bool _contentLoaded = false;
  final List<GlobalKey<_LabelCardState>> _cardKeys = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(12),
            hoverColor: Palette.surfaceHover,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      _isOpen ? '▼' : '▶',
                      style: const TextStyle(
                        color: Palette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Palette.text,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            color: Palette.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CountBadge('${widget.cartons.length}'),
                ],
              ),
            ),
          ),
          if (_isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      AppButton(
                        label: 'چاپ انتخاب‌شده‌ها',
                        onPressed: _printSelected,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedCount()} از ${_cardKeys.length} لیبل انتخاب شده',
                    style: const TextStyle(
                      color: Palette.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < widget.cartons.length; i++)
                        LabelCard(
                          key: _cardKeyFor(i),
                          carton: widget.cartons[i],
                          onSelectionChanged: () => setState(() {}),
                          onPrinted: widget.onPrinted,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  GlobalKey<_LabelCardState> _cardKeyFor(int index) {
    while (_cardKeys.length <= index) {
      _cardKeys.add(GlobalKey<_LabelCardState>());
    }
    return _cardKeys[index];
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen && !_contentLoaded) {
      _contentLoaded = true;
    }
  }

  void _setAllSelected(bool selected) {
    for (final key in _cardKeys) {
      key.currentState?.setSelected(selected);
    }
    setState(() {});
  }

  int _selectedCount() =>
      _cardKeys.where((key) => key.currentState?.isSelected() ?? false).length;

  Future<void> _printSelected() async {
    final selectedCards = _cardKeys
        .where((key) => key.currentState?.isSelected() ?? false)
        .toList();
    if (selectedCards.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Palette.surfaceAlt,
          title: const Text(
            'چاپ لیبل',
            style: TextStyle(color: Palette.text, fontSize: 15),
          ),
          content: const Text(
            'ابتدا حداقل یک لیبل را انتخاب کنید.',
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
    final labels = selectedCards
        .map((key) => key.currentState!._data)
        .toList();
    final ok = await PdfLabels.printLabels(labels);
    if (ok) {
      widget.onPrinted?.call(
        selectedCards.map((key) => key.currentState!.cartonId).toList(),
      );
    }
  }
}
