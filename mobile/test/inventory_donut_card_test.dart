import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/shared/widgets/inventory_donut_card.dart';

void main() {
  const items = [
    InventoryItem(name: 'محصول آ', count: 100, unit: 'عدد', color: Color(0xFF4ADE80)),
    InventoryItem(name: 'محصول ب', count: 0, unit: 'عدد', color: Color(0xFF60A5FA)),
    InventoryItem(name: 'محصول ج', count: 400, unit: 'عدد', color: Color(0xFFFB923C)),
  ];

  const stats = [
    InventoryStat(label: 'محصول ثبت شده', value: '3', color: Color(0xFF4ADE80)),
    InventoryStat(label: 'موجودی فعلی', value: '500', color: Color(0xFF60A5FA)),
    InventoryStat(label: 'مرجوعی‌ها', value: '12', color: Color(0xFFFB923C)),
  ];

  Widget buildCard() {
    return MaterialApp(
      home: Scaffold(
        body: InventoryDonutCard(items: items, stats: stats),
      ),
    );
  }

  Finder centerText(String data) => find.byWidgetPredicate(
        (w) => w is Text && w.data == data && w.style?.fontSize == 22,
      );

  testWidgets('حالت اولیه: مرکز موجودی کلی + درصد سهم از کل در راهنما', (tester) async {
    await tester.pumpWidget(buildCard());
    await tester.pumpAndSettle();

    expect(centerText('۵۰۰'), findsOneWidget);
    expect(find.text('موجودی کل'), findsOneWidget);
    expect(find.text('۲۰.۰٪'), findsOneWidget);
    expect(find.text('۰.۰٪'), findsOneWidget);
    expect(find.text('۸۰.۰٪'), findsOneWidget);
    expect(find.text('محصول ثبت شده'), findsOneWidget);
    expect(find.text('مرجوعی‌ها'), findsOneWidget);
  });

  testWidgets('لمس ردیف راهنما: مرکز محصول انتخاب‌شده با رنگ خودش + حذف بقیه از دایره',
      (tester) async {
    await tester.pumpWidget(buildCard());
    await tester.pumpAndSettle();

    await tester.tap(find.text('محصول آ'));
    await tester.pumpAndSettle();

    final centerCount = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && w.data == '۱۰۰ عدد' && w.style?.fontSize == 15,
      ),
    );
    expect(centerCount.style?.color, const Color(0xFF4ADE80));
    // نام محصول هم در مرکز + راهنمای انتخاب‌شده دیده می‌شود
    expect(find.text('محصول آ'), findsNWidgets(2));
    expect(find.text('موجودی کل'), findsNothing);

    // انتخاب مجدد → برگشت به موجودی کلی
    // «محصول آ» هم در مرکز دایره و هم در راهنما هست؛ ردیف راهنما بعد از مرکز در درخت است
    await tester.tap(find.text('محصول آ').last);
    await tester.pumpAndSettle();
    expect(centerText('۵۰۰'), findsOneWidget);
    expect(find.text('موجودی کل'), findsOneWidget);
  });

  testWidgets('محصول با موجودی صفر قابل انتخاب است و درصدش صفر است', (tester) async {
    await tester.pumpWidget(buildCard());
    await tester.pumpAndSettle();

    await tester.tap(find.text('محصول ب'));
    await tester.pumpAndSettle();

    final centerCount = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && w.data == '۰ عدد' && w.style?.fontSize == 15,
      ),
    );
    expect(centerCount.style?.color, const Color(0xFF60A5FA));
    expect(find.text('موجودی کل'), findsNothing);
  });

  testWidgets('حالت خطا با دکمه تلاش دوباره', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDonutCard(
            error: 'خطا در بارگذاری',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('خطا در بارگذاری'), findsOneWidget);
    await tester.tap(find.text('تلاش دوباره'));
    expect(retried, isTrue);
  });

  testWidgets('لمس کارت، ناوبری را صدا می‌زند', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDonutCard(
            items: items,
            stats: stats,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(InventoryDonutCard));
    expect(tapped, isTrue);
  });
}