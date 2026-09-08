import 'dart:math';

final _random = Random.secure();

/// کلید یکتای سمت کلاینت برای ایدمپوتنسی (checkin/scan-out/manual).
/// سرور با همین کلید پاسخ را کش می‌کند؛ ریت‌رای یا فلاش صف آفلاین با کلید
/// یکسان هرگز عملیات را تکرار نمی‌کند. کلید برای هر عملیات منطقی «یک‌بار»
/// ساخته و در همه تلاش‌های همان عملیات reuse می‌شود.
String newClientKey() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final rand = List.generate(8, (_) => _random.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '$time-$rand';
}
