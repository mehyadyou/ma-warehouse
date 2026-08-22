class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';

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