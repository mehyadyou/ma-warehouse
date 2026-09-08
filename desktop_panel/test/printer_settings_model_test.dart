import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/badge_print_settings.dart';
import 'package:ma_warehouse_panel/core/printer_settings.dart';

void main() {
  group('PrinterSettings.printerName', () {
    test('پیش‌فرض خالی (دیالوگ سیستمی)', () {
      expect(PrinterSettings.defaults.printerName, '');
    });

    test('roundtrip JSON نام چاپگر لیبل', () {
      const s = PrinterSettings(printerName: '4BARCODE 4B-2054TF');
      final restored = PrinterSettings.fromJson(s.toJson());
      expect(restored.printerName, '4BARCODE 4B-2054TF');
      expect(restored, s);
    });

    test('JSON قدیمی بدون printerName → خالی (سازگاری عقبرو)', () {
      final restored = PrinterSettings.fromJson({
        'labelWidthMm': 100,
        'labelHeightMm': 80,
      });
      expect(restored.printerName, '');
    });
  });

  group('BadgePrintSettings.printerName', () {
    test('پیش‌فرض خالی (دیالوگ سیستمی)', () {
      expect(BadgePrintSettings.defaults.printerName, '');
    });

    test('roundtrip JSON نام چاپگر بیجک', () {
      const s = BadgePrintSettings(printerName: 'Canon LBP6030w');
      final restored = BadgePrintSettings.fromJson(s.toJson());
      expect(restored.printerName, 'Canon LBP6030w');
      expect(restored, s);
    });

    test('لیبل و بیجک چاپگر جدا دارند', () {
      const label = PrinterSettings(printerName: '4BARCODE 4B-2054TF');
      const badge = BadgePrintSettings(printerName: 'Canon LBP6030w');
      expect(label.printerName, isNot(badge.printerName));
    });
  });
}
