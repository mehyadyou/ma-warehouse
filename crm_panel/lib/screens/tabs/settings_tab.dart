import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api_service.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../widgets/app_widgets.dart';


/// تب تنظیمات — آدرس سرور + مدیریت کلیدهای API + درباره
class SettingsTab extends StatefulWidget {
  const SettingsTab({
    super.key,
    required this.api,
    required this.userName,
    required this.onLogout,
  });

  final CrmApiService api;
  final String userName;
  final VoidCallback onLogout;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _serverController = TextEditingController();
  final _keyNameController = TextEditingController();

  List<dynamic> _keys = [];
  List<dynamic> _scopes = [];
  final Set<String> _pickedScopes = {};
  bool _loadingKeys = true;
  String? _keysError;

  @override
  void initState() {
    super.initState();
    widget.api.loadServerUrl().then((url) {
      if (mounted) _serverController.text = url;
    });
    _loadKeys();
    widget.api.getApiScopes().then((v) {
      if (mounted) setState(() => _scopes = v);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _serverController.dispose();
    _keyNameController.dispose();
    super.dispose();
  }

  Future<void> _saveServer() async {
    var url = _serverController.text.trim();
    if (url.isEmpty) url = CrmApiService.defaultServerUrl;
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    await widget.api.saveServerUrl(url);
    widget.api.configure(url);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('آدرس سرور ذخیره شد — از این به بعد با همین وصل می‌شود'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadKeys() async {
    setState(() {
      _loadingKeys = true;
      _keysError = null;
    });
    try {
      final keys = await widget.api.getApiKeys();
      if (!mounted) return;
      setState(() {
        _keys = keys;
        _loadingKeys = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingKeys = false;
        _keysError = e.toString();
      });
    }
  }

  String _scopeLabel(dynamic s) {
    if (s is Map<String, dynamic>) return (s['label'] ?? s['value'] ?? s['name'] ?? '').toString();
    return s.toString();
  }

  String _scopeValue(dynamic s) {
    if (s is Map<String, dynamic>) {
      return (s['value'] ?? s['name'] ?? s['label'] ?? '').toString();
    }
    return s.toString();
  }

  Future<void> _createKey() async {
    final name = _keyNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('نام کلید الزامی است (مثلاً حسابداری)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_pickedScopes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حداقل یک دسترسی انتخاب کنید'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      final res = await widget.api.createApiKey(
        name: name,
        scopes: _pickedScopes.toList(),
      );
      if (!mounted) return;
      final raw = (res['key'] ?? res['rawKey'] ?? res['apiKey'] ?? '').toString();
      _keyNameController.clear();
      setState(() => _pickedScopes.clear());
      await _loadKeys();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Palette.surfaceAlt,
          title: const Text('کلید ساخته شد', style: TextStyle(color: Palette.text, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'این کلید فقط همین یک‌بار نمایش داده می‌شود — همین حالا کپی و امن نگه دارید:',
                style: TextStyle(color: Palette.textMuted, fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              SelectableText(
                raw.isEmpty ? '(کلید در پاسخ نبود — لاگ سرور را ببینید)' : raw,
                style: const TextStyle(color: Palette.primary, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (raw.isNotEmpty) Clipboard.setData(ClipboardData(text: raw));
                Navigator.of(context).pop();
              },
              child: const Text('کپی و بستن', style: TextStyle(color: Palette.primary)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _toggleKey(Map<String, dynamic> k) async {
    final id = (k['id'] ?? '').toString();
    final active = k['isActive'] == true;
    try {
      if (active) {
        await widget.api.revokeApiKey(id);
      } else {
        await widget.api.restoreApiKey(id);
      }
      await _loadKeys();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _deleteKey(Map<String, dynamic> k) async {
    final id = (k['id'] ?? '').toString();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.surfaceAlt,
        title: const Text('حذف دائمی کلید؟', style: TextStyle(color: Palette.text, fontSize: 16)),
        content: Text(
          'کلید «${k['name'] ?? ''}» برای همیشه حذف می‌شود و قابل بازگشت نیست.',
          style: const TextStyle(color: Palette.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف', style: TextStyle(color: Palette.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Palette.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.api.deleteApiKey(id);
      await _loadKeys();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CrmPage(
      title: 'تنظیمات',
      subtitle: 'اتصال، کلیدهای API و درباره — واردشده به‌عنوان ${widget.userName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('اتصال به سرور'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 380,
                child: AppTextField(
                  controller: _serverController,
                  label: 'آدرس سرور',
                  hint: CrmApiService.defaultServerUrl,
                  keyboardType: TextInputType.url,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: AppButton(label: 'ذخیره', onPressed: _saveServer, small: true),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('ساخت کلید API جدید'),
          const SizedBox(height: 10),
          SizedBox(
            width: 380,
            child: AppTextField(
              controller: _keyNameController,
              label: 'نام کلید',
              hint: 'مثلاً حسابداری سپیدار',
              onSubmitted: (_) => _createKey(),
            ),
          ),
          const SizedBox(height: 10),
          const Text('دسترسی‌ها:', style: TextStyle(color: Palette.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _scopes)
                FilterChip(
                  label: Text(_scopeLabel(s), style: const TextStyle(fontSize: 12)),
                  selected: _pickedScopes.contains(_scopeValue(s)),
                  onSelected: (v) => setState(() {
                    final val = _scopeValue(s);
                    if (v) {
                      _pickedScopes.add(val);
                    } else {
                      _pickedScopes.remove(val);
                    }
                  }),
                  selectedColor: Palette.primary.withValues(alpha: 0.25),
                  checkmarkColor: Palette.primary,
                ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(label: 'ساخت کلید', onPressed: _createKey, small: true),
          const SizedBox(height: 24),
          const SectionTitle('کلیدهای موجود'),
          const SizedBox(height: 10),
          if (_loadingKeys)
            const LoadingState()
          else if (_keysError != null)
            ErrorState(message: _keysError!, onRetry: () => _loadKeys())
          else if (_keys.isEmpty)
            const EmptyState(message: 'کلیدی ساخته نشده')
          else
            Container(
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle:
                      const TextStyle(color: Palette.textMuted, fontSize: 12),
                  dataTextStyle: const TextStyle(color: Palette.text, fontSize: 13),
                  columns: const [
                    DataColumn(label: Text('نام')),
                    DataColumn(label: Text('پیشوند')),
                    DataColumn(label: Text('وضعیت')),
                    DataColumn(label: Text('استفاده')),
                    DataColumn(label: Text('آخرین استفاده')),
                    DataColumn(label: Text('انقضا')),
                    DataColumn(label: Text('')),
                  ],
                  rows: [
                    for (final k in _keys)
                      DataRow(cells: [
                        DataCell(Text((k['name'] ?? '').toString())),
                        DataCell(SelectableText((k['prefix'] ?? '').toString())),
                        DataCell(Text(
                          k['isActive'] == true ? 'فعال' : 'غیرفعال',
                          style: TextStyle(
                            color: k['isActive'] == true ? Palette.primary : Palette.danger,
                          ),
                        )),
                        DataCell(Text('${k['useCount'] ?? 0}')),
                        DataCell(Text(faDateTime(k['lastUsedAt']))),
                        DataCell(Text(k['expiresAt'] != null ? faDate(k['expiresAt']) : 'بدون انقضا')),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _toggleKey(k as Map<String, dynamic>),
                              child: Text(
                                k['isActive'] == true ? 'ابطال' : 'فعال‌سازی',
                                style: const TextStyle(color: Palette.primary),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _deleteKey(k as Map<String, dynamic>),
                              child: const Text('حذف', style: TextStyle(color: Palette.danger)),
                            ),
                          ],
                        )),
                      ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('درباره'),
          const SizedBox(height: 8),
          const Text(
            'پنل CRM مالک — MA Warehouse نسخه 1.0.0\nفقط‌خواندنی است (به‌جز مدیریت کلیدها) و هیچ عملیاتی روی دادهٔ انبار انجام نمی‌دهد.',
            style: TextStyle(color: Palette.textMuted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
