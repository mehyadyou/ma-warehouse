import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_error.dart';
import '../../core/storage/local_storage.dart';
import '../warehouse_keeper/data/warehouse_keeper_api_service.dart';
import '../warehouse_keeper/providers/warehouse_keeper_provider.dart';

/// نوع عملیات انبار که می‌تواند آفلاین در صف بماند.
/// فقط عملیات «ثبت» (idempotent با clientKey) صف می‌شوند — خواندن‌ها هرگز.
enum PendingOpType {
  scanOutQr('scanout'),
  scanOutSerial('scanout-serial'),
  manualExit('manual'),
  checkin('checkin');

  const PendingOpType(this.value);
  final String value;

  static PendingOpType fromValue(String v) => PendingOpType.values.firstWhere(
        (e) => e.value == v,
        orElse: () => PendingOpType.scanOutQr,
      );
}

/// یک عملیات ثبت‌شده در صف آفلاین.
/// [key] همان clientKey ایدمپوتنسی است: در همه تلاش‌ها (اولین ارسال، تلاش
/// مجدد دستی، فلاش خودکار) ثابت می‌ماند تا سرور دوبار ثبت نکند.
class PendingOp {
  PendingOp({
    required this.key,
    required this.type,
    required this.payload,
    required this.createdAt,
    required this.label,
  });

  final String key;
  final PendingOpType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final String label;

  Map<String, dynamic> toJson() => {
        'key': key,
        'type': type.value,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'label': label,
      };

  factory PendingOp.fromJson(Map<String, dynamic> j) => PendingOp(
        key: j['key'] as String,
        type: PendingOpType.fromValue(j['type'] as String? ?? ''),
        payload: Map<String, dynamic>.from(j['payload'] as Map? ?? {}),
        createdAt:
            DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        label: j['label'] as String? ?? '',
      );
}

final pendingOpsProvider =
    NotifierProvider<PendingOpsNotifier, List<PendingOp>>(
  PendingOpsNotifier.new,
);

/// صف آفلاین عملیات ثبت انبار — ذخیره‌سازی در SharedPreferences (بدون وابستگی
/// جدید)، فلاش با همان clientKey (ایدمپوتنت سمت سرور).
class PendingOpsNotifier extends Notifier<List<PendingOp>> {
  static const _storageKey = 'pending_ops_v1';
  static const _maxOps = 500;

  @override
  List<PendingOp> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final raw = LocalStorage.getRaw(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((m) => PendingOp.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      if (ref.mounted) state = list;
    } catch (_) {
      // خرابی کش صف هرگز اپ را خراب نمی‌کند
    }
  }

  Future<void> _persist() async {
    try {
      await LocalStorage.saveRaw(
        _storageKey,
        jsonEncode(state.map((o) => o.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// افزودن به صف (تکراریِ همان کلید نادیده گرفته می‌شود؛ پر بودن → قدیمی‌ترین حذف)
  Future<void> enqueue(PendingOp op) async {
    if (state.any((o) => o.key == op.key)) return;
    final next = List<PendingOp>.of(state);
    if (next.length >= _maxOps) next.removeAt(0);
    next.add(op);
    state = next;
    await _persist();
  }

  Future<void> remove(String key) async {
    state = state.where((o) => o.key != key).toList();
    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    await _persist();
  }

  /// نتیجه فلاش: تعداد موفق / ناموفق / خطای غیرشبکه‌ای (نیازمند بررسی دستی)
  Future<({int sent, int failed, List<String> errors})> flush() async {
    final api = ref.read(wkApiProvider);
    var sent = 0;
    var failed = 0;
    final errors = <String>[];
    // روی کپی کار می‌کنیم چون state حین فلاش عوض می‌شود
    for (final op in List<PendingOp>.of(state)) {
      try {
        await _send(api, op);
        await remove(op.key);
        sent++;
      } catch (e) {
        failed++;
        // خطای غیرشبکه‌ای (مثل مغایرت سفارش) → از صف خارج و به کاربر گزارش می‌شود
        // تا صف روی عملیات خراب قفل نکند
        if (!isNetworkError(e)) {
          await remove(op.key);
          errors.add('${op.label}: ${_shortError(e)}');
        } else {
          // هنوز آفلاین — بقیه هم احتمالاً شکست می‌خورند؛ توقف
          break;
        }
      }
    }
    return (sent: sent, failed: failed, errors: errors);
  }

  Future<void> _send(WarehouseKeeperApiService api, PendingOp op) async {
    final p = op.payload;
    switch (op.type) {
      case PendingOpType.scanOutQr:
        await api.scanOut(
          p['qrPayload'] as String,
          orderId: p['orderId'] as String?,
          transferId: p['transferId'] as String?,
          clientKey: op.key,
        );
      case PendingOpType.scanOutSerial:
        await api.scanOutSerial(
          p['serialNumber'] as String,
          orderId: p['orderId'] as String?,
          transferId: p['transferId'] as String?,
          clientKey: op.key,
        );
      case PendingOpType.manualExit:
        await api.manualExit(
          productId: p['productId'] as String,
          modelId: p['modelId'] as String?,
          quantity: (p['quantity'] as num).toInt(),
          driverId: p['driverId'] as String?,
          orderId: p['orderId'] as String?,
          transferId: p['transferId'] as String?,
          clientKey: op.key,
        );
      case PendingOpType.checkin:
        await api.submitCheckin(
          (p['items'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
          clientKey: op.key,
        );
    }
  }

  String _shortError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        return (data['error'] as String).split('\n').first;
      }
      return 'خطای سرور (${e.response?.statusCode ?? '؟'})';
    }
    return e.toString().split('\n').first;
  }
}
