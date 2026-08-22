import 'package:flutter/material.dart';

import '../../core/palette.dart';
import '../../widgets/accordion_item.dart';
import '../../widgets/app_widgets.dart';

class GroupKey {
  const GroupKey(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  bool operator ==(Object other) =>
      other is GroupKey && other.title == title && other.subtitle == subtitle;

  @override
  int get hashCode => Object.hash(title, subtitle);
}

typedef GroupEntry = (GroupKey, List<Map<String, dynamic>>);

String _entryDate(Map<String, dynamic> carton) {
  final raw = carton['createdAt']?.toString() ?? '';
  return raw.length > 10
      ? raw.substring(0, 10)
      : (raw.isEmpty ? 'نامشخص' : raw);
}

GroupKey _groupKey(Map<String, dynamic> carton) {
  final model = carton['model'];
  final modelName = model is Map<String, dynamic>
      ? (model['name']?.toString() ?? 'بدون مدل')
      : 'بدون مدل';
  final product = carton['product'];
  final productName = product is Map<String, dynamic>
      ? (product['name']?.toString() ?? 'بدون محصول')
      : 'بدون محصول';
  return GroupKey(
    modelName,
    '$productName | تاریخ ورود: ${_entryDate(carton)}',
  );
}

@visibleForTesting
List<GroupEntry> groupCartonsByLabel(List<Map<String, dynamic>> cartons) {
  final groups = <GroupKey, List<Map<String, dynamic>>>{};
  for (final carton in cartons) {
    groups.putIfAbsent(_groupKey(carton), () => []).add(carton);
  }
  return [for (final entry in groups.entries) (entry.key, entry.value)];
}

class CartonsTab extends StatefulWidget {
  const CartonsTab({
    super.key,
    required this.fetch,
    required this.initialSummary,
    required this.emptySummary,
    required this.emptyState,
    required this.summary,
    required this.errorSummary,
  });

  final Future<List<dynamic>> Function() fetch;
  final String initialSummary;
  final String emptySummary;
  final String emptyState;
  final String Function(int groups, int total) summary;
  final String errorSummary;

  @override
  State<CartonsTab> createState() => CartonsTabState();
}

class CartonsTabState extends State<CartonsTab> {
  final List<Widget> _items = [];
  String _summary = '';
  bool _loading = false;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    _summary = widget.initialSummary;
    WidgetsBinding.instance.addPostFrameCallback((_) => reload());
  }

  Future<void> reload() async {
    setState(() {
      _loading = true;
      _summary = 'در حال بارگذاری...';
    });
    try {
      final raw = await widget.fetch();
      final cartons = raw.whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
      final groups = groupCartonsByLabel(cartons);
      if (mounted) {
        setState(() {
          _loading = false;
          _loadedOnce = true;
          _items.clear();
          if (groups.isEmpty) {
            _summary = widget.emptySummary;
            _items.add(StateLabel(widget.emptyState));
          } else {
            final total = groups.fold<int>(
              0,
              (sum, entry) => sum + entry.$2.length,
            );
            _summary = widget.summary(groups.length, total);
            for (final entry in groups) {
              _items.add(
                AccordionItem(
                  title: entry.$1.title,
                  subtitle: entry.$1.subtitle,
                  cartons: entry.$2,
                ),
              );
            }
          }
        });
      }
    } catch (exc) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadedOnce = true;
          _summary = widget.errorSummary;
          _items
            ..clear()
            ..add(StateLabel(exc.toString()));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _summary,
                  style: const TextStyle(
                    color: Palette.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              AppButton(
                label: 'بارگذاری مجدد',
                variant: AppButtonVariant.secondary,
                onPressed: reload,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_loading && !_loadedOnce)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: Palette.primary),
                  )
                else
                  for (final item in _items) ...[
                    item,
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
