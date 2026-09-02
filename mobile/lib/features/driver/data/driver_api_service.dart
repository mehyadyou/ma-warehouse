import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class DriverApiService {
  final _dio = DioClient().dio;

  /// لیست سفارش‌های آماده تحویل — hasWarehouse=false یعنی راننده به انباری متصل نیست
  Future<({List<dynamic> orders, bool hasWarehouse})> getReadyOrders() async {
    final res = await _dio.get('/driver/orders');
    return (
      orders: res.data['orders'] as List? ?? [],
      hasWarehouse: res.data['hasWarehouse'] as bool? ?? true,
    );
  }

  /// برنامه بارگیری (مرتب بر اساس اولویت باربری) — hasWarehouse=false یعنی راننده به انباری متصل نیست
  Future<Map<String, dynamic>> getLoadingPlan() async {
    final res = await _dio.get('/driver/loading-plan');
    return Map<String, dynamic>.from(res.data);
  }

  /// ثبت تحویل سفارش — عکس بیجک باربری الزامی است؛ بعد از آپلود، سفارش تحویل می‌شود
  Future<Map<String, dynamic>> deliverOrder(
    String orderId, {
    required Uint8List receiptBytes,
    String? notes,
  }) async {
    final formData = FormData.fromMap({
      'receipt': MultipartFile.fromBytes(receiptBytes, filename: 'bijak.jpg'),
      if (notes != null) 'notes': notes,
    });
    final res = await _dio.post('/driver/deliver/$orderId', data: formData);
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