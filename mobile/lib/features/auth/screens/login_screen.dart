import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

const _bg = Color(0xFF0F1114);
const _green = Color(0xFF4ADE80);
const _card = Color(0xFF1A1D22);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authProvider.notifier).login(
          _phoneController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // گوش دادن به خطای ورود (پیام فارسی سرور)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${next.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ═══ پس‌زمینهٔ زنده — هاله‌های سبز متحرک ═══
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) => CustomPaint(
              painter: _GlowPainter(progress: _glowController.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ═══ لوگو با هالهٔ نور ═══
                        _AnimatedLogo(controller: _glowController),
                        const SizedBox(height: 28),

                        // ═══ کارت شیشه‌ای ورود ═══
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _card.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _phoneField(),
                              const SizedBox(height: 14),
                              _passwordField(),
                              const SizedBox(height: 22),
                              _loginButton(authState),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: _green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'اتصال امن',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: _green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'نسخه ۱.۰.۰',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 11,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: _inputDecoration(
        label: 'شماره موبایل',
        hint: '۰۹۱۲۳۴۵۶۷۸۹',
        icon: Icons.phone_android_rounded,
      ),
      validator: (value) {
        final phone = value?.trim() ?? '';
        if (phone.isEmpty) return 'شماره موبایل را وارد کنید';
        if (!RegExp(r'^09\d{9}$').hasMatch(phone)) {
          return 'شماره موبایل معتبر نیست (مثال: ۰۹۱۲۳۴۵۶۷۸۹)';
        }
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      // صفحه‌کلید عمومی: انباردار PIN عددی و مدیر رمز حروفی-عددی می‌زند
      keyboardType: TextInputType.visiblePassword,
      maxLength: 64,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: _inputDecoration(
        label: 'رمز عبور',
        hint: 'رمز حساب',
        icon: Icons.lock_outline_rounded,
        suffix: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: Colors.white38,
            size: 21,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        final v = (value ?? '').trim();
        if (v.isEmpty) return 'رمز عبور را وارد کنید';
        // هم PIN شش‌رقمی انباردار و هم رمز قوی مدیر (سیاست سرور)
        const any = r'^(?:\d{6}|(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$%^&*()_+\-=]{8,64})$';
        if (!RegExp(any).hasMatch(v)) {
          return 'رمز عبور معتبر نیست';
        }
        return null;
      },
      onFieldSubmitted: (_) => _login(),
    );
  }

  Widget _loginButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: authState.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : const Text(
                'ورود به حساب',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      counterText: '',
      prefixIcon: Icon(icon, color: _green, size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF22262D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  لوگوی متحرک با هالهٔ نور
// ═══════════════════════════════════════════════════════════
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final glow = 0.35 + 0.25 * math.sin(controller.value * math.pi);
        return Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _green.withValues(alpha: glow),
                blurRadius: 56,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: _card,
              shape: BoxShape.circle,
              border: Border.all(
                color: _green.withValues(alpha: 0.65),
                width: 1.6,
              ),
            ),
            child: const Icon(
              Icons.warehouse_rounded,
              color: _green,
              size: 50,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  پس‌زمینه: دو هالهٔ نرم متحرک + شبکهٔ محو
// ═══════════════════════════════════════════════════════════
class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    final paint1 = Paint()
      ..color = _green.withValues(alpha: 0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    canvas.drawCircle(
      Offset(
        size.width * (0.85 + 0.08 * math.cos(t)),
        size.height * 0.12,
      ),
      140,
      paint1,
    );

    final paint2 = Paint()
      ..color = _green.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 110);
    canvas.drawCircle(
      Offset(
        size.width * (0.12 + 0.06 * math.sin(t)),
        size.height * 0.88,
      ),
      180,
      paint2,
    );
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
