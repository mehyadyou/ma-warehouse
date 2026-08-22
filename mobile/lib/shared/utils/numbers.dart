const _faDigits = '۰۱۲۳۴۵۶۷۸۹';
const _arDigits = '٠١٢٣٤٥٦٧٨٩';

/// ارقام فارسی/عربی را به انگلیسی برمی‌گرداند و جداکننده‌های هزارگان (٬ ، , و فاصله) را حذف می‌کند
String normalizeDigits(String input) {
  var s = input.replaceAll(RegExp(r'[٬,،\s]'), '');
  s = s.replaceAllMapped(RegExp(r'[۰-۹]'), (m) => '${_faDigits.indexOf(m.group(0)!)}');
  s = s.replaceAllMapped(RegExp(r'[٠-٩]'), (m) => '${_arDigits.indexOf(m.group(0)!)}');
  return s;
}

/// ارقام انگلیسی را به فارسی برمی‌گرداند
String faDigits(String s) {
  return s.replaceAllMapped(
    RegExp(r'[0-9]'),
    (m) => _faDigits[m.group(0)!.codeUnitAt(0) - 48],
  );
}

/// قالب هزارگان با کاما + ارقام فارسی
String formatNumber(num n) {
  final isDecimal = n % 1 != 0;
  final s = isDecimal ? n.toStringAsFixed(2) : n.toInt().toString();
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  final result = buf.toString() + (parts.length > 1 ? '.${parts[1]}' : '');
  return faDigits(result);
}
