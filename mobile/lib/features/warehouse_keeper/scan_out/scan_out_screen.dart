import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import '../models/keeper_driver_model.dart';
import '../models/scan_out_result_model.dart';
import '../providers/warehouse_keeper_provider.dart';
import 'target_picker_sheet.dart';
import '../../../core/network/api_error.dart';

const _bg      = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
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

  /// تخصیصِ انجام‌شده در همین نشست — تا برای کارتن‌های بعدیِ همان سفارش دوباره پرسیده نشود
  String? _assignedOrderId;
  String? _assignedDriverName;

  /// کدی (QR/سریال) که همین الان پردازش شده — تا وقتی دوربین هنوز همان کد را می‌بیند،
  /// اسکنِ تکراریِ همان کد (بعد از خطا/موفقیت یا بستن پیکر) دوباره اجرا نشود
  String? _lastHandledCode;
  DateTime? _lastHandledAt;

  /// آیا این کد همان کدی است که چند لحظه قبل پردازش شده؟ (جلوگیری از چرخهٔ
  /// «خطا → پاپ‌آپ گزینه‌ها» وقتی همان QR جلوی دوربین مانده)
  bool _isHandledRecently(String? raw, String? serial) {
    final code = raw ?? serial;
    final at = _lastHandledAt;
    if (code == null || _lastHandledCode == null || code != _lastHandledCode || at == null) {
      return false;
    }
    return DateTime.now().difference(at) < const Duration(seconds: 4);
  }

  void _markHandled(String? code) {
    if (code == null) return;
    _lastHandledCode = code;
    _lastHandledAt = DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || !raw.startsWith('MA|')) return;
    if (_isHandledRecently(raw, null)) return;
    await _processScan(raw, null);
  }

  /// اسکن سریال دستی (فیلد بالای صفحه)
  Future<void> _scanOutSerial(String value) async {
    if (value.trim().isEmpty || _processing) return;
    if (_isHandledRecently(null, value.trim())) return;
    await _processScan(null, value.trim());
  }

  /// مسیر مشترک اسکن (QR یا سریال): درخواست خروج + نمایش نتیجه.
  /// وقتی سرور چند هدف فعال برمی‌گرداند (candidates)، برگهٔ انتخاب هدف باز می‌شود
  /// و همان اسکن با هدفِ انتخاب‌شده دوباره ارسال می‌شود.
  Future<void> _processScan(String? raw, String? serial, {ScanOutTargetModel? target}) async {
    _markHandled(raw ?? serial);
    setState(() { _scanning = false; _processing = true; });
    try {
      final data = await (serial != null
          ? ref.read(wkApiProvider).scanOutSerial(
              serial,
              orderId: target?.kind == 'order' ? target!.id : widget.orderId,
              transferId: target?.kind == 'transfer' ? target!.id : widget.transferId,
            )
          : ref.read(wkApiProvider).scanOut(
              raw!,
              orderId: target?.kind == 'order' ? target!.id : widget.orderId,
              transferId: target?.kind == 'transfer' ? target!.id : widget.transferId,
            ));
      // پنجرهٔ نادیده‌گیری از لحظهٔ نتیجه هم تازه شود تا دوربین همان کد را
      // بعد از از سرگیری خودکار دوباره اسکن نکند
      _markHandled(raw ?? serial);
      _handleScanResult(data);
    } on DioException catch (e) {
      await _handleScanError(e, raw, serial);
    }
  }

  /// خطای اسکن: اگر سرور لیست هدف‌های ممکن (candidates) را داده، مستقیم برگهٔ انتخاب
  /// باز می‌شود (بدون نمایش کارت خطا)؛ در غیر این صورت کارت خطا + از سرگیری خودکار اسکن.
  Future<void> _handleScanError(DioException e, String? raw, String? serial) async {
    if (!mounted) return;
    final body = e.response?.data;
    final rawCandidates = (body is Map && body['candidates'] is List)
        ? (body['candidates'] as List)
            .whereType<Map>()
            .map((m) => ScanOutTargetModel.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : <ScanOutTargetModel>[];

    if (rawCandidates.isNotEmpty) {
      // چند هدف فعال — بدون فلش خطا، فقط پیکر «کدام هدف؟» باز می‌شود تا انباردار انتخاب کند
      setState(() {
        _lastResult = null;
        _processing = false;
      });
      String productLabel = '';
      final transfer = rawCandidates.where((c) => c.kind == 'transfer').firstOrNull;
      if (transfer != null) {
        final modelName = transfer.modelName;
        productLabel = [
          if (transfer.productName.isNotEmpty) transfer.productName,
          if ((modelName ?? '').isNotEmpty) '($modelName)',
        ].join(' ');
      }
      final picked = await showModalBottomSheet<ScanOutTargetModel>(
        context: context,
        backgroundColor: _surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => TargetPickerSheet(
          candidates: rawCandidates,
          productLabel: productLabel.isNotEmpty ? productLabel : 'این کالا',
        ),
      );
      if (!mounted) return;
      if (picked != null) {
        await _processScan(raw, serial, target: picked);
        return;
      }
      // انصراف — همان کد هنوز جلوی دوربین است؛ تا چند لحظه نادیده گرفته شود تا
      // پیکر با همان QRِ تکراری بلافاصله دوباره باز نشود
      _markHandled(raw ?? serial);
      setState(() { _scanning = true; _lastResult = null; });
      return;
    }

    setState(() {
      _lastResult = _ScanResult(valid: false, message: friendlyError(e));
      _processing = false;
    });
    // خطاهای عادی (مثل «قبلاً خروج داده شده») هم پنجرهٔ نادیده‌گیری را تازه می‌کنند
    // تا وقتی کارتن از جلوی دوربین برداشته می‌شود، همان کد دوباره اجرا نشود
    _markHandled(raw ?? serial);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() { _scanning = true; _lastResult = null; });
    });
  }

  /// نمایش نتیجهٔ اسکن/سریال + در صورت اتصال به سفارش، پیشنهاد انتخاب راننده
  void _handleScanResult(ScanOutResultModel data) {
    if (!mounted) return;
    final order = data.carton?.order;
    setState(() {
      _lastResult = _ScanResult(
        valid: data.valid,
        message: data.valid
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
        orderId: data.valid && order != null ? order.id : null,
        orderNumber: data.valid ? order?.orderNumber : null,
        driver: data.valid ? data.carton?.driver : null,
      );
      _processing = false;
    });

    // خروجِ مطابق سفارش (نه دستور جابه‌جایی) → گزینهٔ انتخاب راننده روی صفحه ظاهر می‌شود
    if (data.valid && order != null && data.carton?.transfer == null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _showDriverSheet(order.id, order.orderNumber);
      });
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() { _scanning = true; _lastResult = null; });
    });
  }

  /// برگهٔ انتخاب راننده — فقط رانندگانی که انباردار برای انبارش تیک زده
  Future<void> _showDriverSheet(String orderId, int? orderNumber) async {
    // اگر همین نشست راننده برای این سفارش انتخاب شده بود، دوباره نپرس
    if (_assignedOrderId == orderId && _assignedDriverName != null) return;

    final orderLabel = orderNumber != null ? 'سفارش شماره $orderNumber' : 'این بار';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _DriverPickerSheet(
        orderLabel: orderLabel,
        onPick: (driver) => _assignDriver(sheetContext, orderId, orderLabel, driver),
      ),
    );
  }

  Future<void> _assignDriver(
    BuildContext sheetContext,
    String orderId,
    String orderLabel,
    KeeperDriverModel driver,
  ) async {
    try {
      await ref.read(wkApiProvider).assignDriverToOrder(orderId, driver.id);
      if (!mounted) return;
      setState(() {
        _assignedOrderId = orderId;
        _assignedDriverName = driver.name;
      });
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('$orderLabel به راننده ${driver.name} تخصیص یافت',
                  style: const TextStyle(color: Colors.white)),
            ),
          ]),
          backgroundColor: _green.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در تخصیص بار: ${friendlyError(e)}'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverName = _lastResult == null
        ? null
        : ((_lastResult!.driver?.name.isNotEmpty ?? false)
            ? _lastResult!.driver!.name
            : (_assignedOrderId != null &&
                    _assignedOrderId == _lastResult!.orderId)
                ? _assignedDriverName
                : null);

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
                  onSubmitted: _scanOutSerial,
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
            child: _ResultCard(result: _lastResult!, driverName: driverName),
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
  final String? orderId;
  final int?    orderNumber;
  final ScanOutDriverModel? driver;
  const _ScanResult({
    required this.valid,
    required this.message,
    this.serial,
    this.isIndividual,
    this.capacity,
    this.unit,
    this.packageType,
    this.transfer,
    this.orderId,
    this.orderNumber,
    this.driver,
  });
}

