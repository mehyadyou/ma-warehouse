import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/network/dio_client.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/auth/providers/auth_provider.dart';
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
        store[call.arguments['key'] as String] =
            call.arguments['value'] as String;
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

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.onRequest);

  final Future<ResponseBody> Function(RequestOptions options) onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio failingDio() {
  return Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = FakeHttpAdapter(
      (_) async => ResponseBody.fromString(
        jsonEncode({'message': 'unauthorized'}),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late Map<String, String> store;

  setUpAll(() async {
    await LocalStorage.init();
  });

  setUp(() async {
    store = mockSecureChannel();
    AuthSession.debugDioFactory = failingDio;
    AuthSession.onSessionExpired = null;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, null);
    AuthSession.debugDioFactory = null;
    AuthSession.onSessionExpired = null;
  });

  Future<AuthState> settled(ProviderContainer container) async {
    container.read(authProvider); // ساخت provider و زمان‌بندی _init
    // صبر برای اجرای کامل microtask های _init
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return container.read(authProvider);
  }

  group('AuthNotifier (بیومتریک)', () {
    test('نشست ذخیره + بیومتریک فعال → isLocked=true (صفحه قفل)', () async {
      store['refresh_token'] = 'old-refresh';
      await LocalStorage.setBiometricEnabled(true);
      await LocalStorage.saveRole('WAREHOUSE_KEEPER');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await settled(container);

      expect(state.isLocked, isTrue);
      expect(state.isLoggedIn, isFalse);
      expect(store['access_token'], isNull);
    });

    test('بدون توکن رفرش → قفل نمی‌شود', () async {
      await LocalStorage.setBiometricEnabled(true);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await settled(container);

      expect(state.isLocked, isFalse);
      expect(state.isLoggedIn, isFalse);
    });

    test('unlock با رفرش شکست‌خورده → logout و بازگشت به حالت خالی', () async {
      store['refresh_token'] = 'expired-refresh';
      await LocalStorage.setBiometricEnabled(true);
      await LocalStorage.saveRole('WAREHOUSE_KEEPER');
      await LocalStorage.saveUserData(
        name: 'کاربر تست',
        phone: '0912',
        avatarUrl: null,
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await settled(container);
      expect(state.isLocked, isTrue);

      final unlocked = await container
          .read(authProvider.notifier)
          .unlockWithBiometrics();

      expect(unlocked, isFalse);
      final after = container.read(authProvider);
      expect(after.isLocked, isFalse);
      expect(after.isLoggedIn, isFalse);
      expect(after.token, isNull);
      expect(store['refresh_token'], isNull);
    });

    test('بیومتریک خاموش + نشست ذخیره → بازیابی مستقیم (بدون قفل)', () async {
      store['access_token'] = 'valid-access';
      await LocalStorage.setBiometricEnabled(false);
      await LocalStorage.saveRole('WAREHOUSE_KEEPER');
      await LocalStorage.saveUserData(
        name: 'کاربر تست',
        phone: '0912',
        avatarUrl: null,
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await settled(container);

      expect(state.isLocked, isFalse);
      expect(state.isLoggedIn, isTrue);
      expect(state.token, 'valid-access');
    });
  });
}
