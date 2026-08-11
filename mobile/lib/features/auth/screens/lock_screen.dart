import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../lock/lock_config.dart';
import '../lock/lock_provider.dart';
import '../lock/lock_storage.dart';
import '../providers/auth_provider.dart';

const _bg = Color(0xFF0F1114);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _danger = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);

enum _LockMode { biometric, pin }

/// صفحه قفل یکپارچه — پین (کیپد ۴ رقمی) یا بیومتریک (اثر انگشت/فیس آید).
/// بعد از ۵ پین اشتباه کولداون ۳۰ ثانیه فعال می‌شود؛ دکمه «ورود با رمز عبور»
/// همیشه در دسترس است (خروج کامل → صفحه لاگین).
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _localAuth = LocalAuthentication();

  bool _checking = true;
  bool _supported = false;
  bool _unlocking = false;
  String? _error;

  _LockMode _mode = _LockMode.biometric;
  String _pin = '';
  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final method = await LockStorage.getMethod();
    final hasPin = await LockStorage.hasPin();

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
      _mode = method == LockMethod.pin && hasPin
          ? _LockMode.pin
          : _LockMode.biometric;
    });

    if (_mode == _LockMode.biometric && supported) {
      _unlockWithBiometrics();
    }
  }

  Future<void> _unlockWithBiometrics() async {
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

    await _completeUnlock();
  }

  Future<void> _completeUnlock() async {
    ref.read(lockProvider.notifier).resetAttempts();
    final result = await ref.read(authProvider.notifier).unlock();
    if (result != UnlockResult.success && mounted) {
      setState(() {
        _unlocking = false;
        _error = result == UnlockResult.invalidSession
            ? 'نشست شما منقضی شده است؛ با رمز عبور وارد شوید'
            : 'اتصال برقرار نشد؛ دوباره تلاش کنید';
      });
    }
  }

  void _onDigit(String digit) {
    if (_pin.length >= 4 || _cooldownRemaining > 0) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == 4) _submitPin();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submitPin() async {
    setState(() => _unlocking = true);
    final ok = await ref.read(lockProvider.notifier).verifyPin(_pin);
    if (!mounted) return;

    if (ok) {
      setState(() => _pin = '');
      await _completeUnlock();
      return;
    }

    setState(() {
      _pin = '';
      _unlocking = false;
      _error = 'پین اشتباه است';
    });
    HapticFeedback.heavyImpact();

    final lock = ref.read(lockProvider);
    if (lock.cooldownUntil != null) {
      _startCooldown();
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    final until = ref.read(lockProvider).cooldownUntil;
    if (until == null || !until.isAfter(DateTime.now())) {
      setState(() => _cooldownRemaining = 0);
      return;
    }
    setState(() => _cooldownRemaining = until.difference(DateTime.now()).inSeconds + 1);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _cooldownRemaining = until.difference(DateTime.now()).inSeconds + 1;
      });
      if (_cooldownRemaining <= 0) {
        _cooldownTimer?.cancel();
      }
    });
  }

  void _loginWithPassword() {
    ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    // شروع تایمر کولداون فقط یک‌بار با فعال شدن آن
    ref.listen(lockProvider, (previous, next) {
      final prevUntil = previous?.cooldownUntil;
      if (next.cooldownUntil != null && next.cooldownUntil != prevUntil) {
        _startCooldown();
      }
    });

    final inCooldown = _cooldownRemaining > 0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _checking
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: CircularProgressIndicator(color: _green),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconTile(_mode == _LockMode.pin),
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
                      _subtitle(inCooldown),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _danger, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (_mode == _LockMode.pin)
                        _pinSection(inCooldown)
                      else
                        _biometricSection(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _iconTile(bool pinMode) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
      ),
      child: Icon(
        pinMode ? Icons.lock_rounded : Icons.fingerprint_rounded,
        size: 52,
        color: _green,
      ),
    );
  }

  Widget _subtitle(bool inCooldown) {
    if (inCooldown) {
      return Text(
        '$_cooldownRemaining ثانیه دیگر تلاش کنید',
        textAlign: TextAlign.center,
        style: const TextStyle(color: _danger, fontSize: 13, fontWeight: FontWeight.w600),
      );
    }

    final message = _mode == _LockMode.pin
        ? 'پین ۴ رقمی خود را وارد کنید'
        : _supported
            ? 'برای ورود، اثر انگشت یا فیس آید خود را تأیید کنید'
            : 'این دستگاه قابلیت تشخیص اثر انگشت یا فیس آید ندارد';
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 13,
      ),
    );
  }

  Widget _pinSection(bool inCooldown) {
    return Column(
      children: [
        _pinDots(),
        const SizedBox(height: 24),
        _keypad(enabled: !inCooldown && !_unlocking),
        const SizedBox(height: 24),
        if (_supported)
          TextButton(
            onPressed: inCooldown ? null : () {
              setState(() => _mode = _LockMode.biometric);
              _unlockWithBiometrics();
            },
            child: const Text(
              'ورود با اثر انگشت',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        TextButton(
          onPressed: _loginWithPassword,
          child: const Text(
            'ورود با رمز عبور',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _pinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? _green : Colors.transparent,
            border: Border.all(
              color: filled ? _green : Colors.white38,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }

  Widget _keypad({required bool enabled}) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          for (final row in keys)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final key in row) _keyButton(key, enabled),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 72, height: 60),
              _keyButton('0', enabled),
              SizedBox(
                width: 72,
                height: 60,
                child: IconButton(
                  icon: const Icon(Icons.backspace_outlined, color: Colors.white70),
                  onPressed: enabled ? _onBackspace : null,
                  iconSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyButton(String digit, bool enabled) {
    return SizedBox(
      width: 72,
      height: 60,
      child: TextButton(
        onPressed: enabled ? () => _onDigit(digit) : null,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        child: Text(digit),
      ),
    );
  }

  Widget _biometricSection() {
    return Column(
      children: [
        if (_supported) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _unlocking ? null : _unlockWithBiometrics,
              icon: _unlocking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (ref.read(lockProvider).hasPin) ...[
          TextButton(
            onPressed: () {
              setState(() {
                _mode = _LockMode.pin;
                _error = null;
              });
            },
            child: const Text(
              'ورود با پین',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 4),
        ],
        TextButton(
          onPressed: _loginWithPassword,
          child: const Text(
            'ورود با رمز عبور',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
