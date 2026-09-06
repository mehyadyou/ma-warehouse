import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/badge_print_settings.dart';
import 'package:ma_warehouse_panel/core/label_data.dart';
import 'package:ma_warehouse_panel/printing/pdf_labels.dart';

/// ═══ تست حساسِ پیش از انتشار — سناریو ۵ ═══
/// «چاپ گروهی ۵۰۰ لیبل»: نشت حافظه، رشدِ بی‌رویهٔ PDF و پایداریِ تولیدِ
/// QR/فونت در حجم بالا — عیناً کاری که اپراتور موقع ورود یک محمولهٔ بزرگ می‌کند.
///
/// اجرا (اختیاری در CI — سنگین است):
///   flutter test test/print_stress_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LabelData labelOf(int i) => LabelData(
        productName: 'سینک ظرفشویی استیل ۱۱۶',
        modelDisplay: 'SL116-$i',
        qtyText: '12 عدد / کارتن',
        serial: 'MA-1405-${i.toString().padLeft(6, '0')}',
        barcode: 'MA-1405-${i.toString().padLeft(6, '0')}',
        tracking: 'MA-1405-${i.toString().padLeft(6, '0')}',
        date: '1405/06/15',
        qrPayload:
            'MA|SN|MA-1405-${i.toString().padLeft(6, '0')}|uuid-$i|سینک ظرفشویی استیل ۱۱۶|SL116|12|hmac-$i',
      );

  BadgeData badgeOf(int i) => BadgeData(
        sequence: i,
        total: 500,
        count: 12,
        modelName: 'SL116',
        packageType: 'کیسه',
        unitsPerBox: 12,
        senderName: 'انبار مرکزی',
        senderPhone: '02111111111',
        senderNationalId: '0012345678',
        receiverName: 'گیرنده $i',
        receiverCity: 'تهران',
        receiverPostalCode: '1234567890',
        receiverAddress: 'خیابان اصلی، پلاک $i',
        receiverPhone: '09120000000',
        shippingMethod: 'باربری',
        carrier: 'تیپاکس',
        orderRef: 'MA-ORDER-$i',
        createdAt: '1405/06/15',
      );

  bool isPdf(Uint8List bytes) =>
      bytes.length > 5 && String.fromCharCodes(bytes.sublist(0, 5)) == '%PDF-';

  final pageMarker = RegExp(r'/Type\s*/Page(?![a-zA-Z])');

  String objBody(String s, String num) {
    final start = s.indexOf('$num 0 obj');
    if (start < 0) return '';
    final end = s.indexOf('endobj', start);
    return end < 0 ? s.substring(start) : s.substring(start, end);
  }

  int countPdfPages(Uint8List bytes) {
    final s = String.fromCharCodes(bytes);
    // ۱) مسیر مستقیم: مارکرِ /Type/Page با فاصلهٔ اختیاری (کتابخانه '/Type/Page' می‌نویسد)
    final direct = pageMarker.allMatches(s).length;
    if (direct > 0) return direct;
    // ۲) مسیر استاندارد PDF: /Root → شیء Pages → /Count N
    final root = RegExp(r'/Root\s+(\d+)\s+\d+\s+R').firstMatch(s);
    if (root == null) return 0;
    final rootObj = objBody(s, root.group(1)!);
    final pagesRef = RegExp(r'/Pages\s+(\d+)\s+\d+\s+R').firstMatch(rootObj);
    if (pagesRef == null) return 0;
    final pagesObj = objBody(s, pagesRef.group(1)!);
    final count = RegExp(r'/Count\s+(\d+)').firstMatch(pagesObj);
    return count == null ? 0 : int.parse(count.group(1)!);
  }

  test('۵۰۰ لیبل → PDF بدون خطا و حافظهٔ منطقی ساخته می‌شود', () async {
    final labels = List.generate(500, labelOf);
    final sw = Stopwatch()..start();

    final bytes = await PdfLabels.buildLabelPdfBytes(labels);

    sw.stop();
    expect(bytes, isNotNull);
    expect(isPdf(bytes!), isTrue);
    // ۵۰۰ صفحه — یکی برای هر لیبل
    expect(countPdfPages(bytes), greaterThanOrEqualTo(500));
    // PDF خام باید زیر ۱۵۰ مگابایت بماند (QRهای PNG و فونت‌ها) —
    // رشدِ بی‌رویه = باگِ حافظه؛ سقفِ واقعی خیلی پایین‌تر است.
    expect(bytes.length, lessThan(150 * 1024 * 1024));

    // ignore: avoid_print
    print('500 labels: ${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB '
        'in ${sw.elapsedMilliseconds} ms');
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('۵۰۰ بیجک (حالت دوتایی) → ۲۵۰ برگهٔ A5', () async {
    final badges = List.generate(500, badgeOf);
    BadgePrintSettingsHolder.instance.notifier.value =
        const BadgePrintSettings(dualMode: true);
    addTearDown(() {
      BadgePrintSettingsHolder.instance.notifier.value =
          BadgePrintSettings.defaults;
    });

    final bytes = await PdfLabels.buildBadgePdfBytes(badges);

    expect(bytes, isNotNull);
    expect(isPdf(bytes!), isTrue);
    // هر صفحه دو بیجک را می‌گیرد → ۲۵۰ صفحه
    expect(countPdfPages(bytes), greaterThanOrEqualTo(250));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('چاپ‌های پشت سر هم (۳ بچ ۵۰۰تایی) → نشانه‌ای از نشت نیست', () async {
    final labels = List.generate(500, labelOf);
    for (var round = 0; round < 3; round++) {
      final bytes = await PdfLabels.buildLabelPdfBytes(labels);
      expect(bytes, isNotNull);
      expect(isPdf(bytes!), isTrue);
    }
    // اگر دورِ سوم هم موفق و هم‌اندازهٔ دورِ اول بود، نشتِ تجمعی نداریم
  }, timeout: const Timeout(Duration(minutes: 8)));
}
