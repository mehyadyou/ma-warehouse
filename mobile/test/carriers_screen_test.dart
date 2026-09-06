import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/features/warehouse_keeper/carriers/carriers_screen.dart';
import 'package:ma_app/features/warehouse_keeper/data/warehouse_keeper_api_service.dart';
import 'package:ma_app/features/warehouse_keeper/models/keeper_carrier_model.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';

/// فیک API باربری — بدون Dio، با ثبت فراخوانی‌ها برای assert
class _FakeApi extends WarehouseKeeperApiService {
  List<KeeperCarrierModel> carriers;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int reorderCalls = 0;
  List<String>? lastReorderIds;
  String? lastSavedName;

  _FakeApi(this.carriers);

  @override
  Future<List<KeeperCarrierModel>> reorderCarriers(List<String> ids) async {
    reorderCalls++;
    lastReorderIds = ids;
    final byId = {for (final c in carriers) c.id: c};
    carriers = [for (final id in ids) byId[id]!];
    return carriers;
  }

  @override
  Future<List<KeeperCarrierModel>> getCarriers() async => carriers;

  @override
  Future<KeeperCarrierModel> createCarrier({
    required String name,
    int priority = 0,
    String? phone,
    String? address,
  }) async {
    createCalls++;
    lastSavedName = name;
    final c = KeeperCarrierModel(
      id: 'c-new',
      name: name,
      priority: priority,
      phone: phone,
      address: address,
    );
    carriers = [...carriers, c];
    return c;
  }

  @override
  Future<KeeperCarrierModel> updateCarrier(
    String id, {
    String? name,
    int? priority,
    String? phone,
    String? address,
  }) async {
    updateCalls++;
    final updated = carriers
        .map((c) => c.id == id
            ? c.copyWith(
                name: name ?? c.name,
                priority: priority ?? c.priority,
                phone: phone,
                address: address,
              )
            : c)
        .toList();
    carriers = updated;
    return updated.firstWhere((c) => c.id == id);
  }

  @override
  Future<void> deleteCarrier(String id) async {
    deleteCalls++;
    carriers = carriers.where((c) => c.id != id).toList();
  }
}

Widget _app(_FakeApi api) {
  return ProviderScope(
    overrides: [wkApiProvider.overrideWithValue(api)],
    child: const MaterialApp(home: CarriersScreen()),
  );
}

