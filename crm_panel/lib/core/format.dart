import 'package:shamsi_date/shamsi_date.dart';

/// تاریخ ISO به شمسی نمایشی (1405/06/15) — خطا → همان رشتهٔ خام
String faDate(dynamic iso) {
  try {
    if (iso == null) return '-';
    final dt = DateTime.parse(iso.toString()).toLocal();
    final j = Jalali.fromDateTime(dt);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${j.year}/${two(j.month)}/${two(j.day)}';
  } catch (_) {
    return iso?.toString() ?? '-';
  }
}

/// تاریخ + ساعت شمسی نمایشی
String faDateTime(dynamic iso) {
  try {
    if (iso == null) return '-';
    final dt = DateTime.parse(iso.toString()).toLocal();
    final j = Jalali.fromDateTime(dt);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${j.year}/${two(j.month)}/${two(j.day)} ${two(dt.hour)}:${two(dt.minute)}';
  } catch (_) {
    return iso?.toString() ?? '-';
  }
}

/// مبلغ نمایشی با جداکننده هزارگان (فقط نمایش — نه محاسبه)
String faMoney(dynamic v) {
  final n = v is num ? v : num.tryParse(v?.toString() ?? '');
  if (n == null) return '-';
  final neg = n < 0;
  var s = n.abs().truncate().toString();
  final buf = StringBuffer();
  var c = 0;
  for (var i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    if (++c % 3 == 0 && i > 0) buf.write('٬');
  }
  return '${neg ? '-' : ''}${buf.toString().split('').reversed.join()}';
}

/// برچسب فارسی وضعیت سفارش/انتقال
String faStatus(dynamic status) {
  switch (status?.toString()) {
    case 'PENDING':
      return 'در انتظار';
    case 'SHIPPED':
      return 'ارسال‌شده';
    case 'DELIVERED':
      return 'تحویل‌شده';
    case 'CANCELED':
      return 'لغوشده';
    case 'IN_TRANSIT':
      return 'در مسیر';
    case 'DONE':
      return 'تکمیل‌شده';
    case 'EXITED':
      return 'خارج‌شده';
    case 'IN_STOCK':
      return 'موجود';
    case 'RETURNED':
      return 'مرجوعی';
    default:
      return status?.toString() ?? '-';
  }
}
