import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/manager_api_service.dart';
import '../../providers/manager_api_provider.dart';
import '../../models/carton_search_model.dart';
import '../../models/order_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _blue = Color(0xFF60A5FA);
const _border = Color(0xFF2A2D33);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);

  // سریال
  final _serialCtrl = TextEditingController();
  Timer? _debounce;
  bool _serialLoading = false;
  CartonSearchModel? _serialResult;  String? _serialError;

  // ارسالی‌ها
  final _senderCtrl = TextEditingController();
  final _receiverCtrl = TextEditingController();
  final _productCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  bool _showShipmentForm = false;
  bool _shipmentsLoading = false;
  List<OrderModel>? _shipments;
  String? _shipmentsError;

  @override
  void dispose() {
    _debounce?.cancel();
    _serialCtrl.dispose();
    _senderCtrl.dispose();
    _receiverCtrl.dispose();
    _productCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  void _onSerialChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _serialResult = null;
        _serialError = null;
        _serialLoading = false;
      });
      return;
    }
    setState(() => _serialLoading = true);
    _debounce = Timer(const Duration(milliseconds: 600), () => _searchSerial(query));
  }

  Future<void> _searchSerial(String query) async {
    try {
      final result = await _api.searchBySerial(query);
      if (!mounted) return;
      setState(() {
        _serialLoading = false;
        _serialResult = result;
        _serialError = result == null ? 'کارتنی با این سریال یافت نشد' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serialLoading = false;
        _serialResult = null;
        _serialError = 'خطا در جستجو';
      });
    }
  }

  Future<void> _searchShipments() async {
    final sender = _senderCtrl.text.trim();
    final receiver = _receiverCtrl.text.trim();
    final product = _productCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    if (sender.isEmpty && receiver.isEmpty && product.isEmpty && model.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _shipmentsLoading = true;
      _shipmentsError = null;
    });
    try {
      final orders = await _api.searchShipments(sender: sender, receiver: receiver, product: product, model: model);
      if (!mounted) return;
      setState(() {
        _shipmentsLoading = false;
        _shipments = orders;
        if (orders.isEmpty) _shipmentsError = 'ارسالی‌ای مطابق این مشخصات یافت نشد';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _shipmentsLoading = false;
        _shipmentsError = 'خطا در جستجو';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('جستجو', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _serialCard(),
          const SizedBox(height: 20),
          _shipmentHeader(),
          if (_showShipmentForm) ...[
            const SizedBox(height: 12),
            _shipmentForm(),
          ],
          const SizedBox(height: 12),
          ..._results(),
        ],
      ),
    );
  }

  // ═══════════ جستجوی سریال ═══════════

  Widget _serialCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.qr_code_2_rounded, color: _green, size: 20),
            SizedBox(width: 8),
            Text('جستجو با سریال کالا', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          TextField(
            controller: _serialCtrl,
            onChanged: _onSerialChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'سریال کالا یا کد QR را وارد کنید...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: _green),
              suffixIcon: _serialLoading
                  ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _green)))
                  : (_serialCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20), onPressed: () { _serialCtrl.clear(); _onSerialChanged(''); })
                      : null),
              filled: true,
              fillColor: _surfaceAlt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _green)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════ جستجوی ارسالی‌ها ═══════════

  Widget _shipmentHeader() {
    return GestureDetector(
      onTap: () => setState(() => _showShipmentForm = !_showShipmentForm),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.local_shipping_rounded, color: _blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('جستجوی ارسالی‌ها', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 3),
                Text('فرستنده، گیرنده، نام و مدل کالا — مشاهده مرحله ارسال', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ]),
            ),
            Icon(_showShipmentForm ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _shipmentForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(
        children: [
          _shipmentField(_senderCtrl, 'فرستنده', 'نام فرستنده را وارد کنید', Icons.person_rounded),
          const SizedBox(height: 10),
          _shipmentField(_receiverCtrl, 'گیرنده', 'نام گیرنده را وارد کنید', Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _shipmentField(_productCtrl, 'نام کالا', 'نام کالا را وارد کنید', Icons.inventory_2_rounded),
          const SizedBox(height: 10),
          _shipmentField(_modelCtrl, 'مدل کالا', 'مدل کالا را وارد کنید', Icons.category_rounded),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _shipmentsLoading ? null : _searchShipments,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _shipmentsLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                  : const Text('جستجوی ارسال', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shipmentField(TextEditingController controller, String label, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: _blue, size: 20),
        filled: true,
        fillColor: _surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _blue)),
      ),
    );
  }

  // ═══════════ نتایج ═══════════

  List<Widget> _results() {
    if (_serialLoading) {
      return const [Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: _green)))];
    }
    if (_serialError != null && _serialResult == null) {
      return [
        _emptyState(Icons.qr_code_2_rounded, _serialError!),
        const SizedBox(height: 16),
        if (_shipmentsLoading) const Center(child: CircularProgressIndicator(color: _blue)),
        if (_shipmentsError != null && (_shipments?.isEmpty ?? true)) _emptyState(Icons.local_shipping_rounded, _shipmentsError!),
        if (_shipments != null) ..._shipmentCards(),
      ];
    }
    return [
      if (_serialResult != null) _serialResultCard(_serialResult!),
      const SizedBox(height: 16),
      if (_shipmentsLoading) const Center(child: CircularProgressIndicator(color: _blue)),
      if (_shipmentsError != null && (_shipments?.isEmpty ?? true)) _emptyState(Icons.local_shipping_rounded, _shipmentsError!),
      if (_shipments != null) ..._shipmentCards(),
    ];
  }

  Widget _emptyState(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: Column(children: [
        Icon(icon, size: 44, color: Colors.white.withValues(alpha: 0.15)),
        const SizedBox(height: 10),
        Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
      ]),
    );
  }

  // ─── نتیجه سریال ───

  Widget _serialResultCard(CartonSearchModel c) {
    final status = c.cartonStatus ?? '';
    final orderStatus = c.orderStatus;
    final delivered = orderStatus == 'DELIVERED';

    final (stageLabel, stageColor, stageIcon) = switch (status) {
      'IN_STOCK' => ('در انبار', _green, Icons.inventory_2_rounded),
      'SHIPPED' when delivered => ('تحویل شده', _green, Icons.verified_rounded),
      'SHIPPED' => ('در مسیر ارسال', _amber, Icons.local_shipping_rounded),
      _ => (status, _amber, Icons.help_rounded),
    };

    final hasOrder = c.orderId != null;
    final relatedOrders = c.relatedOrders;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text('${c.productName ?? '—'}${c.modelName != null ? ' (${c.modelName})' : ''}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            _stageChip(stageLabel, stageColor),
          ]),
          const SizedBox(height: 12),

          // ─── انبار فعلی ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: stageColor.withValues(alpha: 0.3))),
            child: Row(children: [
              Icon(stageIcon, color: stageColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('این کالا در انبار «${c.warehouseName ?? '—'}» است', style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              _stageChip(stageLabel, stageColor),
            ]),
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.flag_rounded, 'مرحله', _stageDetail(c)),
          const SizedBox(height: 6),
          _infoRow(Icons.qr_code_rounded, 'سریال', c.serialNumber ?? c.qrUuid ?? '—'),
          const SizedBox(height: 6),
          _infoRow(Icons.calendar_today_rounded, 'تاریخ ورود', _formatDate(c.createdAt)),
          if (c.scannedOutAt != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.exit_to_app_rounded, 'تاریخ خروج', _formatDate(c.scannedOutAt)),
          ],

          const Divider(color: _border, height: 28),

          // ─── وضعیت سفارش ───
          if (hasOrder) ...[
            Row(children: [
              const Icon(Icons.check_circle_rounded, color: _green, size: 18),
              const SizedBox(width: 8),
              const Text('سفارش برای این کالا ثبت شده است', style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              _stageChip(_orderStatusLabel(orderStatus), _orderStatusColor(orderStatus)),
            ]),
            const SizedBox(height: 10),
            _infoRow(Icons.person_rounded, 'فرستنده', c.senderName ?? '—'),
            const SizedBox(height: 6),
            _infoRow(Icons.person_outline_rounded, 'گیرنده', c.receiverName ?? '—'),
            if (c.city != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.location_city_rounded, 'شهر', c.city),
            ],
            if (c.driverName != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.delivery_dining_rounded, 'راننده', c.driverName),
            ],
            if (c.deliveredAt != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.event_available_rounded, 'تاریخ تحویل', _formatDate(c.deliveredAt)),
            ],
          ] else ...[
            Row(children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white38, size: 18),
              const SizedBox(width: 8),
              const Text('سفارشی برای این کارتن ثبت نشده است', style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
            ]),
            if (relatedOrders.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('سفارش‌های ثبت‌شده برای این کالا:', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
              const SizedBox(height: 6),
              ...relatedOrders.map((r) => _relatedOrderTile(r)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _relatedOrderTile(RelatedOrderModel r) {
    final order = r.order;
    final status = order.status ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: _surfaceAlt, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.receipt_long_rounded, color: _blue, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${order.senderName ?? '—'} ← ${order.receiverName ?? '—'}', style: const TextStyle(color: Colors.white, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text('تعداد: ${r.quantity.toInt()} — ${_formatDate(order.createdAt)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
          ]),
        ),
        _stageChip(_orderStatusLabel(status), _orderStatusColor(status)),
      ]),
    );
  }

  String _orderStatusLabel(String? status) {
    return switch (status) {
      'DELIVERED' => 'تحویل شده',
      'SHIPPED' => 'در مسیر ارسال',
      _ => 'آماده ارسال',
    };
  }

  Color _orderStatusColor(String? status) {
    return switch (status) {
      'DELIVERED' => _green,
      'SHIPPED' => _amber,
      _ => _blue,
    };
  }

  String _stageDetail(CartonSearchModel c) {
    final status = c.cartonStatus ?? '';
    final orderStatus = c.orderStatus;
    if (status == 'IN_STOCK') return 'کالا در انبار موجود است';
    if (orderStatus == 'DELIVERED') return 'کالا به مقصد تحویل داده شده است';
    return 'کالا از انبار خارج شده و در مسیر ارسال است';
  }

  // ─── نتیجه ارسالی‌ها ───

  List<Widget> _shipmentCards() {
    final orders = _shipments ?? [];
    return orders.map((o) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _shipmentCard(o),
    )).toList();
  }

  Widget _shipmentCard(OrderModel o) {
    final status = o.status ?? '';
    final (stageLabel, stageColor, stageIcon) = switch (status) {
      'DELIVERED' => ('تحویل شده', _green, Icons.verified_rounded),
      'SHIPPED' => ('در مسیر ارسال', _amber, Icons.local_shipping_rounded),
      _ => ('آماده ارسال — در انبار', _blue, Icons.pending_actions_rounded),
    };

    final items = o.items;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text('${o.senderName ?? '—'} ← ${o.receiverName ?? '—'}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
            _stageChip(stageLabel, stageColor),
          ]),
          const SizedBox(height: 10),
          _stageTimeline(status, o),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on_rounded, 'انبار مبدا', o.warehouseName ?? '—'),
          if (o.city != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.location_city_rounded, 'شهر مقصد', o.city),
          ],
          if (o.carrier != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.local_shipping_rounded, 'باربری', o.carrier),
          ],
          if (o.driverName != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.delivery_dining_rounded, 'راننده', o.driverName),
          ],
          if (o.deliveredAt != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.event_available_rounded, 'تاریخ تحویل', _formatDate(o.deliveredAt)),
          ],
          if (items.isNotEmpty) ...[
            const Divider(color: _border, height: 24),
            ...items.map((it) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.inventory_2_rounded, color: _green, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('${it.productName ?? '—'}${it.model != null ? ' (${it.model})' : ''}', style: const TextStyle(color: Colors.white, fontSize: 13))),
                Text('تعداد: ${it.quantity.toInt()}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              ]),
            )),
          ],
          const SizedBox(height: 8),
          Text('ثبت: ${_formatDate(o.createdAt)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _stageTimeline(String status, OrderModel o) {
    final delivered = status == 'DELIVERED';
    final shipped = delivered || status == 'SHIPPED';
    final deliveredAt = o.deliveredAt;

    return Row(children: [
      _timelineDot('در انبار مبدا', true, _green),
      Expanded(child: Container(height: 2, color: shipped ? _green : _border)),
      _timelineDot('در مسیر ارسال', shipped, _amber),
      Expanded(child: Container(height: 2, color: delivered ? _green : _border)),
      _timelineDot(delivered ? 'تحویل شده' : (deliveredAt != null ? 'تحویل شده' : 'تحویل نشده'), delivered, _green),
    ]);
  }

  Widget _timelineDot(String label, bool active, Color color) {
    return Expanded(
      child: Column(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? color : _border)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? color : Colors.white.withValues(alpha: 0.3), fontSize: 10)),
      ]),
    );
  }

  Widget _stageChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.35)),
      const SizedBox(width: 8),
      SizedBox(width: 78, child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12))),
      Expanded(child: Text(value ?? '', style: const TextStyle(color: Colors.white, fontSize: 12.5))),
    ]);
  }

  String _formatDate(dynamic value) {
    if (value == null) return '—';
    final date = DateTime.parse(value.toString()).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}/${two(date.month)}/${two(date.day)} - ${two(date.hour)}:${two(date.minute)}';
  }
}
