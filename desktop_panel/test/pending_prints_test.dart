import 'package:flutter_test/flutter_test.dart';
import 'package:ma_warehouse_panel/core/pending_prints.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('صف خالی شروع می‌شود', () async {
    expect(await PendingPrints.count(), 0);
  });

  test('enqueue دسته‌ها را نگه می‌دارد و می‌شمارد', () async {
    expect(await PendingPrints.enqueue(['c1', 'c2']), 1);
    expect(await PendingPrints.enqueue(['c3']), 2);
    expect(await PendingPrints.count(), 2);
  });

  test('flush قدیمی‌ترین اول موفق‌ها را رد می‌کند و روی خطا می‌ایستد', () async {
    await PendingPrints.enqueue(['c1']);
    await PendingPrints.enqueue(['c2']);
    await PendingPrints.enqueue(['c3']);

    final marked = <String>[];
    final left = await PendingPrints.flush((ids) async {
      if (ids.first == 'c2') throw Exception('boom');
      marked.addAll(ids);
    });

    expect(marked, ['c1']);
    expect(left, 2);
    expect(await PendingPrints.count(), 2);
  });

  test('flush کامل صف را خالی می‌کند', () async {
    await PendingPrints.enqueue(['c1']);
    final left = await PendingPrints.flush((_) async {});
    expect(left, 0);
    expect(await PendingPrints.count(), 0);
  });

  test('داده خراب نادیده گرفته می‌شود (کرش نه)', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_print_batches_v1', 'not-json{{{');
    expect(await PendingPrints.count(), 0);
    expect(await PendingPrints.load(), isEmpty);
  });
}
