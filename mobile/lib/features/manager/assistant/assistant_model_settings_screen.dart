import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/network/api_error.dart';
import 'data/assistant_model_api_service.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _danger = Color(0xFFF87171);
const _amber = Color(0xFFFBBF24);
const _border = Color(0xFF2A2D33);
const _textDim = Color(0xFF8A8F98);

/// پیش‌فرض‌های سرویس‌دهنده‌های شناخته‌شده — فقط پر کردن فرم، اجباری نیست
class _ProviderPreset {
  final String label;
  final String? name;
  final String baseUrl;
  final String model;
  final bool thinking;
  const _ProviderPreset({
    required this.label,
    this.name,
    required this.baseUrl,
    required this.model,
    required this.thinking,
  });
}

const _presets = [
  _ProviderPreset(
    label: 'Z.AI (GLM)',
    name: 'Z.AI GLM',
    baseUrl: 'https://api.z.ai/api/paas/v4',
    model: 'glm-4.7-flash',
    thinking: true,
  ),
  _ProviderPreset(
    label: 'DeepSeek',
    name: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com',
    model: 'deepseek-chat',
    thinking: false,
  ),
  _ProviderPreset(
    label: 'OpenAI',
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    model: 'gpt-4o-mini',
    thinking: false,
  ),
  _ProviderPreset(
    label: 'OpenRouter',
    name: 'OpenRouter',
    baseUrl: 'https://openrouter.ai/api/v1',
    model: 'deepseek/deepseek-chat',
    thinking: false,
  ),
  _ProviderPreset(
    label: 'سفارشی',
    name: null,
    baseUrl: '',
    model: '',
    thinking: false,
  ),
];

/// صفحهٔ تنظیمات مدل دستیار هوش مصنوعی (فقط مدیر) — پیکربندی در دیتابیس ذخیره
/// می‌شود تا بعداً بدون تغییر کد/env مدل عوض شود.
class AssistantModelSettingsScreen extends StatefulWidget {
  const AssistantModelSettingsScreen({super.key});

  @override
  State<AssistantModelSettingsScreen> createState() =>
      _AssistantModelSettingsScreenState();
}

