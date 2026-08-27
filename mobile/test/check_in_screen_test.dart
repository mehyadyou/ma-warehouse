import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/warehouse_keeper/check_in/check_in_screen.dart';
import 'package:ma_app/features/warehouse_keeper/data/warehouse_keeper_api_service.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_product_model.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';

class _FakeApi extends WarehouseKeeperApiService {
  static const _products = <KeeperProductModel>[
    KeeperProductModel(
      id: 'p1',
      name: 'کالای تکعددی',
      unit: 'عدد',
      models: [
        KeeperProductVariantModel(
          id: 'm1',
          name: 'تک',
          unitsPerBox: 1,
          packageType: 'کارتن',
        ),
      ],
    ),
    KeeperProductModel(
      id: 'p2',
      name: 'کالای چندعددی',
      unit: 'عدد',
      models: [
        KeeperProductVariantModel(
          id: 'm2',
          name: 'چند',
          unitsPerBox: 12,
          packageType: 'کارتن',
        ),
      ],
    ),
  ];

  @override
  Future<({List<KeeperProductModel> products, int total})> getProductsPage({
    String q = '',
    required int page,
    required int pageSize,
  }) async {
    final query = q.trim().toLowerCase();
    final list = query.isEmpty
        ? _products
        : _products
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
    final total = list.length;
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, total);
    final pageItems = start >= total
        ? const <KeeperProductModel>[]
        : list.sublist(start, end);
    return (products: pageItems, total: total);
  }
}

Widget _app() => ProviderScope(
  overrides: [wkApiProvider.overrideWithValue(_FakeApi())],
  child: const MaterialApp(home: CheckInScreen()),
);

/// باز کردن پیکر محصول و انتخاب محصول با نام داده‌شده
Future<void> _pickProduct(WidgetTester tester, String name) async {
  await tester.tap(find.text('انتخاب محصول...').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

/// انتخاب مدل از دراپ‌داون (با برچسب کامل شامل ظرفیت)
Future<void> _pickModel(WidgetTester tester, String label) async {
  await tester.tap(find.text('انتخاب مدل'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('مدل تکعددی (هر کارتن = یک عدد) → گزینهٔ «تکی» پنهان می‌شود', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    // قبل از انتخاب محصول/مدل، هر دو شمارنده دیده می‌شوند
    expect(find.text('کارتن'), findsOneWidget);
    expect(find.text('تکی'), findsOneWidget);

    await _pickProduct(tester, 'کالای تکعددی');
    await _pickModel(tester, 'تک (1 عدد/کارتن)');

    // چون کارتن همان تک‌عدد است، «تکی» معنی ندارد و پنهان است
    expect(find.text('کارتن'), findsOneWidget);
    expect(find.text('تکی'), findsNothing);
  });

  testWidgets('مدل چندعددی → گزینهٔ «تکی» نمایش داده می‌شود', (tester) async {
    await tester.pumpWidget(_app());

    await _pickProduct(tester, 'کالای چندعددی');
    await _pickModel(tester, 'چند (12 عدد/کارتن)');

    expect(find.text('کارتن'), findsOneWidget);
    expect(find.text('تکی'), findsOneWidget);
  });

  testWidgets('تعویض از مدل تکعددی به چندعددی → «تکی» دوباره ظاهر می‌شود', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    await _pickProduct(tester, 'کالای تکعددی');
    await _pickModel(tester, 'تک (1 عدد/کارتن)');
    expect(find.text('تکی'), findsNothing);

    // محصول دیگری با مدل چندعددی انتخاب می‌شود
    await tester.tap(find.text('کالای تکعددی').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('کالای چندعددی'));
    await tester.pumpAndSettle();
    await _pickModel(tester, 'چند (12 عدد/کارتن)');

    expect(find.text('کارتن'), findsOneWidget);
    expect(find.text('تکی'), findsOneWidget);
  });
}
