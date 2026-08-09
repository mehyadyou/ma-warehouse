import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/manager_api_service.dart';

final managerApiServiceProvider = Provider<ManagerApiService>((ref) {
  return ManagerApiService();
});
