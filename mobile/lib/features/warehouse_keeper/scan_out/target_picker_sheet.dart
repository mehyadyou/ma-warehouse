import 'package:flutter/material.dart';
import '../models/scan_out_result_model.dart';

const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);

/// برگهٔ انتخاب هدف خروج — وقتی چند سفارش/دستور فعال برای یک کالا/مدل وجود دارد
/// (اسکن QR/سریال و خروج دستی). روی هر گزینه → [Navigator.pop] با همان هدف.
class TargetPickerSheet extends StatelessWidget {
  final List<ScanOutTargetModel> candidates;
  final String productLabel;

  const TargetPickerSheet({
    super.key,
    required this.candidates,
    required this.productLabel,
  });

  @override
  Widget build(BuildContext context) {
    final orders = candidates.where((c) => c.kind == 'order').toList();
    final transfers = candidates.where((c) => c.kind == 'transfer').toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rule_rounded, color: _orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('کدام هدف؟',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('چند مقصد فعال برای «$productLabel» — یکی را انتخاب کنید',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (orders.isNotEmpty) ...[
                    _sectionTitle('سفارش‌ها', Icons.receipt_long_rounded, _green),
                    ...orders.map((o) => _item(
                          context,
                          o,
                          icon: Icons.receipt_long_rounded,
                          color: _green,
                          title: o.orderNumber != null ? 'سفارش شماره ${o.orderNumber}' : 'سفارش',
                          subtitle: [
                            if (o.receiverName?.isNotEmpty ?? false) o.receiverName!,
                            if (o.city?.isNotEmpty ?? false) o.city!,
                            if (o.carrier?.isNotEmpty ?? false) o.carrier!,
                          ].join(' — '),
                        )),
                    if (transfers.isNotEmpty) const SizedBox(height: 10),
                  ],
                  if (transfers.isNotEmpty) ...[
                    _sectionTitle('دستورات خروج/جابه‌جایی', Icons.swap_horizontal_circle_rounded, _orange),
                    ...transfers.map((t) {
                      final modelName = t.modelName;
                      return _item(
                        context,
                        t,
                        icon: Icons.swap_horizontal_circle_rounded,
                        color: _orange,
                        title: [
                          if (t.productName.isNotEmpty) t.productName,
                          if ((modelName ?? '').isNotEmpty) '($modelName)',
                        ].join(' '),
                        subtitle: [
                          if (t.quantity != null) '${t.quantity} واحد',
                          if (t.toWarehouseName?.isNotEmpty ?? false)
                            'انتقال به ${t.toWarehouseName}',
                          'دستور مدیر',
                        ].join(' — '),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('انصراف', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _item(
    BuildContext context,
    ScanOutTargetModel target, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context, target),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11.5)),
                  ],
                ]),
              ),
              Icon(Icons.chevron_left_rounded, color: Colors.white.withOpacity(0.3), size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}