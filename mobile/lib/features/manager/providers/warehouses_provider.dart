import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manager_api_provider.dart';
import '../models/warehouse_model.dart';
import '../models/inventory_summary_model.dart';

// Provider for inventory summary (used in InventoryChartCard)
// Remove autoDispose for real-time sync — خطاها بهجای بلیع، در AsyncError میآیند
final managerInventorySummaryProvider = FutureProvider<InventorySummaryModel>((
  ref,
) async {
  return ref.read(managerApiServiceProvider).getInventorySummary();
});

final warehousesProvider =
    AsyncNotifierProvider<WarehousesNotifier, List<WarehouseModel>>(
      WarehousesNotifier.new,
    );

class WarehousesNotifier extends AsyncNotifier<List<WarehouseModel>> {
  @override
  Future<List<WarehouseModel>> build() async {
    final apiService = ref.read(managerApiServiceProvider);
    return apiService.getWarehouses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiService = ref.read(managerApiServiceProvider);
      return apiService.getWarehouses();
    });
  }
}
