import 'package:flutter/material.dart';

import '../core/label_data.dart';
import 'app_widgets.dart';

class BadgeSheetWidget extends StatelessWidget {
  const BadgeSheetWidget({super.key, required this.data});

  final BadgeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 300,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Container(
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: const Text(
              'MA WAREHOUSE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 20,
            child: Center(
              child: Text(
                'بیجک سفارش ${data.sequence} از ${data.total}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 14,
            child: Center(
              child: Text(
                'برگه بیجک',
                style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 7),
              ),
            ),
          ),
          const DashedDivider(),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  _InfoRow(label: 'فرستنده', value: data.senderName),
                  _InfoRow(label: 'گیرنده', value: data.receiverName),
                  _InfoRow(label: 'شهر', value: data.city),
                  _InfoRow(label: 'آدرس', value: data.address),
                  _InfoRow(label: 'کد پستی', value: data.postalCode),
                  _InfoRow(label: 'شیوه ارسال', value: data.shippingMethod),
                  _InfoRow(label: 'باربری', value: data.carrier),
                ],
              ),
            ),
          ),
          const DashedDivider(),
          SizedBox(
            height: 16,
            child: Center(
              child: Text(
                data.orderRef,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'Courier New',
                ),
              ),
            ),
          ),
          SizedBox(
            height: 12,
            child: Center(
              child: Text(
                'MA-BADGE  |  ${data.createdAt}',
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 6,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '▸ $label',
            style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 7),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
