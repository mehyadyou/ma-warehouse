import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  SocketClient(this.baseUrl);

  final String baseUrl;
  io.Socket? _socket;

  void Function(Map<String, dynamic> data)? onScanoutDone;
  void Function(Map<String, dynamic> data)? onCheckinCompleted;
  void Function(Map<String, dynamic> data)? onOrderCreated;
  void Function(Map<String, dynamic> data)? onOrderUpdated;
  void Function(Map<String, dynamic> data)? onOrderDeleted;

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
      _socket!.on('scanout:done', (data) {
        onScanoutDone?.call(_asMap(data));
      });
      _socket!.on('checkin:completed', (data) {
        onCheckinCompleted?.call(_asMap(data));
      });
      // سفارش جدید/ویرایش/حذف توسط مدیریت — بیجکِ منوی «بیجک» فوراً به‌روز می‌شود
      _socket!.on('order:created', (data) {
        onOrderCreated?.call(_asMap(data));
      });
      _socket!.on('order:updated', (data) {
        onOrderUpdated?.call(_asMap(data));
      });
      _socket!.on('order:deleted', (data) {
        onOrderDeleted?.call(_asMap(data));
      });
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

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return const {};
  }
}
