import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ma_app/main.dart';

void main() {
  testWidgets('برنامه بدون خطا بالا می‌آید', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaApp()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
