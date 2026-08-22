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

/// فیلترهای تب «موجودی» — جستجو و فقط-موجودی به‌همراه صفحه‌بندی سمت سرور
class KeeperInventoryQuery {
  final String query;
  final bool onlyInStock;
  const KeeperInventoryQuery({this.query = '', this.onlyInStock = false});
}

/// صفحهٔ اول فهرست موجودی با فیلترها — خطاها به‌جای بلیع، در AsyncError می‌آیند
final keeperInventoryListProvider =
    FutureProvider.family<KeeperInventoryListModel, KeeperInventoryQuery>((
      ref,
      q,
    ) async {
      return ref
          .read(wkApiProvider)
          .getInventoryProducts(
            q: q.query.trim().isEmpty ? null : q.query,
            onlyInStock: q.onlyInStock,
          );
    });

final warehouseProvider = FutureProvider<KeeperWarehouseModel>((ref) async {
  return ref.read(wkApiProvider).getMyWarehouse();
});

final ordersProvider = FutureProvider<List<KeeperOrderModel>>((ref) async {
  return ref.read(wkApiProvider).getOrders();
});

final inventorySummaryProvider = FutureProvider<KeeperInventorySummaryModel>((
  ref,
) async {
  return ref.read(wkApiProvider).getInventorySummary();
});

final transactionsProvider = FutureProvider<List<KeeperTransactionModel>>((
  ref,
) async {
  return ref.read(wkApiProvider).getTransactions();
});
