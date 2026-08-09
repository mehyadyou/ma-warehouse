import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_provider.dart';

const _bg = Color(0xFF0F1114);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _danger = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);

/// صفحه قفل — ورود با اثر انگشت/فیس آید؛ روی دستگاه بدون بیومتریک
/// یا در صورت انصراف، با «ورود با رمز عبور» ادامه می‌دهد.
class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  final _localAuth = LocalAuthentication();
  bool _checking = true;
  bool _supported = false;
  bool _unlocking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    bool supported = false;
    try {
      supported =
          await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (_) {
      supported = false;
    }
    if (!mounted) return;

    setState(() {
      _supported = supported;
      _checking = false;
    });

    if (supported) {
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_unlocking) return;
    setState(() {
      _unlocking = true;
      _error = null;
    });

    final authenticated = await _localAuth.authenticate(
      localizedReason: 'برای ورود به برنامه، اثر انگشت یا فیس آید را تأیید کنید',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (!mounted) return;
    setState(() => _unlocking = false);

    if (!authenticated) {
      setState(() => _error = 'تأیید هویت انجام نشد');
      return;
    }

    final ok = await ref.read(authProvider.notifier).unlockWithBiometrics();
    if (!ok && mounted) {
      setState(() => _error = 'نشست شما منقضی شده است؛ با رمز عبور وارد شوید');
    }
  }

  Future<void> _loginWithPassword() async {
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _checking
                ? const CircularProgressIndicator(color: _green)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: _surfaceAlt,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: _border),
                        ),
                        child: Icon(
                          _supported
                              ? Icons.fingerprint_rounded
                              : Icons.lock_rounded,
                          size: 52,
                          color: _green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'برنامه قفل است',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _supported
                            ? 'برای ورود، اثر انگشت یا فیس آید خود را تأیید کنید'
                            : 'این دستگاه قابلیت تشخیص اثر انگشت یا فیس آید ندارد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _danger, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (_supported)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _unlocking ? null : _unlock,
                            icon: _unlocking
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black87,
                                    ),
                                  )
                                : const Icon(Icons.fingerprint_rounded),
                            label: Text(
                              _unlocking ? 'در حال بررسی...' : 'ورود با اثر انگشت',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loginWithPassword,
                        child: const Text(
                          'ورود با رمز عبور',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
