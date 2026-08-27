import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/warehouse_keeper/scan_out/manual_exit_screen.dart';

void main() {
  Widget wrap() => const ProviderScope(
        child: MaterialApp(
          home: ManualExitScreen(),
        ),
      );

  testWidgets('فرم خروج دستی: گام‌های محصول، مدل، تعداد و دکمه‌ی ثبت نمایش داده می‌شود',
      (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('خروج دستی (بدون QR)'), findsOneWidget);
    expect(find.text('۱. نام محصول'), findsOneWidget);
    expect(find.text('۲. مدل محصول'), findsOneWidget);
    expect(find.text('۳. تعداد خروج'), findsOneWidget);
    expect(find.text('ثبت خروج'), findsOneWidget);
    expect(find.text('انتخاب محصول...'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('استپر تعداد با دکمه‌های + و − تغییر می‌کند', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // در تعداد ۱ دکمه‌ی منفی غیرفعال است
    final minus = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.remove_rounded),
        matching: find.byType(IconButton),
      ),
    );
    expect(minus.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ثبت بدون انتخاب محصول → پیام خطا و بدون درخواست', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('ثبت خروج'));
    await tester.pump();

    expect(find.text('محصول را انتخاب کنید'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
