import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/lock_settings_tile.dart';
import 'data/settings_api_service.dart';
import '../../core/network/api_error.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _danger = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _api = SettingsApiService();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _avatarUrl;
  bool _loading = true;
  bool _saving = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _api.getProfile();
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = profile['name'] as String? ?? '';
        _phoneCtrl.text = profile['phone'] as String? ?? '';
        _avatarUrl = profile['avatarUrl'] as String?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _green),
              title: const Text('انتخاب از گالری', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: _green),
              title: const Text('دوربین', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('در حال بارگذاری عکس...'), behavior: SnackBarBehavior.floating),
      );

      // بدون برش — عکس اصلی همان‌طور که هست آپلود و در کادر گرد با cover نمایش داده می‌شود
      final bytes = await picked.readAsBytes();
      final profile = await _api.uploadAvatar(bytes);
      await ref.read(authProvider.notifier).updateProfileFields(avatarUrl: profile['avatarUrl'] as String?);
      if (!mounted) return;
      setState(() => _avatarUrl = profile['avatarUrl'] as String?);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عکس پروفایل تغییر کرد'), backgroundColor: _green, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e)), backgroundColor: _danger, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('نام نمی‌تواند خالی باشد');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _showError('شماره موبایل نمی‌تواند خالی باشد');
      return;
    }

    final newPassword = _passwordCtrl.text.trim();
    if (newPassword.isNotEmpty) {
      final passwordError = validatePassword(newPassword);
      if (passwordError != null) {
        _showError(passwordError);
        return;
      }
    }
    if (newPassword != _confirmCtrl.text.trim()) {
      _showError('تکرار رمز عبور مطابقت ندارد');
      return;
    }

    setState(() => _saving = true);
    try {
      final profile = await _api.updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: newPassword.isEmpty ? null : newPassword,
      );
      await ref.read(authProvider.notifier).updateProfileFields(
        name: profile['name'] as String?,
        phone: profile['phone'] as String?,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پروفایل با موفقیت ذخیره شد'), backgroundColor: _green, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      String msg = friendlyError(e);
      if (msg.contains('400') || msg.contains('this phone')) {
        msg = 'این شماره موبایل قبلاً ثبت شده است';
      }
      _showError(msg);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$msg'), backgroundColor: _danger, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openNotificationSettings() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _NotificationSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('تنظیمات', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ═══ عکس پروفایل ═══
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _surfaceAlt,
                            border: Border.all(color: _green, width: 3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? Image.network(
                                  SettingsApiService.fullAvatarUrl(_avatarUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                                )
                              : _avatarPlaceholder(),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 13, color: Colors.black87),
                              SizedBox(width: 4),
                              Text('تغییر عکس', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ═══ فیلدها ═══
                _field(
                  controller: _nameCtrl,
                  icon: Icons.person_rounded,
                  label: 'نام',
                  hint: 'مثلاً مهراد',
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _phoneCtrl,
                  icon: Icons.alternate_email_rounded,
                  label: 'یوزرنیم (شماره موبایل)',
                  hint: 'مثلاً 09123456789',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _passwordCtrl,
                  icon: Icons.lock_rounded,
                  label: 'رمز عبور جدید (۶ رقم)',
                  hint: '۶ رقم — خالی بگذارید تا تغییر نکند',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscure: _obscure,
                  toggleVisibility: () => setState(() => _obscure = !_obscure),
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _confirmCtrl,
                  icon: Icons.lock_outline_rounded,
                  label: 'تکرار رمز عبور جدید',
                  hint: 'تکرار رمز عبور',
                  obscure: _obscure,
                ),
                const SizedBox(height: 28),

                // ═══ نوتیفیکیشن‌ها ═══
                _settingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'نوتیفیکیشن‌ها',
                  subtitle: 'مدیریت اعلان‌های ورود و خروج کالا',
                  onTap: _openNotificationSettings,
                ),
                const SizedBox(height: 14),

                // ═══ قفل برنامه (پین / اثر انگشت / فیس آید) ═══
                const LockSettingsTile(),
                const SizedBox(height: 28),

                // ═══ دکمه ذخیره ═══
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                      : const Text('ذخیره تغییرات', style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: _surfaceAlt,
      child: const Icon(Icons.person_rounded, size: 52, color: Color(0xFF4ADE80)),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _surfaceAlt,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _green, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
        trailing: const Icon(Icons.chevron_left_rounded, color: Colors.white38),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscure = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: _green),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.white38),
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

class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  static const _labels = [
    ('CARGO_ENTRY', 'ورود کالا', 'اعلان وقتی انباردار کالای جدید ثبت می‌کند'),
    ('RETURN_ENTRY', 'ورود مرجوعی', 'اعلان وقتی کالای مرجوعی به انبار برمی‌گردد'),
    ('SCAN_OUT', 'خروج کالا', 'اعلان وقتی کالایی از انبار خارج می‌شود'),
    ('SCAN_OUT_ERROR', 'خطاها', 'اعلان خطاهای خروج کالا'),
  ];

  final _api = SettingsApiService();
  Map<String, bool>? _settings;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _api.getNotificationSettings();
      if (!mounted) return;
      setState(() => _settings = settings);
    } catch (_) {
      if (!mounted) return;
      setState(() => _settings = {});
    }
  }

  Future<void> _toggle(String key, bool value) async {
    final current = _settings ?? {};
    setState(() {
      _settings = {...current, key: value};
      _saving = true;
    });
    try {
      final saved = await _api.updateNotificationSettings(_settings!);
      if (!mounted) return;
      setState(() {
        _settings = saved;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _settings = {...current};
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ذخیره تنظیمات ناموفق بود'), backgroundColor: _danger, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 10, bottom: 8), decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.notifications_rounded, color: _green, size: 22),
                  const SizedBox(width: 10),
                  const Text('مدیریت نوتیفیکیشن‌ها', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (_saving) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _green)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('مشخص کنید برای چه رویدادهایی اعلان دریافت کنید', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            const SizedBox(height: 8),
            if (settings == null)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: _green)))
            else
              ..._labels.map((entry) {
                final key = entry.$1;
                return SwitchListTile(
                  value: settings[key] ?? true,
                  onChanged: _saving ? null : (v) => _toggle(key, v),
                  activeTrackColor: _green,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(entry.$2, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(entry.$3, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                );
              }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}