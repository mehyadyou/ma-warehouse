import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// آدرس سرور API — از متغیر محیطی زمانِ کامپایل خوانده می‌شود
/// (dart-define) تا آدرس سرور واقعی در بدنهٔ باینری hard-code نشود:
///
///   flutter build apk --release \
///     --dart-define=API_BASE_URL=https://api.your-domain.ir/api
///
/// حالت توسعه (بدون dart-define): شبیه‌ساز/دستگاه محلی به localhost وصل می‌شود.
/// روی اندروید، `localhost` به `10.0.2.2` ترجمه می‌شود (آدرس host از داخل emulator).
class ApiConstants {
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static String get baseUrl {
    var url = _envBaseUrl;
    // شبیه‌ساز اندروید: localhost هاست به 10.0.2.2 ترجمه می‌شود
    if (!kIsWeb && Platform.isAndroid && url.contains('://localhost:')) {
      url = url.replaceFirst('://localhost:', '://10.0.2.2:');
    }
    return url;
  }

  /// تبدیل مسیر نسبی (مثل /uploads/...) به آدرس کامل
  static String fullUrl(String path) {
    if (path.isEmpty || path.startsWith('http')) return path;
    return '${baseUrl.replaceFirst('/api', '')}$path';
  }

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String createFirstManager = '/auth/create-first-manager';
  static const String verifyPassword = '/auth/verify-password';

  // Manager
  static const String managerDashboard = '/manager/dashboard';
  static const String managerUsers = '/manager/users';
  static const String managerWarehouses = '/manager/warehouses';
  static const String createWarehouseWithKeeper = '/manager/create-warehouse-with-keeper';
}