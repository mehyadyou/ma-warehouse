import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/data/manager_api_service.dart';
import 'package:ma_app/features/manager/dashboard/inventory_chart/product_inventory_screen.dart';
import 'package:ma_app/features/manager/models/manager_inventory_model.dart';
import 'package:ma_app/features/manager/models/product_models_model.dart';
import 'package:ma_app/features/manager/providers/manager_api_provider.dart';

class _FakeApi extends ManagerApiService {
  static final List<ManagerProductRowModel> _allProducts = [
    const ManagerProductRowModel(
      productId: 'p0',
      name: 'سینک ظرفشویی',
      unit: 'عدد',
      totalCount: 200,
      modelCount: 2,
      modelNames: ['SL116', 'SL120'],
    ),
    const ManagerProductRowModel(
      productId: 'p1',
      name: 'کولر گازی',
      unit: 'دستگاه',
      totalCount: 0,
    ),
    for (var i = 2; i < 52; i++)
      ManagerProductRowModel(
        productId: 'p$i',
        name: 'کالای $i',
        unit: 'عدد',
        totalCount: 200,
      ),
  ];

  @override
  Future<ManagerInventoryModel> getManagerInventory({
    int page = 1,
    int pageSize = 12,
    String? q,
    bool onlyInStock = false,
    String? warehouseId,
  }) async {
    var list = _allProducts;
    final query = q?.trim().toLowerCase() ?? '';
    if (query.isNotEmpty) {
      list = list
          .where((p) => (p.name ?? '').toLowerCase().contains(query))
          .toList();
    }
    if (onlyInStock) {
      list = list.where((p) => p.totalCount.toInt() > 0).toList();
    }
    final total = list.length;
    final start = (page - 1) * pageSize;
    final pageProducts = start >= total
        ? const <ManagerProductRowModel>[]
        : list.sublist(start, math.min(start + pageSize, total));
    return ManagerInventoryModel(
      products: pageProducts,
      total: total,
      page: page,
      pageSize: pageSize,
      hasMore: start + pageProducts.length < total,
      warehouses: const [
        WarehouseStockRowModel(
          warehouseName: 'انبار مرکزی',
          totalCount: 200,
          items: [
            StockItemRowModel(
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

  @override
  Future<ProductModelsData> getProductModels(String productId) async {
    return const ProductModelsData(
      product: ProductModelInfo(id: 'p0', name: 'سینک ظرفشویی', unit: 'عدد'),
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
        ProductModelStockModel(modelId: 'm2', name: 'SL120', count: 0),
      ],
    );
  }
}

Widget _app() => ProviderScope(
  overrides: [managerApiServiceProvider.overrideWithValue(_FakeApi())],
  child: const MaterialApp(home: ProductInventoryScreen()),
);

void main() {
  testWidgets('صفحه موجودی کل، محصولات را نشان میدهد', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('موجودی کل'), findsOneWidget);
    expect(find.text('سینک ظرفشویی'), findsOneWidget);
    expect(find.text('کولر گازی'), findsOneWidget);
    // ارقام فارسی
    expect(find.text('۲۰۰ عدد'), findsWidgets);
    expect(find.text('۰ دستگاه'), findsOneWidget);
    // تعداد و نام مدل‌ها روی کارت محصول
    expect(find.text('۲ مدل: SL116، SL120'), findsOneWidget);
    // چیپ خلاصه + هشدار محصولات بیشتر
    expect(find.text('۵۲'), findsOneWidget);
    expect(
      find.text('و ۲ محصول دیگر — برای نمایش بیشتر به پایین بروید'),
      findsOneWidget,
    );
  });

  testWidgets('کلیک روی محصول، مدلها را همان صفحه باز میکند', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('SL116'), findsNothing);

    await tester.tap(find.text('سینک ظرفشویی'));
    await tester.pumpAndSettle();

    expect(find.text('SL116'), findsOneWidget);
    expect(find.text('۲۰۰ عدد'), findsWidgets);
    expect(find.text('کارتن • ۲ در هر جعبه'), findsOneWidget);
    expect(find.text('SL120'), findsOneWidget);
    expect(find.text('موجودی کل'), findsOneWidget);

    await tester.tap(find.text('SL116'));
    await tester.pumpAndSettle();
    expect(find.text('انبار مرکزی'), findsOneWidget);
  });

  testWidgets('جستجو سمت سرور محصول را فیلتر میکند', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'کولر');
    // صبر برای debounce جستجو (۳۵۰ms) سپس بارگذاری مجدد
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('کولر گازی'), findsOneWidget);
    expect(find.text('سینک ظرفشویی'), findsNothing);
    expect(find.text('۰ دستگاه'), findsOneWidget);
  });

  testWidgets('اسکرول تا انتها صفحهٔ بعد را بارگذاری میکند', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // محصول صفحهٔ دوم هنوز نیست
    expect(find.text('کالای 51'), findsNothing);

    for (var i = 0; i < 30; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();
      if (tester.any(find.text('کالای 51'))) break;
    }
    await tester.pumpAndSettle();

    expect(find.text('کالای 51'), findsOneWidget);
    // بعد از بارگذاری کامل، هشدار محصولات دیگر حذف می‌شود
    expect(
      find.text('و ۲ محصول دیگر — برای نمایش بیشتر به پایین بروید'),
      findsNothing,
    );
  });
}
