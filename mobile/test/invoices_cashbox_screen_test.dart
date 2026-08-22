import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/manager/data/manager_api_service.dart';
import 'package:ma_app/features/manager/invoices/invoice_models.dart';
import 'package:ma_app/features/manager/invoices/invoice_repository.dart';
import 'package:ma_app/features/manager/invoices/invoices_cashbox_screen.dart';
import 'package:ma_app/features/manager/models/order_model.dart';
import 'package:ma_app/features/manager/providers/manager_api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApi extends ManagerApiService {
  static int getOrdersCalls = 0;

  static const _orders = [
    OrderModel(
      id: 'o1',
      status: 'DELIVERED',
      receiverName: 'رضا محمدی',
      city: 'تهران',
      createdAt: '2026-01-05T10:00:00Z',
      items: [
        OrderItemModel(productName: 'یخچال', quantity: 2, price: 5000),
      ],
    ),
    OrderModel(
      id: 'o2',
      status: 'SHIPPED',
      receiverName: 'سارا احمدی',
      city: 'کرج',
      createdAt: '2026-01-06T11:00:00Z',
      items: [
        OrderItemModel(productName: 'تلویزیون', quantity: 1, price: 3000),
      ],
    ),
    OrderModel(
      id: 'o3',
      status: 'PENDING',
      receiverName: 'علی کریمی',
      city: 'شیراز',
      createdAt: '2026-01-07T12:00:00Z',
      items: [
        OrderItemModel(productName: 'ماشین لباسشویی', quantity: 1, price: 7000),
      ],
    ),
  ];

  @override
  Future<OrdersPageModel> getOrders({
    int page = 1,
    int pageSize = 50,
    String? status,
  }) async {
    getOrdersCalls++;
    return OrdersPageModel(
      orders: _orders,
      total: _orders.length,
      counts: const OrderCountsModel(
        total: 3,
        pending: 1,
        inTransit: 1,
        delivered: 1,
      ),
    );
  }
}

Widget _app() {
  return ProviderScope(
    overrides: [managerApiServiceProvider.overrideWithValue(_FakeApi())],
    child: const MaterialApp(home: InvoicesCashboxScreen()),
  );
}

/// نمایشگر بلند تا هر سه کارت (دو لایه‌ای) بدون اسکرول ساخته شوند
void _bigViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
  });

  setUp(() async {
    _FakeApi.getOrdersCalls = 0;
    // پاک کردن تاریخچه بین تست‌ها (بدون init مجدد)
    await (await SharedPreferences.getInstance()).clear();
  });

  testWidgets('همهٔ سفارش‌ها بدون فیلتر سرور بارگذاری و بر اساس وضعیت دسته‌بندی می‌شوند',
      (tester) async {
    _bigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(_FakeApi.getOrdersCalls, 1);
    expect(find.text('صندوق'), findsOneWidget);
    // هدر گروه‌ها + چیپ وضعیت همان سفارش
    expect(find.text('در انتظار'), findsNWidgets(2));
    expect(find.text('در حال ارسال'), findsNWidgets(2));
    expect(find.text('تحویل شده'), findsNWidgets(2));
    // هر سفارش: عنوان کارت + مقدار «خریدار» در پنل فاکتور آماده
    expect(find.text('رضا محمدی'), findsNWidgets(2));
    expect(find.text('سارا احمدی'), findsNWidgets(2));
    expect(find.text('علی کریمی'), findsNWidgets(2));
  });

  testWidgets('پنل فاکتور آماده روی هر کارت: خریدار، قلم‌ها و جمع', (tester) async {
    _bigViewport(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // مبلغ کل: عنوان کارت + مقدار «جمع» در پنل
    expect(find.text('۱۰,۰۰۰ تومان'), findsNWidgets(2));
    expect(find.text('۳,۰۰۰ تومان'), findsNWidgets(2));
    expect(find.text('۷,۰۰۰ تومان'), findsNWidgets(2));
    expect(find.textContaining('۱ قلم'), findsNWidgets(3));
    // پنل فاکتور آماده و دکمهٔ اقدام
    expect(find.text('فاکتور آماده — قابل ویرایش'), findsNWidgets(3));
    expect(find.text('ادیت و ساخت فاکتور'), findsNWidgets(3));
  });

  testWidgets('سفارش فاکتورشده نشان «ویرایش فاکتور» می‌گیرد', (tester) async {
    _bigViewport(tester);
    // ذخیره یک فاکتور مرتبط با سفارش o1 در تاریخچه
    await InvoiceRepository().saveToHistory(
      const InvoiceDraftModel(
        id: 'inv-1',
        number: '1',
        sourceOrderId: 'o1',
      ),
    );

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('فاکتور ثبت شده — ویرایش آماده است'), findsOneWidget);
    expect(find.text('ویرایش فاکتور'), findsOneWidget);
    expect(find.text('ادیت و ساخت فاکتور'), findsNWidgets(2));
  });

  testWidgets('لمس سفارش، فاکتورساز پیش‌پر را باز می‌کند', (tester) async {
    _bigViewport(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('رضا محمدی').first);
    await tester.pumpAndSettle();

    // فاکتورساز با خریدار سفارش پیش‌پر شده است
    expect(find.text('فاکتورساز'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'رضا محمدی'),
      findsOneWidget,
    );
  });

  testWidgets('دکمهٔ «ادیت و ساخت فاکتور» فاکتورساز پیش‌پر را باز می‌کند',
      (tester) async {
    _bigViewport(tester);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // اولین دکمه مربوط به سفارش بالای لیست است (در انتظار — علی کریمی)
    await tester.tap(find.text('ادیت و ساخت فاکتور').first);
    await tester.pumpAndSettle();

    expect(find.text('فاکتورساز'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'علی کریمی'),
      findsOneWidget,
    );
  });
}