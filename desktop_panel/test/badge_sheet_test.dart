import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/label_data.dart';
import 'package:ma_warehouse_panel/widgets/badge_sheet_widget.dart';

Map<String, dynamic> _order({
  String shippingMethod = 'باربری',
  String? city,
  String? postalCode,
  String? address,
  String? customerPhone,
  String? senderPhone,
  String? senderNationalId,
}) =>
    {
      'shippingMethod': shippingMethod,
      'carrier': null,
      'city': city,
      'postalCode': postalCode,
      'address': address,
      'customerPhone': customerPhone,
      'senderPhone': senderPhone,
      'senderNationalId': senderNationalId,
    };

Map<String, dynamic> _badge({
  required Map<String, dynamic> order,
  int count = 2,
  String? modelName,
  String? packageType,
  int? unitsPerBox,
  String? senderPhone,
  String? senderNationalId,
  String? receiverCity,
  String? receiverPostalCode,
  String? receiverAddress,
  String? receiverPhone,
}) =>
    {
      'id': 'badge-1',
      'orderId': 'order-1',
      'count': count,
      'modelName': modelName,
      'packageType': packageType,
      'unitsPerBox': unitsPerBox,
      'senderName': 'فرستنده',
      'senderPhone': senderPhone,
      'senderNationalId': senderNationalId,
      'receiverName': 'گیرنده',
      'receiverCity': receiverCity,
      'receiverPostalCode': receiverPostalCode,
      'receiverAddress': receiverAddress,
      'receiverPhone': receiverPhone,
      'createdAt': '2026-08-27T00:00:00.000Z',
      'order': order,
    };

