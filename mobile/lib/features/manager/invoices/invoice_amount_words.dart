const _ones = <String>[
  '',
  'یک',
  'دو',
  'سه',
  'چهار',
  'پنج',
  'شش',
  'هفت',
  'هشت',
  'نه',
  'ده',
  'یازده',
  'دوازده',
  'سیزده',
  'چهارده',
  'پانزده',
  'شانزده',
  'هفده',
  'هجده',
  'نوزده',
];

const _tens = <String>[
  '',
  '',
  'بیست',
  'سی',
  'چهل',
  'پنجاه',
  'شصت',
  'هفتاد',
  'هشتاد',
  'نود',
];

const _hundreds = <String>[
  '',
  'صد',
  'دویست',
  'سیصد',
  'چهارصد',
  'پانصد',
  'ششصد',
  'هفتصد',
  'هشتصد',
  'نهصد',
];

/// تبدیل بخش سه‌رقمی (۰ تا ۹۹۹) به حروف فارسی
String _threeDigits(int n) {
  final parts = <String>[];
  if (n >= 100) {
    parts.add(_hundreds[n ~/ 100]);
    n %= 100;
  }
  if (n >= 20) {
    parts.add(_tens[n ~/ 10]);
    n %= 10;
  }
  if (n > 0) parts.add(_ones[n]);
  return parts.join(' و ');
}

/// تبدیل عدد صحیح به حروف فارسی (بدون واحد)
String integerToWords(int n) {
  if (n == 0) return 'صفر';
  final sign = n < 0 ? 'منفی ' : '';
  var value = n.abs();
  final chunks = <String>[];
  final units = <String>['', ' هزار', ' میلیون', ' میلیارد', ' تریلیون'];
  var index = 0;
  while (value > 0) {
    final chunk = value % 1000;
    if (chunk > 0) {
      var words = _threeDigits(chunk);
      // «یک هزار» نمی‌گوییم؛ فقط «هزار»
      if (chunk == 1 && index == 1) {
        words = 'هزار';
      } else if (chunk == 1 && index >= 2) {
        words = 'یک${units[index]}';
      } else if (index >= 1) {
        words = '$words${units[index]}';
      }
      chunks.add(words);
    }
    value ~/= 1000;
    index++;
  }
  return sign + chunks.reversed.join(' و ');
}

/// مبلغ به حروف به همراه واحد تومان
///
/// مثال: ۲۵۰۰۰۰ → «دویست و پنجاه هزار تومان»
String amountInWords(num amount) {
  final rounded = amount.round();
  final words = integerToWords(rounded);
  if (rounded == 0) return 'صفر تومان';
  return '$words تومان';
}