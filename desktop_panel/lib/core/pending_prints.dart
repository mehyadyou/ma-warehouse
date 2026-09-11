import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// صف مقاوم ثبت چاپ لیبل — اگر POST ثبت چاپ (401/قطعی) شکست، آیدی‌ها اینجا
/// می‌مانند و در اولین موفقیت بعدی (یا استارت بعدی اپ) خودکار فلاش می‌شوند.
/// بدون این صف، چاپ فیزیکی انجام می‌شد ولی دیتابیس بی‌خبر می‌ماند (حادثه BR 116).
class PendingPrints {
  static const _key = 'pending_print_batches_v1';

  static Future<List<List<String>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<List>()
          .map((e) => e.whereType<String>().toList())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<List<String>> batches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(batches));
  }

  /// افزودن یک دستهٔ ثبت‌نشده — برمی‌گرداند: تعداد دسته‌های در انتظار.
  static Future<int> enqueue(List<String> ids) async {
    if (ids.isEmpty) return count();
    final batches = await load();
    batches.add(ids);
    await save(batches);
    return batches.length;
  }

  /// فلاش قدیمی‌ترین‌ها اول؛ روی اولین خطا می‌ایستد. برمی‌گرداند: باقیمانده.
  static Future<int> flush(Future<void> Function(List<String> ids) mark) async {
    final batches = await load();
    final remaining = <List<String>>[];
    var failed = false;
    for (final b in batches) {
      if (failed) {
        remaining.add(b);
        continue;
      }
      try {
        await mark(b);
      } catch (_) {
        failed = true;
        remaining.add(b);
      }
    }
    await save(remaining);
    return remaining.length;
  }

  static Future<int> count() async => (await load()).length;
}
