import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/numbers.dart';
import 'invoice_models.dart';
import 'invoice_preview_screen.dart';
import 'invoice_repository_provider.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _red = Color(0xFFF87171);
const _textDim = Color(0xFF8A8F98);

/// لیست فاکتورهای ساخته‌شده (تاریخچه محلی)
class InvoicesHistoryScreen extends ConsumerStatefulWidget {
  const InvoicesHistoryScreen({super.key});

  @override
  ConsumerState<InvoicesHistoryScreen> createState() =>
      _InvoicesHistoryScreenState();
}

class _InvoicesHistoryScreenState extends ConsumerState<InvoicesHistoryScreen> {
  late final _repo = ref.read(invoiceRepositoryProvider);
  late List<InvoiceDraftModel> _history;

  @override
  void initState() {
    super.initState();
    _history = _repo.loadHistory();
  }

  Future<void> _remove(InvoiceDraftModel invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text(
          'حذف فاکتور',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Text(
          'فاکتور «${invoice.number}» از تاریخچه حذف شود؟',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repo.removeFromHistory(invoice.id);
    if (!mounted) return;
    setState(() => _history = _repo.loadHistory());
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
          'فاکتورهای قبلی',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 52, color: Color(0x33FFFFFF)),
                  const SizedBox(height: 14),
                  Text(
                    'هنوز فاکتوری ساخته نشده است',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final invoice = _history[index];
                return Material(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoicePreviewScreen(
                          draft: invoice,
                          isNew: false,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              color: _green,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'فاکتور ${invoice.number}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${invoice.buyer.name} — ${invoice.dateLabel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _textDim,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${formatNumber(invoice.grandTotal)} تومان',
                                style: const TextStyle(
                                  color: _green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _remove(invoice),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: _red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}