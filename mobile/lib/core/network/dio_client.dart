import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import 'api_constants.dart';
import 'api_error.dart';

/// دلیل شکست رفرش توکن — تفکیک «نشست واقعاً مرده» از «خطای شبکه/سرور»
enum RefreshFailure { invalidSession, network }

/// نتیجهٔ تلاش برای رفرش توکن
class RefreshResult {
  const RefreshResult.ok(String this.accessToken) : failure = null;
  const RefreshResult.failed(RefreshFailure this.failure) : accessToken = null;

  final String? accessToken;
  final RefreshFailure? failure;

  bool get isOk => accessToken != null;
}

/// مدیریت نشست: رفرش تک‌ریسکی توکن + ذخیره جفت توکن جدید.
/// چند درخواست همزمان فقط یک بار refresh می‌زنند (single-flight).
class AuthSession {
  static Future<RefreshResult>? _refreshFuture;

  /// وقتی رفرش ممکن نیست (توکن رفرش منقضی/باطل) فراخوانی می‌شود تا نشست بسته شود
  static void Function()? onSessionExpired;

  /// فقط برای تست — جایگزینی کلاینت شبکه رفرش
  @visibleForTesting
  static Dio Function()? debugDioFactory;

  static Future<String?> refreshAccessToken() async {
    final result = await _getRefresh();
    return result.accessToken;
  }

  /// نسخهٔ آگاه از دلیل شکست — صفحه قفل با خطای شبکه روی قفل می‌ماند
  static Future<RefreshResult> refreshWithOutcome() => _getRefresh();

  static Future<RefreshResult> _getRefresh() {
    return _refreshFuture ??=
        _doRefresh().whenComplete(() => _refreshFuture = null);
  }

  static Future<RefreshResult> _doRefresh() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await SecureStorage.clearTokens();
      return const RefreshResult.failed(RefreshFailure.invalidSession);
    }
    try {
      final dio = debugDioFactory != null
          ? debugDioFactory!()
          : Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );
      final response =
          await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});

      final data = response.data as Map<String, dynamic>?;
      final newAccess = data?['token'] as String?;
      final newRefresh = data?['refreshToken'] as String?;
      if (newAccess == null || newAccess.isEmpty) {
        await SecureStorage.clearTokens();
        return const RefreshResult.failed(RefreshFailure.invalidSession);
      }

      await SecureStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: (newRefresh != null && newRefresh.isNotEmpty)
            ? newRefresh
            : refreshToken,
      );
      return RefreshResult.ok(newAccess);
    } on DioException catch (e) {
      // ۴۰۱ از سرور = توکن باطل/منقضی → پایان نشست؛ خطای شبکه/سرور → نشست محفوظ می‌ماند
      if (e.response?.statusCode == 401) {
        await SecureStorage.clearTokens();
        return const RefreshResult.failed(RefreshFailure.invalidSession);
      }
      return const RefreshResult.failed(RefreshFailure.network);
    } catch (_) {
      // خطای غیر از شبکه (پارس داده و…) — مثل خطای شبکه رفتار کن
      return const RefreshResult.failed(RefreshFailure.network);
    }
  }

  static void forceSessionExpired() {
    onSessionExpired?.call();
  }
}

/// تشخیص نزدیک بودن به انقضای توکن اکسس (JWT exp) بدون نیاز به سرور
bool isAccessTokenExpiringSoon(
  String token, {
  Duration within = const Duration(minutes: 2),
}) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final exp = (payload['exp'] as num?)?.toInt();
    if (exp == null) return true;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
        .isBefore(DateTime.now().add(within));
  } catch (_) {
    return true;
  }
}

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthPath = path.contains('/auth/refresh') ||
              path.contains('/auth/login') ||
              path.contains('/auth/logout');

          // توکن منقضی → رفرش سایلنت → اجرای دوباره درخواست (فقط یک بار)
          if (status == 401 &&
              !isAuthPath &&
              error.requestOptions.extra['_retried'] != true) {
            error.requestOptions.extra['_retried'] = true;
            final outcome = await AuthSession.refreshWithOutcome();
            if (outcome.isOk) {
              error.requestOptions.headers['Authorization'] =
                  'Bearer ${outcome.accessToken}';
              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } on DioException catch (e) {
                return handler.next(_friendly(e));
              }
            }
            // فقط نشستِ واقعاً مرده بسته می‌شود؛ خطای شبکه → خروج ناگهانی ندارد
            if (outcome.failure == RefreshFailure.invalidSession) {
              AuthSession.forceSessionExpired();
            }
          }

          // type/response حفظ می‌شود؛ فقط message طبق قرارداد سرور فارسی می‌شود
          handler.next(_friendly(error));
        },
      ),
    );
  }
}

DioException _friendly(DioException error) {
  return DioException(
    requestOptions: error.requestOptions,
    response: error.response,
    type: error.type,
    error: error.error,
    message: friendlyError(error),
  );
}
