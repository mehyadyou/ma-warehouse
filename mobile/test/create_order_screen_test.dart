import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ma_app/features/manager/data/manager_api_service.dart';
import 'package:ma_app/features/manager/models/carrier_model.dart';
import 'package:ma_app/features/manager/models/order_model.dart';
import 'package:ma_app/features/manager/models/product_model.dart';
import 'package:ma_app/features/manager/models/warehouse_model.dart';
import 'package:ma_app/features/manager/orders/create_order_screen.dart';
import 'package:ma_app/features/manager/providers/manager_api_provider.dart';

class _FakeApi extends ManagerApiService {
  static int createCalls = 0;
  static Map<String, dynamic>? lastOrder;

  static const _warehouses = [
    WarehouseModel(id: 'w1', name: 'انبار مرکزی'),
  ];
  static const _carriers = [
    CarrierModel(id: 'c1', name: 'باربری تهران'),
  ];
  static const _products = [
    ProductModel(id: 'p1', name: 'سینک ظرفشویی', unit: 'عدد'),
    ProductModel(id: 'p2', name: 'کولر گازی', unit: 'دستگاه'),
  ];

  /// برای تست لود مستقل: می‌شود یک Future معلق (Completer) به آن داد
  Future<double?> dollarRateFuture = Future.value(60000.0);

  @override
  Future<List<WarehouseModel>> getWarehouses() async => _warehouses;

  @override
  Future<List<CarrierModel>> getCarriers() async => _carriers;

  @override
  Future<double?> getDollarRate() => dollarRateFuture;

  @override
  Future<({List<ProductModel> products, int total})> getProductsPage({
    String? q,
    required int page,
    required int pageSize,
  }) async {
    final query = q?.trim().toLowerCase() ?? '';
    final filtered = query.isEmpty
        ? _products
        : _products.where((p) => p.name.toLowerCase().contains(query)).toList();
    final start = (page - 1) * pageSize;
    return (
      products: start >= filtered.length
          ? const <ProductModel>[]
          : filtered.sublist(
              start,
              start + pageSize > filtered.length
                  ? filtered.length
                  : start + pageSize,
            ),
      total: filtered.length,
    );
  }

  @override
  Future<Map<String, int>> getOrderStock(
    String warehouseId,
    List<String> productIds,
  ) async {
    return {'p1': 10, 'p2': 5};
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    createCalls++;
    lastOrder = data;
    return const OrderModel(id: 'created-1', orderNumber: 7);
  }
}

class _Home extends StatelessWidget {
  final Widget child;
  const _Home({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/create'),
          child: const Text('رفتن'),
        ),
      ),
    );
  }
}

