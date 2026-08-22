import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/data/manager_api_service.dart';
import 'package:ma_app/features/manager/models/product_model.dart';
import 'package:ma_app/features/manager/models/product_models_model.dart';
import 'package:ma_app/features/manager/models/transfer_model.dart';
import 'package:ma_app/features/manager/models/warehouse_model.dart';
import 'package:ma_app/features/manager/providers/manager_api_provider.dart';
import 'package:ma_app/features/manager/transfers/transfer_screen.dart';

class _FakeApi extends ManagerApiService {
  static Map<String, dynamic>? lastPayload;
  static int createCalls = 0;
  static List<TransferModel> history = [];

  static const _warehouses = [
    WarehouseModel(id: 'wh1', name: 'انبار تهران'),
    WarehouseModel(id: 'wh2', name: 'انبار کرج'),
  ];

  static const _products = [
    ProductModel(
      id: 'p1',
      name: 'یخچال',
      unit: 'عدد',
      models: [ProductVariantModel(id: 'm1', name: 'مدل ۱')],
    ),
  ];

  @override
  Future<List<WarehouseModel>> getWarehouses() async => _warehouses;

  @override
  Future<({List<ProductModel> products, int total})> getProductsPage({
    String? q,
    required int page,
    required int pageSize,
  }) async {
    final filtered = q == null || q.trim().isEmpty
        ? _products
        : _products.where((p) => p.name.contains(q)).toList();
    return (products: filtered, total: filtered.length);
  }

  @override
  Future<ProductModelsData> getProductModels(String productId) async {
    return const ProductModelsData(
      product: ProductModelInfo(id: 'p1', name: 'یخچال', unit: 'عدد'),
      models: [
        ProductModelStockModel(
          modelId: 'm1',
          name: 'مدل ۱',
          count: 20,
          warehouses: [
            ModelWarehouseRowModel(
              warehouseId: 'wh1',
              warehouseName: 'انبار تهران',
              count: 20,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<List<TransferModel>> getTransfers({int limit = 20}) async => history;

  @override
  Future<void> createTransfer({
    required String fromWarehouseId,
    String? toWarehouseId,
    required String productId,
    String? modelId,
    required int quantity,
    String description = '',
  }) async {
    createCalls++;
    lastPayload = {
      'fromWarehouseId': fromWarehouseId,
      'toWarehouseId': toWarehouseId,
      'productId': productId,
      'modelId': modelId,
      'quantity': quantity,
      'description': description,
    };
  }
}

Widget _app() {
  return ProviderScope(
    overrides: [managerApiServiceProvider.overrideWithValue(_FakeApi())],
    child: const MaterialApp(home: TransferScreen()),
  );
}

void _setBigViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    _FakeApi.lastPayload = null;
    _FakeApi.createCalls = 0;
    _FakeApi.history = [];
  });

  testWidgets('فرم اولیه: بدون فیلد مقصد و با دکمهٔ «ثبت خروج»', (
    tester,
  ) async {
    _setBigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('جابه‌جایی محصول'), findsOneWidget);
    expect(find.text('جابه‌جایی به انبار دیگر'), findsOneWidget);
    expect(find.text('انبار مبدأ'), findsOneWidget);
    expect(find.text('انبار مقصد'), findsNothing);
    expect(find.text('ثبت خروج'), findsOneWidget);
    expect(find.text('هنوز جابه‌جایی یا خروجی ثبت نشده است'), findsOneWidget);
  });

  testWidgets('فعال‌سازی جابه‌جایی → فیلد مقصد و دکمهٔ «ثبت جابه‌جایی»', (
    tester,
  ) async {
    _setBigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('جابه‌جایی به انبار دیگر'));
    await tester.pumpAndSettle();

    expect(find.text('انبار مقصد'), findsOneWidget);
    expect(find.text('ثبت جابه‌جایی'), findsOneWidget);
  });

  testWidgets('ثبت بدون انتخاب انبار → پیام خطا', (tester) async {
    _setBigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت خروج'));
    await tester.pump();

    expect(find.text('انبار مبدأ را انتخاب کنید'), findsNWidgets(2));
    expect(_FakeApi.createCalls, 0);
  });

  testWidgets('خروج کامل: انبار + محصول + مدل + مقدار → پیلود صحیح بدون مقصد', (
    tester,
  ) async {
    _setBigViewport(tester);
    _setBigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // انبار مبدأ
    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('انبار تهران').last);
    await tester.pumpAndSettle();

    // محصول
    await tester.tap(find.text('انتخاب محصول...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('یخچال'));
    await tester.pumpAndSettle();

    // مدل
    await tester.tap(find.byType(DropdownButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('مدل ۱').last);
    await tester.pumpAndSettle();

    // موجودی نمایشی
    expect(find.textContaining('موجودی این مدل'), findsOneWidget);

    // مقدار
    await tester.enterText(find.byType(TextField).first, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت خروج'));
    await tester.pumpAndSettle();

    expect(_FakeApi.createCalls, 1);
    expect(_FakeApi.lastPayload, {
      'fromWarehouseId': 'wh1',
      'toWarehouseId': null,
      'productId': 'p1',
      'modelId': 'm1',
      'quantity': 5,
      'description': '',
    });
    expect(find.text('دستور خروج ثبت شد و برای اجرا به انباردار ابلاغ شد'), findsOneWidget);
    // فرم پاک شده است
    expect(find.text('انتخاب محصول...'), findsOneWidget);
  });

  testWidgets('جابه‌جایی کامل با مقصد → پیلود شامل toWarehouseId', (
    tester,
  ) async {
    _setBigViewport(tester);
    _setBigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('جابه‌جایی به انبار دیگر'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('انبار تهران').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('انبار کرج').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('انتخاب محصول...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('یخچال'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('مدل ۱').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '۳'); // فارسی
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت جابه‌جایی'));
    await tester.pumpAndSettle();

    expect(_FakeApi.createCalls, 1);
    expect(_FakeApi.lastPayload?['fromWarehouseId'], 'wh1');
    expect(_FakeApi.lastPayload?['toWarehouseId'], 'wh2');
    expect(_FakeApi.lastPayload?['quantity'], 3);
    expect(find.text('دستور جابه‌جایی ثبت شد و برای اجرا به انباردار ابلاغ شد'), findsOneWidget);
  });

  testWidgets('مقدار بیشتر از موجودی → پیام خطا بدون ارسال', (tester) async {
    _setBigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('انبار تهران').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('انتخاب محصول...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('یخچال'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('مدل ۱').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '25');
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت خروج'));
    await tester.pump();

    expect(find.text('موجودی کافی نیست (موجودی: ۲۰)'), findsOneWidget);
    expect(_FakeApi.createCalls, 0);
  });

  testWidgets('بعد از ثبت، تاریخچه به‌روز می‌شود', (tester) async {
    _FakeApi.history = [
      TransferModel(
        id: 't1',
        fromWarehouseId: 'wh1',
        fromWarehouseName: 'انبار تهران',
        toWarehouseId: 'wh2',
        toWarehouseName: 'انبار کرج',
        productId: 'p1',
        productName: 'یخچال',
        modelId: 'm1',
        modelName: 'مدل ۱',
        quantity: 5,
        createdAt: DateTime(2026, 1, 2),
      ),
    ];

    _setBigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('یخچال — مدل ۱'), findsOneWidget);
    expect(find.text('انبار تهران ← انبار کرج'), findsOneWidget);
    expect(find.text('۵ واحد'), findsOneWidget);
  });
}
