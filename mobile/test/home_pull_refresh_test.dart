import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/warehouse_keeper/dashboard/home/home_screen.dart';

void main() {
  testWidgets('خانه انباردار pull-to-refresh دارد', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
