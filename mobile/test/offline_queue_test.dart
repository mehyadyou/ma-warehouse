import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/network/api_error.dart';
import 'package:ma_app/core/network/client_keys.dart';
import 'package:ma_app/features/auth/lock/offline_verifier.dart';
import 'package:ma_app/features/offline/pending_ops.dart';
import 'package:ma_app/features/warehouse_keeper/data/warehouse_keeper_api_service.dart';
import 'package:ma_app/features/warehouse_keeper/models/scan_out_result_model.dart';
import 'package:ma_app/features/warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ma_app/core/storage/local_storage.dart';

DioException _netError() => DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );

DioException _serverError() => DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 400,
        data: {'error': 'خطا'},
      ),
    );

/// فیک سبک برای فلاش صف — بدون شبکه واقعی
class _FakeKeeperApi extends WarehouseKeeperApiService {
  _FakeKeeperApi({required this.failWithNetworkError});

  final bool failWithNetworkError;

  @override
  Future<ScanOutResultModel> scanOut(String qrPayload,
      {String? orderId, String? transferId, String? clientKey}) async {
    if (failWithNetworkError) throw _netError();
    return ScanOutResultModel.fromJson(const {
      'valid': true,
      'carton': {'id': 'c1', 'serialNumber': 'S1'},
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('isNetworkError', () {
    test('قطعی/تایم‌اوت → true', () {
      for (final t in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          isNetworkError(
              DioException(requestOptions: RequestOptions(path: '/'), type: t)),
          isTrue,
        );
      }
    });

    test('خطای سرور (۴xx) → false (صف نمی‌شود)', () {
      expect(isNetworkError(_serverError()), isFalse);
    });
  });

  group('newClientKey', () {
    test('یکتا و غیرخالی', () {
      final keys = List.generate(200, (_) => newClientKey()).toSet();
      expect(keys.length, 200);
      expect(keys.first.isNotEmpty, isTrue);
    });
  });

  group('OfflineVerifier (بدون حافظه امن در تست)', () {
    test('بدون verifier ذخیره‌شده → false', () async {
      expect(await OfflineVerifier.verify('123456'), isFalse);
    });
  });

  group('PendingOpsNotifier', () {
    late ProviderContainer container;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
    });

    setUp(() async {
      // صف ذخیره‌شده بین تست‌ها تمیز می‌شود
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer(
        overrides: [
          wkApiProvider.overrideWithValue(
              _FakeKeeperApi(failWithNetworkError: false)),
        ],
      );
      await container.read(pendingOpsProvider.notifier).clear();
    });

    tearDown(() => container.dispose());

    test('enqueue + dedupe با کلید یکسان', () async {
      final notifier = container.read(pendingOpsProvider.notifier);
      final op = PendingOp(
        key: 'k1',
        type: PendingOpType.scanOutQr,
        payload: const {'qrPayload': 'MA|x'},
        createdAt: DateTime.now(),
        label: 'تست',
      );
      await notifier.enqueue(op);
      await notifier.enqueue(op);
      expect(container.read(pendingOpsProvider).length, 1);
    });

    test('flush موفق → صف خالی می‌شود', () async {
      final notifier = container.read(pendingOpsProvider.notifier);
      await notifier.enqueue(PendingOp(
        key: 'k2',
        type: PendingOpType.scanOutQr,
        payload: const {'qrPayload': 'MA|y'},
        createdAt: DateTime.now(),
        label: 'تست',
      ));
      final result = await notifier.flush();
      expect(result.sent, 1);
      expect(container.read(pendingOpsProvider), isEmpty);
    });

    test('flush در قطعی → عملیات در صف می‌ماند', () async {
      final offline = ProviderContainer(
        overrides: [
          wkApiProvider.overrideWithValue(
              _FakeKeeperApi(failWithNetworkError: true)),
        ],
      );
      addTearDown(offline.dispose);
      final notifier = offline.read(pendingOpsProvider.notifier);
      await notifier.enqueue(PendingOp(
        key: 'k3',
        type: PendingOpType.scanOutQr,
        payload: const {'qrPayload': 'MA|z'},
        createdAt: DateTime.now(),
        label: 'تست',
      ));
      final result = await notifier.flush();
      expect(result.sent, 0);
      expect(offline.read(pendingOpsProvider).length, 1);
    });
  });
}
