import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/manager/invoices/invoices_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app() {
  return const ProviderScope(
    child: MaterialApp(home: InvoicesScreen()),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
  });

  testWidgets('هاب دو دکمهٔ صندوق و ساخت فاکتور را نشان می‌دهد', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('فاکتورها'), findsOneWidget);
    expect(find.text('مدیریت فاکتورها'), findsOneWidget);
    expect(find.text('صندوق'), findsOneWidget);
    expect(find.text('ساخت فاکتور'), findsOneWidget);
    expect(find.text('فاکتور ساخته‌شده'), findsOneWidget);
    expect(find.text('سفارش آمادهٔ تبدیل'), findsOneWidget);
  });

  testWidgets('لمس «ساخت فاکتور»، فاکتورساز را باز می‌کند', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ساخت فاکتور'));
    await tester.pumpAndSettle();

    expect(find.text('فاکتورساز'), findsOneWidget);
  });
}