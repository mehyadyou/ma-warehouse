import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/palette.dart';
import '../widgets/app_widgets.dart';

/// ورود مدیر — فقط نقش MANAGER اجازه دارد (این پنل مالک است، نه انباردار).
/// آدرس سرور از همین‌جا قابل تغییر و ذخیره است.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api, required this.onLoginSuccess});

  final CrmApiService api;
  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Mode { login, forceChange }

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _busy = false;
  bool _obscure = true;
  bool _showServerField = false;
  String _status = '';
  _Mode _mode = _Mode.login;

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
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passController.text;
    if (phone.isEmpty || password.isEmpty) {
      _showMessage('خطا', 'شماره موبایل و رمز عبور الزامی است.');
      return;
    }
    var serverUrl = _serverController.text.trim();
    if (serverUrl.isEmpty) serverUrl = CrmApiService.defaultServerUrl;
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
      final userData =
          data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : null;
      if (userData?['role']?.toString() != 'MANAGER') {
        widget.api.logout();
        throw ApiError('این پنل فقط برای مدیر سیستم است.');
      }
      if (userData?['mustChangePassword'] == true) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _mode = _Mode.forceChange;
          _status = '';
        });
        return;
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

  String? _managerPasswordError(String v) {
    // هم‌راستا با سیاست سرور: حداقل ۸ کاراکتر شامل حرف و عدد
    if (v.length < 8) return 'رمز مدیر باید حداقل ۸ کاراکتر باشد.';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'رمز مدیر باید شامل حرف و عدد باشد.';
    }
    if (v.length > 64) return 'رمز عبور بیش از حد طولانی است.';
    return null;
  }

  Future<void> _submitNewPassword() async {
    final newPass = _newPassController.text;
    final confirm = _confirmPassController.text;
    final err = _managerPasswordError(newPass);
    if (err != null) {
      _showMessage('خطا', err);
      return;
    }
    if (newPass != confirm) {
      _showMessage('خطا', 'تکرار رمز با رمز جدید مطابقت ندارد.');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.api.updateMyPassword(newPass);
      // توکن‌های تازه از پاسخ می‌آیند؛ برای اطمینان با رمز جدید لاگین مجدد
      final data = await widget.api.login(_phoneController.text.trim(), newPass);
      final userData = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : null;
      if (userData?['role']?.toString() != 'MANAGER') {
        throw ApiError('این پنل فقط برای مدیر سیستم است.');
      }
      if (!mounted) return;
      setState(() => _busy = false);
      widget.onLoginSuccess();
    } catch (exc) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage('خطا', exc.toString());
    }
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.surfaceAlt,
        title: Text(title, style: const TextStyle(color: Palette.text, fontSize: 16)),
        content: Text(message, style: const TextStyle(color: Palette.textMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('باشه', style: TextStyle(color: Palette.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.appBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.admin_panel_settings_rounded,
                    color: Palette.primary, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'پنل CRM مالک',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Palette.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'نظارت کامل مدیریتی — فقط مدیر سیستم',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 28),
                if (_mode == _Mode.login) ...[
                  AppTextField(
                    controller: _phoneController,
                    label: 'شماره موبایل',
                    hint: 'مثلاً 09123456789',
                    keyboardType: TextInputType.phone,
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _passController,
                    label: 'رمز عبور',
                    obscure: _obscure,
                    onSubmitted: (_) => _login(),
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: Palette.textMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showServerField = !_showServerField),
                      icon: const Icon(Icons.settings_rounded,
                          color: Palette.textMuted, size: 18),
                      label: const Text(
                        'آدرس سرور',
                        style: TextStyle(color: Palette.textMuted, fontSize: 12),
                      ),
                    ),
                  ),
                  if (_showServerField) ...[
                    AppTextField(
                      controller: _serverController,
                      label: 'آدرس سرور',
                      hint: CrmApiService.defaultServerUrl,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 12),
                  AppButton(
                    label: _busy ? '...' : 'ورود',
                    onPressed: _busy ? null : _login,
                  ),
                  if (_status.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Palette.textMuted, fontSize: 12),
                    ),
                  ],
                ] else ...[
                  const Text(
                    'رمز فعلی موقتی است — یک رمز قوی جدید (حداقل ۸ کاراکتر شامل حرف و عدد) انتخاب کنید.',
                    style: TextStyle(color: Palette.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _newPassController,
                    label: 'رمز عبور جدید',
                    obscure: _obscure,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _confirmPassController,
                    label: 'تکرار رمز جدید',
                    obscure: _obscure,
                    onSubmitted: (_) => _submitNewPassword(),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _busy ? '...' : 'تأیید و ادامه',
                    onPressed: _busy ? null : _submitNewPassword,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
