import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/warehouse_keeper/data/warehouse_keeper_api_service.dart';
import 'package:ma_app/features/warehouse_keeper/dashboard/inventory/inventory_list_view.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_inventory_model.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';

class _FakeApi extends WarehouseKeeperApiService {
  @override
  Future<KeeperInventoryListModel> getInventoryProducts({
    int page = 1,
    int pageSize = 50,
    String? q,
    bool onlyInStock = false,
  }) async {
    final query = q?.trim().toLowerCase() ?? '';
    final all = <KeeperProductRowModel>[
      const KeeperProductRowModel(
        productId: 'p0',
        name: 'سینک ظرفشویی',
        unit: 'عدد',
        totalCount: 200,
        models: [
          KeeperProductModelStockModel(
            modelId: 'm1',
            name: 'SL116',
            packageType: 'کارتن',
            unitsPerBox: 2,
            count: 200,
          ),
          KeeperProductModelStockModel(modelId: 'm2', name: 'SL120', count: 0),
        ],
      ),
      const KeeperProductRowModel(
        productId: 'p1',
        name: 'کولر گازی',
        unit: 'دستگاه',
        totalCount: 0,
      ),
    ];
    var list = all;
    if (query.isNotEmpty) {
      list = list
          .where((p) => (p.name ?? '').toLowerCase().contains(query))
          .toList();
    }
    if (onlyInStock) {
      list = list.where((p) => p.totalCount.toInt() > 0).toList();
    }
    return KeeperInventoryListModel(
      products: list,
      total: list.length,
      page: page,
      pageSize: pageSize,
      hasMore: false,
      warehouses: const [
        KeeperWarehouseStockRowModel(
          warehouseId: 'w1',
          warehouseName: 'انبار مرکزی',
          totalCount: 200,
          items: [
            KeeperStockItemRowModel(
              productId: 'p0',
              name: 'سینک ظرفشویی',
              unit: 'عدد',
              count: 200,
            ),
          ],
        ),
      ],
    );
  }
}

Widget _app() => ProviderScope(
  overrides: [wkApiProvider.overrideWithValue(_FakeApi())],
  child: const MaterialApp(home: Scaffold(body: InventoryListView())),
);

void main() {
  testWidgets('صفحهٔ موجودی انباردار پس از بارگذاری، محصولات و مدل‌ها را نشان می‌دهد', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    // نباید تا ابد در حالت loading بماند — داده باید نمایش داده شود
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // نام هر محصول هم در نمودار ستونی و هم در کارت محصول می‌آید
    expect(find.text('سینک ظرفشویی'), findsNWidgets(2));
    expect(find.text('کولر گازی'), findsNWidgets(2));
    expect(find.text('SL116'), findsOneWidget);
    expect(find.text('۲۰۰ عدد'), findsWidgets);
  });

  testWidgets('فیلتر فقط-موجودی، محصولات بدون موجودی را حذف می‌کند', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.tap(find.text('فقط موجودی'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('سینک ظرفشویی'), findsNWidgets(2));
    expect(find.text('کولر گازی'), findsNothing);
  });
}
