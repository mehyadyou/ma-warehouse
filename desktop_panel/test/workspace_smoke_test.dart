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
      expect(find.text('ورودی‌های اخیر'), findsWidgets);
      expect(find.text('تکمیل شده‌ها'), findsWidgets);
      expect(find.text('تاریخچه تراکنش‌ها'), findsWidgets);
      expect(find.text('بیجک'), findsWidgets);
      expect(find.text('خروج از حساب'), findsOneWidget);
    },
  );
}
