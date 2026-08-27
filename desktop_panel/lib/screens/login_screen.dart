import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/palette.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.api,
    required this.onLoginSuccess,
  });

  final ApiService api;
  final void Function() onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  bool _busy = false;
  bool _showServerField = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    widget.api.loadServerUrl().then((url) {
      if (mounted) _serverController.text = url;
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passController.text;
    if (phone.isEmpty || password.isEmpty) {
      _showMessage('خطا', 'شماره موبایل و رمز عبور الزامی است.');
      return;
    }
    // رمز اصلی دقیقاً ۶ رقم عددی است (هم‌راستا با سرور)
    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      _showMessage('خطا', 'رمز عبور باید دقیقاً ۶ رقم باشد.');
      return;
    }
    var serverUrl = _serverController.text.trim();
    if (serverUrl.isEmpty) {
      serverUrl = ApiService.defaultServerUrl;
    }
    while (serverUrl.endsWith('/')) {
      serverUrl = serverUrl.substring(0, serverUrl.length - 1);
    }

    setState(() {
      _busy = true;
      _status = 'در حال اعتبارسنجی اطلاعات...';
    });
    try {
      widget.api.configure(serverUrl);
      await widget.api.saveServerUrl(serverUrl);
      final data = await widget.api.login(phone, password);
      final role =
          (data['user'] is Map<String, dynamic>
                  ? (data['user'] as Map<String, dynamic>)['role']
                  : null)
              ?.toString();
      if (role != 'WAREHOUSE_KEEPER') {
        throw ApiError('فقط انبارداران مجاز به ورود هستند.');
      }
      if (mounted) {
        setState(() {
          _busy = false;
          _status = '';
        });
        widget.onLoginSuccess();
      }
    } catch (exc) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = '';
      });
      _showMessage('خطا', exc.toString());
    }
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.surfaceAlt,
        title: Text(
          title,
          style: const TextStyle(color: Palette.text, fontSize: 15),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Palette.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('باشه', style: TextStyle(color: Palette.primary)),
          ),
        ],
      ),
    );
  }

  void resetForm() {
    _phoneController.clear();
    _passController.clear();
    setState(() => _status = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.appBg,
      body: Center(
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            color: Palette.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.border),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 40,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'MA',
                      style: TextStyle(
                        color: Palette.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'پنل انباردار',
                      style: TextStyle(
                        color: Palette.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ورود ایمن به نرم افزار مدیریت انبار',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Palette.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _showServerField
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppInput(
                                  hint: 'آدرس سرور (http://127.0.0.1:3000)',
                                  controller: _serverController,
                                ),
                                const SizedBox(height: 12),
                              ],
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    AppInput(
                      hint: 'شماره موبایل (09xxxxxxxxx)',
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      hint: 'رمز عبور',
                      controller: _passController,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _busy ? null : _login,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: _busy ? 'در حال ورود...' : 'ورود به پنل',
                      height: 48,
                      onPressed: _busy ? null : _login,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Palette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Desktop v3.0',
                      style: TextStyle(color: Color(0xFF555555), fontSize: 10),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  tooltip: 'تنظیمات سرور',
                  onPressed: () =>
                      setState(() => _showServerField = !_showServerField),
                  icon: const Icon(
                    Icons.settings_rounded,
                    size: 16,
                    color: Palette.textMuted,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  splashRadius: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
