import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

const _green = Color(0xFF4ADE80);
const _surfaceAlt = Color(0xFF22262D);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
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
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _green, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.warehouse_rounded,
                      color: _green,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ما',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مدیریت هوشمند انبار',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'شماره موبایل',
                      hintText: '۰۹۱۲۳۴۵۶۷۸۹',
                      prefixIcon: Icon(Icons.phone_android_rounded),
                      counterText: '',
                    ),
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.isEmpty) return 'شماره موبایل را وارد کنید';
                      if (!RegExp(r'^09\d{9}$').hasMatch(phone)) {
                        return 'شماره موبایل معتبر نیست (مثال: ۰۹۱۲۳۴۵۶۷۸۹)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'رمز عبور (۶ رقم)',
                      hintText: '••••••',
                      counterText: '',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return 'رمز عبور را وارد کنید';
                      if (!RegExp(r'^\d{6}$').hasMatch(v)) {
                        return 'رمز عبور باید دقیقاً ۶ رقم باشد';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('ورود'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'نسخه ۱.۰.۰',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
