import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manager_api_provider.dart';
import '../models/recent_activity_model.dart';
import '../models/history_entry_model.dart';

/// فعالیت‌های اخیر داشبورد مدیر — با رویدادهای realtime و بازگشت از صفحات invalidate می‌شود
final recentActivitiesProvider = FutureProvider<RecentActivityData>((ref) async {
  return await ref.read(managerApiServiceProvider).getRecentActivities();
});

/// تاریخچهٔ کامل سیستم — همهٔ وقایع با جزئیات (فیلتر در صفحه انجام می‌شود)
final historyProvider = FutureProvider<List<HistoryEntryModel>>((ref) async {
  return await ref.read(managerApiServiceProvider).getHistory();
});
