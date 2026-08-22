import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/storage/local_storage.dart';
import 'package:ma_app/features/manager/invoices/invoice_models.dart';
import 'package:ma_app/features/manager/invoices/invoice_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

InvoiceDraftModel _sample(String id) {
  return InvoiceDraftModel(
    id: id,
    number: 'فاکتور $id',
    seller: const InvoicePartyModel(name: 'فروشنده تست'),
    buyer: const InvoicePartyModel(name: 'خریدار تست'),
    items: const [InvoiceItemModel(description: 'قلم', quantity: 1, unitPrice: 100)],
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
  });

  setUp(() async {
    // پاک کردن کلیدها بین تست‌ها (بدون init مجدد)
    await (await SharedPreferences.getInstance()).clear();
  });

  final repo = InvoiceRepository();

  group('پروفایل فروشنده', () {
    test('ذخیره و بازیابی', () async {
      const seller = InvoicePartyModel(
        name: 'شرکت نمونه',
        phone: '۰۲۱۱',
        economicCode: '۵۵',
      );
      await repo.saveSellerProfile(seller);
      expect(repo.loadSellerProfile(), seller);
    });

    test('بدون پروفایل → مقدار خالی', () {
      expect(repo.loadSellerProfile(), const InvoicePartyModel());
    });
  });

  group('پیش‌نویس', () {
    test('ذخیره و بازیابی', () async {
      await repo.saveDraft(_sample('d1'));
      expect(repo.loadDraft(), _sample('d1'));
    });

    test('پاک‌سازی', () async {
      await repo.saveDraft(_sample('d1'));
      await repo.clearDraft();
      expect(repo.loadDraft(), isNull);
    });

    test('پیش‌نویس خالی بارگذاری نمی‌شود', () async {
      await repo.saveDraft(const InvoiceDraftModel());
      expect(repo.loadDraft(), isNull);
    });
  });

  group('تاریخچه', () {
    test('فاکتور جدید در ابتدای لیست', () async {
      await repo.saveToHistory(_sample('1'));
      await repo.saveToHistory(_sample('2'));
      final history = repo.loadHistory();
      expect(history.length, 2);
      expect(history.first.id, '2');
    });

    test('ذخیره تکراری با همان شناسه جایگزین می‌شود', () async {
      await repo.saveToHistory(_sample('1'));
      await repo.saveToHistory(_sample('1').copyWith(number: 'ویرایش شده'));
      final history = repo.loadHistory();
      expect(history.length, 1);
      expect(history.first.number, 'ویرایش شده');
    });

    test('سقف ۵۰ فاکتور', () async {
      for (var i = 0; i < 55; i++) {
        await repo.saveToHistory(_sample('$i'));
      }
      expect(repo.loadHistory().length, 50);
    });

    test('حذف از تاریخچه', () async {
      await repo.saveToHistory(_sample('1'));
      await repo.saveToHistory(_sample('2'));
      await repo.removeFromHistory('1');
      final history = repo.loadHistory();
      expect(history.length, 1);
      expect(history.first.id, '2');
    });
  });
}