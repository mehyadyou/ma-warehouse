import 'dart:typed_data';

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
import '../models/shipment_report_model.dart';
import '../models/transfer_model.dart';
import '../models/delivery_inbox_item.dart';
import '../models/product_history_model.dart';

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

  Future<List<ProductModel>> getProducts({
    String? q,
    int? page,
    int? pageSize,
  }) async {
    final response = await _dio.get(
      '/manager/products',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (page != null) 'page': page,
        if (pageSize != null) 'pageSize': pageSize,
      },
    );
    final data = response.data['products'] as List;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  /// صفحهٔ مشخص از محصولات + تعداد کل (برای لیست صفحه‌بندی‌شده)
  Future<({List<ProductModel> products, int total})> getProductsPage({
    String? q,
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get(
      '/manager/products',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = response.data;
    final list = (data['products'] as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
    return (products: list, total: (data['total'] as int?) ?? 0);
  }

  /// یک محصول با مدل‌هایش (برای فرم ویرایش)
  Future<ProductModel> getProduct(String id) async {
    final response = await _dio.get('/manager/products/$id');
    return ProductModel.fromJson(
      response.data['product'] as Map<String, dynamic>,
    );
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
        Map<String, dynamic>.from(data['warehouse'] as Map),
      );
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
    final response = await _dio.get(
      '${ApiConstants.managerWarehouses}/archived',
    );
    return (response.data['warehouses'] as List)
        .map((e) => ArchivedWarehouseModel.fromJson(e))
        .toList();
  }

  Future<void> restoreWarehouse(String id) async {
    await _dio.post('${ApiConstants.managerWarehouses}/$id/restore');
  }

  Future<List<TransactionEntryModel>> getTransactionsByDate(
    String warehouseId,
    String date,
  ) async {
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
    final response = await _dio.get(
      '${ApiConstants.managerWarehouses}/$warehouseId/detail',
    );
    return WarehouseDetailModel.fromJson(response.data);
  }

  Future<InventorySummaryModel> getInventorySummary() async {
    final response = await _dio.get('/manager/inventory-summary');
    return InventorySummaryModel.fromJson(response.data);
  }

  /// نمودارهای عمودی موجودی: مجموع هر محصول در همهٔ انبارها + ریز هر انبار
  /// page/pageSize: صفحهٔ محصولات (مرتب بر موجودی نزولی) — سقف سرور ۵۰۰
  /// q/onlyInStock: جستجو و فیلتر سمت سرور
  Future<ManagerInventoryModel> getManagerInventory({
    int page = 1,
    int pageSize = 12,
    String? q,
    bool onlyInStock = false,
    String? warehouseId,
  }) async {
    final response = await _dio.get(
      '/manager/inventory',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (onlyInStock) 'onlyInStock': 'true',
        if (warehouseId != null && warehouseId.trim().isNotEmpty)
          'warehouseId': warehouseId,
      },
    );
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

  /// گزارش ارسالی‌ها: تعداد هر انبار + تاریخچهٔ روزانه + آخرین ارسالی
  Future<ShipmentReportModel> getShipmentsReport() async {
    final response = await _dio.get('/manager/shipments-report');
    return ShipmentReportModel.fromJson(response.data);
  }

  Future<HistoryPageResult> getHistoryPage({
    int page = 1,
    int pageSize = 50,
    String? category,
    String? q,
  }) async {
    final response = await _dio.get(
      '/manager/history',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (category != null && category != 'all') 'category': category,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    return HistoryPageResult(
      entries: ((data['entries'] as List?) ?? [])
          .map((e) => HistoryEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: ((data['total'] as num?) ?? 0).toInt(),
    );
  }

  /// جستجوی کارتن با سریال — مکان فعلی و مرحله
  Future<CartonSearchModel?> searchBySerial(String serial) async {
    try {
      final response = await _dio.get(
        '/manager/search/serial',
        queryParameters: {'serial': serial},
      );
      return CartonSearchModel.fromJson(response.data['carton']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// سابقهٔ کامل محصولات — لیست تجمیعی با فیلترهای دقیق و صفحه‌بندی
  /// [activityDate] = تاریخِ شمسیِ دقیق (yyyy-mm-dd) — فقط محصولاتی که همان روز فعالیتی داشته‌اند
  Future<ProductHistoryPage> getProductHistory({
    int page = 1,
    int pageSize = 20,
    String? q,
    String? warehouseId,
    String? exitType, // any | carton | individual | none
    String? serial,
    String? customerPhone,
    String? from,
    String? to,
    String? activityDate,
  }) async {
    final response = await _dio.get(
      '/manager/product-history',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (warehouseId != null && warehouseId.isNotEmpty) 'warehouseId': warehouseId,
        if (exitType != null && exitType != 'any') 'exitType': exitType,
        if (serial != null && serial.trim().isNotEmpty) 'serial': serial.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          'customerPhone': customerPhone.trim(),
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        if (activityDate != null && activityDate.isNotEmpty) 'activityDate': activityDate,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final pagination = (data['pagination'] as Map?) ?? const {};
    return ProductHistoryPage(
      rows: ((data['rows'] as List?) ?? [])
          .map((r) => ProductHistoryRow.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList(),
      total: ((pagination['total'] as num?) ?? 0).toInt(),
      hasMore: pagination['hasMore'] == true,
    );
  }

  /// سابقهٔ کامل یک محصول — کارتن‌ها با سریال، تراکنش‌ها، جابه‌جایی/خروج
  /// [activityDate] = فقط رخدادهای همان روزِ شمسی (yyyy-mm-dd)
  Future<ProductHistoryDetailModel> getProductHistoryDetail(
    String productId, {
    String? warehouseId,
    String? modelId,
    String? activityDate,
  }) async {
    final response = await _dio.get(
      '/manager/product-history/$productId',
      queryParameters: {
        if (warehouseId != null && warehouseId.isNotEmpty) 'warehouseId': warehouseId,
        if (modelId != null && modelId.isNotEmpty) 'modelId': modelId,
        if (activityDate != null && activityDate.isNotEmpty) 'activityDate': activityDate,
      },
    );
    return ProductHistoryDetailModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// لیست ارسالی‌ها (سفارش‌های ثبت‌شده) با صفحه‌بندی و شمارندهٔ وضعیت‌ها
  /// [status] = فیلتر وضعیت سمت سرور: pending | in_transit | delivered | other
  Future<OrdersPageModel> getOrders({
    int page = 1,
    int pageSize = 50,
    String? status,
  }) async {
    final response = await _dio.get(
      '/manager/orders',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status,
      },
    );
    return OrdersPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// موجودی قابل سفارش محصولات مشخص در یک انبار (کارتن + لِگاسی)
  Future<Map<String, int>> getOrderStock(
    String warehouseId,
    List<String> productIds,
  ) async {
    final ids = productIds.where((p) => p.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return {};
    final response = await _dio.get(
      '/manager/orders/stock',
      queryParameters: {
        'warehouseId': warehouseId,
        'productIds': ids.join(','),
      },
    );
    final list = (response.data['stock'] as List? ?? []);
    return {
      for (final e in list)
        if (e is Map && e['productId'] != null)
          e['productId'] as String: ((e['available'] as num?) ?? 0).toInt(),
    };
  }

  /// ثبت سفارش جدید — سفارش ساخته‌شده (با شمارهٔ خودکار) برمی‌گردد
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final response = await _dio.post('/manager/orders', data: data);
    final order = (response.data as Map?)?['order'];
    if (order is Map) {
      return OrderModel.fromJson(Map<String, dynamic>.from(order));
    }
    return const OrderModel(id: '');
  }

  /// ویرایش سفارش
  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    await _dio.put('/manager/orders/$id', data: data);
  }

  /// حذف سفارش
  Future<void> deleteOrder(String id) async {
    await _dio.delete('/manager/orders/$id');
  }

  /// جستجوی ارسالی‌ها — متن آزاد یا فیلد‌به‌فیلد، صفحه‌بندی‌شده
  Future<OrdersPageModel> searchShipments({
    String? q,
    String? sender,
    String? receiver,
    String? product,
    String? model,
    String? status,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      '/manager/search/shipments',
      queryParameters: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (sender != null && sender.trim().isNotEmpty) 'sender': sender.trim(),
        if (receiver != null && receiver.trim().isNotEmpty)
          'receiver': receiver.trim(),
        if (product != null && product.trim().isNotEmpty)
          'product': product.trim(),
        if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return OrdersPageModel.fromJson(response.data as Map<String, dynamic>);
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

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _dio.put('/manager/products/$productId', data: data);
  }

  Future<void> updateModel(String modelId, Map<String, dynamic> data) async {
    await _dio.put('/manager/product-models/$modelId', data: data);
  }

  /// افزودن اتمی مدل‌های جدید به محصول موجود — یک درخواست، یک تراکنش در سرور
  Future<void> addProductModels(
    String productId,
    List<Map<String, dynamic>> models,
  ) async {
    await _dio.post(
      '/manager/products/$productId/models',
      data: {'models': models},
    );
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

  /// ثبت خروج یا جابه‌جایی محصول توسط مدیر (دستور دوفازی)
  /// [toWarehouseId] = فقط برای جابه‌جایی؛ خروج بدون مقصد، کالا را از سیستم خارج می‌کند
  Future<void> createTransfer({
    required String fromWarehouseId,
    String? toWarehouseId,
    required String productId,
    String? modelId,
    required int quantity,
    String description = '',
  }) async {
    await _dio.post('/manager/transfers', data: {
      'fromWarehouseId': fromWarehouseId,
      if (toWarehouseId != null && toWarehouseId.trim().isNotEmpty)
        'toWarehouseId': toWarehouseId.trim(),
      'productId': productId,
      if (modelId != null && modelId.trim().isNotEmpty) 'modelId': modelId.trim(),
      'quantity': quantity,
      'description': description.trim(),
    });
  }

  /// لغو دستور در انتظار (فقط PENDING و بدون اسکن اجراشده)
  Future<void> cancelTransfer(String transferId) async {
    await _dio.post('/manager/transfers/$transferId/cancel');
  }

  /// آخرین جابه‌جایی‌ها/خروج‌های ثبت‌شده
  Future<List<TransferModel>> getTransfers({int limit = 20}) async {
    final response = await _dio.get(
      '/manager/transfers',
      queryParameters: {'limit': limit},
    );
    return (response.data['transfers'] as List)
        .map((json) => TransferModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// صندوق تحویل: عکس‌های بیجک باربری — فیلتر راننده و روز/ماه/سال شمسی
  /// [year] و [month] و [day] همه شمسی‌اند؛ برای ماه/روز باید سال هم داده شود
  Future<List<DeliveryInboxItem>> getDeliveryInbox({
    String? driverId,
    int? year,
    int? month,
    int? day,
  }) async {
    final response = await _dio.get(
      '/manager/delivery-inbox',
      queryParameters: {
        if (driverId != null && driverId.isNotEmpty) 'driverId': driverId,
        if (year != null) 'year': year,
        if (month != null) 'month': month,
        if (day != null) 'day': day,
      },
    );
    return (response.data['deliveries'] as List? ?? [])
        .map((e) => DeliveryInboxItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// راننده‌هایی که حداقل یک بیجک در صندوق ثبت کرده‌اند (برای فیلتر راننده)
  Future<List<DeliveryInboxDriver>> getDeliveryInboxDrivers() async {
    final response = await _dio.get('/manager/delivery-inbox/drivers');
    return (response.data['drivers'] as List? ?? [])
        .map((e) => DeliveryInboxDriver.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// دانلود بایت‌های یک فایل (مثلاً عکس بیجک) — برای اشتراک‌گذاری تصویر
  Future<Uint8List> downloadFileBytes(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }
}

class HistoryPageResult {
  final List<HistoryEntryModel> entries;
  final int total;
  const HistoryPageResult({required this.entries, required this.total});
}