Future<void> _openForm(WidgetTester tester, {String buttonText = 'باربری جدید'}) async {
  await tester.tap(find.text(buttonText));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('لیست باربری‌ها از سرور نمایش داده می‌شود', (tester) async {
    final api = _FakeApi([
      const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 1, phone: '071-12345678', address: 'شیراز'),
      const KeeperCarrierModel(id: 'c2', name: 'باربری قدس', priority: 2),
    ]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('باربری فارس'), findsOneWidget);
    expect(find.text('باربری قدس'), findsOneWidget);
    expect(find.textContaining('071-12345678'), findsOneWidget);
  });

  testWidgets('افزودن باربری جدید → ثبت فراخوانی create و ظاهر شدن در انتهای صف', (tester) async {
    final api = _FakeApi([const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 0)]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('باربری‌ای ثبت نشده است'), findsNothing);

    await _openForm(tester);
    await tester.enterText(find.widgetWithText(TextField, 'نام باربری *'), 'باربری تازه');
    // فیلد اولویت حذف شده — ترتیب فقط با درگ‌انددراپ تعیین می‌شود
    expect(find.text('اولویت (عدد کوچک‌تر = زودتر در بارگیری)'), findsNothing);
    await tester.tap(find.text('افزودن باربری'));
    await tester.pumpAndSettle();

    expect(api.createCalls, 1);
    expect(api.lastSavedName, 'باربری تازه');
    expect(find.text('باربری تازه'), findsOneWidget);
  });

  testWidgets('درگ‌انددراپ: جابه‌جایی در صف → reorder با ترتیب جدید ثبت و نمایش داده می‌شود', (tester) async {
    final api = _FakeApi([
      const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 0),
      const KeeperCarrierModel(id: 'c2', name: 'باربری قدس', priority: 1),
    ]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    // جایگاه صف نمایش داده می‌شود: فارس اول (دورترین = اولین بار)، قدس دوم
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle_rounded), findsNWidgets(2));

    // باربری دوم را با دستگیرهٔ درگ به بالا می‌کشیم
    // کارت با ReorderableDelayedDragStartListener درگ می‌شود → اول باید نگه‌داشت
    // (لانگ‌پرس) تا درگ شروع شود، بعد حرکت
    final handle = find.byIcon(Icons.drag_handle_rounded).at(1);
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    for (var i = 0; i < 4; i++) {
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(api.reorderCalls, 1);
    expect(api.lastReorderIds, ['c2', 'c1']);
    // جایگاه جدید: قدس اول
    expect(find.text('باربری قدس'), findsOneWidget);
  });

  testWidgets('با موس: درگ بلافاصله با کلیک-کشیدن (بدون نگه‌داشتن) انجام می‌شود', (tester) async {
    final api = _FakeApi([
      const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 0),
      const KeeperCarrierModel(id: 'c2', name: 'باربری قدس', priority: 1),
    ]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    // حرکت موس روی لیست → حالت درگ فوری فعال می‌شود (بدون نیاز به کلیک)
    final handle = find.byIcon(Icons.drag_handle_rounded).at(1);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(handle));
    await tester.pump();
    await mouse.moveTo(tester.getCenter(handle) + const Offset(10, 0));
    await tester.pump();

    // کلیک و کشیدن فوری — بدون صبر برای kLongPressTimeout
    await mouse.down(tester.getCenter(handle));
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await mouse.moveBy(const Offset(0, -40));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await mouse.up();
    await tester.pumpAndSettle();

    expect(api.reorderCalls, 1);
    expect(api.lastReorderIds, ['c2', 'c1']);
    expect(find.text('باربری قدس'), findsOneWidget);
  });

  testWidgets('بعد از درگ، افزودن/حذف با لیست تازهٔ سرور نمایش داده می‌شود', (tester) async {
    final api = _FakeApi([
      const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 0),
      const KeeperCarrierModel(id: 'c2', name: 'باربری قدس', priority: 1),
    ]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    // اول یک درگ انجام می‌دهیم تا سایهٔ ترتیب محلی فعال شود
    final handle = find.byIcon(Icons.drag_handle_rounded).at(1);
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    for (var i = 0; i < 4; i++) {
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(api.reorderCalls, 1);
    expect(api.lastReorderIds, ['c2', 'c1']);

    // افزودن بعد از درگ → باربری جدید باید ظاهر شود (سایهٔ کهنه نباید پوشانده)
    await _openForm(tester);
    await tester.enterText(find.widgetWithText(TextField, 'نام باربری *'), 'باربری تازه');
    await tester.tap(find.text('افزودن باربری'));
    await tester.pumpAndSettle();
    expect(find.text('باربری تازه'), findsOneWidget);

    // حذف بعد از درگ → کارت حذف‌شده باید ناپدید شود
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();
    expect(api.deleteCalls, 1);
    expect(find.text('باربری قدس'), findsNothing);
  });

  testWidgets('نام خالی → بدون درخواست پیام خطا نشان داده می‌شود', (tester) async {
    final api = _FakeApi([]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await _openForm(tester);

    await tester.tap(find.text('افزودن باربری'));
    await tester.pump();

    expect(api.createCalls, 0);
    expect(find.text('نام باربری الزامی است'), findsOneWidget);
  });

  testWidgets('ویرایش باربری → فرم پیش‌پر شده و تغییرات ذخیره می‌شود', (tester) async {
    final api = _FakeApi([
      const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 1, phone: '071-12345678'),
    ]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // فرم با مقادیر موجود پر شده است
    expect(find.widgetWithText(TextField, 'باربری فارس'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'نام باربری *'), 'باربری نوین فارس');
    await tester.tap(find.text('ذخیرهٔ تغییرات'));
    await tester.pumpAndSettle();

    expect(api.updateCalls, 1);
    expect(find.text('باربری نوین فارس'), findsOneWidget);
    expect(find.text('باربری فارس'), findsNothing);
  });

  testWidgets('حذف باربری با تأیید → ثبت فراخوانی delete و حذف از لیست', (tester) async {
    final api = _FakeApi([
      const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 1),
      const KeeperCarrierModel(id: 'c2', name: 'باربری قدس', priority: 2),
    ]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    // دیالوگ تأیید
    expect(find.text('حذف باربری'), findsOneWidget);
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    expect(api.deleteCalls, 1);
    expect(find.text('باربری فارس'), findsNothing);
    expect(find.text('باربری قدس'), findsOneWidget);
  });

  testWidgets('انصراف از دیالوگ حذف → هیچ درخواستی ارسال نمی‌شود', (tester) async {
    final api = _FakeApi([
      const KeeperCarrierModel(id: 'c1', name: 'باربری فارس', priority: 1),
    ]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('انصراف'));
    await tester.pumpAndSettle();

    expect(api.deleteCalls, 0);
    expect(find.text('باربری فارس'), findsOneWidget);
  });
}