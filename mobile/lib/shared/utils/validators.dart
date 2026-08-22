/// اعتبارسنجی رمز عبور — مطابق سیاست سرور (assertPasswordPolicy):
/// دقیقاً ۶ رقم عددی (مثل پین)
String? validatePassword(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'رمز عبور الزامی است';
  if (!RegExp(r'^\d{6}$').hasMatch(v)) {
    return 'رمز عبور باید دقیقاً ۶ رقم باشد';
  }
  return null;
}

/// اعتبارسنجی شماره موبایل — ۱۱ رقم با پیشوند 09 (مطابق سرور)
String? validatePhone(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'شماره موبایل الزامی است';
  if (!RegExp(r'^09\d{9}$').hasMatch(v)) {
    return 'شماره موبایل باید ۱۱ رقم و با 09 شروع شود';
  }
  return null;
}
