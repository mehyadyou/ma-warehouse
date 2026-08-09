import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/driver_api_service.dart';

final driverApiProvider = Provider<DriverApiService>((ref) => DriverApiService());

// لیست سفارش‌های آماده
final readyOrdersProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(driverApiProvider);
  return api.getReadyOrders();
});

// برنامه بارگیری
final loadingPlanProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(driverApiProvider);
  return api.getLoadingPlan();
});

// تاریخچه تحویل‌ها
final myDeliveriesProvider = FutureProvider.family<List<dynamic>, String?>((ref, date) async {
  final api = ref.watch(driverApiProvider);
  return api.getMyDeliveries(date: date);
});