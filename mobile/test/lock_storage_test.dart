import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/auth/lock/lock_config.dart';
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

  group('LockStorage', () {
    test('روش قفل: ذخیره و بازیابی', () async {
      expect(await LockStorage.getMethod(), LockMethod.none);

      await LockStorage.saveMethod(LockMethod.fingerprint);
      expect(await LockStorage.getMethod(), LockMethod.fingerprint);

      await LockStorage.saveMethod(LockMethod.face);
      expect(await LockStorage.getMethod(), LockMethod.face);

      await LockStorage.saveMethod(LockMethod.none);
      expect(await LockStorage.getMethod(), LockMethod.none);
    });

    test('clearAll (خروج از حساب): روش قفل پاک و پین قدیمی از دستگاه حذف می‌شود', () async {
      // پین قدیمی از نسخه‌های قبل — باید هنگام خروج پاک شود
      store['lock_pin_salt'] = 'salt';
      store['lock_pin_hash'] = 'hash';
      await LocalStorage.saveLockMethod('fingerprint');

      await LockStorage.clearAll();

      expect(await LockStorage.getMethod(), LockMethod.none);
      expect(store.containsKey('lock_pin_salt'), isFalse);
      expect(store.containsKey('lock_pin_hash'), isFalse);
    });

    test('زمان قفل خودکار: پیش‌فرض فوراً (۰) و ذخیره/بازیابی', () async {
      expect(LockStorage.getAutoLockMinutes(), LockStorage.defaultAutoLockMinutes);
      expect(LockStorage.getAutoLockMinutes(), 0);

      await LockStorage.saveAutoLockMinutes(5);
      expect(LockStorage.getAutoLockMinutes(), 5);

      await LockStorage.saveAutoLockMinutes(0);
      expect(LockStorage.getAutoLockMinutes(), 0);
    });
  });
}
