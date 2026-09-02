import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/warehouse_keeper_api_service.dart';
import '../models/keeper_carrier_model.dart';
import '../models/keeper_driver_model.dart';
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
/// نکته: کلید خانوادهٔ Riverpod با == مقایسه می‌شود؛ بدون پیاده‌سازی آن، هر build
/// یک provider تازه با حالت loading می‌سازد و صفحه هیچ‌وقت داده را نشان نمی‌دهد.
class KeeperInventoryQuery {
  final String query;
  final bool onlyInStock;
  const KeeperInventoryQuery({this.query = '', this.onlyInStock = false});

  @override
  bool operator ==(Object other) =>
      other is KeeperInventoryQuery &&
      other.query == query &&
      other.onlyInStock == onlyInStock;

  @override
  int get hashCode => Object.hash(query, onlyInStock);
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

/// رانندگان تعریف‌شده توسط مدیریت — بخش «مدیریت رانندگان» پنل انباردار
final driversProvider = FutureProvider<List<KeeperDriverModel>>((ref) async {
  return ref.read(wkApiProvider).getDrivers();
});

/// تیک زدن/برداشتن تیک راننده — پس از موفقیت، لیست رانندگان رفرش می‌شود
final driverAssignmentProvider = FutureProvider.family<void, ({String driverId, bool assigned})>((
  ref,
  args,
) async {
  final api = ref.read(wkApiProvider);
  await api.assignDriver(args.driverId, args.assigned);
  ref.invalidate(driversProvider);
});

/// باربری‌ها — منوی «باربری» پنل انباردار
final carriersProvider = FutureProvider<List<KeeperCarrierModel>>((ref) async {
  return ref.read(wkApiProvider).getCarriers();
});

/// ذخیرهٔ باربری (افزودن/ویرایش) — بعد از موفقیت لیست رفرش می‌شود
final carrierSaveProvider = FutureProvider.family<
    KeeperCarrierModel, ({String? id, String name, int priority, String? phone, String? address})>((
  ref,
  args,
) async {
  final api = ref.read(wkApiProvider);
  final carrier = args.id == null || args.id!.isEmpty
      ? await api.createCarrier(
          name: args.name,
          priority: args.priority,
          phone: args.phone,
          address: args.address,
        )
      : await api.updateCarrier(
          args.id!,
          name: args.name,
          priority: args.priority,
          phone: args.phone,
          address: args.address,
        );
  ref.invalidate(carriersProvider);
  return carrier;
});

/// حذف باربری — بعد از موفقیت لیست رفرش می‌شود
final carrierDeleteProvider = FutureProvider.family<void, String>((ref, id) async {
  final api = ref.read(wkApiProvider);
  await api.deleteCarrier(id);
  ref.invalidate(carriersProvider);
});

/// بازچینی صف بارگیری (درگ‌انددراپ) — لیست مرتب‌شدهٔ تازه از سرور برمی‌گردد؛
/// صفحه با همان لیست، UI خودش را به‌روز می‌کند (نیازی به invalidate نیست)
final carrierReorderProvider =
    FutureProvider.family<List<KeeperCarrierModel>, List<String>>((ref, ids) async {
  return ref.read(wkApiProvider).reorderCarriers(ids);
});
