import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تنظیمات چاپگر و ابعاد لیبل فیزیکی — ذخیره‌شده‌ی پایدار که همه‌ی دستورهای چاپ
/// ([PdfLabels.printLabels] و بیجک) از آن استفاده می‌کنند.
class PrinterSettings {
  const PrinterSettings({
    this.labelWidthMm = 100,
    this.labelHeightMm = 80,
    this.labelMarginMm = 6,
    this.printerName = '',
    this.scalePercent = 100,
    this.offsetXmm = 0,
    this.offsetYmm = 0,
  });

  /// ابعاد واقعی کاغذ لیبل (سانتی‌متر ×۱۰). مثلاً لیبل ۱۰×۸ = عرض ۱۰۰، ارتفاع ۸۰.
  final double labelWidthMm;
  final double labelHeightMm;

  /// حاشیه‌ی داخلی کاغذ (فاصله‌ی محتوا از لبه‌ی برش) — میلی‌متر
  final double labelMarginMm;

  /// نام چاپگر هدف؛ اگر خالی باشد چاپگر پیش‌فرض ویندوز استفاده می‌شود
  final String printerName;

  /// درصد مقیاس محتوا نسبت به اندازه‌ی پایه (۱۰۰ = اندازه‌ی اصلی)
  final double scalePercent;

  /// جابه‌جایی افقی محتوا نسبت به مرکز لیبل (میلی‌متر، مثبت = راست)
  final double offsetXmm;

  /// جابه‌جایی عمودی محتوا نسبت به مرکز لیبل (میلی‌متر، مثبت = بالا)
  final double offsetYmm;

  static const PrinterSettings defaults = PrinterSettings();

  PrinterSettings copyWith({
    double? labelWidthMm,
    double? labelHeightMm,
    double? labelMarginMm,
    String? printerName,
    double? scalePercent,
    double? offsetXmm,
    double? offsetYmm,
  }) {
    return PrinterSettings(
      labelWidthMm: labelWidthMm ?? this.labelWidthMm,
      labelHeightMm: labelHeightMm ?? this.labelHeightMm,
      labelMarginMm: labelMarginMm ?? this.labelMarginMm,
      printerName: printerName ?? this.printerName,
      scalePercent: scalePercent ?? this.scalePercent,
      offsetXmm: offsetXmm ?? this.offsetXmm,
      offsetYmm: offsetYmm ?? this.offsetYmm,
    );
  }

  Map<String, dynamic> toJson() => {
        'labelWidthMm': labelWidthMm,
        'labelHeightMm': labelHeightMm,
        'labelMarginMm': labelMarginMm,
        'printerName': printerName,
        'scalePercent': scalePercent,
        'offsetXmm': offsetXmm,
        'offsetYmm': offsetYmm,
      };

  factory PrinterSettings.fromJson(Map<String, dynamic> json) {
    double d(key, double fallback) {
      final v = json[key];
      final n = v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
      return (n ?? 0) > 0 ? n! : fallback;
    }

    // برای مقادیری که می‌توانند صفر یا منفی باشند (آفست، اسکیل صفر مجاز نیست)
    double dAny(key, double fallback) {
      final v = json[key];
      final n = v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
      if (n == null) return fallback;
      if (key == 'scalePercent' && n <= 0) return fallback;
      return n;
    }

    return PrinterSettings(
      labelWidthMm: d('labelWidthMm', defaults.labelWidthMm),
      labelHeightMm: d('labelHeightMm', defaults.labelHeightMm),
      labelMarginMm: d('labelMarginMm', defaults.labelMarginMm),
      printerName: json['printerName']?.toString() ?? '',
      scalePercent: dAny('scalePercent', defaults.scalePercent),
      offsetXmm: dAny('offsetXmm', defaults.offsetXmm),
      offsetYmm: dAny('offsetYmm', defaults.offsetYmm),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PrinterSettings &&
      other.labelWidthMm == labelWidthMm &&
      other.labelHeightMm == labelHeightMm &&
      other.labelMarginMm == labelMarginMm &&
      other.printerName == printerName &&
      other.scalePercent == scalePercent &&
      other.offsetXmm == offsetXmm &&
      other.offsetYmm == offsetYmm;

  @override
  int get hashCode => Object.hash(
        labelWidthMm,
        labelHeightMm,
        labelMarginMm,
        printerName,
        scalePercent,
        offsetXmm,
        offsetYmm,
      );
}

/// حامل درون‌حافظه‌ایِ تنظیمات فعلی چاپ — پیش‌نمایش و خودِ چاپ هر دو از این می‌خوانند
/// تا هر بار که سیو شد، فوراً هم در پیش‌نمایش و هم در چاپ اعمال شود.
class PrinterSettingsHolder {
  PrinterSettingsHolder._();
  static final PrinterSettingsHolder instance = PrinterSettingsHolder._();

  static const _storageKey = 'print_settings_v1';

  final ValueNotifier<PrinterSettings> notifier =
      ValueNotifier<PrinterSettings>(PrinterSettings.defaults);

  PrinterSettings get current => notifier.value;

  /// بارگذاری از دیسک در زمان اجرا
  Future<PrinterSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return current;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = PrinterSettings.fromJson(json);
      notifier.value = loaded;
      return loaded;
    } catch (_) {
      return current;
    }
  }

  /// ذخیره‌ی پایدار + به‌روزرسانی مقدار درون‌حافظه (پیش‌نمایش و چاپ بلافاصله اعمال می‌شود)
  Future<void> save(PrinterSettings settings) async {
    notifier.value = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(settings.toJson()));
  }
}