void main() {
  group('BadgeData.fromBadge', () {
    test('تیپاکس: فیلدهای عکسِ لحظهٔ ثبت از خودِ بیجک خوانده می‌شوند', () {
      final data = BadgeData.fromBadge(
        _badge(
          order: _order(
            shippingMethod: 'تیپاکس',
            city: 'شهر قدیمی سفارش',
          ),
          senderPhone: '02111111111',
          senderNationalId: '0012345678',
          receiverCity: 'تهران',
          receiverPostalCode: '1234567890',
          receiverAddress: 'خیابان آزادی، پلاک ۱',
          receiverPhone: '09120000000',
          count: 5,
        ),
      );

      expect(data.isTipax, isTrue);
      expect(data.count, 5);
      expect(data.senderName, 'فرستنده');
      expect(data.senderPhone, '02111111111');
      expect(data.senderNationalId, '0012345678');
      expect(data.receiverName, 'گیرنده');
      expect(data.receiverCity, 'تهران');
      expect(data.receiverPostalCode, '1234567890');
      expect(data.receiverAddress, 'خیابان آزادی، پلاک ۱');
      expect(data.receiverPhone, '09120000000');
    });

    test('بیجک قدیمی بدون عکس: فیلدها از اطلاعات سفارش fallback می‌شوند', () {
      final data = BadgeData.fromBadge(
        _badge(
          order: _order(
            shippingMethod: 'باربری',
            city: 'اصفهان',
            postalCode: '98765',
            address: 'آدرس سفارش',
            customerPhone: '09131111111',
            senderPhone: '03111111111',
            senderNationalId: '0011223344',
          ),
        ),
      );

      expect(data.isBarebari, isTrue);
      expect(data.receiverCity, 'اصفهان');
      expect(data.receiverPostalCode, '98765');
      expect(data.receiverAddress, 'آدرس سفارش');
      expect(data.receiverPhone, '09131111111');
      expect(data.senderPhone, '03111111111');
      expect(data.senderNationalId, '0011223344');
      expect(data.count, 2);
    });
  });

  group('BadgeSheetWidget', () {
    Future<void> pump(WidgetTester tester, BadgeData data) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(body: SingleChildScrollView(child: BadgeSheetWidget(data: data))),
        ),
      );
    }

    testWidgets('باربری: فقط فیلدهای باربری نمایش داده می‌شود', (tester) async {
      final data = BadgeData.fromBadge(
        _badge(
          order: _order(shippingMethod: 'باربری', city: 'اصفهان'),
          receiverCity: 'اصفهان',
          receiverPhone: '09131111111',
          count: 3,
        ),
      );
      await pump(tester, data);

      for (final label in [
        'فرستنده',
        'گیرنده',
        'شهر گیرنده',
        'تلفن گیرنده',
        'مدل',
      ]) {
        expect(find.text('▸ $label'), findsOneWidget,
            reason: 'باید ردیف «$label» باشد');
      }
      // بدون عکسِ بسته‌بندی: پیش‌فرض «کارتن» و تعداد کل
      expect(find.text('▸ تعداد کارتن'), findsOneWidget);
      // مقدارها
      expect(find.text('اصفهان'), findsOneWidget);
      expect(find.text('09131111111'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('—'), findsOneWidget); // مدل ثبت نشده

      // فیلدهای تیپاکس نباید دیده شوند
      expect(find.text('▸ تلفن فرستنده'), findsNothing);
      expect(find.text('▸ کد ملی فرستنده'), findsNothing);
      expect(find.text('▸ کد پستی گیرنده'), findsNothing);
      expect(find.text('▸ آدرس گیرنده'), findsNothing);
    });

    testWidgets('تیپاکس: همهٔ ۹ فیلد نمایش داده می‌شود', (tester) async {
      final data = BadgeData.fromBadge(
        _badge(
          order: _order(shippingMethod: 'تیپاکس'),
          senderPhone: '02111111111',
          senderNationalId: '0012345678',
          receiverCity: 'تهران',
          receiverPostalCode: '1234567890',
          receiverAddress: 'خیابان آزادی',
          receiverPhone: '09120000000',
          count: 4,
        ),
      );
      await pump(tester, data);

      for (final label in [
        'فرستنده',
        'تلفن فرستنده',
        'کد ملی فرستنده',
        'گیرنده',
        'شهر گیرنده',
        'کد پستی گیرنده',
        'آدرس گیرنده',
        'تلفن گیرنده',
        'مدل',
        'تعداد کارتن',
      ]) {
        expect(find.text('▸ $label'), findsOneWidget,
            reason: 'باید ردیف «$label» باشد');
      }
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('نوع بسته و مدل از پنل مدیریت روی بیجک می‌آید', (tester) async {
      final data = BadgeData.fromBadge(
        _badge(
          order: _order(shippingMethod: 'باربری', city: 'تهران'),
          modelName: 'مدل آ',
          packageType: 'کیسه',
          unitsPerBox: 10,
          count: 25,
          receiverCity: 'تهران',
          receiverPhone: '09120000000',
        ),
      );
      await pump(tester, data);

      // ردیف مدل + برچسب داینامیک بسته
      expect(find.text('▸ مدل'), findsOneWidget);
      expect(find.text('مدل آ'), findsOneWidget);
      expect(find.text('▸ تعداد کیسه'), findsOneWidget);
      // تعداد بسته = ۲۵ ÷ ۱۰ → ۳ (گرد به بالا)
      expect(find.text('3'), findsOneWidget);
      // برچسب ثابت قدیمی نباید باشد
      expect(find.text('▸ تعداد کارتن'), findsNothing);
    });

    testWidgets('باربری: ردیف «باربری» با نام دقیق باربری نمایش داده می‌شود', (tester) async {
      final withCarrier = BadgeData.fromBadge(
        {
          ..._badge(order: _order(shippingMethod: 'باربری', city: 'تبریز')),
          'order': {
            'shippingMethod': 'باربری',
            'carrier': 'باربری تهران بار',
          },
        },
      );
      await pump(tester, withCarrier);

      expect(find.text('▸ باربری'), findsOneWidget);
      expect(find.text('باربری تهران بار'), findsOneWidget);
    });

    testWidgets('تیپاکس: ردیف باربری مقدار «تیپاکس» دارد', (tester) async {
      final data = BadgeData.fromBadge(
        _badge(order: _order(shippingMethod: 'تیپاکس')),
      );
      await pump(tester, data);

      expect(find.text('▸ باربری'), findsOneWidget);
      expect(find.text('تیپاکس'), findsOneWidget);
    });
  });
}
