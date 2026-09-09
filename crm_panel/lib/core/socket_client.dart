import 'package:socket_io_client/socket_io_client.dart' as io;

/// سوکت CRM — فقط برای تازه‌سازی خودکار داشبورد (best-effort).
/// هر رویداد دامنه، تب مربوط را دوباره بارگذاری می‌کند.
class CrmSocketClient {
  CrmSocketClient(this.baseUrl);

  final String baseUrl;
  io.Socket? _socket;

  /// رویداد دامنه رخ داد (نام رویداد + payload) — تب‌ها خودشان تصمیم می‌گیرند
  void Function(String event, Map<String, dynamic> data)? onEvent;

  static const List<String> events = [
    'order:created',
    'order:updated',
    'order:deleted',
    'checkin:completed',
    'transfer:created',
    'transfer:completed',
    'transfer:canceled',
  ];

  void connect(String token) {
    try {
      if (_socket != null && _socket!.connected) return;
      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );
      _socket!.onConnect((_) {
        _socket!.emit('authenticate', {'token': token});
      });
      for (final event in events) {
        _socket!.on(event, (data) {
          try {
            onEvent?.call(event, data is Map<String, dynamic> ? data : const {});
          } catch (_) {}
        });
      }
      _socket!.connect();
    } catch (_) {
      // Realtime is best-effort; the panel works without it.
    }
  }

  void disconnect() {
    try {
      if (_socket != null && _socket!.connected) {
        _socket!.disconnect();
      }
    } catch (_) {
      // ignore
    }
    _socket?.dispose();
    _socket = null;
  }
}
