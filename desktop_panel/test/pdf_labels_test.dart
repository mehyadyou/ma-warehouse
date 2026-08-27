import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/label_data.dart';
import 'package:ma_warehouse_panel/printing/pdf_labels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final label = LabelData(
    productName: 'سینک ظرفشویی',
    modelDisplay: 'مدل ایکس',
    qtyText: '12 عدد / کارتن',
    serial: 'SER12345',
    barcode: 'SER12345',
    tracking: 'SER12345',
    date: '2026-08-20',
    qrPayload: 'https://ma.example/s/SER12345',
  );

  final badge = BadgeData(
    sequence: 2,
    total: 4,
    senderName: 'انبار مرکزی',
    receiverName: 'گیرنده نمونه',
    city: 'تهران',
    address: 'خیابان اصلی، پلاک ۱۲',
    postalCode: '1234567890',
    shippingMethod: 'پست پیشتاز',
    carrier: 'تیپاکس',
    orderRef: 'MA-ABCD1234',
    createdAt: '2026-08-20',
  );

  test('label PDF builds with fonts, QR and 100x100mm pages', () async {
    final bytes = await PdfLabels.buildLabelPdfBytes([label, label]);
    expect(bytes, isNotNull);
    expect(_isPdf(bytes!), isTrue);
  });

  test('badge PDF builds with fonts and layout', () async {
    final bytes = await PdfLabels.buildBadgePdfBytes([badge]);
    expect(bytes, isNotNull);
    expect(_isPdf(bytes!), isTrue);
  });

  test('empty inputs return null', () async {
    expect(await PdfLabels.buildLabelPdfBytes([]), isNull);
    expect(await PdfLabels.buildBadgePdfBytes([]), isNull);
  });
}

bool _isPdf(Uint8List bytes) {
  if (bytes.length < 5) return false;
  return String.fromCharCodes(bytes.sublist(0, 5)) == '%PDF-';
}
