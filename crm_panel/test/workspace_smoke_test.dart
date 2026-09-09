import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_crm_panel/core/socket_client.dart';
import 'package:ma_crm_panel/screens/workspace_screen.dart';

import 'fake_api.dart';

void main() {
  testWidgets('ورک‌اسپیس: هر ۶ تب با داده قلابی رندر می‌شوند', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WorkspaceScreen(
        api: FakeCrmApi(),
        socket: CrmSocketClient('http://127.0.0.1:3000'),
        userName: 'مدیر تست',
        onLogout: () {},
      ),
    ));
    await tester.pumpAndSettle();

    // سایدبار + تب پیش‌فرض (نمای کلی)
    expect(find.text('CRM مالک'), findsOneWidget);
    expect(find.text('نمای کلی'), findsWidgets);
    expect(find.text('کاربران فعال'), findsOneWidget);

    // مشتریان
    await tester.tap(find.text('مشتریان'));
    await tester.pumpAndSettle();
    expect(find.textContaining('09120000001'), findsWidgets);

    // مالی
    await tester.tap(find.text('مالی'));
    await tester.pumpAndSettle();
    expect(find.textContaining('جمع مبالغ'), findsOneWidget);

    // فعالیت‌ها
    await tester.tap(find.text('فعالیت‌ها'));
    await tester.pumpAndSettle();
    expect(find.textContaining('تایم‌لاین'), findsOneWidget);

    // سلامت سیستم
    await tester.tap(find.text('سلامت سیستم'));
    await tester.pumpAndSettle();
    expect(find.text('outbox در انتظار'), findsOneWidget);

    // تنظیمات + جدول کلیدها
    await tester.tap(find.text('تنظیمات'));
    await tester.pumpAndSettle();
    expect(find.textContaining('حسابداری'), findsWidgets);
  });
}
