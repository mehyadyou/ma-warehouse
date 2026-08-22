import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/realtime/socket_service.dart';
import 'package:ma_app/features/manager/assistant/assistant_screen.dart';
import 'package:ma_app/features/manager/assistant/data/assistant_api_service.dart';
import 'package:ma_app/features/manager/assistant/providers/assistant_provider.dart';

class _FakeApi extends AssistantApiService {
  _FakeApi() : super(socket: SocketService());

  int askCalls = 0;
  String? lastMessage;
  List<AssistantHistoryItem> lastHistory = [];
  bool fail = false;

  /// پاسخ سفارشی — برای تست محتوای خاص (مثل جدول پهن)
  String response = 'گزارش کامل موجودی';

  @override
  Future<void> ask({
    required String message,
    required List<AssistantHistoryItem> history,
    required void Function(String text) onToken,
    required void Function(String text) onStatus,
    required void Function(String fullText) onDone,
    required void Function(String error) onError,
  }) async {
    askCalls++;
    lastMessage = message;
    lastHistory = history;
    if (fail) {
      onError('خطای تست دستیار');
      return;
    }
    // رویدادها مثل سوکت واقعی تدریجی می‌رسند تا وضعیت میانهٔ استریم قابل مشاهده باشد
    onStatus('بذار موجودی رو حساب کنم');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    onToken(response);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    onDone(response);
  }
}

Widget _app(_FakeApi api) {
  return ProviderScope(
    overrides: [assistantApiServiceProvider.overrideWithValue(api)],
    child: const MaterialApp(home: AssistantScreen()),
  );
}

/// دکمهٔ ارسال (شناسایی با آیکون — مستقل از ترتیب درخت)
Finder get _sendButton => find.ancestor(
  of: find.byIcon(Icons.send_rounded),
  matching: find.byType(IconButton),
);

void main() {
  late _FakeApi api;

  setUp(() {
    api = _FakeApi();
  });

  testWidgets('حالت اولیه: عنوان، راهنما، میکروفون و ارسال غیرفعال', (
    tester,
  ) async {
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('دستیار'), findsOneWidget);
    expect(find.text('از دستیار بپرس'), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    // دکمهٔ ارسال غیرفعال است
    final sendBtn = tester.widget<IconButton>(_sendButton);
    expect(sendBtn.onPressed, isNull);
  });

  testWidgets(
    'ارسال پیام: حباب کاربر + پاسخ استریمی + تاریخچه بدون پیام جاری',
    (tester) async {
      await tester.pumpWidget(_app(api));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'موجودی امروز چند است؟');
      await tester.pump();

      // پس از تایپ، ارسال فعال می‌شود
      final sendBtn = tester.widget<IconButton>(_sendButton);
      expect(sendBtn.onPressed, isNotNull);

      await tester.tap(_sendButton);
      await tester.pumpAndSettle();

      expect(api.askCalls, 1);
      expect(api.lastMessage, 'موجودی امروز چند است؟');
      expect(api.lastHistory, isEmpty);

      // حباب کاربر
      expect(find.text('موجودی امروز چند است؟'), findsOneWidget);
      // پاسخ نهایی دستیار
      expect(find.text('گزارش کامل موجودی'), findsOneWidget);
      // فیلد ورودی پاک شده است
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    },
  );

  testWidgets('در حال فکرکردن: وضعیت زنده (reasoning) هنگام استریم دیده می‌شود', (
    tester,
  ) async {
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'موجودی؟');
    await tester.pump();
    await tester.tap(_sendButton);
    // هنوز استریم تمام نشده — وضعیت فکرکردن باید دیده شود (مثل حالت واقعی)
    await tester.pump();

    expect(find.text('بذار موجودی رو حساب کنم'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('گزارش کامل موجودی'), findsOneWidget);
  });

  testWidgets('خطای دستیار → snackbar نمایش داده می‌شود', (tester) async {
    api.fail = true;
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'سلام');
    await tester.pump();
    await tester.tap(_sendButton);
    await tester.pumpAndSettle();

    expect(find.text('خطای تست دستیار'), findsOneWidget);
    expect(api.askCalls, 1);
  });

  testWidgets('چت جدید: با تأیید، گفتگو پاک می‌شود', (tester) async {
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'سلام');
    await tester.pump();
    await tester.tap(_sendButton);
    await tester.pumpAndSettle();
    expect(find.text('گزارش کامل موجودی'), findsOneWidget);

    // دکمهٔ چت جدید فقط وقتی گفتگو وجود دارد دیده می‌شود
    await tester.tap(find.byIcon(Icons.add_comment_rounded));
    await tester.pumpAndSettle();
    expect(find.text('گفتگوی فعلی پاک شود؟'), findsOneWidget);

    await tester.tap(find.text('پاک کن'));
    await tester.pumpAndSettle();

    // برگشت به حالت اولیه
    expect(find.text('از دستیار بپرس'), findsOneWidget);
    expect(find.byIcon(Icons.add_comment_rounded), findsNothing);
  });

  testWidgets(
    'جدول پهن: فقط خود جدول اسکرول افقی می‌شود و صفحه دفرمه نمی‌شود',
    (tester) async {
      // جدولی با ستون‌های زیاد — خیلی پهن‌تر از عرض صفحهٔ تست
      api.response = [
        '| انبار | محصول | مدل | موجودی | در انتظار | ارسال‌شده |',
        '|-------|--------|-----|--------|-----------|----------|',
        '| انبار تهران | یخچال ساید بای ساید بزرگ با نام خیلی طولانی |',
        'مدل ۲۰۲۶ پریمیوم | ۱۲۰ | ۴۵ | ۳۲ |',
        '| انبار کرج | لباسشویی | مدل X | ۸ | ۲ | ۱ |',
        '',
      ].join('\n');

      await tester.pumpWidget(_app(api));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'گزارش جدولی بده');
      await tester.pump();
      await tester.tap(_sendButton);
      // بدون settle کامل: در طول استریم جدول هم باید اسکرول‌پذیر باشد
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      // جدول در یک اسکرول افقی قرار گرفته است
      final horizontalScrolls = tester.widgetList<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      ).where((w) => w.scrollDirection == Axis.horizontal);
      expect(horizontalScrolls, isNotEmpty);

      // محتوای جدول قابل مشاهده است
      expect(find.text('انبار تهران'), findsOneWidget);
      expect(find.textContaining('یخچال ساید بای ساید'), findsOneWidget);
    },
  );

  testWidgets('تاریخچه: فقط ۱۲ پیام آخر ارسال می‌شود', (tester) async {
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    // چند پیام قبلی می‌فرستیم (هر بار fake فوری پاسخ می‌دهد)
    for (var i = 1; i <= 15; i++) {
      await tester.enterText(find.byType(TextField), 'پیام $i');
      await tester.pump();
      await tester.tap(_sendButton);
      await tester.pumpAndSettle();
    }

    expect(api.askCalls, 15);
    // ۱۴ پیام قبلی بود (کاربر+دستیار) → فقط ۱۲ تای آخر ارسال شد
    expect(api.lastHistory.length, 12);
    expect(api.lastHistory.first.role, 'user');
    expect(api.lastHistory.first.content, 'پیام 9');
    expect(api.lastHistory.last.role, 'assistant');
  });
}
