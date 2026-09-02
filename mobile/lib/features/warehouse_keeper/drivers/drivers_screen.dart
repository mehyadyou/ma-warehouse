import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_keeper_provider.dart';
import '../models/keeper_driver_model.dart';
import '../../../core/network/api_error.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _border = Color(0xFF2A2D33);

class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key});

  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  /// تیک‌هایی که در حال ارسال هستند — جلوگیری از لمس دوباره
  final Set<String> _pendingIds = {};

  /// لیست هندلرهای سوکت — برای حذف کامل در dispose نگه داشته می‌شود
  final Map<String, Function(dynamic)> _socketHandlers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_registerSocketListeners);
  }

  /// وقتی انباردار دیگری تیکی زد/برداشت، لیست همین‌جا زنده رفرش می‌شود
  void _registerSocketListeners() {
    final socket = ref.read(socketServiceProvider);
    final handler = (dynamic data) {
      if (mounted) ref.invalidate(driversProvider);
    };
    socket.on('driver:assigned', handler);
    _socketHandlers['driver:assigned'] = handler;
  }

  @override
  void dispose() {
    final socket = ref.read(socketServiceProvider);
    _socketHandlers.forEach(
      (event, handler) => socket.offEvent(event, handler),
    );
    _socketHandlers.clear();
    super.dispose();
  }

  Future<void> _onTick(KeeperDriverModel driver, bool assigned) async {
    final unassign = !assigned;
    // تأیید کاربر — برداشتن تیک یعنی پنل راننده خالی می‌شود
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          unassign ? 'برداشتن تیک' : 'اتصال راننده',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Text(
          unassign
              ? '«${driver.name}» از انبار شما جدا می‌شود و پنل راننده خالی می‌شود.'
              : '«${driver.name}» به انبار شما متصل می‌شود و برای سایر انبارها غیرقابل انتخاب خواهد بود.',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              unassign ? 'جدا شود' : 'متصل شود',
              style: TextStyle(
                color: unassign ? Colors.redAccent : _green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _pendingIds.add(driver.id));
    try {
      await ref
          .read(driverAssignmentProvider((driverId: driver.id, assigned: assigned)).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              unassign
                  ? 'راننده از انبار شما جدا شد'
                  : 'راننده به انبار شما متصل شد',
            ),
            backgroundColor: unassign ? Colors.orange : _green,
            behavior: SnackBarBehavior.floating,
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
      if (mounted) setState(() => _pendingIds.remove(driver.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driversProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text(
          'مدیریت رانندگان',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _green),
            onPressed: () => ref.invalidate(driversProvider),
          ),
        ],
      ),
      body: driversAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _green)),
        error: (err, _) => _buildError(context, ref),
        data: (drivers) => drivers.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white.withValues(alpha: 0.25),
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'راننده‌ای تعریف نشده است',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: drivers.length + 1, // +1 برای راهنمای بالا
                itemBuilder: (context, index) {
                  if (index == 0) return const _ListHint();
                  return _DriverCard(
                    driver: drivers[index - 1],
                    pending: _pendingIds.contains(drivers[index - 1].id),
                    onTick: (assigned) => _onTick(drivers[index - 1], assigned),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: Colors.white.withValues(alpha: 0.3),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'خطا در دریافت اطلاعات',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(driversProvider),
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              side: BorderSide(color: _green.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('تلاش دوباره'),
          ),
        ],
      ),
    );
  }
}

/// راهنمای بالای لیست — توضیح معنای تیک
class _ListHint extends StatelessWidget {
  const _ListHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'با زدن تیک، راننده فقط به انبار شما متصل می‌شود و برای سایر انبارها غیرفعال است.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.driver,
    required this.pending,
    required this.onTick,
  });

  final KeeperDriverModel driver;
  final bool pending;

  /// با true → تیک زدن؛ با false → برداشتن تیک
  final void Function(bool assigned) onTick;

  @override
  Widget build(BuildContext context) {
    final isMine = driver.assignedToMe;
    final isOther = driver.assignedToOther;

    return Opacity(
      // راننده‌ای که به انبار دیگری متصل است → کمرنگ و غیرقابل انتخاب
      opacity: isOther ? 0.45 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMine ? _green.withValues(alpha: 0.5) : _border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: _orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    driver.phone,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  if (isOther && driver.warehouseName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'متصل به انبار ${driver.warehouseName}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isOther)
              Icon(
                Icons.lock_rounded,
                color: Colors.white.withValues(alpha: 0.3),
                size: 20,
              )
            else
              _TickButton(
                isMine: isMine,
                pending: pending,
                onTap: () => onTick(!isMine),
              ),
          ],
        ),
      ),
    );
  }
}

class _TickButton extends StatelessWidget {
  const _TickButton({
    required this.isMine,
    required this.pending,
    required this.onTap,
  });

  final bool isMine;
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (pending) {
      return const SizedBox(
        width: 34,
        height: 34,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: _green),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isMine
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isMine ? _green : Colors.white.withValues(alpha: 0.35),
          size: 28,
        ),
      ),
    );
  }
}