class _ResultCard extends StatelessWidget {
  final _ScanResult result;
  final String? driverName;
  const _ResultCard({required this.result, this.driverName});

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
            // راننده‌ای که این بار برایش تعریف شده
            if (result.valid && driverName != null && driverName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.local_shipping_rounded, color: _green, size: 15),
                const SizedBox(width: 6),
                Text('راننده: $driverName',
                    style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// برگهٔ انتخاب راننده — لیست رانندگانی که انباردار تیک زده (متصل به همین انبار)
class _DriverPickerSheet extends ConsumerStatefulWidget {
  final String orderLabel;
  final void Function(KeeperDriverModel driver) onPick;
  const _DriverPickerSheet({required this.orderLabel, required this.onPick});

  @override
  ConsumerState<_DriverPickerSheet> createState() => _DriverPickerSheetState();
}

class _DriverPickerSheetState extends ConsumerState<_DriverPickerSheet> {
  late final Future<List<KeeperDriverModel>> _driversFuture;

  @override
  void initState() {
    super.initState();
    // همیشه تازه — ممکن است انباردار همین الان راننده‌ای را تیک زده باشد
    ref.invalidate(driversProvider);
    _driversFuture = ref.read(driversProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: _green, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('انتخاب راننده',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(widget.orderLabel,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Flexible(
              child: FutureBuilder<List<KeeperDriverModel>>(
                future: _driversFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator(color: _green)),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('خطا در دریافت رانندگان',
                            style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ),
                    );
                  }
                  // فقط رانندگانی که انباردار برای انبار خودش تیک زده
                  final drivers = (snap.data ?? [])
                      .where((d) => d.assignedToMe && !d.assignedToOther)
                      .toList();
                  if (drivers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(children: [
                        Icon(Icons.person_off_rounded, size: 40, color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 10),
                        const Text('هنوز راننده‌ای تیک نخورده',
                            style: TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('از منوی «مدیریت رانندگان» یک راننده انتخاب کنید',
                            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
                      ]),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: drivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final d = drivers[i];
                      return Material(
                        color: _surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => widget.onPick(d),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: _green.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    d.name.isEmpty ? '؟' : String.fromCharCode(d.name.runes.first),
                                    style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(d.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                  if (d.phone.isNotEmpty)
                                    Text(d.phone,
                                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                                ]),
                              ),
                              const Icon(Icons.check_circle_outline_rounded, color: _green, size: 20),
                            ]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}