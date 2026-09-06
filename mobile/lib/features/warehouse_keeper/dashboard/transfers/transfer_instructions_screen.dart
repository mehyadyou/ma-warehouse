import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../manager/models/transfer_model.dart';
import '../../data/warehouse_keeper_api_service.dart';
import '../../providers/warehouse_keeper_provider.dart';
import '../../scan_out/scan_out_screen.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

/// دستورات جابه‌جایی/خروج مدیر برای این انبار — انباردار با اسکن کارتن‌ها
/// هر دستور را تا تکمیل سهمیه اجرا می‌کند
class TransferInstructionsScreen extends ConsumerStatefulWidget {
  const TransferInstructionsScreen({super.key});

  @override
  ConsumerState<TransferInstructionsScreen> createState() =>
      _TransferInstructionsScreenState();
}

class _TransferInstructionsScreenState
    extends ConsumerState<TransferInstructionsScreen> {
  late final WarehouseKeeperApiService _api = ref.read(wkApiProvider);

  List<TransferModel> _transfers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.getTransfers(limit: 50);
      if (!mounted) return;
      setState(() {
        _transfers = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'خطا در دریافت دستورها';
      });
    }
  }

  Future<void> _openScan(TransferModel t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanOutScreen(
          transferId: t.id,
          transferLabel: _label(t),
        ),
      ),
    );
    _load();
  }

  String _label(TransferModel t) {
    final dest = t.toWarehouseName ?? 'خروج از انبار';
    return '${t.productName}${t.modelName != null ? ' — ${t.modelName}' : ''} ← $dest';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'دستورهای خروج/جابه‌جایی',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _green,
        backgroundColor: _surface,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _green, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _textDim, size: 34),
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: _textDim)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _load,
              child: const Text(
                'تلاش دوباره',
                style: TextStyle(color: _green),
              ),
            ),
          ],
        ),
      );
    }
    if (_transfers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.task_alt_rounded, color: _textDim, size: 48),
          SizedBox(height: 12),
          Text(
            'دستوری برای اجرا ندارید',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textDim, fontSize: 13.5),
          ),
          SizedBox(height: 6),
          Text(
            'دستورهای خروج/جابه‌جایی مدیر اینجا نمایش داده می‌شوند',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _transfers.length,
      itemBuilder: (ctx, i) {
        final t = _transfers[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _card(t),
        );
      },
    );
  }

  Widget _card(TransferModel t) {
    final isTransfer = t.toWarehouseId != null;
    final color = isTransfer ? _green : _amber;
    final progress =
        t.quantity > 0 ? (t.executedUnits / t.quantity).clamp(0.0, 1.0) : 0.0;
    return GestureDetector(
      onTap: t.status == 'PENDING' ? () => _openScan(t) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: t.status == 'PENDING'
                ? color.withValues(alpha: 0.45)
                : _border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    isTransfer
                        ? Icons.swap_horizontal_circle_rounded
                        : Icons.logout_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.productName}${t.modelName != null ? ' — ${t.modelName}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isTransfer
                            ? 'از ${t.fromWarehouseName} به ${t.toWarehouseName}'
                            : 'خروج از ${t.fromWarehouseName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.9),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${t.quantity} واحد',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'اجرا شده ${t.executedUnits} از ${t.quantity} واحد',
                  style: const TextStyle(color: _textDim, fontSize: 11),
                ),
                const Spacer(),
                if (t.status == 'PENDING')
                  const Text(
                    'اسکن برای اجرا',
                    style: TextStyle(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}