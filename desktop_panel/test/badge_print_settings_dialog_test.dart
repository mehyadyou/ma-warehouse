import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/badge_print_settings.dart';
import 'package:ma_warehouse_panel/widgets/badge_print_settings_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    BadgePrintSettingsHolder.instance.notifier.value =
        BadgePrintSettings.defaults;
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showBadgePrintSettingsDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('dialog renders without overflow at small window size',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await openDialog(tester);

    expect(find.text('تنظیمات چاپ بیجک'), findsOneWidget);
    expect(find.text('اعمال تنظیمات'), findsOneWidget);
    expect(find.text('ذخیره و بستن'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dual mode shows two badges; toggling shows one', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await openDialog(tester);

    // حالت دوتایی (پیش‌فرض): دو بیجک در پیش‌نمایش
    expect(find.text('بیجک سفارش 1 از 2'), findsNWidgets(2));

    // خاموش کردن تیک → حالت تکی: یک بیجک
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('بیجک سفارش 1 از 2'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // کشیدن در حالت تکی هم باید کار کند
    await tester.drag(
      find.byKey(const ValueKey('badgePreviewDrag')),
      const Offset(30, -15),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'scale slider and mouse drag update draft; apply keeps dialog open',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await openDialog(tester);

    expect(find.byType(Slider), findsOneWidget);

    // کشیدن پیش‌نمایش، آفست حالت دوتایی را تغییر می‌دهد (بدون خطا)
    await tester.drag(
      find.byKey(const ValueKey('badgePreviewDrag')),
      const Offset(30, -15),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    // اعمال → ذخیره‌ی پایدار، دیالوگ باز می‌ماند
    await tester.tap(find.text('اعمال تنظیمات'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4)); // پایان تایمر اسنک‌بار
    await tester.pumpAndSettle();

    expect(find.text('تنظیمات چاپ بیجک'), findsOneWidget,
        reason: 'پس از «اعمال» دیالوگ باید باز بماند');
    final current = BadgePrintSettingsHolder.instance.current;
    expect(current.dualOffsetXmm, isNot(0));
    expect(current.dualOffsetYmm, isNot(0));
    expect(current.dualMode, isTrue);
  });

  testWidgets('settings of dual and single modes are stored separately',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await openDialog(tester);

    // حالت دوتایی: جابه‌جایی به راست
    await tester.drag(
      find.byKey(const ValueKey('badgePreviewDrag')),
      const Offset(30, 0),
    );
    await tester.pump();
    await tester.tap(find.text('اعمال تنظیمات'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // حالت تکی: تیک را برمی‌داریم و جابه‌جایی دیگری اعمال می‌کنیم
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('بیجک سفارش 1 از 2'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('badgePreviewDrag')),
      const Offset(-40, 20),
    );
    await tester.pump();

    // ذخیره و بستن
    await tester.tap(find.text('ذخیره و بستن'));
    await tester.pumpAndSettle();
    expect(find.text('تنظیمات چاپ بیجک'), findsNothing);

    final saved = BadgePrintSettingsHolder.instance.current;
    expect(saved.dualMode, isFalse);
    // هر دو حالت جداگانه ذخیره شده‌اند
    expect(saved.dualOffsetXmm, isNot(0));
    expect(saved.singleOffsetXmm, isNot(0));
    expect(saved.dualOffsetXmm, isNot(saved.singleOffsetXmm));
    expect(saved.singleOffsetYmm, isNot(0));
  });
}
