import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/updates/update_popup.dart';
import 'package:ma_app/core/updates/update_service.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

AppUpdateInfo _info({bool isForce = false}) => AppUpdateInfo(
      versionName: '1.2.0',
      versionCode: 12,
      changelog: 'رفع اشکال فیلتر تاریخ و بهبود سرعت',
      isForce: isForce,
      apkUrl: '/uploads/apk/ma-12.apk',
      apkSizeBytes: 52_428_800, // ۵۰ مگابایت
      apkSha256: 'abc',
    );

void main() {
  testWidgets('پاپ‌آپ بروزرسانی: نام نسخه، توضیحات و حجم نمایش داده می‌شود',
      (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showUpdatePopup(context, _info()),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('بروزرسانی جدید'), findsOneWidget);
    expect(find.text('نسخهٔ ۱.۲.۰ آماده است'), findsOneWidget);
    expect(find.text('رفع اشکال فیلتر تاریخ و بهبود سرعت'), findsOneWidget);
    // ۵۲۴۲۸۸۰۰ بایت ≈ ۵۰ مگابایت
    expect(find.textContaining('مگابایت'), findsOneWidget);
    expect(find.text('نصب بروزرسانی'), findsOneWidget);
    // حالت اختیاری: دکمهٔ «بعداً» هست
    expect(find.text('بعداً'), findsOneWidget);
  });

  testWidgets('پاپ‌آپ اجباری: بدون دکمهٔ «بعداً» + هشدار اجباری',
      (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showUpdatePopup(context, _info(isForce: true)),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('بعداً'), findsNothing);
    expect(find.textContaining('اجباری'), findsOneWidget);
  });

  testWidgets('پاپ‌آپ اجباری با back بسته نمی‌شود', (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showUpdatePopup(context, _info(isForce: true)),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isTrue);

    // barrierDismissible=false → تپ روی بیرون دیالوگ نمی‌بندد
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('بروزرسانی جدید'), findsOneWidget);
  });

  testWidgets('حالت اختیاری: تپ روی بیرون دیالوگ می‌بندد', (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showUpdatePopup(context, _info()),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('بروزرسانی جدید'), findsNothing);
  });

  test('AppUpdateInfo.fromJson — پارس درست فیلدهای سرور', () {
    final info = AppUpdateInfo.fromJson({
      'versionName': '2.0.1',
      'versionCode': 20,
      'changelog': 'تست',
      'isForce': true,
      'apkUrl': '/uploads/apk/ma-20.apk',
      'apkSizeBytes': 1000,
      'apkSha256': 'deadbeef',
    });
    expect(info.versionCode, 20);
    expect(info.isForce, isTrue);
    expect(info.apkSha256, 'deadbeef');
  });
}