class _AssistantModelSettingsScreenState
    extends State<AssistantModelSettingsScreen> {
  final _api = AssistantModelApiService();
  final _nameCtrl = TextEditingController();
  final _baseUrlCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _maxTokensCtrl = TextEditingController();

  bool _thinking = true;
  bool _hasApiKey = false;
  String? _apiKeyTail;
  bool _fromDb = false;
  bool _loading = true;
  bool _saving = false;
  bool _testing = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelCtrl.dispose();
    _apiKeyCtrl.dispose();
    _maxTokensCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cfg = await _api.getConfig();
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = cfg.name ?? '';
        _baseUrlCtrl.text = cfg.baseUrl;
        _modelCtrl.text = cfg.model;
        _maxTokensCtrl.text = '${cfg.maxTokens}';
        _thinking = cfg.thinking;
        _hasApiKey = cfg.hasApiKey;
        _apiKeyTail = cfg.apiKeyTail;
        _fromDb = cfg.fromDb;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('دریافت تنظیمات مدل ناموفق بود');
    }
  }

  AssistantModelConfig _draft() {
    return AssistantModelConfig(
      name: _nameCtrl.text.trim(),
      baseUrl: _baseUrlCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      maxTokens: int.tryParse(_maxTokensCtrl.text.trim()) ?? 8000,
      thinking: _thinking,
      fromDb: _fromDb,
      hasApiKey: _hasApiKey,
    );
  }

  void _applyPreset(_ProviderPreset p) {
    setState(() {
      _nameCtrl.text = p.name ?? '';
      _baseUrlCtrl.text = p.baseUrl;
      _modelCtrl.text = p.model;
      _thinking = p.thinking;
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// اعتبارسنجی فرم — خطای فارسی برمی‌گرداند یا null
  String? _validate() {
    final baseUrl = _baseUrlCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    final maxTokens = int.tryParse(_maxTokensCtrl.text.trim());
    if (baseUrl.isEmpty) return 'آدرس پایهٔ سرویس‌دهنده الزامی است';
    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      return 'آدرس پایه باید با http:// یا https:// شروع شود';
    }
    if (model.isEmpty) return 'نام مدل الزامی است';
    if (maxTokens == null || maxTokens < 256) {
      return 'سقف توکن باید عددی حداقل ۲۵۶ باشد';
    }
    return null;
  }

  Future<void> _test() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }
    setState(() => _testing = true);
    try {
      final result = await _api.testConfig(
        config: _draft(),
        apiKey: _apiKeyCtrl.text,
      );
      if (!mounted) return;
      _showSuccess('اتصال برقرار شد ✓ (${result.latencyMs}ms)');
    } catch (e) {
      if (!mounted) return;
      _showError('تست ناموفق: ${friendlyError(e)}');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await _api.saveConfig(
        config: _draft(),
        apiKey: _apiKeyCtrl.text,
      );
      if (!mounted) return;
      setState(() {
        _hasApiKey = saved.hasApiKey;
        _apiKeyTail = saved.apiKeyTail;
        _fromDb = saved.fromDb;
        _apiKeyCtrl.clear();
      });
      _showSuccess('مدل ذخیره شد — از همین حالا در گفتگوها اعمال می‌شود');
    } catch (e) {
      if (!mounted) return;
      _showError(friendlyError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetToEnv() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('بازگشت به تنظیمات پیش‌فرض؟',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'پیکربندی اختصاصی مدل حذف می‌شود و دستیار از مقادیر .env (ZAI_API_KEY و …) استفاده می‌کند.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بازگشت به پیش‌فرض',
                style: TextStyle(color: _danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      final cfg = await _api.resetConfig();
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = cfg.name ?? '';
        _baseUrlCtrl.text = cfg.baseUrl;
        _modelCtrl.text = cfg.model;
        _maxTokensCtrl.text = '${cfg.maxTokens}';
        _thinking = cfg.thinking;
        _hasApiKey = cfg.hasApiKey;
        _apiKeyTail = cfg.apiKeyTail;
        _fromDb = false;
        _apiKeyCtrl.clear();
        _saving = false;
      });
      _showSuccess('به مقادیر پیش‌فرض برگشت');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(friendlyError(e));
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
          'مدل دستیار هوش مصنوعی',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ═══ وضعیت فعلی ═══
                _statusBanner(),
                const SizedBox(height: 18),

                // ═══ انتخاب سریع سرویس‌دهنده ═══
                const Text('سرویس‌دهنده (پیش‌فرض‌ها برای پر کردن سریع فرم)',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presets.map((p) {
                    return GestureDetector(
                      onTap: () => _applyPreset(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _border),
                        ),
                        child: Text(
                          p.label,
                          style: const TextStyle(color: _green, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // ═══ فیلدها ═══
                _field(
                  controller: _nameCtrl,
                  icon: Icons.label_rounded,
                  label: 'نام دلخواه (اختیاری)',
                  hint: 'مثلاً GLM رایگان',
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _baseUrlCtrl,
                  icon: Icons.link_rounded,
                  label: 'آدرس پایه (Base URL)',
                  hint: 'https://api.z.ai/api/paas/v4',
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _modelCtrl,
                  icon: Icons.smart_toy_rounded,
                  label: 'نام مدل',
                  hint: 'glm-4.7-flash',
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _apiKeyCtrl,
                  icon: Icons.key_rounded,
                  label: 'کلید API',
                  hint: _hasApiKey
                      ? 'کلیدی ذخیره شده است — برای تعویض، کلید جدید بنویسید'
                      : 'مثلاً sk-…',
                  obscure: _obscure,
                  toggleVisibility: () => setState(() => _obscure = !_obscure),
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _maxTokensCtrl,
                  icon: Icons.token_rounded,
                  label: 'سقف توکن پاسخ',
                  hint: '8000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 6),

                // ═══ حالت فکرکردن ═══
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: _surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: SwitchListTile(
                    value: _thinking,
                    onChanged: (v) => setState(() => _thinking = v),
                    activeTrackColor: _green,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    title: const Text('حالت فکر کردن (Thinking)',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'فقط مدل‌های Z.AI/GLM از این افزونه پشتیبانی می‌کنند؛ برای سرویس‌دهنده‌های دیگر خاموش کنید',
                      style: TextStyle(color: Colors.white38, fontSize: 11.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ═══ دکمه‌ها ═══
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _test,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _green,
                          side: const BorderSide(color: _green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _testing
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _green))
                            : const Icon(Icons.wifi_tethering_rounded, size: 20),
                        label: Text(_testing ? 'در حال تست…' : 'تست اتصال'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                            : const Icon(Icons.save_rounded, size: 20, color: Colors.black87),
                        label: Text(_saving ? 'در حال ذخیره…' : 'ذخیره مدل',
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
                if (_fromDb) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _saving ? null : _resetToEnv,
                    style: TextButton.styleFrom(foregroundColor: _danger),
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('بازگشت به تنظیمات .env'),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _statusBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fromDb ? _green : _amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            _fromDb ? Icons.storage_rounded : Icons.settings_rounded,
            color: _fromDb ? _green : _amber,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fromDb ? 'مدل اختصاصی ذخیره‌شده در دیتابیس' : 'در حال استفاده از مقادیر .env',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'مدل فعال: ${_modelCtrl.text.isEmpty ? '—' : _modelCtrl.text}'
                  '${_hasApiKey ? '  •  کلید: …${_apiKeyTail ?? ''}' : ''}',
                  style: const TextStyle(color: _textDim, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: _green),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.white38),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: _surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _green)),
      ),
    );
  }
}
