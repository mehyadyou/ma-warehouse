import 'package:ma_crm_panel/core/api_service.dart';

/// API قلابی برای تست‌های ویجت — هیچ شبکه‌ای نمی‌زند.
class FakeCrmApi extends CrmApiService {
  FakeCrmApi({
    this.loginRole = 'MANAGER',
    this.mustChange = false,
    this.loginThrows,
  });

  final String loginRole;
  final bool mustChange;
  final Object? loginThrows;

  @override
  Future<String> loadServerUrl() async => 'http://127.0.0.1:3000';

  @override
  Future<void> saveServerUrl(String url) async {}

  @override
  void configure(String baseUrl) {}

  @override
  Future<Map<String, dynamic>> login(String phone, String password) async {
    if (loginThrows != null) throw loginThrows!;
    return {
      'token': 't',
      'user': {'id': 'u1', 'name': 'مدیر تست', 'role': loginRole, 'mustChangePassword': mustChange},
    };
  }

  @override
  Future<void> updateMyPassword(String newPassword) async {}

  @override
  Future<Map<String, dynamic>> getOverview() async => {
        'usersCount': 7,
        'warehousesCount': 2,
        'ordersPending': 3,
        'transfersPending': 1,
        'outboxPending': 0,
        'outboxFailed': 0,
        'todayOrders': 5,
        'todayDayKey': 14050615,
      };

  @override
  Future<Map<String, dynamic>> getHealth() async => {
        'counts': {'users': 7, 'orders': 13, 'cartons': 35, 'products': 5, 'transfers': 0},
        'outbox': {'pending': 0, 'failed': 0, 'oldestPendingAt': null, 'oldestPendingType': null},
        'redis': true,
        'uptimeSec': 100,
        'node': 'v22',
        'now': '2026-09-08T00:00:00.000Z',
      };

  @override
  Future<Map<String, dynamic>> getInventorySummary() async => {
        'activeProducts': 5,
        'totalUnits': 100,
      };

  @override
  Future<Map<String, dynamic>> getCustomers({String q = '', int page = 1, int pageSize = 20}) async => {
        'customers': [
          {
            'phone': '09120000001',
            'orders': 2,
            'spent': 200000,
            'items': 3,
            'city': 'تهران',
            'name': 'گیرنده',
            'lastAt': '2026-09-01T10:00:00.000Z',
          },
        ],
        'total': 1,
        'page': page,
        'pageSize': pageSize,
      };

  @override
  Future<Map<String, dynamic>> getCustomerDetail(String phone) async => {
        'phone': phone,
        'totals': {'orders': 1, 'spent': 100000, 'items': 2},
        'orders': [],
        'activity': [],
      };

  @override
  Future<Map<String, dynamic>> getFinance({String? from, String? to, String? warehouseId}) async => {
        'totals': {'revenue': 250000, 'units': 4, 'orders': 2, 'capped': false},
        'byDay': [
          {'key': '2026-09-05', 'revenue': 250000, 'units': 4, 'orders': 2},
        ],
        'byWarehouse': [],
        'byCity': [],
        'byCarrier': [],
      };

  @override
  Future<Map<String, dynamic>> getUserActivity(
      {String? userId, String? from, String? to, int limit = 50}) async => {
        'entries': [
          {
            'kind': 'audit',
            'at': '2026-09-05T10:00:00.000Z',
            'action': 'user.update',
            'data': {'action': 'user.update'},
          },
        ],
        'counts': {'activities': 0, 'audits': 1, 'transactions': 0},
      };

  @override
  Future<Map<String, dynamic>> getAudit({
    String? actorId,
    String? entity,
    String? action,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 20,
  }) async => {
        'entries': [
          {
            'id': 'a1',
            'action': 'user.update',
            'entity': 'User',
            'entityId': 'u1',
            'actorId': 'u1',
            'createdAt': '2026-09-05T10:00:00.000Z',
          },
        ],
        'total': 1,
        'page': page,
        'pageSize': pageSize,
      };

  @override
  Future<List<dynamic>> getUsers() async => [
        {'id': 'u1', 'name': 'مدیر تست', 'phone': '09120000000', 'role': 'MANAGER'},
      ];

  @override
  Future<List<dynamic>> getWarehouses() async => [
        {'id': 'w1', 'name': 'انبار ۱'},
      ];

  @override
  Future<Map<String, dynamic>> getApiUsage({int? from, int? to}) async => {
        'keys': [
          {
            'key': {'id': 'k1', 'name': 'حسابداری', 'prefix': 'ma_live_x', 'isActive': true},
            'totalHits': 15,
            'totalErrors': 1,
            'days': [
              {'day': 14050615, 'hits': 15, 'errors': 1},
            ],
          },
        ],
        'from': from,
        'to': to,
      };

  @override
  Future<List<dynamic>> getApiScopes() async => ['orders', 'products'];

  @override
  Future<List<dynamic>> getApiKeys() async => [
        {
          'id': 'k1',
          'name': 'حسابداری',
          'prefix': 'ma_live_x',
          'isActive': true,
          'useCount': 15,
          'lastUsedAt': null,
          'expiresAt': null,
        },
      ];

  @override
  Future<Map<String, dynamic>> createApiKey({
    required String name,
    required List<String> scopes,
    String? expiresAt,
  }) async {
    if (name.isEmpty || scopes.isEmpty) throw ApiError('نام و دسترسی الزامی است');
    return {'id': 'k2', 'key': 'ma_live_TESTKEY123', 'name': name};
  }

  @override
  Future<void> revokeApiKey(String id) async {}

  @override
  Future<void> restoreApiKey(String id) async {}

  @override
  Future<void> deleteApiKey(String id) async {}
}
