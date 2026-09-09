import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';


/// تب مشتریان — جستجو + جدول صفحه‌بندی + جزئیات کامل هر مشتری
class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key, required this.api, required this.refreshTick});

  final CrmApiService api;
  final int refreshTick;

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final _searchController = TextEditingController();

  List<dynamic> _rows = [];
  int _total = 0;
  int _page = 1;
  static const int _pageSize = 20;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });
    try {
      final res = await widget.api.getCustomers(
        q: _searchController.text,
        page: _page,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _rows = res['customers'] as List<dynamic>;
        _total = res['total'] as int;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = (_total / _pageSize).ceil().clamp(1, 1000000);
    return CrmPage(
      title: 'مشتریان',
      subtitle: 'گروه‌بندی بر اساس شماره موبایل — $_total مشتری',
      onRefresh: () => _load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 320,
                child: AppTextField(
                  controller: _searchController,
                  label: 'جستجو (شماره، نام، شهر)',
                  hint: 'مثلاً 0912 یا تهران',
                  keyboardType: TextInputType.text,
                  onSubmitted: (_) => _load(page: 1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: AppButton(label: 'جستجو', onPressed: () => _load(page: 1), small: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const LoadingState()
          else if (_error != null)
            ErrorState(message: _error!, onRetry: () => _load())
          else if (_rows.isEmpty)
            const EmptyState(message: 'مشتری یافت نشد')
          else ...[
            _table(),
            const SizedBox(height: 10),
            _pager(pages),
          ],
        ],
      ),
    );
  }

  Widget _table() {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(color: Palette.textMuted, fontSize: 12),
          dataTextStyle: const TextStyle(color: Palette.text, fontSize: 13),
          columns: const [
            DataColumn(label: Text('موبایل')),
            DataColumn(label: Text('نام')),
            DataColumn(label: Text('شهر')),
            DataColumn(label: Text('سفارش‌ها'), numeric: true),
            DataColumn(label: Text('جمع خرید'), numeric: true),
            DataColumn(label: Text('آخرین سفارش')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final r in _rows)
              DataRow(cells: [
                DataCell(SelectableText(
                  (r['phone'] ?? '-').toString(),
                  style: const TextStyle(color: Palette.text, fontSize: 13),
                )),
                DataCell(Text((r['name'] ?? '-').toString())),
                DataCell(Text((r['city'] ?? '-').toString())),
                DataCell(Text('${r['orders'] ?? 0}')),
                DataCell(Text(faMoney(r['spent']))),
                DataCell(Text(faDate(r['lastAt']))),
                DataCell(
                  TextButton(
                    onPressed: () => _openDetail((r['phone'] ?? '').toString()),
                    child: const Text('جزئیات', style: TextStyle(color: Palette.primary)),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _pager(int pages) {
    return Row(
      children: [
        TextButton(
          onPressed: _page > 1 && !_loading ? () => _load(page: _page - 1) : null,
          child: const Text('قبلی', style: TextStyle(color: Palette.primary)),
        ),
        Text(
          'صفحه $_page از $pages',
          style: const TextStyle(color: Palette.textMuted, fontSize: 12),
        ),
        TextButton(
          onPressed: _page < pages && !_loading ? () => _load(page: _page + 1) : null,
          child: const Text('بعدی', style: TextStyle(color: Palette.primary)),
        ),
      ],
    );
  }

  Future<void> _openDetail(String phone) async {
    if (phone.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _CustomerDetailDialog(api: widget.api, phone: phone),
    );
  }
}

class _CustomerDetailDialog extends StatefulWidget {
  const _CustomerDetailDialog({required this.api, required this.phone});

  final CrmApiService api;
  final String phone;

  @override
  State<_CustomerDetailDialog> createState() => _CustomerDetailDialogState();
}

class _CustomerDetailDialogState extends State<_CustomerDetailDialog> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.api.getCustomerDetail(widget.phone).then((v) {
      if (mounted) setState(() => {_data = v, _loading = false});
    }).catchError((Object e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
      return <String, dynamic>{};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'مشتری ${widget.phone}',
                      style: const TextStyle(
                        color: Palette.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Palette.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const LoadingState()
                    : _error != null
                        ? ErrorState(
                            message: _error!,
                            onRetry: () => Navigator.of(context).pop(),
                          )
                        : _detail(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail() {
    final totals = (_data?['totals'] as Map<String, dynamic>?) ?? {};
    final orders = ((_data?['orders'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
    final activity = ((_data?['activity'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: KpiCard(title: 'تعداد سفارش', value: '${totals['orders'] ?? 0}'),
              ),
              SizedBox(
                width: 200,
                child: KpiCard(title: 'جمع خرید', value: faMoney(totals['spent'])),
              ),
              SizedBox(
                width: 200,
                child: KpiCard(title: 'تعداد اقلام', value: '${totals['items'] ?? 0}'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('سفارش‌ها'),
          const SizedBox(height: 8),
          if (orders.isEmpty)
            const Text('سفارشی نیست', style: TextStyle(color: Palette.textMuted))
          else
            for (final o in orders)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'سفارش #${o['orderNumber'] ?? '-'} — ${faStatus(o['status'])}',
                            style: const TextStyle(
                              color: Palette.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          faDate(o['createdAt']),
                          style: const TextStyle(color: Palette.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ((o['items'] as List<dynamic>?) ?? [])
                          .map((it) =>
                              '${(it['product'] as Map?)?['name'] ?? 'کالا'} × ${it['quantity']}')
                          .join('، '),
                      style: const TextStyle(color: Palette.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 14),
          SectionTitle('فعالیت‌ها (${activity.length})'),
          const SizedBox(height: 8),
          if (activity.isEmpty)
            const Text('فعالیتی نیست', style: TextStyle(color: Palette.textMuted))
          else
            for (final a in activity.take(20))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (a['label'] ?? a['type'] ?? '').toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Palette.text, fontSize: 12),
                      ),
                    ),
                    Text(
                      faDate(a['createdAt']),
                      style: const TextStyle(color: Palette.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
