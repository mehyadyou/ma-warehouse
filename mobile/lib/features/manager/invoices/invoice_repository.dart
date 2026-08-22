import 'dart:convert';

import '../../../core/storage/local_storage.dart';
import 'invoice_models.dart';

/// ذخیره‌سازی محلی فاکتورها: پروفایل فروشنده، پیش‌نویس و تاریخچه
class InvoiceRepository {
  static const _sellerKey = 'invoices_seller_profile';
  static const _draftKey = 'invoices_draft';
  static const _historyKey = 'invoices_history';

  // ─── پروفایل فروشنده (برای پیش‌پر کردن فاکتورهای بعدی) ───
  Future<void> saveSellerProfile(InvoicePartyModel seller) async {
    await LocalStorage.saveRaw(
      _sellerKey,
      jsonEncode(seller.toJson()),
    );
  }

  InvoicePartyModel loadSellerProfile() {
    final raw = LocalStorage.getRaw(_sellerKey);
    if (raw == null || raw.isEmpty) return const InvoicePartyModel();
    try {
      return InvoicePartyModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const InvoicePartyModel();
    }
  }

  // ─── پیش‌نویس ───
  Future<void> saveDraft(InvoiceDraftModel draft) async {
    await LocalStorage.saveRaw(_draftKey, jsonEncode(draft.toJson()));
  }

  InvoiceDraftModel? loadDraft() {
    final raw = LocalStorage.getRaw(_draftKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final draft = InvoiceDraftModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (draft.isEmpty) return null;
      return draft;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft() async {
    await LocalStorage.removeRaw(_draftKey);
  }

  // ─── تاریخچه ───
  Future<void> saveToHistory(InvoiceDraftModel invoice) async {
    final history = loadHistory();
    history.removeWhere((item) => item.id == invoice.id);
    history.insert(0, invoice);
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    await LocalStorage.saveRaw(
      _historyKey,
      jsonEncode(history.map((item) => item.toJson()).toList()),
    );
  }

  List<InvoiceDraftModel> loadHistory() {
    final raw = LocalStorage.getRaw(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => InvoiceDraftModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> removeFromHistory(String id) async {
    final history = loadHistory()..removeWhere((item) => item.id == id);
    await LocalStorage.saveRaw(
      _historyKey,
      jsonEncode(history.map((item) => item.toJson()).toList()),
    );
  }
}