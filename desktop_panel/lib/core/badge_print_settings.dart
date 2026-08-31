import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تنظیمات چیدمان بیجک روی کاغذ — جداگانه برای دو حالت:
/// - حالت دوتایی (پیش‌فرض): دو بیجک کنار هم روی برگهٔ A5 افقی (۲۱۰×۱۴۸)
/// - حالت تکی: هر بیجک روی یک برگهٔ A6 (۱۰۵×۱۴۸)
///
/// هر حالت مقیاس و جابه‌جایی مستقل خودش را دارد تا کاربر بتواند
/// هر دو را جداگانه تنظیم و ذخیره کند.
class BadgePrintSettings {
  const BadgePrintSettings({
    this.dualMode = true,
    this.dualScalePercent = 100,
    this.dualOffsetXmm = 0,
    this.dualOffsetYmm = 0,
    this.singleScalePercent = 100,
    this.singleOffsetXmm = 0,
    this.singleOffsetYmm = 0,
  });

  /// true = دو بیجک در هر برگه (A5 افقی) | false = یک بیجک در هر برگه (A6)
  final bool dualMode;

  // تنظیمات حالت دوتایی
  final double dualScalePercent;
  final double dualOffsetXmm;
  final double dualOffsetYmm;

  // تنظیمات حالت تکی
  final double singleScalePercent;
  final double singleOffsetXmm;
  final double singleOffsetYmm;

  /// مقادیرِ حالتِ فعال — چاپ و پیش‌نمایش از این‌ها می‌خوانند
  double get scalePercent => dualMode ? dualScalePercent : singleScalePercent;
  double get offsetXmm => dualMode ? dualOffsetXmm : singleOffsetXmm;
  double get offsetYmm => dualMode ? dualOffsetYmm : singleOffsetYmm;

  static const BadgePrintSettings defaults = BadgePrintSettings();

  BadgePrintSettings copyWith({
    bool? dualMode,
    double? dualScalePercent,
    double? dualOffsetXmm,
    double? dualOffsetYmm,
    double? singleScalePercent,
    double? singleOffsetXmm,
    double? singleOffsetYmm,
  }) {
    return BadgePrintSettings(
      dualMode: dualMode ?? this.dualMode,
      dualScalePercent: dualScalePercent ?? this.dualScalePercent,
      dualOffsetXmm: dualOffsetXmm ?? this.dualOffsetXmm,
      dualOffsetYmm: dualOffsetYmm ?? this.dualOffsetYmm,
      singleScalePercent: singleScalePercent ?? this.singleScalePercent,
      singleOffsetXmm: singleOffsetXmm ?? this.singleOffsetXmm,
      singleOffsetYmm: singleOffsetYmm ?? this.singleOffsetYmm,
    );
  }

  Map<String, dynamic> toJson() => {
        'dualMode': dualMode,
        'dualScalePercent': dualScalePercent,
        'dualOffsetXmm': dualOffsetXmm,
        'dualOffsetYmm': dualOffsetYmm,
        'singleScalePercent': singleScalePercent,
        'singleOffsetXmm': singleOffsetXmm,
        'singleOffsetYmm': singleOffsetYmm,
      };

  factory BadgePrintSettings.fromJson(Map<String, dynamic> json) {
    double d(key, double fallback) {
      final v = json[key];
      final n = v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
      return (n ?? 0) > 0 ? n! : fallback;
    }

    // آفست می‌تواند صفر یا منفی باشد؛ فقط اسکیل صفر مجاز نیست
    double dAny(key, double fallback) {
      final v = json[key];
      final n = v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
      if (n == null) return fallback;
      if ((key == 'dualScalePercent' || key == 'singleScalePercent') &&
          n <= 0) {
        return fallback;
      }
      return n;
    }

    return BadgePrintSettings(
      dualMode: json['dualMode'] == true,
      dualScalePercent: d('dualScalePercent', defaults.dualScalePercent),
      dualOffsetXmm: dAny('dualOffsetXmm', defaults.dualOffsetXmm),
      dualOffsetYmm: dAny('dualOffsetYmm', defaults.dualOffsetYmm),
      singleScalePercent: d('singleScalePercent', defaults.singleScalePercent),
      singleOffsetXmm: dAny('singleOffsetXmm', defaults.singleOffsetXmm),
      singleOffsetYmm: dAny('singleOffsetYmm', defaults.singleOffsetYmm),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BadgePrintSettings &&
      other.dualMode == dualMode &&
      other.dualScalePercent == dualScalePercent &&
      other.dualOffsetXmm == dualOffsetXmm &&
      other.dualOffsetYmm == dualOffsetYmm &&
      other.singleScalePercent == singleScalePercent &&
      other.singleOffsetXmm == singleOffsetXmm &&
      other.singleOffsetYmm == singleOffsetYmm;

  @override
  int get hashCode => Object.hash(
        dualMode,
        dualScalePercent,
        dualOffsetXmm,
        dualOffsetYmm,
        singleScalePercent,
        singleOffsetXmm,
        singleOffsetYmm,
      );
}

/// حامل درون‌حافظه‌ایِ تنظیمات فعلی چاپ بیجک — پیش‌نمایش و چاپ هر دو از این می‌خوانند
/// تا هر بار که اعمال/ذخیره شد، فوراً در چاپ اعمال شود.
class BadgePrintSettingsHolder {
  BadgePrintSettingsHolder._();
  static final BadgePrintSettingsHolder instance = BadgePrintSettingsHolder._();

  static const _storageKey = 'badge_print_settings_v1';

  final ValueNotifier<BadgePrintSettings> notifier =
      ValueNotifier<BadgePrintSettings>(BadgePrintSettings.defaults);

  BadgePrintSettings get current => notifier.value;

  /// بارگذاری از دیسک در زمان اجرا
  Future<BadgePrintSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return current;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = BadgePrintSettings.fromJson(json);
      notifier.value = loaded;
      return loaded;
    } catch (_) {
      return current;
    }
  }

  /// ذخیره‌ی پایدار + به‌روزرسانی مقدار درون‌حافظه
  Future<void> save(BadgePrintSettings settings) async {
    notifier.value = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(settings.toJson()));
  }
}
