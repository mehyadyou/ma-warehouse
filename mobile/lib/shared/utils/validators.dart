/// اعتبارسنجی رمز عبور — مطابق سیاست سرور (assertPasswordPolicy):
/// دقیقاً ۶ رقم عددی (مثل پین) — برای انباردار/راننده
String? validatePassword(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'رمز عبور الزامی است';
  if (!RegExp(r'^\d{6}$').hasMatch(v)) {
    return 'رمز عبور باید دقیقاً ۶ رقم باشد';
  }
  return null;
}

/// اعتبارسنجی رمز ورود — هم PIN شش‌رقمی و هم رمز قوی مدیر (حداقل ۸ کاراکتر حرف+عدد)
String? validateLoginPassword(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'رمز عبور الزامی است';
  const any = r'^(?:\d{6}|(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$%^&*()_+\-=]{8,64})$';
  if (!RegExp(any).hasMatch(v)) {
    return 'رمز عبور معتبر نیست';
  }
  return null;
}

/// اعتبارسنجی رمز مدیر — حداقل ۸ کاراکتر شامل حرف و عدد
String? validateManagerPassword(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'رمز عبور الزامی است';
  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$%^&*()_+\-=]{8,64}$').hasMatch(v)) {
    return 'رمز مدیر باید حداقل ۸ کاراکتر شامل حرف و عدد باشد';
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