Widget _app({ManagerApiService? api}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _Home(
          child: const SizedBox.shrink(),
        ),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateOrderScreen(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      managerApiServiceProvider.overrideWithValue(api ?? _FakeApi()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// انتخاب محصول ردیف [rowIndex] از پیکر جستجو
Future<void> _pickProduct(WidgetTester tester, int rowIndex, String name) async {
  final productField = find.ancestor(
    of: find.byIcon(Icons.search_rounded).at(rowIndex),
    matching: find.byType(GestureDetector),
  );
  await tester.tap(productField.first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

Future<void> _selectWarehouse(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButton<String>).at(0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('انبار مرکزی').last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _FakeApi.createCalls = 0;
    _FakeApi.lastOrder = null;
  });

  testWidgets('چند ردیف محصول در یک درخواست ثبت میشود و ارقام فارسی نرمال میشود', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفتن'));
    await tester.pumpAndSettle();

    await _selectWarehouse(tester);

    // ردیف اول: سینک ظرفشویی
    await tester.tap(find.text('افزودن محصول'));
    await tester.pumpAndSettle();
    await _pickProduct(tester, 0, 'سینک ظرفشویی');
    await tester.enterText(find.widgetWithText(TextField, '1').first, '۳');
    await tester.enterText(find.byType(TextField).at(1), '100');

    // ردیف دوم: کولر گازی
    await tester.tap(find.text('افزودن محصول'));
    await tester.pumpAndSettle();
    await _pickProduct(tester, 1, 'کولر گازی');
    await tester.enterText(find.widgetWithText(TextField, '1').first, '5');
    await tester.enterText(find.byType(TextField).at(3), '200');

    // اطلاعات فرستنده/گیرنده — با رقم فارسی در تلفن
    await tester.enterText(
      find.widgetWithText(TextField, 'نام فرستنده *'),
      'علی',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'نام گیرنده *'),
      'رضا',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'شماره تماس *'),
      '۰۹۱۲۳۴۵۶۷۸۹',
    );
    await tester.enterText(find.widgetWithText(TextField, 'شهر *'), 'تهران');
    await tester.enterText(
      find.widgetWithText(TextField, 'آدرس *'),
      'خیابان آزادی',
    );

    // باربری — بعد از پر شدن ردیفها، تنها hint باقیمانده dropdown باربری است
    final carrierHint = find.text('انتخاب کنید...');
    await tester.ensureVisible(carrierHint);
    await tester.tap(carrierHint);
    await tester.pumpAndSettle();
    await tester.tap(find.text('باربری تهران').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت سفارش'));
    await tester.pumpAndSettle();

    expect(_FakeApi.createCalls, 1);
    final order = _FakeApi.lastOrder!;
    expect(order['warehouseId'], 'w1');
    expect(order['shippingMethod'], 'باربری');
    expect(order['carrier'], 'باربری تهران');
    expect(order['senderName'], 'علی');
    expect(order['receiverName'], 'رضا');
    expect(order['city'], 'تهران');
    expect(order['address'], 'خیابان آزادی');
    expect(order['customerPhone'], '09123456789');

    final items = order['items'] as List;
    expect(items.length, 2);
    // تعداد فارسی ۳ → ۳
    expect((items[0] as Map)['quantity'], 3);
    expect((items[0] as Map)['productId'], 'p1');
    // قیمت دلار با نرخ لحظه‌ای → تومان
    expect((items[0] as Map)['price'], 6000000);
    expect((items[0] as Map)['exchangeRate'], 60000.0);
    expect((items[1] as Map)['quantity'], 5);
    expect((items[1] as Map)['productId'], 'p2');
    expect((items[1] as Map)['price'], 12000000);
  });

  testWidgets('انبارها مستقل از نرخ دلار لود میشوند (بدون پیام گمراه‌کننده)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // نرخ دلار معلق می‌ماند تا مطمئن شویم انبارها منتظر آن نمی‌مانند
    final rateCompleter = Completer<double?>();
    final api = _FakeApi()..dollarRateFuture = rateCompleter.future;

    await tester.pumpWidget(_app(api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفتن'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // نرخ دلار هنوز پاسخ نداده ولی انبارها باید لود شده باشند
    expect(find.text('هنوز انباری ساخته نشده است'), findsNothing,
        reason: 'انبارها نباید منتظر نرخ دلار بمانند');
    expect(find.text('در حال بارگذاری انبارها...'), findsNothing);

    // dropdown انبار آیتم دارد
    await tester.tap(find.byType(DropdownButton<String>).at(0));
    await tester.pumpAndSettle();
    expect(find.text('انبار مرکزی'), findsOneWidget);
    await tester.tap(find.text('انبار مرکزی').last);
    await tester.pumpAndSettle();

    // حالا نرخ دلار هم می‌رسد — صفحه باید بدون خطا بنشیند
    rateCompleter.complete(60000);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('تعداد بیشتر از موجودی انبار قبل از ارسال بلاک میشود', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفتن'));
    await tester.pumpAndSettle();

    await _selectWarehouse(tester);
    await tester.tap(find.text('افزودن محصول'));
    await tester.pumpAndSettle();
    await _pickProduct(tester, 0, 'سینک ظرفشویی');
    await tester.enterText(find.widgetWithText(TextField, '1').first, '15');

    await tester.tap(find.text('ثبت سفارش'));
    await tester.pumpAndSettle();

    expect(find.textContaining('موجودی کافی نیست'), findsOneWidget);
    // هم در برچسب ردیف و هم در پیام خطا
    expect(find.textContaining('موجودی: ۱۰'), findsWidgets);
    expect(_FakeApi.createCalls, 0);
  });

  testWidgets('موجودی انبار کنار هر ردیف نمایش داده میشود', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفتن'));
    await tester.pumpAndSettle();

    await _selectWarehouse(tester);
    await tester.tap(find.text('افزودن محصول'));
    await tester.pumpAndSettle();
    await _pickProduct(tester, 0, 'سینک ظرفشویی');
    await tester.pumpAndSettle();
    expect(find.text('موجودی: ۱۰'), findsOneWidget);

    await tester.tap(find.text('افزودن محصول'));
    await tester.pumpAndSettle();
    await _pickProduct(tester, 1, 'کولر گازی');
    await tester.pumpAndSettle();
    expect(find.text('موجودی: ۵'), findsOneWidget);
  });

  testWidgets('ردیف با واحد تومان: exchangeRate ارسال نمیشود', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفتن'));
    await tester.pumpAndSettle();

    await _selectWarehouse(tester);
    await tester.tap(find.text('افزودن محصول'));
    await tester.pumpAndSettle();
    await _pickProduct(tester, 0, 'سینک ظرفشویی');
    await tester.enterText(find.widgetWithText(TextField, '1').first, '2');
    await tester.enterText(find.byType(TextField).at(1), '100');

    // واحد قیمت ردیف اول: دلار → تومان
    await tester.tap(find.widgetWithText(DropdownButton<String>, 'دلار').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تومان').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'نام فرستنده *'),
      'علی',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'نام گیرنده *'),
      'رضا',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'شماره تماس *'),
      '09123456789',
    );
    await tester.enterText(find.widgetWithText(TextField, 'شهر *'), 'تهران');
    await tester.enterText(
      find.widgetWithText(TextField, 'آدرس *'),
      'خیابان آزادی',
    );

    final carrierHint = find.text('انتخاب کنید...');
    await tester.ensureVisible(carrierHint);
    await tester.tap(carrierHint);
    await tester.pumpAndSettle();
    await tester.tap(find.text('باربری تهران').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت سفارش'));
    await tester.pumpAndSettle();

    expect(_FakeApi.createCalls, 1);
    final items = _FakeApi.lastOrder!['items'] as List;
    final item = items[0] as Map;
    // قیمت تومانی مستقیم ذخیره می‌شود و نرخ ارز ارسال نمی‌شود
    expect(item['price'], 100);
    expect(item.containsKey('exchangeRate'), isFalse);
  });
}
