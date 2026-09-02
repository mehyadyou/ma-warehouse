import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/driver_api_service.dart';
import '../providers/driver_provider.dart';
import '../../../core/network/api_error.dart';

const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _info = Color(0xFF60A5FA);
const _border = Color(0xFF2A2D33);

class DeliveryTab extends ConsumerStatefulWidget {
  const DeliveryTab({super.key});

  @override
  ConsumerState<DeliveryTab> createState() => _DeliveryTabState();
}

class _DeliveryTabState extends ConsumerState<DeliveryTab> {
  final _api = DriverApiService();
  String? _deliveringOrderId;

  /// جریان تحویل: سیستم اول عکس بیجک باربری را می‌خواهد (گالری یا دوربین)،
  /// بعد از آپلود، سفارش تحویل می‌شود.
  Future<void> _startDelivery(String orderId, String carrier) async {
    // ۱) انتخاب عکس بیجک: گالری یا دوربین
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'عکس بیجک باربری',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'برای ثبت تحویل، عکس بیجکی که باربری هنگام تحویل بار به شما داده است را پیوست کنید',
                style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _green),
              title: const Text('انتخاب از گالری', style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: _green),
              title: const Text('دوربین', style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('انصراف', style: TextStyle(color: Colors.white38)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    // ۲) گرفتن عکس
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('باز کردن دوربین/گالری ممکن نشد؛ دوباره تلاش کنید'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    // ۳) پیش‌نمایش + تأیید نهایی — بعد از آپلود، سفارش تحویل می‌شود
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأیید تحویل', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Text('آیا این سفارش به $carrier تحویل داده شد؟',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(Icons.warning_rounded, size: 16, color: _orange.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('بعد از تأیید، قابل بازگشت نیست',
                      style: TextStyle(color: _orange.withOpacity(0.7), fontSize: 11)),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('آپلود و ثبت تحویل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // ۴) آپلود بیجک + ثبت تحویل
    setState(() => _deliveringOrderId = orderId);
    try {
      await _api.deliverOrder(orderId, receiptBytes: bytes);
      ref.invalidate(readyOrdersProvider);
      ref.invalidate(myDeliveriesProvider(null));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('تحویل با موفقیت ثبت شد'),
            ]),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: ${friendlyError(e)}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deliveringOrderId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(readyOrdersProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _green)),
      error: (err, _) => _buildError(friendlyError(err)),
      data: (result) {
        // راننده‌ای که تیکش توسط انباردار برداشته شده → پنل خالی با پیام راهنما
        if (!result.hasWarehouse) return _buildNotConnected();
        if (result.orders.isEmpty) return _buildEmpty();

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(readyOrdersProvider),
          color: _green,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: result.orders.length,
            itemBuilder: (_, i) {
              final order = result.orders[i] as Map<String, dynamic>;
              return _buildDeliveryCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> order) {
    final id = order['id'] as String;
    final orderNumber = order['orderNumber'];
    final carrier = order['carrier'] ?? 'نامشخص';
    final city = order['city'] ?? '';
    final address = order['address'] ?? '';
    final phone = order['customerPhone'] ?? '';
    final items = order['items'] as List<dynamic>? ?? [];
    // سفارش تازه‌ثبت‌شده (PENDING) هنوز از انبار خارج نشده — قابل تحویل نیست
    final isPending = (order['status'] as String?) == 'PENDING';
    final isDelivering = _deliveringOrderId == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(
            child: Text(
                orderNumber != null && orderNumber.toString().isNotEmpty
                    ? 'سفارش شماره $orderNumber'
                    : 'سفارش #${id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isPending ? _orange : _info).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (isPending ? _orange : _info).withOpacity(0.2)),
            ),
            child: Text(isPending ? 'در انتظار خروج از انبار' : 'آماده تحویل',
                style: TextStyle(
                  color: isPending ? _orange : _info,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ]),
        const SizedBox(height: 10),
        // Info rows
        if (carrier.isNotEmpty)
          _infoRow(Icons.business_rounded, carrier),
        if (city.isNotEmpty)
          _infoRow(Icons.location_city_rounded, city),
        if (address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Icon(Icons.location_on_rounded, size: 13, color: Colors.white.withOpacity(0.3)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(address,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        if (phone.isNotEmpty)
          _infoRow(Icons.phone_rounded, phone),
        // Items chips
        if (items.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: items.map((item) {
              final name = item['product']?['name'] ?? item['productName'] ?? '';
              final qty = item['quantity'] ?? 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: Text('$name × $qty',
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 14),
        // Deliver button — سفارش‌های تازه‌ثبت‌شده تا خروج از انبار غیرفعال‌اند
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isDelivering || isPending
                ? null
                : () => _startDelivery(id, carrier),
            icon: isDelivering
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isPending ? Icons.hourglass_empty_rounded : Icons.check_rounded, size: 20),
            label: Text(
              isDelivering
                  ? 'در حال ثبت...'
                  : isPending
                      ? 'منتظر خروج از انبار'
                      : 'تحویل به مشتری',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPending ? _surfaceAlt : _green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 13, color: Colors.white.withOpacity(0.35)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_shipping_rounded, size: 64, color: Colors.white12),
        SizedBox(height: 16),
        Text('باری برای شما تعریف نشده',
            style: TextStyle(color: Colors.white38, fontSize: 15)),
        SizedBox(height: 6),
        Text('منتظر باشید انباردار هنگام خروج محصول، بار را به شما تخصیص دهد',
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

  Widget _buildError(String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withOpacity(0.4)),
        const SizedBox(height: 12),
        Text('خطا: $msg', style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
      ]),
    );
  }
}