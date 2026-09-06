import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/label_data.dart';

void main() {
  group('LabelData.fromCarton', () {
    test('reads model and product from nested objects', () {
      final data = LabelData.fromCarton({
        'model': {'name': 'مدل ایکس', 'unitsPerBox': 12},
        'product': {'name': 'محصول وای'},
        'serialNumber': 'ABC-1234',
        'createdAt': '2026-08-20T10:00:00.000Z',
        'qrPayload': 'QR-DATA',
      });
      expect(data.modelDisplay, 'مدل ایکس');
      expect(data.productName, 'محصول وای');
      expect(data.qtyText, '12 عدد / کارتن');
      expect(data.serial, 'ABC-1234');
      expect(data.barcode, 'ABC-1234');
      expect(data.tracking, 'ABC-1234');
      expect(data.date, '2026-08-20');
      expect(data.qrPayload, 'QR-DATA');
    });

    test('falls back to productName and capacityPerBox when flat', () {
      final data = LabelData.fromCarton({
        'productName': 'محصول تخت',
        'capacityPerBox': 6,
        'serialNumber': 'SER',
      });
      expect(data.modelDisplay, 'محصول تخت');
      expect(data.productName, 'محصول تخت');
      expect(data.qtyText, '6 عدد / کارتن');
    });

    test('marks individual units', () {
      final data = LabelData.fromCarton({'isIndividualUnit': true});
      expect(data.qtyText, '۱ عدد (تکی)');
    });

    test('derives serial from qrUuid when serial missing', () {
      final data = LabelData.fromCarton({
        'qrUuid': 'a1b2c3d4-1111-2222-3333-444455556666',
      });
      expect(data.serial, 'A1B2C3D4');
    });

    test('falls back to tracking placeholder when nothing available', () {
      final data = LabelData.fromCarton({});
      expect(data.tracking, 'MA-XXXXXXXX');
      expect(data.barcode, '000000');
      expect(data.modelDisplay, '—');
      expect(data.productName, '');
    });

    test('qrPayload falls back to tracking', () {
      final data = LabelData.fromCarton({'serialNumber': 'SER123'});
      expect(data.qrPayload, 'SER123');
    });

    test('barcode is truncated to 16 chars', () {
      final data = LabelData.fromCarton({
        'serialNumber': '12345678901234567890',
      });
      expect(data.barcode, '1234567890123456');
    });
  });

  group('BadgeData.fromBadge', () {
    test('maps order fields and applies group total', () {
      final data = BadgeData.fromBadge({
        'orderId': 'abcd-1234-efgh',
        'sequence': 2,
        'senderName': 'فرستنده',
        'receiverName': 'گیرنده',
        'createdAt': '2026-08-20T10:00:00.000Z',
        'order': {
          'city': 'تهران',
          'address': 'خیابان اصلی',
          'postalCode': '12345',
          'shippingMethod': 'پست',
          'carrier': 'تیپاکس',
        },
      }, total: 5);
      expect(data.sequence, 2);
      expect(data.total, 5);
      expect(data.orderRef, 'MA-ABCD1234');
      expect(data.receiverCity, 'تهران');
      // تاریخ روی بیجک شمسی است (۲۰۲۶-۰۸-۲۰ → ۱۴۰۵/۰۵/۲۹)
      expect(data.createdAt, '۱۴۰۵/۰۵/۲۹');
      expect(data.missingReceiver, isFalse);
    });

    test('reports missing receiver', () {
      final data = BadgeData.fromBadge({
        'orderId': 'x',
        'sequence': 1,
        'senderName': 'فرستنده',
      }, total: 1);
      expect(data.missingReceiver, isTrue);
      expect(data.receiverName, '');
    });

    test('uses badge total when group total not given', () {
      final data = BadgeData.fromBadge({
        'orderId': 'x',
        'sequence': 3,
        'total': 9,
      });
      expect(data.total, 9);
    });

    test('badge reads model/package snapshot and computes package count', () {
      final data = BadgeData.fromBadge({
        'orderId': 'x',
        'sequence': 1,
        'count': 10,
        'modelName': 'مدل آ',
        'packageType': 'کیسه',
        'unitsPerBox': 4,
      }, total: 1);
      expect(data.modelName, 'مدل آ');
      expect(data.packageLabel, 'کیسه');
      expect(data.modelDisplay, 'مدل آ');
      // ۱۰ ÷ ۴ → ۳ بسته (گرد به بالا)
      expect(data.packageCount, 3);
    });

    test('badge falls back to کارتن label and total count without snapshot', () {
      final data = BadgeData.fromBadge({
        'orderId': 'x',
        'sequence': 1,
        'count': 7,
      });
      expect(data.packageLabel, 'کارتن');
      expect(data.modelDisplay, '—');
      expect(data.packageCount, 7);
    });

    group('carrierLabel (نام باربری روی بیجک)', () {
      test('باربری: نام دقیق باربریِ ثبت‌شده برگردانده می‌شود', () {
        final data = BadgeData.fromBadge({
          'orderId': 'x',
          'sequence': 1,
          'order': {'shippingMethod': 'باربری', 'carrier': 'باربری امین'},
        });
        expect(data.isBarebari, isTrue);
        expect(data.carrierLabel, 'باربری امین');
      });

      test('باربری بدون carrier: fallback به «باربری»', () {
        final data = BadgeData.fromBadge({
          'orderId': 'x',
          'sequence': 1,
          'order': {'shippingMethod': 'باربری', 'carrier': null},
        });
        expect(data.carrierLabel, 'باربری');
      });

      test('تیپاکس: همیشه «تیپاکس» (carrier نادیده گرفته می‌شود)', () {
        final data = BadgeData.fromBadge({
          'orderId': 'x',
          'sequence': 1,
          'order': {'shippingMethod': 'تیپاکس', 'carrier': 'چیز دیگر'},
        });
        expect(data.isTipax, isTrue);
        expect(data.carrierLabel, 'تیپاکس');
      });

      test('روش دیگر با carrier: نام carrier', () {
        final data = BadgeData.fromBadge({
          'orderId': 'x',
          'sequence': 1,
          'order': {'shippingMethod': 'پست', 'carrier': 'پست پیشتاز'},
        });
        expect(data.carrierLabel, 'پست پیشتاز');
      });

      test('بدون هیچ اطلاعاتی: «—»', () {
        final data = BadgeData.fromBadge({
          'orderId': 'x',
          'sequence': 1,
          'order': <String, dynamic>{},
        });
        expect(data.carrierLabel, '—');
      });
    });
  });

  group('shortOrderId', () {
    test('formats MA- prefix with 8 chars uppercase', () {
      expect(shortOrderId('abcd1234-efgh-5678'), 'MA-ABCD1234');
      expect(shortOrderId('AB-CD-12-34'), 'MA-ABCD1234');
    });

    test('handles short ids', () {
      expect(shortOrderId('ab'), 'MA-AB');
    });
  });
}
