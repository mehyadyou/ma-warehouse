import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/screens/tabs/printed_tab.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: PrintedTab(
            labelsTab: const SizedBox(key: ValueKey('labels-view')),
            badgesTab: const SizedBox(key: ValueKey('badges-view')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('پیش‌فرض فیلتر «لیبل» است و «بیجک» نمای چاپ‌شده‌ها را نشان می‌دهد',
      (tester) async {
    await pump(tester);

    // فیلتر وجود دارد و نمای پیش‌فرض لیبل است
    expect(find.text('نمایش:'), findsOneWidget);
    expect(find.text('لیبل'), findsOneWidget);
    expect(find.text('بیجک'), findsOneWidget);
    expect(find.byKey(const ValueKey('labels-view')), findsOneWidget);
    expect(find.byKey(const ValueKey('badges-view')), findsNothing);

    // انتخاب فیلتر بیجک → نمای بیجک‌های چاپ‌شده
    await tester.tap(find.text('بیجک'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('labels-view')), findsNothing);
    expect(find.byKey(const ValueKey('badges-view')), findsOneWidget);

    // برگشت به لیبل
    await tester.tap(find.text('لیبل'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('labels-view')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
