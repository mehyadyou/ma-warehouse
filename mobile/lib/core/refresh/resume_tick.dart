import 'package:flutter_riverpod/flutter_riverpod.dart';

/// تیک بازگشت به اپ — هر resume واقعی (بعد از پس‌زمینه) +۱ می‌شود.
/// داشبوردها گوش می‌دهند و پرووایدرهایشان را invalidate می‌کنند تا کاربر
/// بدون خروج/ورود و حتی بدون pull، دیتای تازه ببیند.
/// invalidate روی پرووایدرِ گوش‌داده‌نشده بی‌اثر است، پس طوفان رفرش نداریم.
class ResumeTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final resumeTickProvider =
    NotifierProvider<ResumeTickNotifier, int>(ResumeTickNotifier.new);
