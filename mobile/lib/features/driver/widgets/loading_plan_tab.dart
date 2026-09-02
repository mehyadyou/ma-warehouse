import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/driver_provider.dart';
import '../../../core/network/api_error.dart';

const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
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
        // راننده‌ای که تیکش توسط انباردار برداشته شده → پنل خالی با پیام راهنما
        if (data['hasWarehouse'] == false) return _buildNotConnected();
        final plan = (data['plan'] as List<dynamic>?) ?? [];
        final pending = (data['pendingOrders'] as List<dynamic>?) ?? [];
        // سفارش‌های تازه‌ثبت‌شده هم باید دیده شوند — حتی اگر هنوز بارگیری‌ای نباشد
        if (plan.isEmpty && pending.isEmpty) return _buildEmpty();

        final children = <Widget>[
          _buildHeader(plan.length, pending.length),
          if (pending.isNotEmpty) ...[_buildPendingHeader(pending.length), ...pending.map((p) => _buildPendingCard(p as Map<String, dynamic>))],
          if (plan.isNotEmpty) ...[const SizedBox(height: 4), ...plan.asMap().entries.map((e) => _buildPlanCard(e.value as Map<String, dynamic>, e.key))],
        ];

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(loadingPlanProvider),
          color: _green,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: children,
          ),
        );
      },
    );
  }

  Widget _buildHeader(int total, int pendingCount) {
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
            Text(
              pendingCount > 0
                  ? 'و $pendingCount سفارش در انتظار خروج از انبار'
                  : 'به ترتیب صف بارگیری: از بالا نزدیک‌ترین، اول بار زده می‌شود',
              style: TextStyle(
                color: pendingCount > 0 ? _orange : Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: pendingCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ]),
        ),
        Icon(Icons.arrow_downward_rounded, color: _green.withOpacity(0.5), size: 20),
      ]),
    );
  }

  /// عنوان بخش سفارش‌های تازه‌ثبت‌شده (هنوز از انبار خارج نشده‌اند)
  Widget _buildPendingHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: _orange, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$count سفارش در انتظار خروج از انبار',
            style: const TextStyle(color: _orange, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    );
  }

  /// کارت سفارش تازه‌ثبت‌شده — هنوز کارتنی برای بار زدن ندارد
  Widget _buildPendingCard(Map<String, dynamic> item) {
    final orderNumber = item['orderNumber'];
    final carrier = item['carrier'] ?? 'نامشخص';
    final city = item['city'];
    final items = (item['items'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _orange.withOpacity(0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hourglass_empty_rounded, color: _orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  orderNumber != null && orderNumber.toString().isNotEmpty
                      ? 'سفارش شماره $orderNumber'
                      : carrier,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              if (orderNumber != null && orderNumber.toString().isNotEmpty)
                Text(carrier,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              if (city != null && city.toString().isNotEmpty)
                Text(city.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orange.withOpacity(0.2)),
            ),
            child: const Text('در انتظار خروج',
                style: TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        // اقلام سفارش
        if (items.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: items.map((i) {
              final name = i['productName'] ?? '';
              final qty = i['quantity'] ?? 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _orange.withOpacity(0.15)),
                ),
                child: Text('$name × $qty',
                    style: TextStyle(color: _orange.withOpacity(0.85), fontSize: 11)),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 8),
        Text('به محض خروج از انبار، برای بارگیری آماده می‌شود',
            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
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
        Text('باری برای شما تعریف نشده',
            style: TextStyle(color: Colors.white38, fontSize: 15)),
        SizedBox(height: 6),
        Text('وقتی انباردار هنگام خروج محصول راننده را انتخاب کند، بار اینجا ظاهر می‌شود',
            style: TextStyle(color: Colors.white24, fontSize: 12),
            textAlign: TextAlign.center),
      ]),
    );
  }

  /// راننده به انباری متصل نیست (تیک توسط انباردار برداشته شده) — پنل خالی با پیام راهنما
  Widget _buildNotConnected() {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.link_off_rounded, size: 64, color: Colors.white12),
        SizedBox(height: 16),
        Text('به انباری متصل نیستید',
            style: TextStyle(color: Colors.white38, fontSize: 15)),
        SizedBox(height: 6),
        Text('با انباردار هماهنگ کنید تا شما را متصل کند',
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