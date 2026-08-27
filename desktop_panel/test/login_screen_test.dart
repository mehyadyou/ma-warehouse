import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/api_service.dart';
import 'package:ma_warehouse_panel/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'server url field is hidden by default and toggles with gear button',
    (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: ApiService(), onLoginSuccess: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // دکمهٔ چرخ‌دنده با tooltip وجود دارد و فیلد سرور در شروع دیده نمی‌شود
      expect(find.byTooltip('تنظیمات سرور'), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
      // فقط دو فیلد: شماره موبایل و رمز عبور
      expect(find.byType(TextField), findsNWidgets(2));

      // کلیک روی ⚙ → فیلد سرور ظاهر می‌شود و مقدار پیش‌فرض را دارد
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(3));
      final serverField = tester
          .widgetList<TextField>(find.byType(TextField))
          .first;
      expect(serverField.controller?.text, ApiService.defaultServerUrl);

      // کلیک دوباره → مخفی می‌شود
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(2));
    },
  );
}
