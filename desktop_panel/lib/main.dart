import 'package:flutter/material.dart';

import 'core/api_service.dart';
import 'core/palette.dart';
import 'core/socket_client.dart';
import 'screens/login_screen.dart';
import 'screens/workspace_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaWarehousePanelApp());
}

class MaWarehousePanelApp extends StatelessWidget {
  const MaWarehousePanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'پنل انباردار — MA Warehouse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Palette.appBg,
        colorScheme: const ColorScheme.dark(
          primary: Palette.primary,
          surface: Palette.surface,
        ),
        fontFamily: 'Vazirmatn',
        visualDensity: VisualDensity.compact,
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final ApiService _api = ApiService();
  late SocketClient _socket;

  bool _loggedIn = false;
  String _userName = 'انباردار';
  String? _authNotice;

  @override
  void initState() {
    super.initState();
    _socket = SocketClient(ApiService.defaultServerUrl);
    // تمدید خودکار توکن: سوکت با توکن تازه وصل می‌شود؛ اگر رفرش شکست،
    // نشست مرده است و کاربر با پیام واضح به ورود برمی‌گردد (نه صفحه خالی).
    _api.onTokenRefreshed = (newToken) {
      _socket.reconnect(newToken);
    };
    _api.onAuthExpired = () {
      _socket.disconnect();
      if (mounted) {
        setState(() {
          _loggedIn = false;
          _authNotice = 'نشست شما منقضی شد؛ لطفاً دوباره وارد شوید.';
        });
      }
    };
  }

  Future<void> _onLoginSuccess() async {
    final userName = _api.user?['name']?.toString() ?? 'انباردار';
    final token = _api.token;
    final serverUrl = await _api.loadServerUrl();
    _socket = SocketClient(serverUrl);
    if (token != null) {
      _socket.connect(token);
    }
    if (mounted) {
      setState(() {
        _loggedIn = true;
        _userName = userName;
        _authNotice = null;
      });
    }
  }

  void _onLogout() {
    _api.logout();
    _socket.disconnect();
    setState(() {
      _loggedIn = false;
      _userName = 'انباردار';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loggedIn
        ? WorkspaceScreen(
            api: _api,
            socket: _socket,
            userName: _userName,
            onLogout: _onLogout,
          )
        : LoginScreen(
            api: _api,
            onLoginSuccess: _onLoginSuccess,
            notice: _authNotice,
          );
  }
}
