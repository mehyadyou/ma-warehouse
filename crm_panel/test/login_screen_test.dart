import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_crm_panel/screens/login_screen.dart';

import 'fake_api.dart';

void main() {
  testWidgets('لاگین مدیر موفق → onLoginSuccess', (tester) async {
    var done = false;
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(
        api: FakeCrmApi(),
        onLoginSuccess: () => done = true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '09120000000');
    await tester.enterText(find.byType(TextField).at(1), 'Manager123');
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    expect(done, isTrue);
  });

  testWidgets('نقش غیرمدیر رد می‌شود', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(
        api: FakeCrmApi(loginRole: 'WAREHOUSE_KEEPER'),
        onLoginSuccess: () {},
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '09120000000');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    expect(find.textContaining('فقط برای مدیر'), findsWidgets);
  });

  testWidgets('رمز موقت → حالت تغییر رمز با قانون قوی', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(
        api: FakeCrmApi(mustChange: true),
        onLoginSuccess: () {},
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '09120000000');
    await tester.enterText(find.byType(TextField).at(1), 'Temp1234');
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    // صفحه تغییر رمز با راهنمای رمز قوی
    expect(find.textContaining('حداقل ۸ کاراکتر'), findsOneWidget);
  });
}
