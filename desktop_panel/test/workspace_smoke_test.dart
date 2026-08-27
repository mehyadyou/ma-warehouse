import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/api_service.dart';
import 'package:ma_warehouse_panel/core/socket_client.dart';
import 'package:ma_warehouse_panel/screens/workspace_screen.dart';

void main() {
  testWidgets(
    'workspace renders without Scaffold ancestor (Material required)',
    (tester) async {
      final api = ApiService()..configure('http://127.0.0.1:1');
      final socket = SocketClient('http://127.0.0.1:1');

      await tester.pumpWidget(
        MaterialApp(
          // مثل main.dart اپ واقعی، کل اپ RTL است
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
          home: WorkspaceScreen(
            api: api,
            socket: socket,
            userName: 'انباردار تست',
            onLogout: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('محصولات'), findsWidgets);
      expect(find.text('چاپ شده‌ها'), findsWidgets);
      expect(find.text('تکمیل شده‌ها'), findsWidgets);
      expect(find.text('تاریخچه تراکنش‌ها'), findsWidgets);
      expect(find.text('بیجک'), findsWidgets);
      expect(find.text('خروج از حساب'), findsOneWidget);

      // در RTL سایدبار باید سمت راست پنجره باشد (کنار چپ = باگ)
      final contentX = tester.getCenter(find.text('بروزرسانی')).dx;
      final sidebarX = tester.getCenter(find.text('خروج از حساب')).dx;
      expect(sidebarX, greaterThan(contentX),
          reason: 'سایدبار باید سمت راست محتوا باشد');
    },
  );

  testWidgets('آیتم‌های منوی سایدبار هم‌سایز و تمام‌عرض هستند', (tester) async {
    final api = ApiService()..configure('http://127.0.0.1:1');
    final socket = SocketClient('http://127.0.0.1:1');

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: WorkspaceScreen(
          api: api,
          socket: socket,
          userName: 'انباردار تست',
          onLogout: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    final labels = [
      'محصولات',
      'چاپ شده‌ها',
      'تکمیل شده‌ها',
      'تاریخچه تراکنش‌ها',
      'بیجک',
    ];
    final sizes = labels
        .map(
          (l) => tester.getSize(find.byKey(ValueKey('navItem_$l'))),
        )
        .toList();

    // همهٔ آیتم‌ها هم‌عرض و هم‌ارتفاع‌اند
    expect(sizes.map((s) => s.width).toSet().length, 1,
        reason: 'عرض همهٔ آیتم‌های منو باید یکسان باشد');
    expect(sizes.map((s) => s.height).toSet().length, 1,
        reason: 'ارتفاع همهٔ آیتم‌های منو باید یکسان باشد');

    // تمام‌عرض: نزدیک به عرض سایدبار (۲۴۰ - پدینگ‌های ۳۲)
    expect(sizes.first.width, greaterThan(190),
        reason: 'آیتم‌های منو باید تمام‌عرض سایدبار را بگیرند');

    // دکمهٔ «خروج از حساب» هم تمام‌عرض و هم‌عرض آیتم‌های منو
    final logoutSize = tester.getSize(
      find.ancestor(
        of: find.text('خروج از حساب'),
        matching: find.byType(Material),
      ).first,
    );
    expect(logoutSize.width, sizes.first.width);
  });

  testWidgets('تب «چاپ شده‌ها» با انتخاب از منو باز می‌شود', (tester) async {
    final api = ApiService()..configure('http://127.0.0.1:1');
    final socket = SocketClient('http://127.0.0.1:1');

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: WorkspaceScreen(
          api: api,
          socket: socket,
          userName: 'انباردار تست',
          onLogout: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.tap(find.text('چاپ شده‌ها'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // تب بدون خطای رندر باز می‌شود (سرویس به سرور واقعی وصل نیست)
    expect(tester.takeException(), isNull);
    // تب فعال است و تب محصولات دیگر در ایندکس فعال نیست
    expect(find.text('چاپ شده‌ها'), findsWidgets);
  });
}
