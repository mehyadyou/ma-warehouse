import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/screens/tabs/cartons_tab.dart';
import 'package:ma_warehouse_panel/screens/tabs/badges_tab.dart';
import 'package:ma_warehouse_panel/widgets/accordion_item.dart';
import 'package:ma_warehouse_panel/widgets/badge_group_card.dart';

Map<String, dynamic> carton(
  String model,
  String product,
  String createdAt, {
  String serial = 'S1',
}) {
  return {
    'model': {'name': model, 'unitsPerBox': 10},
    'product': {'name': product},
    'createdAt': createdAt,
    'serialNumber': serial,
  };
}

void main() {
  group('groupCartonsByLabel', () {
    test('groups by (model, product | entry date)', () {
      final groups = groupCartonsByLabel([
        carton('مدل آ', 'محصول ۱', '2026-08-20T10:00:00'),
        carton('مدل آ', 'محصول ۱', '2026-08-20T12:00:00'),
        carton('مدل آ', 'محصول ۲', '2026-08-20T10:00:00'),
        carton('مدل ب', 'محصول ۱', '2026-08-20T10:00:00'),
      ]);
      expect(groups.length, 3);
      final first = groups.first;
      expect(first.$1.title, 'مدل آ');
      expect(first.$1.subtitle, 'محصول ۱ | تاریخ ورود: 2026-08-20');
      expect(first.$2.length, 2);
    });

    test('preserves insertion order', () {
      final groups = groupCartonsByLabel([
        carton('مدل ز', 'محصول', '2026-08-20T10:00:00'),
        carton('مدل آ', 'محصول', '2026-08-20T10:00:00'),
      ]);
      expect(groups.map((e) => e.$1.title).toList(), ['مدل ز', 'مدل آ']);
    });

    test('empty input yields empty output', () {
      expect(groupCartonsByLabel([]), isEmpty);
    });
  });

  group('groupBadgesByOrder', () {
    test('groups, sorts by createdAt, derives sequence and total', () {
      final groups = groupBadgesByOrder([
        {'orderId': 'o1', 'createdAt': '2026-08-20T12:00:00'},
        {'orderId': 'o1', 'createdAt': '2026-08-20T10:00:00'},
        {'orderId': 'o1', 'createdAt': '2026-08-20T11:00:00'},
        {'orderId': 'o2', 'createdAt': '2026-08-20T09:00:00'},
      ]);
      expect(groups.length, 2);
      final first = groups.first;
      expect(first.$1, 'o1');
      expect(first.$2.map((b) => (b['sequence'], b['total'])).toList(), [
        (1, 3),
        (2, 3),
        (3, 3),
      ]);
      expect(first.$2.map((b) => b['createdAt']).toList(), [
        '2026-08-20T10:00:00',
        '2026-08-20T11:00:00',
        '2026-08-20T12:00:00',
      ]);
    });
  });

  group('CartonsTab widget', () {
    testWidgets('renders accordion items and summary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartonsTab(
              fetch: () async => [
                carton('مدل آ', 'محصول ۱', '2026-08-20T10:00:00'),
                carton('مدل آ', 'محصول ۱', '2026-08-20T12:00:00'),
              ],
              initialSummary: 'آخرین برچسب‌های ثبت شده',
              emptySummary: 'هیچ کارتنی ثبت نشده.',
              emptyState: 'هیچ ورودی جدیدی ثبت نشده است.',
              summary: (groups, total) =>
                  '$groups گروه کالا | $total برچسب آماده چاپ',
              errorSummary: 'خطا',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 گروه کالا | 2 برچسب آماده چاپ'), findsOneWidget);
      expect(find.byType(AccordionItem), findsOneWidget);
      expect(find.text('مدل آ'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartonsTab(
              fetch: () async => [],
              initialSummary: '',
              emptySummary: 'هیچ کارتنی ثبت نشده.',
              emptyState: 'هیچ ورودی جدیدی ثبت نشده است.',
              summary: (groups, total) => '$groups',
              errorSummary: 'خطا',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('هیچ کارتنی ثبت نشده.'), findsOneWidget);
      expect(find.text('هیچ ورودی جدیدی ثبت نشده است.'), findsOneWidget);
    });
  });

  group('BadgeGroupCard widget', () {
    testWidgets('renders title with short order id and badge count', (
      tester,
    ) async {
      final badges = [
        {
          'orderId': 'abcdef12-3456',
          'sequence': 1,
          'senderName': 'فرستنده',
          'receiverName': 'گیرنده',
          'order': {
            'warehouse': {'name': 'انبار مرکزی'},
            'status': 'PENDING',
          },
        },
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BadgeGroupCard(orderId: 'abcdef12-3456', badges: badges),
          ),
        ),
      );

      expect(find.text('MA-ABCDEF12 — سفارش انبار مرکزی'), findsOneWidget);
      expect(find.text('1 بیجک'), findsOneWidget);
      expect(find.textContaining('در انتظار'), findsOneWidget);
    });
  });
}
