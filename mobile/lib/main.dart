import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/local_storage.dart';
import 'core/routes/app_router.dart';
import 'core/updates/update_popup.dart';
import 'core/updates/update_service.dart';
import 'features/auth/lock/lock_lifecycle_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  runApp(
    const ProviderScope(
      child: MaApp(),
    ),
  );
}

class MaApp extends ConsumerStatefulWidget {
  const MaApp({super.key});

  @override
  ConsumerState<MaApp> createState() => _MaAppState();
}

class _MaAppState extends ConsumerState<MaApp> {
  bool _updateChecked = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ما - مدیریت انبار',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: _UpdateGate(
          checked: _updateChecked,
          onChecked: () => setState(() => _updateChecked = true),
          child: LockLifecycleObserver(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// بررسی بروزرسانی یک بار در هر اجرا — بعد از اولین فریم (که اسپلش دیده شود)
/// پاپ‌آپ فقط وقتی نمایش داده می‌شود که صفحهٔ واقعی (نه اسپلش) جلو است.
class _UpdateGate extends StatefulWidget {
  const _UpdateGate({
    required this.checked,
    required this.onChecked,
    required this.child,
  });

  final bool checked;
  final VoidCallback onChecked;
  final Widget child;

  @override
  State<_UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<_UpdateGate> {
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.checked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  @override
  void dispose() {
    // لغو تایمر — در تست‌ها و بستن سریع اپ، تایمر معلق باقی نمی‌ماند
    _delayTimer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    // کمی صبر تا اپ کامل بالا بیاید (اسپلش/مسیردهی) — آپدیت نباید مانع کار عادی باشد
    final completer = Completer<void>();
    _delayTimer = Timer(const Duration(seconds: 2), completer.complete);
    if (!mounted) {
      _delayTimer?.cancel();
      return;
    }
    await completer.future;
    if (!mounted) return;
    final result = await UpdateService.instance.checkForUpdate();
    if (!mounted) return;
    widget.onChecked();
    if (result is UpdateAvailable) {
      await showUpdatePopup(context, result.info);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
