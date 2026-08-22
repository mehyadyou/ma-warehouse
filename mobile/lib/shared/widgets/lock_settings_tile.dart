import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../features/auth/lock/lock_config.dart';
import '../../features/auth/lock/lock_provider.dart' hide LockState;

const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _danger = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);

/// تنظیمات قفل برنامه — مشترک برای همه نقش‌ها (مدیر/انباردار/راننده).
/// پین جداگانه وجود ندارد؛ قفل با همان رمز اصلی ۶ رقمی حساب باز می‌شود
/// و بیومتریک (اثر انگشت/فیس آید) فقط میان‌بر دستگاه است.
/// غیرفعال کردن قفل نیازمند تأیید (بیومتریک یا رمز) است.
class LockSettingsTile extends ConsumerStatefulWidget {
  const LockSettingsTile({super.key});

  @override
  ConsumerState<LockSettingsTile> createState() => _LockSettingsTileState();
}

class _LockSettingsTileState extends ConsumerState<LockSettingsTile> {
  Future<void> _selectMethod(LockMethod method) async {
    final lock = ref.read(lockProvider);

    // غیرفعال کردن قفل = کاهش امنیت → تأیید با بیومتریک یا رمز اصلی
    if (method == LockMethod.none && lock.method != LockMethod.none) {
      if (lock.fingerprintAvailable || lock.faceAvailable) {
        final ok = await _promptBiometric();
        if (!ok || !mounted) return;
      } else {
        final ok = await _promptPasswordVerify();
        if (!ok || !mounted) return;
      }
    }

    final changed = await ref.read(lockProvider.notifier).changeMethod(method);
    if (changed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('روش قفل تغییر کرد'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _promptBiometric() async {
    final localAuth = LocalAuthentication();
    try {
      return await localAuth.authenticate(
        localizedReason: 'برای غیرفعال کردن قفل برنامه تأیید کنید',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// تأیید با رمز اصلی — وقتی دستگاه بیومتریک ندارد
  Future<bool> _promptPasswordVerify() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _PasswordVerifyDialog(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(lockProvider);

    return Material(
      color: _surfaceAlt,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: lock.checking
            ? const SizedBox(
                height: 40,
                child: Center(
                  child: CircularProgressIndicator(color: _green, strokeWidth: 2),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_rounded, color: _green, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'قفل برنامه',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'باز کردن برنامه با رمز اصلی حساب (۶ رقم) یا بیومتریک',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _methodChip(LockMethod.none, Icons.lock_open_rounded, 'بدون قفل', enabled: true),
                      _methodChip(LockMethod.fingerprint, Icons.fingerprint_rounded, 'اثر انگشت', enabled: lock.fingerprintAvailable),
                      _methodChip(LockMethod.face, Icons.face_retouching_natural_rounded, 'فیس آید', enabled: lock.faceAvailable),
                    ],
                  ),
                  if (lock.method != LockMethod.none) ...[
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.timer_outlined, color: _green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'قفل خودکار',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'پس از این مدت ماندن در پس‌زمینه، برنامه قفل می‌شود',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _delayChip(0, 'فوراً'),
                        _delayChip(1, '۱ دقیقه'),
                        _delayChip(5, '۵ دقیقه'),
                        _delayChip(15, '۱۵ دقیقه'),
                        _delayChip(30, '۳۰ دقیقه'),
                        _delayChip(60, '۱ ساعت'),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _methodChip(LockMethod method, IconData icon, String label, {required bool enabled}) {
    final selected = ref.read(lockProvider).method == method;
    return GestureDetector(
      onTap: enabled ? () => _selectMethod(method) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _green : _border,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: !enabled ? Colors.white24 : (selected ? _green : Colors.white60),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: !enabled ? Colors.white24 : (selected ? _green : Colors.white70),
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// چیپ انتخاب مدت قفل خودکار — دقیقه (۰ = فوراً با رفتن به پس‌زمینه)
  Widget _delayChip(int minutes, String label) {
    final selected = ref.read(lockProvider).autoLockMinutes == minutes;
    return GestureDetector(
      onTap: () => ref.read(lockProvider.notifier).changeAutoLockMinutes(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _green : _border,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 14, color: selected ? _green : Colors.white60),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? _green : Colors.white70,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دیالوگ تأیید رمز اصلی (۶ رقم) برای غیرفعال کردن قفل — وقتی بیومتریک در دسترس نیست
class _PasswordVerifyDialog extends ConsumerStatefulWidget {
  const _PasswordVerifyDialog();

  @override
  ConsumerState<_PasswordVerifyDialog> createState() => _PasswordVerifyDialogState();
}

class _PasswordVerifyDialogState extends ConsumerState<_PasswordVerifyDialog> {
  final _passwordCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordCtrl.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      setState(() => _error = 'رمز عبور باید دقیقاً ۶ رقم باشد');
      return;
    }
    final ok = await ref.read(lockProvider.notifier).verifyPassword(password);
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = 'رمز عبور اشتباه است');
      _passwordCtrl.clear();
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surfaceAlt,
      title: const Text('تأیید رمز', style: TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'رمز ۶ رقمی',
              labelStyle: const TextStyle(color: Colors.white54),
              counterText: '',
              filled: true,
              fillColor: _surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: _danger, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('انصراف'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('تأیید', style: TextStyle(color: _green)),
        ),
      ],
    );
  }
}
