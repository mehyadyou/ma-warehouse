import 'package:flutter/material.dart';

import 'core/api_service.dart';
import 'core/palette.dart';
import 'core/socket_client.dart';
import 'screens/login_screen.dart';
import 'screens/workspace_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CrmPanelApp());
}

class CrmPanelApp extends StatelessWidget {
  const CrmPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'پنل CRM مالک — MA Warehouse',
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
  final CrmApiService _api = CrmApiService();
  late CrmSocketClient _socket;

  bool _loggedIn = false;
  String _userName = 'مدیر';

  @override
  void initState() {
    super.initState();
    _socket = CrmSocketClient(CrmApiService.defaultServerUrl);
  }

  Future<void> _onLoginSuccess() async {
    final userName = _api.user?['name']?.toString() ?? 'مدیر';
    final token = _api.token;
    final serverUrl = await _api.loadServerUrl();
    _socket = CrmSocketClient(serverUrl);
    if (token != null) {
      _socket.connect(token);
    }
    if (mounted) {
      setState(() {
        _loggedIn = true;
        _userName = userName;
      });
    }
  }

  void _onLogout() {
    _api.logout();
    _socket.disconnect();
    setState(() {
      _loggedIn = false;
      _userName = 'مدیر';
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
        : LoginScreen(api: _api, onLoginSuccess: _onLoginSuccess);
  }
}
