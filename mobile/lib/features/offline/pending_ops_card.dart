import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../warehouse_keeper/providers/warehouse_keeper_provider.dart';
import 'pending_ops.dart';

const _orange = Color(0xFFFB923C);
const _green = Color(0xFF4ADE80);
const _surface = Color(0xFF1A1D22);
const _border = Color(0xFF2A2D33);

/// کارت «صف آفلاین» در خانهٔ انباردار — تعداد عملیات ثبت‌نشده + دکمهٔ ارسال.
/// وقتی خالی است هیچ‌چیز رندر نمی‌کند.
class PendingOpsCard extends ConsumerStatefulWidget {
  const PendingOpsCard({super.key});

  @override
  ConsumerState<PendingOpsCard> createState() => _PendingOpsCardState();
}

class _PendingOpsCardState extends ConsumerState<PendingOpsCard> {
  bool _flushing = false;

  Future<void> _flush() async {
    if (_flushing) return;
    setState(() => _flushing = true);
    try {
      final result = await ref.read(pendingOpsProvider.notifier).flush();
      if (!mounted) return;
      // موجودی/سفارش‌ها بعد از فلاش موفق تازه می‌شوند
      if (result.sent > 0) {
        ref.invalidate(inventorySummaryProvider);
        ref.invalidate(keeperInventoryListProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(ordersProvider);
      }
      final msg = result.sent > 0
          ? '${result.sent} عملیات ارسال شد'
          : result.failed > 0
              ? 'هنوز آفلاین هستید — بعداً تلاش کنید'
              : 'صف خالی شد';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errors.isNotEmpty ? '$msg\n${result.errors.first}' : msg,
          ),
          backgroundColor: result.sent > 0 ? _green : _orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _flushing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ops = ref.watch(pendingOpsProvider);
    if (ops.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _orange.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, color: _orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ops.length} عملیات در صف آفلاین',
                  style: const TextStyle(
                    color: _orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ops.length == 1 ? ops.first.label : 'با اتصال اینترنت ارسال می‌شوند',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _flushing ? null : _flush,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _flushing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Text('ارسال'),
          ),
        ],
      ),
    );
  }
}
