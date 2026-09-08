import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_error.dart';
import '../../../shared/utils/validators.dart';
import '../data/auth_api_service.dart';
import '../providers/auth_provider.dart';

const _bg = Color(0xFF0F1114);
const _green = Color(0xFF4ADE80);
const _surfaceAlt = Color(0xFF1A1D22);
const _border = Color(0xFF2A2E35);

/// صفحهٔ تغییر اجباری رمز در اولین ورود با رمز موقتِ داده‌شده توسط مدیر.
/// تا تغییر رمز، مسیردهی اجازهٔ ورود به هیچ صفحهٔ دیگری نمی‌دهد.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newPassword = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (newPassword != confirm) {
      setState(() => _error = 'تکرار رمز عبور مطابقت ندارد');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref.read(authServiceProvider).updateProfile(
            password: newPassword,
          );

      final token = result['token'] as String?;
      final refreshToken = result['refreshToken'] as String?;
      final notifier = ref.read(authProvider.notifier);
      if (token != null && token.isNotEmpty && refreshToken != null) {
        await notifier.applyPasswordChanged(
          token: token,
          refreshToken: refreshToken,
          password: newPassword,
        );
      } else {
        // توکن تازه نیامد — پرچم فقط محلی پاک می‌شود؛ رفرش بعدی نشست را تازه می‌کند
        await notifier.applyPasswordChanged(
          token: '',
          refreshToken: '',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رمز عبور با موفقیت تغییر کرد — خوش آمدید!'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // مدیر رمز قوی (حرف+عدد) و انباردار/راننده PIN شش‌رقمی — مطابق سیاست سرور
    final isManager = ref.watch(authProvider).role == 'MANAGER';
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: _green, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: _green,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'تغییر رمز عبور',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isManager
                        ? 'رمز فعلی شما موقتی است.\nبرای ادامه، یک رمز قوی جدید (حداقل ۸ کاراکتر شامل حرف و عدد) انتخاب کنید.'
                        : 'رمز فعلی شما موقتی است.\nبرای ادامه، یک رمز ۶ رقمی جدید انتخاب کنید.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.7,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _field(
                    controller: _newCtrl,
                    label: isManager ? 'رمز عبور جدید (حرف+عدد)' : 'رمز عبور جدید (۶ رقم)',
                    hint: isManager ? 'حداقل ۸ کاراکتر' : '۶ رقم عددی',
                    isManager: isManager,
                    validator: (v) {
                      final err = isManager
                          ? validateManagerPassword(v)
                          : validatePassword(v);
                      if (err != null) return err;
                      if (!isManager && (v?.trim() ?? '') == '123456') {
                        return 'رمز جدید نباید با رمز موقت یکسان باشد';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _confirmCtrl,
                    label: 'تکرار رمز عبور جدید',
                    hint: 'تکرار رمز جدید',
                    isManager: isManager,
                    validator: (v) {
                      final err = isManager
                          ? validateManagerPassword(v)
                          : validatePassword(v);
                      if (err != null) return err;
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'تأیید و ادامه',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'این رمز جدید، رمز ورود شما به برنامه خواهد بود',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    bool isManager = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscure,
      keyboardType:
          isManager ? TextInputType.visiblePassword : TextInputType.number,
      maxLength: isManager ? 64 : 6,
      inputFormatters:
          isManager ? null : [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: _green),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: Colors.white38,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: _surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
      ),
    );
  }
}
