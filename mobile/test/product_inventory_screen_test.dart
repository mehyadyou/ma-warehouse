import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/data/manager_api_service.dart';
import 'package:ma_app/features/manager/dashboard/inventory_chart/product_inventory_screen.dart';
import 'package:ma_app/features/manager/models/manager_inventory_model.dart';
import 'package:ma_app/features/manager/models/product_models_model.dart';
import 'package:ma_app/features/manager/providers/manager_api_provider.dart';

class _FakeApi extends ManagerApiService {
  @override
  Future<ManagerInventoryModel> getManagerInventory() async {
    return ManagerInventoryModel(
      products: const [
        ManagerProductRowModel(
          productId: 'p1',
          name: 'سینک ظرفشویی',
          unit: 'عدد',
          totalCount: 200,
        ),
        ManagerProductRowModel(
          productId: 'p2',
          name: 'کولر گازی',
          unit: 'دستگاه',
          totalCount: 0,
        ),
      ],
      warehouses: const [
        WarehouseStockRowModel(
          warehouseName: 'انبار مرکزی',
          totalCount: 200,
          items: [
            StockItemRowModel(
              productId: 'p1',
              name: 'سینک ظرفشویی',
              unit: 'عدد',
              count: 200,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<ProductModelsData> getProductModels(String productId) async {
    return const ProductModelsData(
      product: ProductModelInfo(id: 'p1', name: 'سینک ظرفشویی', unit: 'عدد'),
      models: [
        ProductModelStockModel(
          modelId: 'm1',
          name: 'SL116',
          packageType: 'کارتن',
          unitsPerBox: 2,
          count: 200,
          warehouses: [
            ModelWarehouseRowModel(
              warehouseId: 'w1',
              warehouseName: 'انبار مرکزی',
              count: 200,
            ),
          ],
        ),
        ProductModelStockModel(
          modelId: 'm2',
          name: 'SL120',
          count: 0,
        ),
      ],
    );
  }
}

void main() {
  testWidgets('صفحه موجودی کل، محصولات را نشان میدهد', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          managerApiServiceProvider.overrideWithValue(_FakeApi()),
        ],
        child: const MaterialApp(home: ProductInventoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('موجودی کل'), findsOneWidget);
    expect(find.text('سینک ظرفشویی'), findsOneWidget);
    expect(find.text('200 عدد'), findsOneWidget);
    expect(find.text('کولر گازی'), findsOneWidget);
    expect(find.text('0 دستگاه'), findsOneWidget);
  });

  testWidgets('کلیک روی محصول، مدلها را همان صفحه باز میکند', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          managerApiServiceProvider.overrideWithValue(_FakeApi()),
        ],
        child: const MaterialApp(home: ProductInventoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SL116'), findsNothing);

    await tester.tap(find.text('سینک ظرفشویی'));
    await tester.pumpAndSettle();

    expect(find.text('SL116'), findsOneWidget);
    expect(find.text('200 عدد'), findsNWidgets(2));
    expect(find.text('کارتن • 2 در هر جعبه'), findsOneWidget);
    expect(find.text('SL120'), findsOneWidget);
    expect(find.text('موجودی کل'), findsOneWidget);

    await tester.tap(find.text('SL116'));
    await tester.pumpAndSettle();
    expect(find.text('انبار مرکزی'), findsOneWidget);
  });

  testWidgets('جستجو محصول را فیلتر میکند', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          managerApiServiceProvider.overrideWithValue(_FakeApi()),
        ],
        child: const MaterialApp(home: ProductInventoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'کولر');
    await tester.pumpAndSettle();

    expect(find.text('کولر گازی'), findsOneWidget);
    expect(find.text('سینک ظرفشویی'), findsNothing);
  });
}
