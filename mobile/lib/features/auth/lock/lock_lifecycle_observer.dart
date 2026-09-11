import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/refresh/resume_tick.dart';
import '../providers/auth_provider.dart';
import 'lock_config.dart';
import 'lock_provider.dart';

/// قفل مجدد هنگام بازگشت به برنامه از پس‌زمینه:
/// اگر روش قفل (بیومتریک یا رمز اصلی حساب) فعال باشد و نشست باز باشد،
/// پس از گذشت «زمان قفل خودکار» از لحظه رفتن به پس‌زمینه، با بازگشت
/// برنامه قفل می‌شود — زمان از تنظیمات قابل تغییر است (۰ = فوراً).
class LockLifecycleObserver extends ConsumerStatefulWidget {
  const LockLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockLifecycleObserver> createState() =>
      _LockLifecycleObserverState();
}

class _LockLifecycleObserverState extends ConsumerState<LockLifecycleObserver>
    with WidgetsBindingObserver {
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final at = _backgroundedAt;
        _backgroundedAt = null;
        if (at != null) {
          _lockIfTimedOut(at);
          // بازگشت واقعی از پس‌زمینه با نشست باز → تیک رفرش برای داشبوردها
          if (ref.read(authProvider).isLoggedIn) {
            ref.read(resumeTickProvider.notifier).bump();
          }
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _lockIfTimedOut(DateTime backgroundedAt) {
    final auth = ref.read(authProvider);
    final lock = ref.read(lockProvider);
    if (!auth.isLoggedIn || auth.isLocked) return;
    if (lock.checking || lock.method == LockMethod.none) return;
    // قفل همیشه قابل اعمال است — رمز اصلی حساب جایگزین پین است
    final elapsed = DateTime.now().difference(backgroundedAt);
    if (elapsed >= Duration(minutes: lock.autoLockMinutes)) {
      ref.read(authProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}