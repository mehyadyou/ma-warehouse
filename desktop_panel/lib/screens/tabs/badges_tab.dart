import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/badge_group_card.dart';

@visibleForTesting
List<(String, List<Map<String, dynamic>>)> groupBadgesByOrder(
  List<Map<String, dynamic>> badges,
) {
  final groups = <String, List<Map<String, dynamic>>>{};
  for (final badge in badges) {
    final orderId = badge['orderId']?.toString() ?? 'بدون سفارش';
    groups.putIfAbsent(orderId, () => []).add(badge);
  }
  for (final items in groups.values) {
    items.sort(
      (a, b) => (a['createdAt']?.toString() ?? '').compareTo(
        b['createdAt']?.toString() ?? '',
      ),
    );
    for (var i = 0; i < items.length; i++) {
      items[i] = {...items[i], 'sequence': i + 1, 'total': items.length};
    }
  }
  return [for (final entry in groups.entries) (entry.key, entry.value)];
}

class BadgesTab extends StatefulWidget {
  const BadgesTab({super.key, required this.api, this.printed = false, this.onPrinted});

  final ApiService api;

  /// false = فقط بیجک‌های چاپ‌نشده (منوی «بیجک») |
  /// true = فقط بیجک‌های چاپ‌شده (تب «چاپ شده‌ها»)
  final bool printed;

  /// بعد از موفقیت چاپ صدا زده می‌شود تا بیجک‌ها به «چاپ شده‌ها» منتقل شوند
  final void Function(List<String> badgeIds)? onPrinted;

  @override
  State<BadgesTab> createState() => BadgesTabState();
}

class BadgesTabState extends State<BadgesTab> {
  final List<Widget> _groups = [];
  String _summary = 'بیجک‌های ثبت‌شده برای سفارش‌ها';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      _loading = true;
      _summary = 'در حال بارگذاری...';
    });
    try {
      final raw = await widget.api.getBadges(printed: widget.printed);
      final badges = raw.whereType<Map<String, dynamic>>().toList();
      final groups = groupBadgesByOrder(badges);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _groups.clear();
        if (groups.isEmpty) {
          _summary = widget.printed
              ? 'هیچ بیجکی چاپ نشده است.'
              : 'هیچ بیجکی ثبت نشده است.';
          _groups.add(
            StateLabel(
              widget.printed
                  ? 'بیجک‌های چاپ‌شده اینجا نمایش داده می‌شوند.'
                  : 'هنوز بیجکی برای سفارش‌ها ساخته نشده است.',
            ),
          );
        } else {
          final total = groups.fold<int>(
            0,
            (sum, entry) => sum + entry.$2.length,
          );
          _summary = widget.printed
              ? '${groups.length} سفارش | $total بیجک چاپ‌شده'
              : '${groups.length} سفارش | $total بیجک آماده چاپ';
          for (final entry in groups) {
            _groups.add(
              BadgeGroupCard(
                orderId: entry.$1,
                badges: entry.$2,
                onPrinted: widget.onPrinted,
              ),
            );
          }
        }
      });
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _summary = 'خطا در دریافت اطلاعات';
        _groups
          ..clear()
          ..add(StateLabel(exc.toString()));
      });
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
                onPressed: load,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: Palette.primary),
                  )
                else
                  for (final group in _groups) ...[
                    group,
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
