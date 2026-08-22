import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/shared/widgets/inventory_donut_card.dart';

void main() {
  const items = [
    InventoryItem(name: 'محصول آ', count: 100, unit: 'عدد', color: Color(0xFF4ADE80)),
    InventoryItem(name: 'محصول ب', count: 0, unit: 'عدد', color: Color(0xFF60A5FA)),
    InventoryItem(name: 'محصول ج', count: 400, unit: 'عدد', color: Color(0xFFFB923C)),
  ];

  testWidgets('debug tap', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: InventoryDonutCard(items: items)),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('محصول آ'));
    await tester.pumpAndSettle();

    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      debugPrint('TEXT: "${w.data}" fontSize=${w.style?.fontSize} color=${w.style?.color}');
    }
  });
}