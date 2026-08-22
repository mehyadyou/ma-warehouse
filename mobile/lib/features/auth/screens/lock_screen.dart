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

/// صفحه قفل یکپارچه — با همان رمز اصلی ۶ رقمی حساب باز می‌شود
/// (تأیید سمت سرور)؛ بیومتریک (اثر انگشت/فیس آید) فقط میان‌بر دستگاه است.
/// بعد از ۵ رمز اشتباه کولداون ۳۰ ثانیه فعال می‌شود؛ «خروج از حساب»
/// راه فرار در صورت فراموشی رمز است (بازگشت به صفحه ورود).
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

  String _password = '';
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

    // روش ذخیره‌شده بیومتریک و دستگاه سنسور دارد → تلاش خودکار بیومتریک
    if (method != LockMethod.none && supported) {
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
            ? 'نشست شما منقضی شده است؛ از حساب خارج شده و دوباره وارد شوید'
            : 'اتصال برقرار نشد؛ دوباره تلاش کنید';
      });
    }
  }

  void _onDigit(String digit) {
    if (_password.length >= 6 || _cooldownRemaining > 0) return;
    setState(() {
      _password += digit;
      _error = null;
    });
    if (_password.length == 6) _submitPassword();
  }

  void _onBackspace() {
    if (_password.isEmpty) return;
    setState(() => _password = _password.substring(0, _password.length - 1));
  }

  Future<void> _submitPassword() async {
    setState(() => _unlocking = true);
    final ok = await ref.read(lockProvider.notifier).verifyPassword(_password);
    if (!mounted) return;

    if (ok) {
      setState(() => _password = '');
      await _completeUnlock();
      return;
    }

    setState(() {
      _password = '';
      _unlocking = false;
      _error = 'رمز عبور اشتباه است';
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

  /// راه فرار فراموشی رمز — خروج کامل از حساب (پاک‌سازی قفل + رفتن به ورود)
  void _logout() {
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
                      _iconTile(),
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
                      _passwordSection(inCooldown),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _iconTile() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
      ),
      child: const Icon(
        Icons.lock_rounded,
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
        style: const TextStyle(
          color: _danger,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return const Text(
      'رمز ۶ رقمی خود را وارد کنید',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white54,
        fontSize: 13,
      ),
    );
  }

  Widget _passwordSection(bool inCooldown) {
    return Column(
      children: [
        _passwordDots(),
        const SizedBox(height: 24),
        _keypad(enabled: !inCooldown && !_unlocking),
        const SizedBox(height: 24),
        if (_supported)
          TextButton(
            onPressed: inCooldown ? null : _unlockWithBiometrics,
            child: const Text(
              'ورود با اثر انگشت',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        TextButton(
          onPressed: _logout,
          child: const Text(
            'خروج از حساب',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _passwordDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < _password.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: 15,
          height: 15,
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
}
