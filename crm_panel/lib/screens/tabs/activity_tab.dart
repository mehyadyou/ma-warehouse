import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';


/// تب فعالیت‌ها — تایم‌لاین کاربران + جدول AuditLog (ممیزی)
class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key, required this.api, required this.refreshTick});

  final CrmApiService api;
  final int refreshTick;

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CrmPage(
      title: 'فعالیت‌ها و ممیزی',
      subtitle: 'هر که چه کرد، کی کرد — قابل پیگیری تا سطح رکورد',
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Palette.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Palette.border),
            ),
            child: TabBar(
              controller: _tabs,
              labelColor: Palette.primary,
              unselectedLabelColor: Palette.textMuted,
              indicatorColor: Palette.primary,
              tabs: const [
                Tab(text: 'تایم‌لاین کاربران'),
                Tab(text: 'ممیزی (Audit)'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 560,
            child: TabBarView(
              controller: _tabs,
              children: [
                _UserTimeline(api: widget.api),
                _AuditTable(api: widget.api),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTimeline extends StatefulWidget {
  const _UserTimeline({required this.api});

  final CrmApiService api;

  @override
  State<_UserTimeline> createState() => _UserTimelineState();
}

class _UserTimelineState extends State<_UserTimeline> {
  List<dynamic> _users = [];
  String? _userId;
  List<dynamic> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.api.getUsers().then((v) {
      if (mounted) setState(() => _users = v);
    }).catchError((_) {});
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.api.getUserActivity(userId: _userId, limit: 100);
      if (!mounted) return;
      setState(() {
        _entries = res['entries'] as List<dynamic>;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('کاربر', style: TextStyle(color: Palette.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Palette.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _userId,
                    hint: const Text('همه کاربران',
                        style: TextStyle(color: Palette.textMuted, fontSize: 13)),
                    isExpanded: true,
                    dropdownColor: Palette.surfaceAlt,
                    style: const TextStyle(color: Palette.text, fontSize: 13),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('همه کاربران')),
                      for (final u in _users)
                        DropdownMenuItem<String?>(
                          value: (u['id'] ?? '').toString(),
                          child: Text(
                            '${u['name'] ?? ''} (${u['phone'] ?? ''})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() => _userId = v);
                      _load();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const LoadingState()
              : _error != null
                  ? ErrorState(message: _error!, onRetry: () => _load())
                  : _entries.isEmpty
                      ? const EmptyState(message: 'فعالیتی نیست')
                      : ListView.builder(
                          itemCount: _entries.length,
                          itemBuilder: (context, i) {
                            final e = _entries[i] as Map<String, dynamic>;
                            final kind = (e['kind'] ?? '').toString();
                            final color = kind == 'audit'
                                ? const Color(0xFFA78BFA)
                                : kind == 'transaction'
                                    ? const Color(0xFF60A5FA)
                                    : Palette.primary;
                            final title = kind == 'audit'
                                ? (e['action'] ?? '').toString()
                                : kind == 'transaction'
                                    ? '${(e['data'] as Map?)?['type'] ?? ''} — ${(e['data'] as Map?)?['productName'] ?? ''}'
                                    : ((e['data'] as Map?)?['label'] ?? (e['data'] as Map?)?['type'] ?? '').toString();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Palette.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Palette.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      kind == 'audit'
                                          ? 'ممیزی'
                                          : kind == 'transaction'
                                              ? 'تراکنش'
                                              : 'فعالیت',
                                      style: TextStyle(color: color, fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SelectableText(
                                      title,
                                      style: const TextStyle(color: Palette.text, fontSize: 12.5),
                                    ),
                                  ),
                                  Text(
                                    faDateTime(e['at']),
                                    style: const TextStyle(color: Palette.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _AuditTable extends StatefulWidget {
  const _AuditTable({required this.api});

  final CrmApiService api;

  @override
  State<_AuditTable> createState() => _AuditTableState();
}

class _AuditTableState extends State<_AuditTable> {
  final _entityController = TextEditingController();
  final _actionController = TextEditingController();

  List<dynamic> _rows = [];
  int _total = 0;
  int _page = 1;
  static const int _pageSize = 20;
  bool _loading = true;
  String? _error;

  @override
  void dispose() {
    _entityController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });
    try {
      final res = await widget.api.getAudit(
        entity: _entityController.text,
        action: _actionController.text,
        page: _page,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _rows = res['entries'] as List<dynamic>;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            SizedBox(
              width: 180,
              child: AppTextField(
                controller: _entityController,
                label: 'موجودیت (مثل Order)',
                onSubmitted: (_) => _load(page: 1),
              ),
            ),
            SizedBox(
              width: 220,
              child: AppTextField(
                controller: _actionController,
                label: 'اکشن (مثل user.)',
                onSubmitted: (_) => _load(page: 1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: AppButton(label: 'فیلتر', onPressed: () => _load(page: 1), small: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const LoadingState()
              : _error != null
                  ? ErrorState(message: _error!, onRetry: () => _load())
                  : _rows.isEmpty
                      ? const EmptyState(message: 'رکورد ممیزی نیست')
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle:
                                const TextStyle(color: Palette.textMuted, fontSize: 12),
                            dataTextStyle:
                                const TextStyle(color: Palette.text, fontSize: 12.5),
                            columns: const [
                              DataColumn(label: Text('زمان')),
                              DataColumn(label: Text('اکشن')),
                              DataColumn(label: Text('موجودیت')),
                              DataColumn(label: Text('شناسه')),
                              DataColumn(label: Text('کنشگر')),
                            ],
                            rows: [
                              for (final r in _rows)
                                DataRow(cells: [
                                  DataCell(Text(faDateTime(r['createdAt']))),
                                  DataCell(SelectableText((r['action'] ?? '').toString())),
                                  DataCell(Text((r['entity'] ?? '').toString())),
                                  DataCell(SelectableText(
                                      ((r['entityId'] ?? '-') as Object).toString())),
                                  DataCell(Text(((r['actorId'] ?? '-') as Object).toString())),
                                ]),
                            ],
                          ),
                        ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: _page > 1 && !_loading ? () => _load(page: _page - 1) : null,
              child: const Text('قبلی', style: TextStyle(color: Palette.primary)),
            ),
            Text(
              'صفحه $_page از $pages ($_total رکورد)',
              style: const TextStyle(color: Palette.textMuted, fontSize: 12),
            ),
            TextButton(
              onPressed: _page < pages && !_loading ? () => _load(page: _page + 1) : null,
              child: const Text('بعدی', style: TextStyle(color: Palette.primary)),
            ),
          ],
        ),
      ],
    );
  }
}
