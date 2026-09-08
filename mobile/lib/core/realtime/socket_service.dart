import 'package:socket_io_client/socket_io_client.dart';
import '../storage/secure_storage.dart';
import '../network/api_constants.dart';
import '../network/dio_client.dart';

class SocketService {
  static final SocketService _instance = SocketService._();
  SocketService._();
  factory SocketService() => _instance;

  Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// شنونده‌های اتصال مجدد — مثل فلاش صف آفلاین هنگام بازگشت اینترنت
  final List<void Function()> _reconnectListeners = [];

  void addReconnectListener(void Function() listener) {
    if (!_reconnectListeners.contains(listener)) {
      _reconnectListeners.add(listener);
    }
  }

  void removeReconnectListener(void Function() listener) {
    _reconnectListeners.remove(listener);
  }

  Future<void> connect() async {
    if (_isConnected) return;

    // توکن اکسس کوتاه‌عمر است؛ قبل از اتصال اگر نزدیک انقضا بود رفرش کن
    var token = await SecureStorage.getAccessToken();
    if (token == null || token.isEmpty) return;
    if (isAccessTokenExpiringSoon(token)) {
      token = await AuthSession.refreshAccessToken();
      if (token == null) return;
    }

    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    _socket = io(
      baseUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.onConnect((_) {
      final wasConnected = _isConnected;
      _isConnected = true;
      // اتصال مجدد (بعد از قطعی) → شنونده‌ها (فلاش صف آفلاین)
      if (!wasConnected) {
        for (final l in List.of(_reconnectListeners)) {
          try {
            l();
          } catch (_) {}
        }
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
    });

    _socket?.onConnectError((error) {
      print('Socket connection error: $error');
      _isConnected = false;
    });
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// ارسال رویداد به سرور (مثل درخواست دستیار هوش مصنوعی)
  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  /// حذف فقط همین listener (بقیهٔ listenerهای همان رویداد — مثل داشبورد — دست‌نخورده می‌مانند)
  void offEvent(String event, Function(dynamic) callback) {
    _socket?.off(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
  }
}
