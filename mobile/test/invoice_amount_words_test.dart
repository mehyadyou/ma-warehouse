import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/invoices/invoice_amount_words.dart';

void main() {
  group('integerToWords', () {
    test('صفر و یک‌رقمی‌ها', () {
      expect(integerToWords(0), 'صفر');
      expect(integerToWords(1), 'یک');
      expect(integerToWords(5), 'پنج');
      expect(integerToWords(19), 'نوزده');
    });

    test('دهگان و صدگان', () {
      expect(integerToWords(20), 'بیست');
      expect(integerToWords(45), 'چهل و پنج');
      expect(integerToWords(100), 'صد');
      expect(integerToWords(123), 'صد و بیست و سه');
      expect(integerToWords(999), 'نهصد و نود و نه');
    });

    test('هزارها', () {
      expect(integerToWords(1000), 'هزار');
      expect(integerToWords(1100), 'هزار و صد');
      expect(integerToWords(1001), 'هزار و یک');
      expect(integerToWords(12000), 'دوازده هزار');
      expect(integerToWords(10500), 'ده هزار و پانصد');
      expect(integerToWords(100000), 'صد هزار');
    });

    test('میلیون و بالاتر', () {
      expect(integerToWords(1000000), 'یک میلیون');
      expect(integerToWords(2500000), 'دو میلیون و پانصد هزار');
      expect(
        integerToWords(1234567),
        'یک میلیون و دویست و سی و چهار هزار و پانصد و شصت و هفت',
      );
      expect(integerToWords(1000000000), 'یک میلیارد');
    });

    test('اعداد منفی', () {
      expect(integerToWords(-25), 'منفی بیست و پنج');
    });
  });

  group('amountInWords', () {
    test('با واحد تومان', () {
      expect(amountInWords(0), 'صفر تومان');
      expect(amountInWords(1), 'یک تومان');
      expect(amountInWords(250000), 'دویست و پنجاه هزار تومان');
      expect(amountInWords(1000000), 'یک میلیون تومان');
    });

    test('مبلغ اعشاری گرد می‌شود', () {
      expect(amountInWords(1250.7), 'هزار و دویست و پنجاه و یک تومان');
    });
  });
}