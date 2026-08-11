import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/warehouse_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/archive_models.dart';
import '../models/inventory_summary_model.dart';
import '../models/manager_inventory_model.dart';
import '../models/product_models_model.dart';
import '../models/warehouse_inventory_row_model.dart';
import '../models/warehouse_detail_model.dart';
import '../models/carton_search_model.dart';
import '../models/history_entry_model.dart';
import '../models/carrier_model.dart';
import '../models/recent_activity_model.dart';
import '../models/transaction_entry_model.dart';
import '../models/user_report_model.dart';

class ManagerApiService {
  final Dio _dio = DioClient().dio;

  Future<List<WarehouseModel>> getWarehouses() async {
    final response = await _dio.get(ApiConstants.managerWarehouses);
    final data = response.data['warehouses'] as List;
    return data.map((json) => WarehouseModel.fromJson(json)).toList();
  }

  /// لیست کاربران فعال (برای انتخاب انباردار)
  Future<List<UserModel>> getUsers() async {
    final response = await _dio.get(ApiConstants.managerUsers);
    return (response.data['users'] as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  Future<List<ProductModel>> getProducts({String? q, int? page, int? pageSize}) async {
    final response = await _dio.get('/manager/products', queryParameters: {
      if (q != null && q.isNotEmpty) 'q': q,
      if (page != null) 'page': page,
      if (pageSize != null) 'pageSize': pageSize,
    });
    final data = response.data['products'] as List;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  /// صفحهٔ مشخص از محصولات + تعداد کل (برای لیست صفحه‌بندی‌شده)
  Future<({List<ProductModel> products, int total})> getProductsPage({
    String? q,
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get('/manager/products', queryParameters: {
      if (q != null && q.isNotEmpty) 'q': q,
      'page': page,
      'pageSize': pageSize,
    });
    final data = response.data;
    final list = (data['products'] as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
    return (products: list, total: (data['total'] as int?) ?? 0);
  }

  /// لیست محصولات بایگانی‌شده (برای بازیابی)
  Future<List<ArchivedProductModel>> getArchivedProducts() async {
    final response = await _dio.get('/manager/products/archived');
    return (response.data['products'] as List)
        .map((e) => ArchivedProductModel.fromJson(e))
        .toList();
  }

  /// بازگرداندن محصول/مدل بایگانی‌شده
  Future<void> restoreProduct(String id) async {
    await _dio.post('/manager/products/$id/restore');
  }

  Future<void> restoreModel(String id) async {
    await _dio.post('/manager/product-models/$id/restore');
  }

  Future<WarehouseModel> createWarehouseWithKeeper({
    required String warehouseName,
    required String keeperName,
    required String keeperPhone,
    required String keeperPassword,
  }) async {
    final response = await _dio.post(
      ApiConstants.createWarehouseWithKeeper,
      data: {
        'warehouseName': warehouseName,
        'keeperName': keeperName,
        'keeperPhone': keeperPhone,
        'keeperPassword': keeperPassword,
      },
    );
    final data = response.data;
    if (data is Map && data['warehouse'] is Map) {
      return WarehouseModel.fromJson(
          Map<String, dynamic>.from(data['warehouse'] as Map));
    }
    return WarehouseModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> updateWarehouse({
    required String id,
    required String name,
    String? address,
    String? keeperId,
  }) async {
    await _dio.put(
      '${ApiConstants.managerWarehouses}/$id',
      data: {'name': name, 'address': address, 'keeperId': keeperId},
    );
  }

  Future<void> deleteWarehouse(String id) async {
    await _dio.delete('${ApiConstants.managerWarehouses}/$id');
  }

  /// لیست انبارهای بایگانی‌شده (برای بازیابی)
  Future<List<ArchivedWarehouseModel>> getArchivedWarehouses() async {
    final response = await _dio.get('${ApiConstants.managerWarehouses}/archived');
    return (response.data['warehouses'] as List)
        .map((e) => ArchivedWarehouseModel.fromJson(e))
        .toList();
  }

  Future<void> restoreWarehouse(String id) async {
    await _dio.post('${ApiConstants.managerWarehouses}/$id/restore');
  }

  Future<List<TransactionEntryModel>> getTransactionsByDate(String warehouseId, String date) async {
    final response = await _dio.get(
      '${ApiConstants.managerWarehouses}/$warehouseId/transactions',
      queryParameters: {'date': date},
    );
    return (response.data['transactions'] as List)
        .map((e) => TransactionEntryModel.fromJson(e))
        .toList();
  }

  /// جزئیات کامل یک انبار: آمار ورود/خروج + موجودی محصولات (صفحه جزئیات انبار)
  Future<WarehouseDetailModel> getWarehouseDetail(String warehouseId) async {
    final response = await _dio.get('${ApiConstants.managerWarehouses}/$warehouseId/detail');
    return WarehouseDetailModel.fromJson(response.data);
  }

  Future<InventorySummaryModel> getInventorySummary() async {
    final response = await _dio.get('/manager/inventory-summary');
    return InventorySummaryModel.fromJson(response.data);
  }

  /// نمودارهای عمودی موجودی: مجموع هر محصول در همهٔ انبارها + ریز هر انبار
  Future<ManagerInventoryModel> getManagerInventory() async {
    final response = await _dio.get('/manager/inventory');
    return ManagerInventoryModel.fromJson(response.data);
  }

  /// مدل‌های یک محصول به‌همراه موجودی هر مدل در هر انبار
  Future<ProductModelsData> getProductModels(String productId) async {
    final response = await _dio.get('/manager/inventory/product/$productId');
    return ProductModelsData.fromJson(response.data);
  }

  Future<List<WarehouseInventoryRowModel>> getWarehouseInventory() async {
    final response = await _dio.get('/manager/warehouse-inventory');
    return (response.data['inventory'] as List)
        .map((e) => WarehouseInventoryRowModel.fromJson(e))
        .toList();
  }

  Future<RecentActivityData> getRecentActivities() async {
    final response = await _dio.get('/manager/recent-activities');
    return RecentActivityData.fromJson(response.data);
  }

  Future<List<HistoryEntryModel>> getHistory() async {
    final response = await _dio.get('/manager/history');
    return (response.data['entries'] as List? ?? [])
        .map((e) => HistoryEntryModel.fromJson(e))
        .toList();
  }

  /// جستجوی کارتن با سریال — مکان فعلی و مرحله
  Future<CartonSearchModel?> searchBySerial(String serial) async {
    try {
      final response = await _dio.get('/manager/search/serial', queryParameters: {'serial': serial});
      return CartonSearchModel.fromJson(response.data['carton']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// لیست کامل ارسالی‌ها (سفارش‌های ثبت‌شده) با جزئیات دقیق
  Future<List<OrderModel>> getOrders() async {
    final response = await _dio.get('/manager/orders');
    return (response.data['orders'] as List)
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }

  /// ثبت سفارش جدید
  Future<void> createOrder(Map<String, dynamic> data) async {
    await _dio.post('/manager/orders', data: data);
  }

  /// ویرایش سفارش
  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    await _dio.put('/manager/orders/$id', data: data);
  }

  /// حذف سفارش
  Future<void> deleteOrder(String id) async {
    await _dio.delete('/manager/orders/$id');
  }

  /// جستجوی ارسالی‌ها (فرستنده / گیرنده / کالا / مدل) — مرحله ارسال
  Future<List<OrderModel>> searchShipments({
    String? sender,
    String? receiver,
    String? product,
    String? model,
  }) async {
    final response = await _dio.get('/manager/search/shipments', queryParameters: {
      if (sender != null && sender.trim().isNotEmpty) 'sender': sender.trim(),
      if (receiver != null && receiver.trim().isNotEmpty) 'receiver': receiver.trim(),
      if (product != null && product.trim().isNotEmpty) 'product': product.trim(),
      if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
    });
    return (response.data['orders'] as List)
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }

  /// نرخ دلار آزاد (تومان) — tgju؛ روی خطا null برمی‌گرداند تا UI دست نگه دارد
  Future<double?> getDollarRate() async {
    try {
      final response = await _dio.get('/manager/rate/dollar');
      final rate = response.data['rate'];
      if (rate == null) return null;
      final price = rate['price'];
      if (price is num) return price.toDouble();
      return double.tryParse('$price');
    } on DioException {
      return null;
    }
  }

  /// لیست شرکت‌های باربری
  Future<List<CarrierModel>> getCarriers() async {
    final response = await _dio.get('/manager/carriers');
    return (response.data['carriers'] as List? ?? [])
        .map((e) => CarrierModel.fromJson(e))
        .toList();
  }

  Future<void> deleteProduct(String productId) async {
    await _dio.delete('/manager/products/$productId');
  }

  Future<void> deleteModel(String modelId) async {
    await _dio.delete('/manager/product-models/$modelId');
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _dio.post('/manager/products', data: data);
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _dio.put('/manager/products/$productId', data: data);
  }

  Future<void> updateModel(String modelId, Map<String, dynamic> data) async {
    await _dio.put('/manager/product-models/$modelId', data: data);
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete('/manager/users/$id');
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _dio.put('/manager/users/$id', data: data);
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await _dio.post('/manager/users', data: data);
  }

  /// گزارش کامل یک کاربر: پروفایل، آمار، آخرین و فعالیت‌های اخیر
  Future<UserReportModel> getUserReport(String userId) async {
    final response = await _dio.get('/manager/users/$userId/report');
    return UserReportModel.fromJson(response.data);
  }
}
