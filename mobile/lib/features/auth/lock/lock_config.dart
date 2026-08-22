/// روش قفل برنامه — روی دستگاه ذخیره می‌شود و به حساب کاربر گره نمی‌خورد.
/// پین جداگانه وجود ندارد؛ قفل با همان رمز اصلی ۶ رقمی حساب باز می‌شود
/// (بیومتریک فقط میان‌بر دستگاه است).
enum LockMethod {
  none,
  fingerprint,
  face;

  static LockMethod fromName(String? name) {
    return LockMethod.values.firstWhere(
      (m) => m.name == name,
      orElse: () => LockMethod.none,
    );
  }
}
