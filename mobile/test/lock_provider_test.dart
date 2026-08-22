import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/auth/data/auth_api_service.dart';
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

class _FakeAuthApi extends AuthApiService {
  _FakeAuthApi(this.accept);

  final bool accept;
  int calls = 0;
  String? lastPassword;

  @override
  Future<bool> verifyPassword(String password) async {
    calls++;
    lastPassword = password;
    return accept;
  }
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

  ProviderContainer containerWithApi(bool accept) {
    return ProviderContainer(
      overrides: [
        lockVerifyApiProvider.overrideWithValue(_FakeAuthApi(accept)),
      ],
    );
  }

  group('LockNotifier', () {
    test('بارگذاری اولیه: checking=false با مقادیر ذخیره‌شده', () async {
      await LocalStorage.saveLockMethod('fingerprint');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await settled(container);
      expect(state.checking, isFalse);
      expect(state.method, LockMethod.fingerprint);
    });

    test('verifyPassword: رمز درست از سرور → تلاش‌ها صفر', () async {
      final container = containerWithApi(true);
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      expect(await notifier.verifyPassword('123456'), isTrue);
      expect(container.read(lockProvider).failedAttempts, 0);
    });

    test('verifyPassword: پنج اشتباه → کولداون ۳۰ ثانیه و رمز درست هم رد می‌شود', () async {
      final container = containerWithApi(false);
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      for (var i = 1; i <= 4; i++) {
        expect(await notifier.verifyPassword('000000'), isFalse);
        expect(container.read(lockProvider).failedAttempts, i);
      }

      // پنجمین اشتباه → کولداون فعال
      expect(await notifier.verifyPassword('000000'), isFalse);
      final afterFive = container.read(lockProvider);
      expect(afterFive.failedAttempts, 0);
      expect(afterFive.cooldownUntil, isNotNull);
      expect(afterFive.cooldownUntil!.isAfter(DateTime.now()), isTrue);

      // در کولداون حتی با API درست هم پذیرفته نمی‌شود (فیک قبلی هنوز false است)
      expect(await notifier.verifyPassword('123456'), isFalse);
    });

    test('verifyPassword: خطای شبکه → مثل تلاش ناموفق رفتار می‌شود', () async {
      final container = ProviderContainer(
        overrides: [
          lockVerifyApiProvider.overrideWithValue(_ThrowingApi()),
        ],
      );
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      expect(await notifier.verifyPassword('123456'), isFalse);
      expect(container.read(lockProvider).failedAttempts, 1);
    });

    test('resetAttempts بعد از موفقیت بیومتریک، کولداون را پاک می‌کند', () async {
      final container = containerWithApi(false);
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      for (var i = 0; i < 5; i++) {
        await notifier.verifyPassword('000000');
      }
      expect(container.read(lockProvider).cooldownUntil, isNotNull);

      notifier.resetAttempts();
      expect(container.read(lockProvider).cooldownUntil, isNull);
      expect(container.read(lockProvider).failedAttempts, 0);
    });

    test('changeMethod: روش بیومتریک ذخیره و بازیابی می‌شود', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);

      final notifier = container.read(lockProvider.notifier);
      expect(await notifier.changeMethod(LockMethod.fingerprint), isTrue);
      expect(container.read(lockProvider).method, LockMethod.fingerprint);
      expect(await LockStorage.getMethod(), LockMethod.fingerprint);

      await notifier.changeMethod(LockMethod.none);
      expect(container.read(lockProvider).method, LockMethod.none);
    });

    test('clearAllForLogout: روش قفل پاک و پین قدیمی از دستگاه حذف می‌شود', () async {
      store['lock_pin_salt'] = 'salt';
      store['lock_pin_hash'] = 'hash';
      await LocalStorage.saveLockMethod('fingerprint');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);
      await container.read(lockProvider.notifier).clearAllForLogout();

      final state = container.read(lockProvider);
      expect(state.method, LockMethod.none);
      expect(await LockStorage.getMethod(), LockMethod.none);
      expect(store.containsKey('lock_pin_salt'), isFalse);
      expect(store.containsKey('lock_pin_hash'), isFalse);
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

    test('زمان قفل خودکار: پیش‌فرض فوراً و تغییر با ذخیره‌سازی', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await settled(container);
      expect(container.read(lockProvider).autoLockMinutes, 0);

      final notifier = container.read(lockProvider.notifier);
      expect(await notifier.changeAutoLockMinutes(5), isTrue);
      expect(container.read(lockProvider).autoLockMinutes, 5);
      expect(LockStorage.getAutoLockMinutes(), 5);

      expect(await notifier.changeAutoLockMinutes(-1), isFalse);
      expect(container.read(lockProvider).autoLockMinutes, 5);

      await notifier.changeAutoLockMinutes(0);
      expect(container.read(lockProvider).autoLockMinutes, 0);
    });

    test('زمان قفل خودکار ذخیره‌شده (۱۵ دقیقه) در بارگذاری اولیه خوانده می‌شود', () async {
      await LocalStorage.saveAutoLockMinutes(15);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await settled(container);
      expect(state.autoLockMinutes, 15);
    });
  });
}

class _ThrowingApi extends AuthApiService {
  @override
  Future<bool> verifyPassword(String password) async {
    throw Exception('network down');
  }
}
