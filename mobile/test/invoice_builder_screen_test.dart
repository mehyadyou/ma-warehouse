import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/manager/invoices/invoice_builder_screen.dart';
import 'package:ma_app/features/manager/invoices/invoice_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app({InvoiceDraftModel? initialDraft}) {
  return ProviderScope(
    child: MaterialApp(home: InvoiceBuilderScreen(initialDraft: initialDraft)),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
  });

  testWidgets('فرم خالی باز می‌شود و اعتبارسنجی پیام می‌دهد', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('فاکتورساز'), findsOneWidget);

    await tester.tap(find.text('پیش‌نمایش و ساخت فاکتور'));
    await tester.pumpAndSettle();

    expect(find.text('نام فروشنده را وارد کنید'), findsOneWidget);
  });

  testWidgets('با پر کردن فرم، پیش‌نمایش فاکتور باز می‌شود', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // فروشنده و خریدار
    await tester.enterText(find.widgetWithText(TextField, 'نام *').first, 'فروشگاه ما');
    await tester.enterText(find.widgetWithText(TextField, 'نام *').last, 'مشتری نمونه');

    // یک قلم
    await tester.enterText(
      find.widgetWithText(TextField, 'شرح کالا/خدمات *'),
      'سینک ظرفشویی',
    );
    await tester.enterText(find.widgetWithText(TextField, 'تعداد'), '2');
    await tester.enterText(find.widgetWithText(TextField, 'قیمت واحد'), '1000');

    // مبلغ نهایی به‌صورت زنده محاسبه می‌شود (جمع اقلام و مبلغ نهایی)
    await tester.pump();
    expect(find.text('۲,۰۰۰'), findsNWidgets(2));

    await tester.tap(find.text('پیش‌نمایش و ساخت فاکتور'));
    await tester.pumpAndSettle();

    // ورود به پیش‌نمایش و رندر قالب
    expect(find.text('پیش‌نمایش فاکتور'), findsOneWidget);
    expect(find.textContaining('مبلغ نهایی'), findsOneWidget);
    expect(find.textContaining('دو هزار تومان'), findsOneWidget);
  });

  testWidgets('تغییر به فاکتور رسمی، فیلدهای کد اقتصادی را نشان می‌دهد', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('کد اقتصادی'), findsNothing);

    await tester.tap(find.text('فاکتور رسمی'));
    await tester.pumpAndSettle();

    expect(find.text('کد اقتصادی'), findsNWidgets(2));
    expect(find.text('شماره ثبت'), findsNWidgets(2));
  });

  testWidgets('با initialDraft فیلدها پیش‌پر می‌شوند', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final draft = InvoiceDraftModel(
      number: '12',
      buyer: const InvoicePartyModel(
        name: 'خریدار سفارش',
        phone: '۰۹۱۲',
        address: 'تهران — خیابان آزادی',
      ),
      items: const [
        InvoiceItemModel(
          description: 'یخچال — مدل A',
          quantity: 2,
          unit: 'عدد',
          unitPrice: 5000,
        ),
      ],
      sourceOrderId: 'order-1',
    );

    await tester.pumpWidget(_app(initialDraft: draft));
    await tester.pumpAndSettle();

    expect(find.text('فاکتورساز'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'خریدار سفارش'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, '۰۹۱۲'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'تهران — خیابان آزادی'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'یخچال — مدل A'), findsOneWidget);
    expect(find.widgetWithText(TextField, '۲'), findsOneWidget);
    expect(find.widgetWithText(TextField, '۵,۰۰۰'), findsOneWidget);
  });
}