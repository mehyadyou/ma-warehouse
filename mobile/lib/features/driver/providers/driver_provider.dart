import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/driver_api_service.dart';
import '../../../core/realtime/socket_service.dart';

final driverApiProvider = Provider<DriverApiService>((ref) => DriverApiService());

// Socket service - singleton, بدون وابستگی چرخه‌ای
final socketServiceProvider = Provider<SocketService>((ref) => SocketService());

// لیست سفارش‌های آماده — hasWarehouse=false یعنی راننده به انباری متصل نیست
final readyOrdersProvider =
    FutureProvider<({List<dynamic> orders, bool hasWarehouse})>((ref) async {
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