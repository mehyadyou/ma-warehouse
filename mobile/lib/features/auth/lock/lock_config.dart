/// روش قفل برنامه — روی دستگاه ذخیره می‌شود و به حساب کاربر گره نمی‌خورد
enum LockMethod {
  none,
  fingerprint,
  face,
  pin;

  static LockMethod fromName(String? name) {
    return LockMethod.values.firstWhere(
      (m) => m.name == name,
      orElse: () => LockMethod.none,
    );
  }
}
