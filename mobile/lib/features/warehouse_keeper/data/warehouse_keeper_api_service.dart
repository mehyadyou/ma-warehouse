import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../manager/models/carton_search_model.dart';
import '../../manager/models/order_model.dart';
import '../../manager/models/transfer_model.dart';
import '../models/check_in_result_model.dart';
import '../models/keeper_carrier_model.dart';
import '../models/keeper_driver_model.dart';
import '../models/keeper_inventory_model.dart';
import '../models/keeper_inventory_summary_model.dart';
import '../models/keeper_order_model.dart';
import '../models/keeper_report_model.dart';
import '../models/keeper_product_model.dart';
import '../models/keeper_transaction_model.dart';
import '../models/keeper_warehouse_model.dart';
import '../models/loading_plan_item_model.dart';
import '../models/scan_out_result_model.dart';

class WarehouseKeeperApiService {
  final _dio = DioClient().dio;

  Future<KeeperWarehouseModel> getMyWarehouse() async {
    final res = await _dio.get('/warehouse-keeper/my-warehouse');
    return KeeperWarehouseModel.fromJson(
      Map<String, dynamic>.from(res.data['warehouse'] ?? {}),
    );
  }

  Future<List<KeeperOrderModel>> getOrders() async {
    final res = await _dio.get('/warehouse-keeper/orders');
    return (res.data['orders'] as List? ?? [])
        .map(
          (e) => KeeperOrderModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  /// جستجوی کارتن با سریال — فقط انبار خود انباردار
  Future<CartonSearchModel?> searchBySerial(String serial) async {
    try {
      final response = await _dio.get(
        '/warehouse-keeper/search/serial',
        queryParameters: {'serial': serial},
      );
      return CartonSearchModel.fromJson(response.data['carton']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// جستجوی ارسالی‌ها (فرستنده / گیرنده / کالا / مدل) — فقط انبار خود انباردار
  Future<List<OrderModel>> searchShipments({
    String? sender,
    String? receiver,
    String? product,
    String? model,
  }) async {
    final response = await _dio.get(
      '/warehouse-keeper/search/shipments',
      queryParameters: {
        if (sender != null && sender.trim().isNotEmpty) 'sender': sender.trim(),
        if (receiver != null && receiver.trim().isNotEmpty)
          'receiver': receiver.trim(),
        if (product != null && product.trim().isNotEmpty)
          'product': product.trim(),
        if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
      },
    );
    return (response.data['orders'] as List? ?? [])
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<KeeperInventorySummaryModel> getInventorySummary() async {
    final res = await _dio.get('/warehouse-keeper/inventory-summary');
    return KeeperInventorySummaryModel.fromJson(
      Map<String, dynamic>.from(res.data['summary'] ?? {}),
    );
  }

  Future<KeeperInventoryListModel> getInventoryProducts({
    int page = 1,
    int pageSize = 50,
    String? q,
    bool onlyInStock = false,
  }) async {
    final res = await _dio.get(
      '/warehouse-keeper/inventory/products',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (onlyInStock) 'onlyInStock': 'true',
      },
    );
    return KeeperInventoryListModel.fromJson(
      Map<String, dynamic>.from(res.data),
    );
  }

  Future<KeeperProductModelsData> getProductModels(String productId) async {
    final res = await _dio.get(
      '/warehouse-keeper/inventory/product/$productId',
    );
    return KeeperProductModelsData.fromJson(
      Map<String, dynamic>.from(res.data),
    );
  }

  Future<List<KeeperTransactionModel>> getTransactions({String? date}) async {
    final res = await _dio.get(
      '/warehouse-keeper/transactions',
      queryParameters: {'date': date},
    );
    return (res.data['transactions'] as List? ?? [])
        .map(
          (e) => KeeperTransactionModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<List<KeeperProductModel>> getProducts() async {
    final res = await _dio.get('/warehouse-keeper/products');
    return (res.data['products'] as List? ?? [])
        .map(
          (e) =>
              KeeperProductModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  /// صفحهٔ محصولات با جستجو — برای پیکر جستجوشونده (سقف سرور ۵۰۰)
  Future<({List<KeeperProductModel> products, int total})> getProductsPage({
    String q = '',
    required int page,
    required int pageSize,
  }) async {
    final res = await _dio.get(
      '/warehouse-keeper/products',
      queryParameters: {
        if (q.trim().isNotEmpty) 'q': q.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final list = (data['products'] as List? ?? [])
        .map(
          (e) =>
              KeeperProductModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    return (products: list, total: (data['total'] as int?) ?? 0);
  }

  Future<CheckInResultModel> submitCheckin(
    List<Map<String, dynamic>> items,
  ) async {
    final res = await _dio.post(
      '/warehouse-keeper/checkin',
      data: {'items': items},
    );
    return CheckInResultModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<ScanOutResultModel> scanOut(String qrPayload, {String? orderId, String? transferId}) async {
    final res = await _dio.post(
      '/warehouse-keeper/scan-out',
      data: {
        'qrPayload': qrPayload,
        if (orderId != null) 'orderId': orderId,
        if (transferId != null) 'transferId': transferId,
      },
    );
    return ScanOutResultModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<ScanOutResultModel> scanOutSerial(String serialNumber, {String? orderId, String? transferId}) async {
    final res = await _dio.post(
      '/warehouse-keeper/scan-out',
      data: {
        'serialNumber': serialNumber,
        if (orderId != null) 'orderId': orderId,
        if (transferId != null) 'transferId': transferId,
      },
    );
    return ScanOutResultModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// خروج دستی (بدون QR) برای محصولاتی که برچسب ندارند — محصول + مدل + تعداد،
  /// اعتبارسنجی مطابق سفارش یا دستور خروج/جابه‌جایی مدیر سمت سرور انجام می‌شود
  /// [driverId] اگر داده شود، این بار (سفارش) برای همان رانندهٔ تیک‌خورده تعریف می‌شود.
  /// [orderId]/[transferId] وقتی چند هدف فعال است از پیکر انتخاب می‌شوند.
  Future<ScanOutResultModel> manualExit({
    required String productId,
    String? modelId,
    required int quantity,
    String? driverId,
    String? orderId,
    String? transferId,
  }) async {
    final res = await _dio.post(
      '/warehouse-keeper/scan-out/manual',
      data: {
        'productId': productId,
        if (modelId != null && modelId.trim().isNotEmpty) 'modelId': modelId,
        'quantity': quantity,
        if (driverId != null && driverId.trim().isNotEmpty) 'driverId': driverId,
        if (orderId != null && orderId.trim().isNotEmpty) 'orderId': orderId,
        if (transferId != null && transferId.trim().isNotEmpty) 'transferId': transferId,
      },
    );
    return ScanOutResultModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// تعریف بار (سفارش) برای راننده — بعد از اسکن خروج، انباردار راننده را از
  /// لیست رانندگان تیک‌خورده انتخاب می‌کند
  Future<Map<String, dynamic>> assignDriverToOrder(String orderId, String driverId) async {
    final res = await _dio.post(
      '/warehouse-keeper/scan-out/assign-driver',
      data: {'orderId': orderId, 'driverId': driverId},
    );
    return Map<String, dynamic>.from(res.data);
  }

  /// گزارش عملکرد انباردار — نمودارها + فیلتر بازه و محدوده (فعالیت‌های من / کل انبار)
  Future<KeeperReportsData> getReports({
    required String from,
    required String to,
    String scope = 'mine',
  }) async {
    final res = await _dio.get(
      '/warehouse-keeper/reports',
      queryParameters: {'from': from, 'to': to, 'scope': scope},
    );
    return KeeperReportsData.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// کارتن‌های خروج‌زده‌شده برای یک سفارش خاص — نمایش پیشرفت خروج
  Future<List<Map<String, dynamic>>> getOrderCartons(String orderId) async {
    final res = await _dio.get('/warehouse-keeper/orders/$orderId/cartons');
    return (res.data['cartons'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// دستورات جابه‌جایی/خروج مدیر برای انبار خودم — برای اجرا با اسکن
  Future<List<TransferModel>> getTransfers({int limit = 50}) async {
    final res = await _dio.get(
      '/warehouse-keeper/transfers',
      queryParameters: {'limit': limit},
    );
    return (res.data['transfers'] as List? ?? [])
        .map((e) => TransferModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<LoadingPlanItemModel>> getLoadingPlan(
    List<Map<String, dynamic>> items,
    String strategy,
  ) async {
    final res = await _dio.post(
      '/warehouse-keeper/loading-plan',
      data: {'items': items, 'strategy': strategy},
    );
    return (res.data['plan'] as List? ?? [])
        .map(
          (e) => LoadingPlanItemModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// رانندگان تعریف‌شده توسط مدیریت — بخش «مدیریت رانندگان» پنل انباردار
  Future<List<KeeperDriverModel>> getDrivers() async {
    final res = await _dio.get('/warehouse-keeper/drivers');
    return (res.data['drivers'] as List? ?? [])
        .map(
          (e) => KeeperDriverModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// تیک زدن/برداشتن تیک راننده — اتصال/قطع راننده به انبارِ خودِ انباردار
  Future<void> assignDriver(String driverId, bool assigned) async {
    await _dio.put(
      '/warehouse-keeper/drivers/$driverId',
      data: {'assigned': assigned},
    );
  }

  /// باربری‌ها — منوی «باربری» پنل انباردار (همان لیستی که مدیر هنگام ثبت سفارش می‌بیند)
  Future<List<KeeperCarrierModel>> getCarriers() async {
    final res = await _dio.get('/warehouse-keeper/carriers');
    return (res.data['carriers'] as List? ?? [])
        .map(
          (e) => KeeperCarrierModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// افزودن باربری جدید
  Future<KeeperCarrierModel> createCarrier({
    required String name,
    int priority = 0,
    String? phone,
    String? address,
  }) async {
    final res = await _dio.post(
      '/warehouse-keeper/carriers',
      data: {
        'name': name,
        'priority': priority,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
      },
    );
    return KeeperCarrierModel.fromJson(
      Map<String, dynamic>.from(res.data['carrier'] as Map),
    );
  }

  /// ویرایش باربری — فقط فیلدهای ارسالی تغییر می‌کنند
  Future<KeeperCarrierModel> updateCarrier(
    String id, {
    String? name,
    int? priority,
    String? phone,
    String? address,
  }) async {
    final res = await _dio.put(
      '/warehouse-keeper/carriers/$id',
      data: {
        if (name != null) 'name': name,
        if (priority != null) 'priority': priority,
        'phone': (phone == null || phone.trim().isEmpty) ? null : phone.trim(),
        'address': (address == null || address.trim().isEmpty) ? null : address.trim(),
      },
    );
    return KeeperCarrierModel.fromJson(
      Map<String, dynamic>.from(res.data['carrier'] as Map),
    );
  }

  /// حذف باربری — سفارش‌های قبلی نام باربری را نگه داشته‌اند
  Future<void> deleteCarrier(String id) async {
    await _dio.delete('/warehouse-keeper/carriers/$id');
  }

  /// تغییر ترتیب صف بارگیری (درگ‌انددراپ انباردار) — [ids] همان ترتیب جدید از بالا به پایین است؛
  /// اولویت‌ها سمت سرور بازچینی می‌شوند تا برنامهٔ بارگیری راننده همان ترتیب را بگیرد
  Future<List<KeeperCarrierModel>> reorderCarriers(List<String> ids) async {
    final res = await _dio.put(
      '/warehouse-keeper/carriers/reorder',
      data: {'ids': ids},
    );
    return (res.data['carriers'] as List? ?? [])
        .map((e) => KeeperCarrierModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
