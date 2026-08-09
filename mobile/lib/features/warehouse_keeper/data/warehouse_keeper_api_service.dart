import '../../../core/network/dio_client.dart';
import '../models/check_in_result_model.dart';
import '../models/keeper_inventory_model.dart';
import '../models/keeper_inventory_summary_model.dart';
import '../models/keeper_order_model.dart';
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
        Map<String, dynamic>.from(res.data['warehouse'] ?? {}));
  }

  Future<List<KeeperOrderModel>> getOrders() async {
    final res = await _dio.get('/warehouse-keeper/orders');
    return (res.data['orders'] as List? ?? [])
        .map((e) => KeeperOrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<KeeperInventorySummaryModel> getInventorySummary() async {
    final res = await _dio.get('/warehouse-keeper/inventory-summary');
    return KeeperInventorySummaryModel.fromJson(
        Map<String, dynamic>.from(res.data['summary'] ?? {}));
  }

  Future<KeeperInventoryListModel> getInventoryProducts() async {
    final res = await _dio.get('/warehouse-keeper/inventory/products');
    return KeeperInventoryListModel.fromJson(
        Map<String, dynamic>.from(res.data));
  }

  Future<KeeperProductModelsData> getProductModels(String productId) async {
    final res = await _dio.get('/warehouse-keeper/inventory/product/$productId');
    return KeeperProductModelsData.fromJson(
        Map<String, dynamic>.from(res.data));
  }

  Future<List<KeeperTransactionModel>> getTransactions({String? date}) async {
    final res = await _dio.get('/warehouse-keeper/transactions',
        queryParameters: {'date': date});
    return (res.data['transactions'] as List? ?? [])
        .map((e) =>
            KeeperTransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<KeeperProductModel>> getProducts() async {
    final res = await _dio.get('/warehouse-keeper/products');
    return (res.data['products'] as List? ?? [])
        .map((e) => KeeperProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<CheckInResultModel> submitCheckin(List<Map<String, dynamic>> items) async {
    final res = await _dio.post('/warehouse-keeper/checkin', data: {'items': items});
    return CheckInResultModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<ScanOutResultModel> scanOut(String qrPayload) async {
    final res = await _dio.post('/warehouse-keeper/scan-out', data: {'qrPayload': qrPayload});
    return ScanOutResultModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<ScanOutResultModel> scanOutSerial(String serialNumber) async {
    final res = await _dio.post('/warehouse-keeper/scan-out', data: {
      'serialNumber': serialNumber,
    });
    return ScanOutResultModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<List<LoadingPlanItemModel>> getLoadingPlan(
    List<Map<String, dynamic>> items,
    String strategy,
  ) async {
    final res = await _dio.post('/warehouse-keeper/loading-plan', data: {
      'items': items,
      'strategy': strategy,
    });
    return (res.data['plan'] as List? ?? [])
        .map((e) =>
            LoadingPlanItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
