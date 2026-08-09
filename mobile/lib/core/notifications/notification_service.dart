import 'dart:async';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../realtime/socket_service.dart';
import 'notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  NotificationService._();
  factory NotificationService() => _instance;

  final Dio _dio = DioClient().dio;

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  final _unreadController = StreamController<int>.broadcast();
  Stream<int> get onUnreadChanged => _unreadController.stream;

  final _listController = StreamController<List<AppNotification>>.broadcast();
  Stream<List<AppNotification>> get onListChanged => _listController.stream;

  bool _initialized = false;

  /// بعد از ورود/بازیابی نشست: دریافت تاریخچه + اتصال سوکت
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    SocketService().off('notification');
    SocketService().on('notification', (data) {
      if (data is Map<String, dynamic>) {
        _handleSocketNotification(data);
      }
    });

    await refresh();
  }

  /// دریافت لیست + تعداد خوانده‌نشده از سرور
  Future<void> refresh() async {
    try {
      final response = await _dio.get('/notifications');
      final list = (response.data as List<dynamic>? ?? [])
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
      _notifications
        ..clear()
        ..addAll(list);
      _emit();
    } catch (_) {
      // در صورت خطای شبکه، لیست فعلی حفظ می‌شود
    }
  }

  /// خواندن همه از سرور
  Future<void> markAllRead() async {
    if (_notifications.isEmpty) return;
    try {
      await _dio.patch('/notifications/mark-read', data: {});
    } catch (_) {}
    for (final n in _notifications) {
      n.isRead = true;
    }
    _emit();
  }

  /// پاک کردن همهٔ اعلان‌ها (سرور + محلی)
  Future<void> clear() async {
    try {
      await _dio.delete('/notifications');
    } catch (_) {}
    _notifications.clear();
    _emit();
  }

  /// خواندن یک نوتیفیکیشن
  Future<void> markRead(String id) async {
    try {
      await _dio.patch('/notifications/mark-read', data: {'ids': [id]});
    } catch (_) {}
    final n = _notifications.where((n) => n.id == id).firstOrNull;
    if (n != null) {
      n.isRead = true;
      _emit();
    }
  }

  void _handleSocketNotification(Map<String, dynamic> data) {
    try {
      final notification = AppNotification.fromJson(data);
      _notifications.insert(0, notification);
      _emit();
    } catch (_) {}
  }

  void _emit() {
    _unreadController.add(unreadCount);
    _listController.add(List.unmodifiable(_notifications));
  }

  void dispose() {
    _unreadController.close();
    _listController.close();
  }
}
