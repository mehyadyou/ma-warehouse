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

/// تعداد واحد موجودی یک کارتن: تکی = ۱، کارتن = ظرفیت بسته (unitsPerBox)
int unitsOfCarton(Map<String, dynamic> carton) {
  if (carton['isIndividual'] == true) return 1;
  final model = carton['model'];
  if (model is Map<String, dynamic>) {
    final cap = model['unitsPerBox'];
    if (cap is num) return cap.toInt();
  }
  final cap = carton['capacityPerBox'];
  if (cap is num) return cap.toInt();
  return 0;
}

/// واحد نمایش محصول (مثل «عدد») — از واحد تعریف‌شدهٔ مدیر
String unitOfCartons(List<Map<String, dynamic>> cartons) {
  if (cartons.isEmpty) return 'عدد';
  final product = cartons.first['product'];
  if (product is Map<String, dynamic>) {
    final unit = product['unit']?.toString().trim() ?? '';
    if (unit.isNotEmpty) return unit;
  }
  return 'عدد';
}

String _entryDate(Map<String, dynamic> carton) {
  final raw = carton['createdAt']?.toString() ?? '';
  return raw.length > 10
      ? raw.substring(0, 10)
      : (raw.isEmpty ? 'نامشخص' : raw);
}

GroupKey _groupKey(
  Map<String, dynamic> carton, {
  required bool groupByDate,
}) {
  final model = carton['model'];
  final modelName = model is Map<String, dynamic>
      ? (model['name']?.toString() ?? 'بدون مدل')
      : 'بدون مدل';
  final product = carton['product'];
  final productName = product is Map<String, dynamic>
      ? (product['name']?.toString() ?? 'بدون محصول')
      : 'بدون محصول';
  // با groupByDate=false تاریخ در کلید گروه نمی‌آید تا مدل تکراریِ همان محصول
  // در همان ستون جمع شود و ستون جدید ساخته نشود
  final subtitle = groupByDate
      ? '$productName | تاریخ ورود: ${_entryDate(carton)}'
      : productName;
  return GroupKey(modelName, subtitle);
}

@visibleForTesting
List<GroupEntry> groupCartonsByLabel(
  List<Map<String, dynamic>> cartons, {
  bool groupByDate = true,
}) {
  final groups = <GroupKey, List<Map<String, dynamic>>>{};
  for (final carton in cartons) {
    groups
        .putIfAbsent(
          _groupKey(carton, groupByDate: groupByDate),
          () => [],
        )
        .add(carton);
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
    this.groupByDate = true,
    this.showExitedBadge = false,
    this.onAddProduct,
    this.onPrinted,
  });

  final Future<List<dynamic>> Function() fetch;
  final String initialSummary;
  final String emptySummary;
  final String emptyState;
  final String Function(int groups, int total) summary;
  final String errorSummary;

  /// false یعنی گروه‌بندی فقط بر اساس (محصول، مدل) و بدون تاریخ —
  /// مدل تکراریِ همان محصول در همان ستون جمع می‌شود
  final bool groupByDate;

  /// در تب خروجی‌ها (groupByDate=false): به‌جای «موجودی»، تعداد کل
  /// واحدِ خارج‌شدهٔ هر گروه نمایش داده می‌شود
  final bool showExitedBadge;

  /// اگر ست باشد، دکمه «افزودن محصول» بالای تب نمایش داده می‌شود
  final VoidCallback? onAddProduct;

  /// بعد از موفقیت چاپ صدا زده می‌شود تا کارتن‌ها به «چاپ شده‌ها» منتقل شوند
  final void Function(List<String> cartonIds)? onPrinted;

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
      final groups = groupCartonsByLabel(
        cartons,
        groupByDate: widget.groupByDate,
      );
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
              var subtitle = entry.$1.subtitle;
              // در تب محصولات، موجودی (به واحد) و تعداد لیبل/QR را نشان بده تا با
              // پنل انباردار هماهنگ باشد — فقط کارتن‌های در انبار شمرده می‌شوند؛
              // هر کارتن/تکی یک QR دارد ولی موجودی به واحد شمرده می‌شود
              if (!widget.groupByDate) {
                final units = entry.$2.fold<int>(
                  0,
                  (sum, carton) => sum + unitsOfCarton(carton),
                );
                subtitle = widget.showExitedBadge
                    ? '$subtitle | $units ${unitOfCartons(entry.$2)} خارج شده'
                    : '$subtitle | موجودی: $units ${unitOfCartons(entry.$2)} | ${entry.$2.length} لیبل (QR)';
              }
              _items.add(
                AccordionItem(
                  title: entry.$1.title,
                  subtitle: subtitle,
                  cartons: entry.$2,
                  onPrinted: widget.onPrinted,
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
              if (widget.onAddProduct != null) ...[
                AppButton(
                  label: 'افزودن محصول',
                  onPressed: widget.onAddProduct,
                ),
                const SizedBox(width: 8),
              ],
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
