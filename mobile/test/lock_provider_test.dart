import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/auth/lock/lock_config.dart';
import 'package:ma_app/features/auth/lock/lock_provider.dart';
import 'package:ma_app/features/auth/lock/lock_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const secureChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

Map<String, String> mockSecureChannel() {
  final store = <String, String>{};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureChannel, (call) async {
    switch (call.method) {
      case 'read':
        return store[call.arguments['key'] as String];
      case 'write':
        store[call.arguments['key'] as String] = call.arguments['value'] as String;
        return null;
      case 'delete':
        store.remove(call.arguments['key'] as String);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(call.arguments['key'] as String);
      case 'readAll':
        return Map<String, String>.from(store);
    }
    return null;
  });
  return store;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late Map<String, String> store;

  setUpAll(() async {
    await LocalStorage.init();
  });

  setUp(() {
    store = mockSecureChannel();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, null);
  });

  Future<LockState> settled(ProviderContainer container) async {
    container.read(lockProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return container.read(lockProvider);
  }

  group('LockNotifier', () {
    test('بارگذاری اولیه: checking=false با مقادیر ذخیره‌شده', () async {
      await LocalStorage.saveLockMethod('pin');
      store['lock_pin_salt'] = 'salt';
      store['lock_pin_hash'] = 'hash';

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await settled(container);
      expect(state.checking, isFalse);
      expect(state.method, LockMethod.pin);
      expect(state.hasPin, isTrue);
    });

    test('setupPin: پین معتبر قبول و پین نامعتبر رد می‌شود', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      expect(await notifier.setupPin('12'), isFalse);
      expect(await notifier.setupPin('12345'), isFalse);
      expect(await notifier.setupPin('abcd'), isFalse);

      expect(await notifier.setupPin('2468'), isTrue);
      expect(container.read(lockProvider).hasPin, isTrue);
      expect(await LockStorage.verifyPin('2468'), isTrue);
    });

    test('changeMethod به پین بدون پین → رد؛ بعد از تعیین پین → قبول', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      expect(await notifier.changeMethod(LockMethod.pin), isFalse);

      await notifier.setupPin('1357');
      expect(await notifier.changeMethod(LockMethod.pin), isTrue);
      expect(container.read(lockProvider).method, LockMethod.pin);
      expect(container.read(lockProvider).hasPin, isTrue);
    });

    test('تغییر روش از پین به بدون قفل، پین را نگه می‌دارد (مصوب)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      await notifier.setupPin('1357');
      await notifier.changeMethod(LockMethod.pin);
      await notifier.changeMethod(LockMethod.none);

      expect(container.read(lockProvider).method, LockMethod.none);
      expect(container.read(lockProvider).hasPin, isTrue);
      expect(await LockStorage.verifyPin('1357'), isTrue);
    });

    test('changePin: با پین فعلی اشتباه رد، با درست قبول', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      await notifier.setupPin('1234');

      expect(await notifier.changePin('9999', '0000'), isFalse);
      expect(await notifier.changePin('1234', '0000'), isTrue);
      expect(await LockStorage.verifyPin('0000'), isTrue);
      expect(await LockStorage.verifyPin('1234'), isFalse);
    });

    test('verifyPin: پین درست → تلاش‌ها صفر؛ پنج اشتباه → کولداون ۳۰ ثانیه', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      await notifier.setupPin('1234');
      await notifier.changeMethod(LockMethod.pin);

      expect(await notifier.verifyPin('1234'), isTrue);
      expect(container.read(lockProvider).failedAttempts, 0);

      for (var i = 1; i <= 4; i++) {
        expect(await notifier.verifyPin('0000'), isFalse);
        expect(container.read(lockProvider).failedAttempts, i);
      }

      // پنجمین اشتباه → کولداون فعال
      expect(await notifier.verifyPin('0000'), isFalse);
      final afterFive = container.read(lockProvider);
      expect(afterFive.failedAttempts, 0);
      expect(afterFive.cooldownUntil, isNotNull);
      expect(
        afterFive.cooldownUntil!.isAfter(DateTime.now()),
        isTrue,
      );

      // در کولداون حتی پین درست هم پذیرفته نمی‌شود
      expect(await notifier.verifyPin('1234'), isFalse);
    });

    test('clearAllForLogout: همه‌چیز پاک می‌شود', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      await notifier.setupPin('1234');
      await notifier.changeMethod(LockMethod.pin);

      await notifier.clearAllForLogout();

      final state = container.read(lockProvider);
      expect(state.method, LockMethod.none);
      expect(state.hasPin, isFalse);
      expect(await LockStorage.getMethod(), LockMethod.none);
    });

    test('مهاجرت از سوئیچ قدیمی: biometric_enabled=true → روش قفل نوشته می‌شود', () async {
      // بدون کلید lock_method — فقط سوئیچ قدیمی فعال است
      await LocalStorage.setBiometricEnabled(true);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      // در محیط تست بیومتریک در دسترس نیست → مهاجرت به none انجام می‌شود
      // (نکته مهم: کلید روش قفل حالا نوشته شده است — مهاجرت یک‌باره انجام شد)
      expect(LocalStorage.getLockMethod(), isNotNull);
      expect(container.read(lockProvider).checking, isFalse);
    });
  });
}
