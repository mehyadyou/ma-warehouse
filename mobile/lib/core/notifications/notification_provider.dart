import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import 'notification_model.dart';

final unreadCountProvider = StreamProvider<int>((ref) {
  return NotificationService().onUnreadChanged;
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return NotificationService().onListChanged;
});
