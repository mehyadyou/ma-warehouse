import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/manager/data/manager_api_service.dart';
import 'package:ma_app/features/manager/models/order_model.dart';
import 'package:ma_app/features/manager/orders/shipments_screen.dart';
import 'package:ma_app/features/manager/providers/manager_api_provider.dart';

class _FakeApi extends ManagerApiService {
  static int getOrdersCalls = 0;
  static String? lastStatus;

  static const _orders = [
    OrderModel(
      id: 'o1',
      status: 'PENDING',
      senderName: 'علی',
      receiverName: 'رضا',
      city: 'تهران',
      createdAt: '2026-01-01T10:00:00Z',
    ),
    OrderModel(
      id: 'o2',
      status: 'SHIPPED',
      senderName: 'مریم',
      receiverName: 'سارا',
      city: 'کرج',
      createdAt: '2026-01-01T11:00:00Z',
    ),
  ];

  @override
  Future<OrdersPageModel> getOrders({
    int page = 1,
    int pageSize = 50,
    String? status,
  }) async {
    getOrdersCalls++;
    lastStatus = status;
    return OrdersPageModel(
      orders: _orders,
      total: _orders.length,
      counts: const OrderCountsModel(total: 2, pending: 1, inTransit: 1),
    );
  }
}

Widget _app() {
  return ProviderScope(
    overrides: [managerApiServiceProvider.overrideWithValue(_FakeApi())],
    child: const MaterialApp(
      home: ShipmentsScreen(),
    ),
  );
}

void main() {
  setUp(() {
    _FakeApi.getOrdersCalls = 0;
    _FakeApi.lastStatus = null;
  });

  testWidgets('بارگذاری اولیه بدون فیلتر وضعیت است', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(_FakeApi.getOrdersCalls, 1);
    expect(_FakeApi.lastStatus, isNull);
    expect(find.text('ارسالی‌ها'), findsOneWidget);
  });

  testWidgets('لمس chip وضعیت، فیلتر را سمت سرور اعمال میکند', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // «در انتظار» هم در chip آمار و هم در کارت سفارش هست — اولی chip است
    await tester.tap(find.text('در انتظار').first);
    await tester.pumpAndSettle();

    expect(_FakeApi.getOrdersCalls, 2);
    expect(_FakeApi.lastStatus, 'pending');

    // خاموش کردن فیلتر → دوباره بدون status
    await tester.tap(find.text('در انتظار').first);
    await tester.pumpAndSettle();
    expect(_FakeApi.getOrdersCalls, 3);
    expect(_FakeApi.lastStatus, isNull);
  });
}