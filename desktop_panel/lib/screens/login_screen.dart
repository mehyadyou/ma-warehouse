import 'package:flutter/material.dart';

import '../core/api_service.dart';
import '../core/palette.dart';
import '../widgets/app_widgets.dart';

/// حالت‌های صفحهٔ ورود: عادی / تغییر اجباری رمز
enum _Mode { login, forceChange }

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

  // فیلدهای تغییر اجباری رمز
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _busy = false;
  bool _showServerField = false;
  bool _obscureNew = true;
  _Mode _mode = _Mode.login;
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
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  String get _statusText {
    switch (_mode) {
      case _Mode.login:
        return _status;
      case _Mode.forceChange:
        return 'رمز فعلی موقتی است — برای ادامه یک رمز ۶ رقمی جدید انتخاب کنید';
    }
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
      final userData =
          data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : null;
      final role = userData?['role']?.toString();
      if (role != 'WAREHOUSE_KEEPER') {
        throw ApiError('فقط انبارداران مجاز به ورود هستند.');
      }
      // رمز موقت — کاربر باید در اولین ورود رمز را عوض کند
      final mustChange = userData?['mustChangePassword'] == true;
      if (mustChange) {
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

  Future<void> _submitNewPassword() async {
    final newPass = _newPassController.text;
    final confirm = _confirmPassController.text;
    if (!RegExp(r'^\d{6}$').hasMatch(newPass)) {
      _showMessage('خطا', 'رمز جدید باید دقیقاً ۶ رقم باشد.');
      return;
    }
    if (newPass == _passController.text) {
      _showMessage('خطا', 'رمز جدید نباید با رمز موقت یکسان باشد.');
      return;
    }
    if (newPass != confirm) {
      _showMessage('خطا', 'تکرار رمز با رمز جدید مطابقت ندارد.');
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.api.updateMyPassword(newPass);
      // تغییر رمز → tokenVersion بالا رفته و توکن قبلی باطل شده است؛
      // با رمز جدید دوباره وارد می‌شویم تا توکن تازه صادر شود
      final data = await widget.api.login(_phoneController.text.trim(), newPass);
      final userData = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : null;
      if (userData?['role']?.toString() != 'WAREHOUSE_KEEPER') {
        throw ApiError('فقط انبارداران مجاز به ورود هستند.');
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
    _newPassController.clear();
    _confirmPassController.clear();
    setState(() {
      _status = '';
      _mode = _Mode.login;
    });
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Palette.textMuted, fontSize: 13),
      filled: true,
      fillColor: Palette.appBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isForceChange = _mode == _Mode.forceChange;

    return Scaffold(
      backgroundColor: Palette.appBg,
      body: Stack(
        children: [
          // ═══ پس‌زمینه — دو هالهٔ نرم سبز ═══
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Palette.primary.withValues(alpha: 0.10),
                    Palette.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Palette.primary.withValues(alpha: 0.07),
                    Palette.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
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
                        // ═══ لوگو در دایرهٔ درخشان ═══
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Palette.primary.withValues(alpha: 0.6),
                              width: 1.4,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'MA',
                              style: TextStyle(
                                color: Palette.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isForceChange ? 'تغییر رمز عبور' : 'پنل انباردار',
                          style: const TextStyle(
                            color: Palette.primary,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: Text(
                            _statusText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isForceChange
                                  ? const Color(0xFFFBBF24)
                                  : Palette.textMuted,
                              fontSize: isForceChange ? 12 : 12,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: _showServerField && !isForceChange
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppInput(
                                      hint:
                                          'آدرس سرور (http://127.0.0.1:3000)',
                                      controller: _serverController,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        if (!isForceChange) ...[
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
                        ] else ...[
                          TextField(
                            controller: _newPassController,
                            obscureText: _obscureNew,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(
                                color: Palette.text, fontSize: 14),
                            decoration: _decoration(
                              'رمز جدید (۶ رقم)',
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 18,
                                  color: Palette.textMuted,
                                ),
                                onPressed: () => setState(
                                    () => _obscureNew = !_obscureNew),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmPassController,
                            obscureText: _obscureNew,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            onSubmitted:
                                _busy ? null : (_) => _submitNewPassword(),
                            style: const TextStyle(
                                color: Palette.text, fontSize: 14),
                            decoration: _decoration('تکرار رمز جدید'),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: _busy ? 'در حال ثبت...' : 'تأیید و ورود',
                            height: 48,
                            onPressed:
                                _busy ? null : _submitNewPassword,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed:
                                _busy ? null : () => setState(() => _mode = _Mode.login),
                            child: const Text(
                              'بازگشت به ورود',
                              style: TextStyle(
                                color: Palette.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'Desktop v3.0',
                          style: TextStyle(
                              color: Color(0xFF555555), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (!isForceChange)
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
        ],
      ),
    );
  }
}
