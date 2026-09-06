import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/warehouse_keeper/dashboard/home/unreviewed_orders_card.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_order_model.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';

KeeperOrderModel _order(String status) =>
    KeeperOrderModel(id: 'o-$status', orderNumber: 1, status: status);

Widget _app(List<KeeperOrderModel> orders, {VoidCallback? onTap}) {
  return ProviderScope(
    overrides: [
      ordersProvider.overrideWith((ref) async => orders),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: UnreviewedOrdersCard(onTap: onTap),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('وجود سفارش PENDING → کارت با شمار نمایش داده می‌شود', (tester) async {
    await tester.pumpWidget(_app([
      _order('PENDING'),
      _order('PENDING'),
      _order('SHIPPED'),
    ]));
    await tester.pumpAndSettle();

    // عنوان کارت (متن داخل Text.rich)
    expect(
      find.textContaining('سفارش بررسی', findRichText: true),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    // شمارِ فارسیِ سفارش‌های در انتظار
    expect(find.textContaining('۲', findRichText: true), findsOneWidget);
  });

  testWidgets('بدون سفارش PENDING → کارت نمایش داده نمی‌شود', (tester) async {
    await tester.pumpWidget(_app([
      _order('SHIPPED'),
      _order('DELIVERED'),
      _order('CANCELED'),
    ]));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('سفارش بررسی', findRichText: true),
      findsNothing,
    );
    expect(find.byIcon(Icons.receipt_long_rounded), findsNothing);
  });

  testWidgets('لیست خالی → کارت نمایش داده نمی‌شود', (tester) async {
    await tester.pumpWidget(_app([]));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.receipt_long_rounded), findsNothing);
  });

  testWidgets('لمس کارت → onTap صدا زده می‌شود', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _app([_order('PENDING')], onTap: () => tapped++),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(UnreviewedOrdersCard));
    expect(tapped, 1);
  });
}
