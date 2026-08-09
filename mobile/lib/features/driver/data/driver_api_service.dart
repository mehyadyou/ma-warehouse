import '../../../core/network/dio_client.dart';

class DriverApiService {
  final _dio = DioClient().dio;

  /// لیست سفارش‌های آماده تحویل
  Future<List<dynamic>> getReadyOrders() async {
    final res = await _dio.get('/driver/orders');
    return res.data['orders'] ?? [];
  }

  /// برنامه بارگیری (مرتب بر اساس اولویت باربری)
  Future<Map<String, dynamic>> getLoadingPlan() async {
    final res = await _dio.get('/driver/loading-plan');
    return Map<String, dynamic>.from(res.data);
  }

  /// ثبت تحویل سفارش
  Future<Map<String, dynamic>> deliverOrder(String orderId, {String? notes}) async {
    final res = await _dio.post('/driver/deliver/$orderId', data: {
      if (notes != null) 'notes': notes,
    });
    return Map<String, dynamic>.from(res.data);
  }

  /// تاریخچه تحویل‌ها
  Future<List<dynamic>> getMyDeliveries({String? date}) async {
    final res = await _dio.get('/driver/deliveries', queryParameters: {
      if (date != null) 'date': date,
    });
    return res.data['deliveries'] ?? [];
  }
}