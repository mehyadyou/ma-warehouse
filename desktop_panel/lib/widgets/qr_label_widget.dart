import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/label_data.dart';
import 'app_widgets.dart';

class QRLabelWidget extends StatelessWidget {
  const QRLabelWidget({super.key, required this.data});

  final LabelData data;

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
          QrImageView(
            data: data.qrPayload,
            version: QrVersions.auto,
            size: 95,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
          const DashedDivider(),
          _InfoRow(label: 'مدل', value: data.modelDisplay),
          _InfoRow(label: 'تعداد', value: data.qtyText),
          _InfoRow(label: 'سریال', value: data.serial),
          _InfoRow(label: 'تاریخ', value: data.date),
          const DashedDivider(),
          SizedBox(
            height: 22,
            child: Center(
              child: Text(
                '*${data.barcode}*',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'Courier New',
                ),
              ),
            ),
          ),
          SizedBox(
            height: 14,
            child: Center(
              child: Text(
                data.tracking,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 6,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
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
    return SizedBox(
      height: 18,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Text(
              '▸ $label',
              style: const TextStyle(color: Colors.black, fontSize: 7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
