import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/network/dio_client.dart';
import 'package:ma_app/core/storage/secure_storage.dart';

const secureChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

/// جایگزین کانال secure storage با یک Map در حافظه
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

/// آداپتر HTTP جعلی: هیچ درخواست واقعی شبکه‌ای نمی‌زند
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.onRequest);

  final Future<ResponseBody> Function(RequestOptions options) onRequest;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Dio fakeDio(FakeHttpAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = adapter;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> store;

  setUp(() {
    store = mockSecureChannel();
    AuthSession.debugDioFactory = null;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, null);
    AuthSession.debugDioFactory = null;
  });

  group('AuthSession.refreshAccessToken', () {
    test('رفرش موفق: توکن جدید ذخیره می‌شود و برمی‌گردد', () async {
      store['refresh_token'] = 'old-refresh';
      final adapter = FakeHttpAdapter((options) async {
        expect(options.path, '/auth/refresh');
        return jsonResponse({
          'token': 'new-access',
          'refreshToken': 'new-refresh',
        }, 200);
      });
      AuthSession.debugDioFactory = () => fakeDio(adapter);

      final token = await AuthSession.refreshAccessToken();

      expect(token, 'new-access');
      expect(await SecureStorage.getAccessToken(), 'new-access');
      expect(await SecureStorage.getRefreshToken(), 'new-refresh');
    });

    test('رفرش شکست‌خورده (401): null برمی‌گردد و توکن‌ها پاک می‌شوند', () async {
      store['refresh_token'] = 'old-refresh';
      final adapter = FakeHttpAdapter(
        (_) async => jsonResponse({'message': 'unauthorized'}, 401),
      );
      AuthSession.debugDioFactory = () => fakeDio(adapter);

      final token = await AuthSession.refreshAccessToken();

      expect(token, isNull);
      expect(store['access_token'], isNull);
      expect(store['refresh_token'], isNull);
    });

    test('نبود توکن رفرش: بدون درخواست شبکه null برمی‌گردد', () async {
      final adapter = FakeHttpAdapter(
        (_) async => jsonResponse({}, 200),
      );
      AuthSession.debugDioFactory = () => fakeDio(adapter);

      final token = await AuthSession.refreshAccessToken();

      expect(token, isNull);
      expect(adapter.requestCount, 0);
    });

    test('رفرش با خطای شبکه: null برمی‌گردد ولی توکن‌ها حفظ می‌شوند', () async {
      store['refresh_token'] = 'old-refresh';
      store['access_token'] = 'old-access';
      final adapter = FakeHttpAdapter(
        (_) async => throw DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.connectionError,
        ),
      );
      AuthSession.debugDioFactory = () => fakeDio(adapter);

      final token = await AuthSession.refreshAccessToken();

      expect(token, isNull);
      expect(store['access_token'], 'old-access');
      expect(store['refresh_token'], 'old-refresh');
    });

    test('refreshWithOutcome: 401 → invalidSession، خطای شبکه → network', () async {
      store['refresh_token'] = 'r1';
      AuthSession.debugDioFactory = () => fakeDio(
        FakeHttpAdapter(
          (_) async => jsonResponse({'message': 'unauthorized'}, 401),
        ),
      );

      var outcome = await AuthSession.refreshWithOutcome();
      expect(outcome.isOk, isFalse);
      expect(outcome.failure, RefreshFailure.invalidSession);
      expect(store['refresh_token'], isNull);

      store['refresh_token'] = 'r2';
      AuthSession.debugDioFactory = () => fakeDio(
        FakeHttpAdapter(
          (_) async => throw DioException(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            type: DioExceptionType.receiveTimeout,
          ),
        ),
      );

      outcome = await AuthSession.refreshWithOutcome();
      expect(outcome.isOk, isFalse);
      expect(outcome.failure, RefreshFailure.network);
      expect(store['refresh_token'], 'r2');
    });

    test('single-flight: دو درخواست همزمان فقط یک بار شبکه را می‌زنند', () async {
      store['refresh_token'] = 'old-refresh';
      final adapter = FakeHttpAdapter(
        (_) async => jsonResponse({
          'token': 'new-access',
          'refreshToken': 'new-refresh',
        }, 200),
      );
      AuthSession.debugDioFactory = () => fakeDio(adapter);

      final results = await Future.wait([
        AuthSession.refreshAccessToken(),
        AuthSession.refreshAccessToken(),
      ]);

      expect(adapter.requestCount, 1);
      expect(results, ['new-access', 'new-access']);
    });
  });
}
