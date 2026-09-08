import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';

/// نوار «حالت آفلاین» بالای داشبوردها — فقط وقتی authProvider.offlineMode فعال است.
/// دکمه «تلاش اتصال»: رفرش سایلنت؛ موفق = خروج از حالت آفلاین و اتصال سوکت.
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      final ok = await ref.read(authProvider.notifier).retryOnline();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'اتصال برقرار شد' : 'هنوز آفلاین هستید'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offline = ref.watch(authProvider.select((s) => s.offlineMode));
    if (!offline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFB923C).withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: Color(0xFFFB923C), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'حالت آفلاین — ثبت‌ها در صف می‌مانند',
              style: TextStyle(color: Color(0xFFFB923C), fontSize: 12.5),
            ),
          ),
          TextButton(
            onPressed: _retrying ? null : _retry,
            child: _retrying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('تلاش اتصال',
                    style: TextStyle(color: Color(0xFFFB923C))),
          ),
        ],
      ),
    );
  }
}
