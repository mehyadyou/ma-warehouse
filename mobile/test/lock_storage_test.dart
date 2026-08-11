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

      await LockStorage.saveMethod(LockMethod.pin);
      expect(await LockStorage.getMethod(), LockMethod.pin);

      await LockStorage.saveMethod(LockMethod.fingerprint);
      expect(await LockStorage.getMethod(), LockMethod.fingerprint);
    });

    test('پین: تعیین، تأیید درست و غلط', () async {
      expect(await LockStorage.hasPin(), isFalse);

      await LockStorage.setPin('1234');

      expect(await LockStorage.hasPin(), isTrue);
      expect(await LockStorage.verifyPin('1234'), isTrue);
      expect(await LockStorage.verifyPin('0000'), isFalse);
      expect(await LockStorage.verifyPin('123'), isFalse);
    });

    test('پین: هش و salt جداگانه ذخیره می‌شوند (نه پین خام)', () async {
      await LockStorage.setPin('9876');

      expect(store['lock_pin_hash'], isNotNull);
      expect(store['lock_pin_salt'], isNotNull);
      expect(store['lock_pin_hash'], isNot('9876'));
      expect(store.values.contains('9876'), isFalse);
    });

    test('دو پین یکسان → هش متفاوت (salt تصادفی)', () async {
      await LockStorage.setPin('1111');
      final firstHash = store['lock_pin_hash'];
      final firstSalt = store['lock_pin_salt'];

      await LockStorage.setPin('1111');
      final secondHash = store['lock_pin_hash'];
      final secondSalt = store['lock_pin_salt'];

      expect(firstHash, isNot(secondHash));
      expect(firstSalt, isNot(secondSalt));
      expect(await LockStorage.verifyPin('1111'), isTrue);
    });

    test('clearPin: پین پاک می‌شود و تأیید ناموفق می‌شود', () async {
      await LockStorage.setPin('1234');
      await LockStorage.clearPin();

      expect(await LockStorage.hasPin(), isFalse);
      expect(await LockStorage.verifyPin('1234'), isFalse);
    });

    test('clearAll (خروج از حساب): پین و روش قفل پاک می‌شوند', () async {
      await LockStorage.saveMethod(LockMethod.face);
      await LockStorage.setPin('1234');

      await LockStorage.clearAll();

      expect(await LockStorage.getMethod(), LockMethod.none);
      expect(await LockStorage.hasPin(), isFalse);
    });

    test('تغییر روش قفل پین را پاک نمی‌کند (مصوب)', () async {
      await LockStorage.setPin('1234');
      await LockStorage.saveMethod(LockMethod.none);

      expect(await LockStorage.hasPin(), isTrue);
    });
  });
}
