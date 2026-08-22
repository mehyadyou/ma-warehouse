import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import '../models/scan_out_result_model.dart';
import '../providers/warehouse_keeper_provider.dart';
import '../../../core/network/api_error.dart';

const _bg      = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green   = Color(0xFF4ADE80);
const _red     = Color(0xFFEF4444);
const _orange  = Color(0xFFFB923C);

class ScanOutScreen extends ConsumerStatefulWidget {
  /// وقتی [orderId] داده شود، هر کارتن اسکن‌شده به همان سفارش متصل می‌شود
  /// (اولین خروج → سفارش SHIPPED) — اعتبارسنجی تطابق کالا/مدل سمت سرور انجام می‌شود
  /// وقتی [transferId] داده شود، هر کارتن اسکن‌شده برای همان دستور جابه‌جایی/خروج
  /// مدیر اجرا می‌شود (تا تکمیل سهمیه → دستور DONE)
  const ScanOutScreen({super.key, this.orderId, this.orderLabel, this.transferId, this.transferLabel});

  final String? orderId;
  final String? orderLabel;
  final String? transferId;
  final String? transferLabel;

  @override
  ConsumerState<ScanOutScreen> createState() => _ScanOutScreenState();
}

class _ScanOutScreenState extends ConsumerState<ScanOutScreen> {
  final _controller = MobileScannerController();

  bool _scanning   = true;
  bool _processing = false;
  _ScanResult? _lastResult;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || !raw.startsWith('MA|')) return;

    setState(() { _scanning = false; _processing = true; });

    try {
      final data = await ref
          .read(wkApiProvider)
          .scanOut(raw, orderId: widget.orderId, transferId: widget.transferId);
      if (mounted) {
        setState(() {
          _lastResult = _ScanResult(
            valid:    data.valid,
            message:  data.valid
                ? '${data.carton?.productName ?? ''} — ${data.carton?.modelName ?? ''}'
                : data.error,
            serial: data.carton?.serialNumber,
            isIndividual: data.valid
                ? data.carton?.isIndividualUnit ?? false
                : null,
            capacity: data.valid
                ? data.carton?.capacityPerBox
                : null,
            unit: data.valid
                ? data.carton?.unit
                : null,
            packageType: data.valid
                ? data.carton?.packageType
                : null,
            transfer: data.carton?.transfer,
          );
          _processing = false;
        });
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() { _scanning = true; _lastResult = null; });
        });
      }
    } on DioException catch (e) {
      final msg = friendlyError(e);
      if (mounted) {
        setState(() {
          _lastResult = _ScanResult(valid: false, message: msg);
          _processing = false;
        });
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() { _scanning = true; _lastResult = null; });
        });
      }
    }
  }

  // متد جدید برای اسکن سریال
  Future<void> _scanOutSerial(String value) async {
    if (value.trim().isEmpty || _processing) return;
    
    setState(() { 
      _scanning = false; 
      _processing = true; 
    });

    try {
      final result = await ref
          .read(wkApiProvider)
          .scanOutSerial(value.trim(), orderId: widget.orderId, transferId: widget.transferId);
      if (mounted) {
        setState(() {
          _lastResult = _ScanResult(
            valid: result.valid,
            message: result.valid
                ? '${result.carton?.productName ?? ''} — ${result.carton?.modelName ?? ''}'
                : result.error,
            serial: result.carton?.serialNumber,
            isIndividual: result.valid 
                ? result.carton?.isIndividualUnit ?? false 
                : null,
            capacity: result.valid 
                ? result.carton?.capacityPerBox 
                : null,
            unit: result.valid
                ? result.carton?.unit
                : null,
            packageType: result.valid
                ? result.carton?.packageType
                : null,
            transfer: result.carton?.transfer,
          );
          _processing = false;
        });
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() { 
            _scanning = true; 
            _lastResult = null; 
          });
        });
      }
    } on DioException catch (e) {
      final msg = friendlyError(e);
      if (mounted) {
        setState(() {
          _lastResult = _ScanResult(valid: false, message: msg);
          _processing = false;
        });
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() { 
            _scanning = true; 
            _lastResult = null; 
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: Text(
          widget.transferId != null
              ? 'اجرای دستور خروج/جابه‌جایی'
              : widget.orderId != null
              ? 'خروج برای سفارش'
              : 'اسکن خروج کالا',
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(children: [

        // نشانگر هدف — وقتی انباردار برای یک سفارش یا دستور خاص اسکن می‌کند
        if (widget.transferId != null || widget.orderId != null)
          Positioned(
            top: 16, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (widget.transferId != null ? _green : _orange).withOpacity(0.5),
                ),
              ),
              child: Row(children: [
                Icon(
                  widget.transferId != null
                      ? Icons.swap_horizontal_circle_rounded
                      : Icons.receipt_long_rounded,
                  color: widget.transferId != null ? _green : _orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.transferLabel ??
                        widget.orderLabel ??
                        'هدف #${(widget.transferId ?? widget.orderId)!.substring(0, 8)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
          ),

        // بالای صفحه - فیلد سریال دستی
        Positioned(
          top: (widget.transferId != null || widget.orderId != null) ? 76 : 16, left: 16, right: 16,
          child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _green.withOpacity(0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.qr_code_2_rounded, color: _green, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'یا سریال کالا را دستی وارد کنید...',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
            border: InputBorder.none,
            isDense: true,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onSubmitted: _scanOutSerial, // استفاده از متد جدید
        ),
      ),
    ]),
  ),
),

        MobileScanner(controller: _controller, onDetect: _onDetect),
        Center(
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: _lastResult == null
                    ? _green.withOpacity(0.8)
                    : _lastResult!.valid ? _green : _red,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        if (_lastResult != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _ResultCard(result: _lastResult!),
          ),
        if (_processing)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator(color: _green)),
          ),
        if (_lastResult == null && !_processing)
          Positioned(
            top: (widget.transferId != null || widget.orderId != null) ? 132 : 24, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text('QR کارتن را در مقابل دوربین قرار دهید', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),
      ]),
    );
  }
}

class _ScanResult {
  final bool    valid;
  final String  message;
  final String? serial;
  final bool?   isIndividual;
  final int?    capacity;
  final String? unit;
  final String? packageType;
  final ScanOutTransferModel? transfer;
  const _ScanResult({required this.valid, required this.message, this.serial, this.isIndividual, this.capacity, this.unit, this.packageType, this.transfer});
}

class _ResultCard extends StatelessWidget {
  final _ScanResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.valid ? _green : _red;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(result.valid ? Icons.check_circle_rounded : Icons.error_rounded, color: color, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              result.valid
                  ? (result.transfer != null ? 'اجرای دستور ثبت شد' : 'خروج ثبت شد')
                  : 'خطا',
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(result.message, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            if (result.valid && result.transfer != null && result.transfer!.toWarehouseName != null) ...[
              const SizedBox(height: 4),
              Text(
                'انتقال به ${result.transfer!.toWarehouseName}',
                style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
            if (result.valid && result.serial != null) ...[
              const SizedBox(height: 4),
              Text('سریال: ${result.serial}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
            if (result.valid && result.isIndividual != null) ...[
              const SizedBox(height: 4),
              Text(
                result.isIndividual! ? 'تکی' : '${result.packageType ?? 'کارتن'} — ${result.capacity} ${result.unit ?? 'عدد'}',
                style: TextStyle(color: result.isIndividual! ? _orange : _green, fontSize: 12),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}