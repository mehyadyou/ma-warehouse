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
/// انتخاب روش قفل (بدون قفل / اثر انگشت / فیس آید / پین) + تعیین/تغییر/حذف پین.
/// تغییر روش قفل هرگز پین را پاک نمی‌کند؛ غیرفعال کردن قفل نیازمند تأیید است.
class LockSettingsTile extends ConsumerStatefulWidget {
  const LockSettingsTile({super.key});

  @override
  ConsumerState<LockSettingsTile> createState() => _LockSettingsTileState();
}

class _LockSettingsTileState extends ConsumerState<LockSettingsTile> {
  Future<void> _selectMethod(LockMethod method) async {
    final lock = ref.read(lockProvider);

    // غیرفعال کردن قفل = کاهش امنیت → تأیید با پین یا بیومتریک
    if (method == LockMethod.none && lock.method != LockMethod.none) {
      if (lock.hasPin) {
        final ok = await _promptPinVerify();
        if (!ok || !mounted) return;
      } else if (lock.isBiometric) {
        final ok = await _promptBiometric();
        if (!ok || !mounted) return;
      }
    }

    // انتخاب پین بدون پین ذخیره‌شده → پنجره تعیین پین
    if (method == LockMethod.pin && !lock.hasPin) {
      final pin = await _openPinSheet(requireCurrent: false);
      if (pin == null || !mounted) return;
      final ok = await ref.read(lockProvider.notifier).setupPin(pin);
      if (!ok) return;
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

  Future<bool> _promptPinVerify() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _PinVerifyDialog(),
    );
    return confirmed ?? false;
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

  /// پنجره تعیین/تغییر پین — خروجی پین جدید (null = انصراف)
  Future<String?> _openPinSheet({required bool requireCurrent}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _PinSheet(requireCurrent: requireCurrent),
      ),
    );
  }

  Future<void> _changePin() async {
    final lock = ref.read(lockProvider);
    if (!lock.hasPin) return;
    // پنجره تغییر پین: پین فعلی را تأیید و پین جدید را ذخیره می‌کند
    final newPin = await _openPinSheet(requireCurrent: true);
    if (newPin == null || !mounted) return;
    _showMessage('پین تغییر کرد');
  }

  Future<void> _removePin() async {
    final lock = ref.read(lockProvider);
    if (!lock.hasPin) return;
    final confirmed = await _promptPinVerify();
    if (!confirmed || !mounted) return;
    await ref.read(lockProvider.notifier).clearPin();
    if (mounted) _showMessage('پین حذف شد');
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                child: Center(child: CircularProgressIndicator(color: _green, strokeWidth: 2)),
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
                    'هر بار باز کردن برنامه بدون وارد کردن رمز',
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
                      _methodChip(LockMethod.none, Icons.lock_open_rounded, 'بدون قفل'),
                      if (lock.fingerprintAvailable)
                        _methodChip(LockMethod.fingerprint, Icons.fingerprint_rounded, 'اثر انگشت'),
                      if (lock.faceAvailable)
                        _methodChip(LockMethod.face, Icons.face_retouching_natural_rounded, 'فیس آید'),
                      _methodChip(LockMethod.pin, Icons.pin_rounded, 'پین'),
                    ],
                  ),
                  if (lock.hasPin && lock.method == LockMethod.pin) ...[
                    const SizedBox(height: 8),
                    _actionRow(Icons.refresh_rounded, 'تغییر پین', _changePin),
                  ],
                  if (lock.hasPin && lock.method != LockMethod.pin) ...[
                    const SizedBox(height: 8),
                    _actionRow(Icons.delete_outline_rounded, 'حذف پین', _removePin),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _methodChip(LockMethod method, IconData icon, String label) {
    final selected = ref.read(lockProvider).method == method;
    return GestureDetector(
      onTap: () => _selectMethod(method),
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
            Icon(icon, size: 16, color: selected ? _green : Colors.white60),
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

  Widget _actionRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// پنجره تعیین/تغییر پین — فقط ۴ رقم
class _PinSheet extends ConsumerStatefulWidget {
  final bool requireCurrent;

  const _PinSheet({required this.requireCurrent});

  @override
  ConsumerState<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends ConsumerState<_PinSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text.trim();
    final newPin = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (widget.requireCurrent && !RegExp(r'^\d{4}$').hasMatch(current)) {
      setState(() => _error = 'پین فعلی باید ۴ رقم باشد');
      return;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(newPin)) {
      setState(() => _error = 'پین جدید باید ۴ رقم باشد');
      return;
    }
    if (newPin != confirm) {
      setState(() => _error = 'تکرار پین مطابقت ندارد');
      return;
    }

    final notifier = ref.read(lockProvider.notifier);
    if (widget.requireCurrent) {
      final ok = await notifier.changePin(current, newPin);
      if (!ok) {
        if (mounted) setState(() => _error = 'پین فعلی اشتباه است');
        return;
      }
    } else {
      final ok = await notifier.setupPin(newPin);
      if (!ok) {
        if (mounted) setState(() => _error = 'پین نامعتبر است');
        return;
      }
    }
    if (mounted) Navigator.pop(context, newPin);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.requireCurrent ? 'تغییر پین' : 'تعیین پین',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'پین باید ۴ رقم باشد',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (widget.requireCurrent) ...[
            _pinField(_currentCtrl, 'پین فعلی'),
            const SizedBox(height: 12),
          ],
          _pinField(_newCtrl, 'پین جدید'),
          const SizedBox(height: 12),
          _pinField(_confirmCtrl, 'تکرار پین جدید'),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: _danger, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('تأیید', style: TextStyle(color: Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pinField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      autofocus: controller == _newCtrl && !widget.requireCurrent,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        counterText: '',
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
      ),
    );
  }
}

/// دیالوگ تأیید پین برای عملیات حساس (غیرفعال کردن قفل / حذف پین)
class _PinVerifyDialog extends ConsumerStatefulWidget {
  const _PinVerifyDialog();

  @override
  ConsumerState<_PinVerifyDialog> createState() => _PinVerifyDialogState();
}

class _PinVerifyDialogState extends ConsumerState<_PinVerifyDialog> {
  final _pinCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref.read(lockProvider.notifier).verifyPin(_pinCtrl.text.trim());
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = 'پین اشتباه است');
      _pinCtrl.clear();
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surfaceAlt,
      title: const Text('تأیید پین', style: TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'پین ۴ رقمی',
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
