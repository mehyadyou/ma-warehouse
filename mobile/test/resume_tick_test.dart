import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_app/core/refresh/resume_tick.dart';

void main() {
  test('مقدار اولیه صفر است', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(resumeTickProvider), 0);
  });

  test('bump هر بار یک واحد اضافه می‌کند', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(resumeTickProvider.notifier).bump();
    container.read(resumeTickProvider.notifier).bump();
    expect(container.read(resumeTickProvider), 2);
  });

  test('شنونده روی bump بیدار می‌شود', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var calls = 0;
    container.listen<int>(resumeTickProvider, (_, __) => calls++);
    container.read(resumeTickProvider.notifier).bump();
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
  });
}
