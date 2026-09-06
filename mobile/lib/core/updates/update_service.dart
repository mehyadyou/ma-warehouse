import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../network/api_constants.dart';
import '../storage/secure_storage.dart';

/// اطلاعات نسخهٔ جدید از سرور
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.changelog,
    required this.isForce,
    required this.apkUrl,
    required this.apkSizeBytes,
    required this.apkSha256,
  });

  final String versionName;
  final int versionCode;
  final String changelog;
  final bool isForce;
  final String apkUrl;
  final int apkSizeBytes;
  final String apkSha256;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> j) => AppUpdateInfo(
        versionName: j['versionName'] as String,
        versionCode: (j['versionCode'] as num).toInt(),
        changelog: j['changelog'] as String,
        isForce: j['isForce'] as bool? ?? false,
        apkUrl: j['apkUrl'] as String,
        apkSizeBytes: (j['apkSizeBytes'] as num?)?.toInt() ?? 0,
        apkSha256: j['apkSha256'] as String? ?? '',
      );
}

/// نتیجهٔ بررسی بروزرسانی
sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

class NoUpdate extends UpdateCheckResult {
  const NoUpdate();
}

class UpdateAvailable extends UpdateCheckResult {
  const UpdateAvailable(this.info);
  final AppUpdateInfo info;
}

/// وضعیت دانلود برای نوار پیشرفت
class DownloadProgress {
  const DownloadProgress({required this.received, required this.total});
  final int received;
  final int total;
  double get fraction => total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
}

/// سرویس بروزرسانی از راه دور — بررسی، دانلود APK و اجرای نصب
class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  static const _checkPath = '/app/updates/check';

  Dio? _dio;
  Dio get _http {
    _dio ??= Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10), // دانلود APK طول می‌کشد
    ));
    return _dio!;
  }

  /// نسخهٔ فعلی نصب‌شده روی دستگاه
  Future<int> currentVersionCode() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 1;
  }

  /// بررسی سرور — خطاها را نمی‌پراند: بدون اینترنت هم آپ بدون مشکل بالا می‌آید
  Future<UpdateCheckResult> checkForUpdate() async {
    try {
      if (kIsWeb || !Platform.isAndroid) return const NoUpdate();
      final current = await currentVersionCode();
      final response = await _http.get(
        _checkPath,
        queryParameters: {'currentVersionCode': current},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['updateAvailable'] == true) {
        return UpdateAvailable(AppUpdateInfo.fromJson(data));
      }
      return const NoUpdate();
    } catch (_) {
      // خطای شبکه/سرور هرگز مانع بالا آمدن اپ نمی‌شود
      return const NoUpdate();
    }
  }

  /// دانلود APK با نوار پیشرفت — خروجی: مسیر فایل یا null در خطا
  Future<String?> downloadApk(
    AppUpdateInfo info, {
    void Function(DownloadProgress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final token = await SecureStorage.getAccessToken();
      final dir = await getApkDirectory();
      final savePath =
          '${dir.path}${Platform.pathSeparator}ma-${info.versionCode}.apk';

      // اگر قبلاً کامل دانلود شده، دوباره دانلود نکن (resume تجربهٔ بهتر)
      final existing = File(savePath);
      if (await existing.exists() &&
          await existing.length() == info.apkSizeBytes &&
          info.apkSizeBytes > 0) {
        return savePath;
      }

      await _http.download(
        info.apkUrl,
        savePath,
        cancelToken: cancelToken,
        options: Options(
          headers: token != null && token.isNotEmpty
              ? {'Authorization': 'Bearer $token'}
              : null,
        ),
        onReceiveProgress: (received, total) =>
            onProgress?.call(DownloadProgress(received: received, total: total)),
      );

      // اعتبارسنجی حجم — هش کامل در آپ رفرش‌دهنده سنگین است؛ حداقل حجم چک شود
      if (info.apkSizeBytes > 0) {
        final len = await File(savePath).length();
        if (len != info.apkSizeBytes) {
          await existing.delete().catchError((_) => existing);
          return null;
        }
      }
      return savePath;
    } catch (_) {
      return null;
    }
  }

  /// اجرای نصب — اندروید صفحهٔ مجوز نصب سیستم را نشان می‌دهد
  Future<bool> installApk(String filePath) async {
    final result = await OpenFilex.open(filePath);
    return result.type == ResultType.done;
  }

  Future<Directory> getApkDirectory() async {
    final dir = await Directory.systemTemp.createTemp('ma_update');
    return dir.parent;
  }
}
