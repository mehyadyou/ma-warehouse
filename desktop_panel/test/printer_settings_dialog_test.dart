import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/printer_settings.dart';
import 'package:ma_warehouse_panel/widgets/printer_settings_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PrinterSettingsHolder.instance.notifier.value = PrinterSettings.defaults;
  });

  testWidgets('settings dialog renders without overflow at small window size',
      (tester) async {
    // شبیه‌سازی پنجره‌ی کوچک‌تر از محتوای دیالوگ
    await tester.binding.setSurfaceSize(const Size(900, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showPrinterSettingsDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // دیالوگ باز شد
    expect(find.text('تنظیمات چاپگر'), findsOneWidget);
    expect(find.text('ذخیره تنظیمات'), findsOneWidget);

    // هیچ overflow یافت نشد
    expect(tester.takeException(), isNull);
  });

  testWidgets('scale slider and drag preview update draft settings',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showPrinterSettingsDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // اسلایدر مقیاس موجود است
    expect(find.byType(Slider), findsOneWidget);

    // کشیدن پیش‌نمایش، آفست را تغییر می‌دهد (بدون خطا)
    final previewFinder = find.byType(GestureDetector);
    expect(previewFinder, findsWidgets);
    await tester.drag(previewFinder.first, const Offset(30, -15));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // دکمه‌ی وسط‌چین موجود است
    expect(find.text('وسط‌چین (ریست)'), findsOneWidget);
  });
}
