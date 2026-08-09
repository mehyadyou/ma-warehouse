import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/driver_provider.dart';
import '../../../core/network/api_error.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _info = Color(0xFF60A5FA);
const _border = Color(0xFF2A2D33);

class LoadingPlanTab extends ConsumerWidget {
  const LoadingPlanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(loadingPlanProvider);

    return planAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _green)),
      error: (err, _) => _buildError(context, ref, friendlyError(err)),
      data: (data) {
        final plan = (data['plan'] as List<dynamic>?) ?? [];
        if (plan.isEmpty) return _buildEmpty();

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(loadingPlanProvider),
          color: _green,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: plan.length + 1, // +1 for header
            itemBuilder: (_, i) {
              if (i == 0) return _buildHeader(plan.length);
              final item = plan[i - 1] as Map<String, dynamic>;
              return _buildPlanCard(item, i - 1);
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.route_rounded, color: _green, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$total سفارش آماده بارگیری',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            Text('دورترین باربری اول بار زده شود',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ]),
        ),
        Icon(Icons.arrow_downward_rounded, color: _green.withOpacity(0.5), size: 20),
      ]),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> item, int index) {
    final sequence = item['sequence'] ?? index + 1;
    final carrier = item['carrier'] ?? 'نامشخص';
    final city = item['city'];
    final address = item['address'];
    final phone = item['customerPhone'];
    final totalItems = item['totalItems'] ?? (item['items'] as List<dynamic>?)?.length ?? 0;
    final isFirst = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFirst ? _green.withOpacity(0.5) : _border,
          width: isFirst ? 1.5 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Sequence badge
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isFirst ? _green : _green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('$sequence',
                  style: TextStyle(
                    color: isFirst ? Colors.black : _green,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          // Carrier info
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(carrier,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              if (city != null && city.toString().isNotEmpty)
                Text(city.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          // Items count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orange.withOpacity(0.2)),
            ),
            child: Text('$totalItems بسته',
                style: const TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        // Details row
        if (address != null && address.toString().isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withOpacity(0.35)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(address.toString(),
                  style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ],
        if (phone != null && phone.toString().isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.phone_rounded, size: 13, color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 6),
            Text(phone.toString(),
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ]),
        ],
        // First item indicator
        if (isFirst)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _green.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text('اولین بار — ته وانت',
                  style: TextStyle(color: _green.withOpacity(0.7), fontSize: 11)),
            ]),
          ),
      ]),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_rounded, size: 64, color: Colors.white12),
        SizedBox(height: 16),
        Text('هیچ سفارشی برای بارگیری نیست',
            style: TextStyle(color: Colors.white38, fontSize: 15)),
        SizedBox(height: 6),
        Text('منتظر ثبت سفارش و خروج از انبار باشید',
            style: TextStyle(color: Colors.white24, fontSize: 12)),
      ]),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withOpacity(0.5)),
        const SizedBox(height: 12),
        Text('خطا در دریافت اطلاعات',
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => ref.invalidate(loadingPlanProvider),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('تلاش مجدد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }
}