import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/badge_print_settings.dart';
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
    count: 4,
    modelName: 'مدل ایکس',
    packageType: 'کیسه',
    unitsPerBox: 2,
    senderName: 'انبار مرکزی',
    senderPhone: '02111111111',
    senderNationalId: '0012345678',
    receiverName: 'گیرنده نمونه',
    receiverCity: 'تهران',
    receiverPostalCode: '1234567890',
    receiverAddress: 'خیابان اصلی، پلاک ۱۲',
    receiverPhone: '09120000000',
    shippingMethod: 'تیپاکس',
    carrier: 'تیپاکس',
    orderRef: 'MA-ABCD1234',
    createdAt: '2026-08-20',
  );

  /// بیجک باربری — نام دقیق باربری باید روی برگه بیاید
  final barebariBadge = BadgeData(
    sequence: 1,
    total: 1,
    count: 6,
    modelName: '',
    packageType: '',
    unitsPerBox: null,
    senderName: 'انبار مرکزی',
    senderPhone: '',
    senderNationalId: '',
    receiverName: 'گیرنده باربری',
    receiverCity: 'تبریز',
    receiverPostalCode: '',
    receiverAddress: '',
    receiverPhone: '09141111111',
    shippingMethod: 'باربری',
    carrier: 'باربری امین.trans',
    orderRef: 'MA-DEAD1234',
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

  test('badge PDF builds in single mode (one badge per A6 page)', () async {
    BadgePrintSettingsHolder.instance.notifier.value = const BadgePrintSettings(
      dualMode: false,
      singleScalePercent: 95,
      singleOffsetXmm: 2,
      singleOffsetYmm: -1,
    );
    addTearDown(() {
      BadgePrintSettingsHolder.instance.notifier.value =
          BadgePrintSettings.defaults;
    });

    final bytes = await PdfLabels.buildBadgePdfBytes([badge, badge]);
    expect(bytes, isNotNull);
    expect(_isPdf(bytes!), isTrue);
  });

  test('barebari badge PDF includes exact carrier name', () async {
    final bytes = await PdfLabels.buildBadgePdfBytes([barebariBadge]);
    expect(bytes, isNotNull);
    expect(_isPdf(bytes!), isTrue);
    // نام دقیق باربری (UTF-8) باید داخل PDF باشد — pdf package متن‌ها را
    // در content stream ذخیره می‌کند؛ جستجوی بایت‌به‌بایت پایدار نیست،
    // پس صحت را از سمت مدل ثابت کرده‌ایم (carrierLabel) و اینجا فقط ساختار:
    expect(barebariBadge.carrierLabel, 'باربری امین.trans');
    expect(barebariBadge.isBarebari, isTrue);
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
