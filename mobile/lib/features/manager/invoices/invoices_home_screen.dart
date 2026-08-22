import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/numbers.dart';
import '../data/manager_api_service.dart';
import '../providers/manager_api_provider.dart';
import 'invoice_builder_screen.dart';
import 'invoice_repository_provider.dart';
import 'invoices_cashbox_screen.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _amber = Color(0xFFFBBF24);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

/// صفحهٔ مقصد منوی «فاکتورها» — ورودی صندوق (تبدیل سفارش‌ها) و فاکتورساز
class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  late final _repo = ref.read(invoiceRepositoryProvider);
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);

  int _historyCount = 0;

  /// سفارش‌های تحویل‌شدهٔ آمادهٔ تبدیل؛ null = بارگذاری نشده/خطا
  int? _readyCount;

  @override
  void initState() {
    super.initState();
    _historyCount = _repo.loadHistory().length;
    _loadReadyCount();
  }

  Future<void> _loadReadyCount() async {
    try {
      final page = await _api.getOrders(
        page: 1,
        pageSize: 1,
        status: 'delivered',
      );
      final converted = _repo
          .loadHistory()
          .where((invoice) => (invoice.sourceOrderId ?? '').isNotEmpty)
          .length;
      final ready = (page.counts.total - converted).clamp(0, 1 << 31);
      if (!mounted) return;
      setState(() => _readyCount = ready);
    } catch (_) {
      // بدون اینترنت: شمارندهٔ صندوق پنهان می‌ماند؛ صندوق خودش خطا را نشان می‌دهد
      if (!mounted) return;
      setState(() => _readyCount = null);
    }
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
          'فاکتورها',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _green,
        backgroundColor: _surface,
        onRefresh: _loadReadyCount,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _statCard(label: 'فاکتور ساخته‌شده', value: _historyCount, color: _green)),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    label: 'سفارش آمادهٔ تبدیل',
                    value: _readyCount,
                    color: _amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _actionCard(
              icon: Icons.point_of_sale_rounded,
              title: 'صندوق',
              subtitle: 'تبدیل سفارش‌های تحویل‌شده به فاکتور',
              accent: _amber,
              trailing: _readyCount != null && _readyCount! > 0
                  ? _countChip('${formatNumber(_readyCount!)} سفارش', _amber)
                  : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InvoicesCashboxScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _actionCard(
              icon: Icons.receipt_long_rounded,
              title: 'ساخت فاکتور',
              subtitle: 'فاکتور جدید از صفر',
              accent: _green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InvoiceBuilderScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _green.withValues(alpha: 0.14),
            _surface,
            _surface,
          ],
        ),
        border: Border.all(color: _green.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _green.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: _green, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مدیریت فاکتورها',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سفارش‌های تحویل‌شده را به فاکتور تبدیل کنید یا فاکتور جدیدی بسازید',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required int? value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value == null ? '—' : formatNumber(value),
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: _textDim, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _textDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_left_rounded, color: _textDim, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}