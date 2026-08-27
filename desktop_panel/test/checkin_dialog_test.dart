import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/api_service.dart';
import 'package:ma_warehouse_panel/widgets/checkin_dialog.dart';

class FakeApi extends ApiService {
  List<Map<String, dynamic>>? submittedItems;

  @override
  Future<({List<dynamic> products, int total})> getProducts({
    String q = '',
    int page = 1,
    int pageSize = 50,
  }) async {
    return (
      products: [
        {
          'id': 'p1',
          'name': 'اسپیکر',
          'unit': 'عدد',
          'models': [
            {
              'id': 'm1',
              'name': 'مدل آ',
              'unitsPerBox': 10,
              'packageType': 'کارتن',
            },
            {
              'id': 'm2',
              'name': 'مدل ب',
              'unitsPerBox': 6,
              'packageType': 'کارتن',
            },
          ],
        },
      ],
      total: 1,
    );
  }

  @override
  Future<List<dynamic>> submitCheckin(
    List<Map<String, dynamic>> items, {
    String? clientKey,
  }) async {
    submittedItems = items;
    return [
      {'serialNumber': 'SN-1001'},
      {'serialNumber': 'SN-1002'},
    ];
  }
}

Future<void> pumpDialog(WidgetTester tester, FakeApi api) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => CheckInDialog(
                  api: api,
                  onSuccess: () {},
                ),
              ),
              child: const Text('باز کردن'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('باز کردن'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('check-in dialog: pick product, model, counts and submit', (
    tester,
  ) async {
    final api = FakeApi();
    var success = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => CheckInDialog(
                    api: api,
                    onSuccess: () => success = true,
                  ),
                ),
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();

    // انتخاب محصول → باز شدن پیکر جستجو
    await tester.tap(find.text('انتخاب محصول...'));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب محصول'), findsOneWidget);
    expect(find.text('اسپیکر'), findsOneWidget);
    await tester.tap(find.text('اسپیکر'));
    await tester.pumpAndSettle();

    // انتخاب مدل
    await tester.tap(find.text('انتخاب مدل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مدل آ (10 عدد/کارتن)'));
    await tester.pumpAndSettle();

    // یک کارتن اضافه (تکی پیش‌فرض ۱ است)
    await tester.tap(find.byKey(const Key('row-0-carton-inc')));
    await tester.pumpAndSettle();

    // ثبت
    await tester.tap(find.text('ثبت ورود کالا'));
    await tester.pumpAndSettle();

    expect(api.submittedItems, [
      {
        'productId': 'p1',
        'modelId': 'm1',
        'entryType': 'NEW',
        'cartonCount': 1,
        'individualCount': 1,
      },
    ]);

    // دیالوگ موفقیت: ۲ QR ساخته شد
    expect(find.text('2 QR Code تولید شد'), findsOneWidget);
    expect(find.textContaining('SN-1001'), findsOneWidget);
    await tester.tap(find.text('باشه'));
    await tester.pumpAndSettle();
    expect(success, isTrue);
    expect(find.text('ورود کالا به انبار'), findsNothing);
  });

  testWidgets('check-in dialog: validation without product', (tester) async {
    final api = FakeApi();
    await pumpDialog(tester, api);
    await tester.tap(find.text('ثبت ورود کالا'));
    await tester.pumpAndSettle();
    expect(find.text('ردیف 1: محصول انتخاب نشده'), findsOneWidget);
    expect(api.submittedItems, isNull);
  });

  testWidgets('check-in dialog: adding and removing rows', (tester) async {
    final api = FakeApi();
    await pumpDialog(tester, api);
    await tester.tap(find.text('افزودن ردیف'));
    await tester.pumpAndSettle();
    expect(find.text('ردیف 2'), findsOneWidget);
    // حذف ردیف ۲ — فقط یک آیکون close در ردیف‌های اضافه وجود دارد
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('ردیف 2'), findsNothing);
  });

  testWidgets('تیک بدون QRcode همیشه نمایش داده می‌شود (حتی در حالت کالای نو)',
      (tester) async {
    final api = FakeApi();
    await pumpDialog(tester, api);
    // قبل از هر تغییری، تیک باید دیده شود ولی غیرفعال باشد
    expect(find.text('بدون QRcode'), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.onChanged, isNull); // غیرفعال برای کالای نو
    expect(checkbox.value, isFalse);
  });

  testWidgets('مرجوعی → قفل شمارنده‌ها + نمایش فیلد سریال', (tester) async {
    final api = FakeApi();
    await pumpDialog(tester, api);

    // انتخاب مرجوعی از دراپ‌داون نوع ورود
    await tester.tap(find.text('کالای نو'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مرجوعی'));
    await tester.pumpAndSettle();

    // فیلد سریال باید نمایش داده شود
    expect(find.text('سریال یا اسکن QR'), findsOneWidget);
    // تیک بدون QRcode باید خاموش باشد
    expect(find.text('بدون QRcode'), findsOneWidget);
    // شمارنده‌ها قفل‌اند — دکمه‌های اضافه/کم نباید فعال باشند
    final cartonInc = find.byKey(const Key('row-0-carton-inc'));
    final takInc = find.byKey(const Key('row-0-tak-inc'));
    expect(cartonInc, findsOneWidget);
    expect(takInc, findsOneWidget);
  });

  testWidgets('تیک بدون QR → مخفی‌شدن فیلد سریال و ارسال withoutQr', (tester) async {
    final api = FakeApi();
    await pumpDialog(tester, api);

    // انتخاب مرجوعی
    await tester.tap(find.text('کالای نو'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مرجوعی'));
    await tester.pumpAndSettle();

    // انتخاب محصول و مدل
    await tester.tap(find.text('انتخاب محصول...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اسپیکر'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('انتخاب مدل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مدل آ (10 عدد/کارتن)'));
    await tester.pumpAndSettle();

    // زدن تیک بدون QRcode
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // فیلد سریال باید مخفی شده باشد
    expect(find.text('سریال یا اسکن QR'), findsNothing);

    // ثبت
    await tester.tap(find.text('ثبت ورود کالا'));
    await tester.pumpAndSettle();

    expect(api.submittedItems, isNotNull);
    expect(api.submittedItems![0]['entryType'], 'RETURNED');
    expect(api.submittedItems![0]['withoutQr'], isTrue);
    expect(api.submittedItems![0]['cartonCount'], 0);
    expect(api.submittedItems![0]['individualCount'], 1);
  });

  testWidgets('payload خام USB → استخراج سریال', (tester) async {
    final api = FakeApi();
    await pumpDialog(tester, api);

    // انتخاب مرجوعی
    await tester.tap(find.text('کالای نو'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مرجوعی'));
    await tester.pumpAndSettle();

    // انتخاب محصول و مدل
    await tester.tap(find.text('انتخاب محصول...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اسپیکر'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('انتخاب مدل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مدل آ (10 عدد/کارتن)'));
    await tester.pumpAndSettle();

    // تایپ سریال خام USB
    await tester.enterText(
        find.byType(TextField).last, 'MA|SN|MA-1405-000099|uuid|hmac');

    // ثبت
    await tester.tap(find.text('ثبت ورود کالا'));
    await tester.pumpAndSettle();

    expect(api.submittedItems, isNotNull);
    // سریال استخراج شده باید MA-1405-000099 باشد
    expect(api.submittedItems![0]['serialNumber'], 'MA-1405-000099');
    expect(api.submittedItems![0]['entryType'], 'RETURNED');
  });
}
