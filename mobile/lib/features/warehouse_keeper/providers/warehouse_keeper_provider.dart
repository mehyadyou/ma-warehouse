import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/warehouse_keeper_api_service.dart';
import '../models/keeper_inventory_model.dart';
import '../models/keeper_inventory_summary_model.dart';
import '../models/keeper_order_model.dart';
import '../models/keeper_transaction_model.dart';
import '../models/keeper_warehouse_model.dart';
import '../../../core/realtime/socket_service.dart';

final wkApiProvider = Provider((ref) => WarehouseKeeperApiService());

// Socket service - singleton, no circular dependency
final socketServiceProvider = Provider<SocketService>((ref) => SocketService());

final warehouseProvider =
    FutureProvider.autoDispose<KeeperWarehouseModel>((ref) async {
  try {
    return await ref.read(wkApiProvider).getMyWarehouse();
  } catch (_) {
    return const KeeperWarehouseModel();
  }
});

// Remove autoDispose for real-time sync
final ordersProvider = FutureProvider<List<KeeperOrderModel>>((ref) async {
  try {
    return await ref.read(wkApiProvider).getOrders();
  } catch (_) {
    return const [];
  }
});

// Remove autoDispose for real-time sync
final inventorySummaryProvider =
    FutureProvider<KeeperInventorySummaryModel>((ref) async {
  try {
    return await ref.read(wkApiProvider).getInventorySummary();
  } catch (_) {
    return const KeeperInventorySummaryModel();
  }
});

// Remove autoDispose for real-time sync
final keeperInventoryListProvider =
    FutureProvider<KeeperInventoryListModel>((ref) async {
  try {
    return await ref.read(wkApiProvider).getInventoryProducts();
  } catch (_) {
    return const KeeperInventoryListModel();
  }
});

final transactionsProvider =
    FutureProvider.autoDispose<List<KeeperTransactionModel>>((ref) async {
  try {
    return await ref.read(wkApiProvider).getTransactions();
  } catch (_) {
    return const [];
  }
});
