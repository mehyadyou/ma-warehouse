import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/utils/validators.dart';
import '../../../models/user_model.dart';
import '../../../models/warehouse_model.dart';
import '../../../data/manager_api_service.dart';
import '../../../providers/manager_api_provider.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);
const _blue = Color(0xFF60A5FA);
const _purple = Color(0xFFA78BFA);
const _danger = Color(0xFFF87171);
const _border = Color(0xFF2A2D33);

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  late final ManagerApiService _api = ref.read(managerApiServiceProvider);
  List<UserModel> _users = [];
  List<WarehouseModel> _warehouses = [];
  bool _loading = true;
  String? _loadError;
  String? _roleFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        _api.getUsers(),
        _api.getWarehouses(),
      ]);
      if (!mounted) return;
      setState(() {
        _users = results[0] as List<UserModel>;
        _warehouses = results[1] as List<WarehouseModel>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'خطا در دریافت اطلاعات');
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<UserModel> get _filteredUsers {
    if (_roleFilter == null) return _users;
    return _users.where((u) => u.role == _roleFilter).toList();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'MANAGER': return _purple;
      case 'WAREHOUSE_KEEPER': return _green;
      case 'DRIVER': return _orange;
      default: return _blue;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'MANAGER': return 'مدیر';
      case 'WAREHOUSE_KEEPER': return 'انباردار';
      case 'DRIVER': return 'راننده';
      default: return role;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'MANAGER': return Icons.admin_panel_settings_rounded;
      case 'WAREHOUSE_KEEPER': return Icons.warehouse_rounded;
      case 'DRIVER': return Icons.local_shipping_rounded;
      default: return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('مدیریت کاربران', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: _green), onPressed: () => _showUserDialog()),
        ],
      ),
      body: Column(children: [
        // فیلتر نقش
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterChip(label: 'همه', selected: _roleFilter == null, color: _blue, onTap: () => setState(() => _roleFilter = null)),
              const SizedBox(width: 8),
              _FilterChip(label: 'مدیران', selected: _roleFilter == 'MANAGER', color: _purple, onTap: () => setState(() => _roleFilter = 'MANAGER')),
              const SizedBox(width: 8),
              _FilterChip(label: 'انبارداران', selected: _roleFilter == 'WAREHOUSE_KEEPER', color: _green, onTap: () => setState(() => _roleFilter = 'WAREHOUSE_KEEPER')),
              const SizedBox(width: 8),
              _FilterChip(label: 'رانندگان', selected: _roleFilter == 'DRIVER', color: _orange, onTap: () => setState(() => _roleFilter = 'DRIVER')),
            ]),
          ),
        ),

        // لیست
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _green))
              : _loadError != null
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.cloud_off_rounded, color: Colors.white.withOpacity(0.3), size: 40),
                        const SizedBox(height: 12),
                        Text(_loadError!, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _loadData,
                          style: OutlinedButton.styleFrom(foregroundColor: _green, side: BorderSide(color: _green.withValues(alpha: 0.4))),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('تلاش دوباره'),
                        ),
                      ]),
                    )
                  : _filteredUsers.isEmpty
                  ? Center(child: Text('کاربری یافت نشد', style: TextStyle(color: Colors.white.withOpacity(0.4))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final u = _filteredUsers[index];
                        final color = _roleColor(u.role ?? '');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
                          child: Row(children: [
                            Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(_roleIcon(u.role ?? ''), color: color, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(u.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(u.phone ?? '', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                            ])),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text(_roleLabel(u.role ?? ''), style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600))),
                            const SizedBox(width: 8),
                            // Edit button (hidden for MANAGER)
                            if (u.role != 'MANAGER')
                              GestureDetector(
                                onTap: () => _showUserDialog(user: u),
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: _blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.edit_rounded, color: _blue, size: 18),
                                ),
                              ),
                            if (u.role != 'MANAGER') const SizedBox(width: 6),
                            // Delete button (hidden for MANAGER)
                            if (u.role != 'MANAGER')
                              GestureDetector(
                                onTap: () => _deleteUser(u),
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: _danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.delete_outline_rounded, color: _danger, size: 18),
                                ),
                              ),

                          ]),
                        );
                      },
                    ),
        ),
      ]),
    );
  }

  // ═══════════ DELETE USER ═══════════
  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('حذف کاربر', style: TextStyle(color: Colors.white)),
        content: Text('آیا از حذف "${user.name}" اطمینان دارید؟\nاین عمل قابل بازگشت نیست.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _danger),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.deleteUser(user.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} حذف شد'), backgroundColor: _green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      String msg = 'خطا در حذف کاربر';
      if (e is DioException && e.response?.data != null && e.response?.data['error'] != null) {
        msg = '${e.response?.data['error']}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: _danger, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  // ═══════════ ADD / EDIT USER DIALOG ═══════════
  void _showUserDialog({UserModel? user}) {
    showDialog(
      context: context,
      builder: (_) => _UserDialog(
        user: user,
        warehouses: _warehouses,
        apiService: _api,
        onSaved: _loadData,
      ),
    );
  }
}

/// دیالوگ ساخت/ویرایش کاربر — اعتبارسنجی کامل + نمایش خطای سرور داخل دیالوگ
class _UserDialog extends StatefulWidget {
  final UserModel? user;
  final List<WarehouseModel> warehouses;
  final ManagerApiService apiService;
  final VoidCallback onSaved;

  const _UserDialog({
    required this.user,
    required this.warehouses,
    required this.apiService,
    required this.onSaved,
  });

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  bool get _isEdit => widget.user != null;

  late final TextEditingController _nameCtrl =
      TextEditingController(text: _isEdit ? widget.user!.name ?? '' : '');
  late final TextEditingController _phoneCtrl =
      TextEditingController(text: _isEdit ? widget.user!.phone ?? '' : '');
  final _passCtrl = TextEditingController();

  late String _role = _isEdit
      ? (widget.user!.role ?? 'WAREHOUSE_KEEPER')
      : 'WAREHOUSE_KEEPER';
  late String? _warehouseId = _isEdit ? widget.user!.warehouseId : null;

  String? _saveError;
  bool _saving = false;

  bool get _needsWarehouse => _role == 'WAREHOUSE_KEEPER';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passCtrl.text.trim();

    String? error;
    if (name.isEmpty) {
      error = 'نام الزامی است';
    } else if (validatePhone(phone) != null) {
      error = validatePhone(phone);
    } else if (_needsWarehouse && _warehouseId == null) {
      error = 'برای نقش انباردار، انتخاب انبار الزامی است';
    } else if (!_isEdit && validatePassword(password) != null) {
      error = validatePassword(password);
    } else if (_isEdit && password.isNotEmpty && validatePassword(password) != null) {
      error = validatePassword(password);
    }
    if (error != null) {
      setState(() => _saveError = error);
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final data = <String, dynamic>{
        'name': name,
        'phone': phone,
        'role': _role,
        'warehouseId': _needsWarehouse ? _warehouseId : null,
      };
      if (password.isNotEmpty) data['password'] = password;

      if (_isEdit) {
        await widget.apiService.updateUser(widget.user!.id, data);
      } else {
        await widget.apiService.createUser(data);
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      widget.onSaved();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'کاربر ویرایش شد' : 'کاربر جدید ثبت شد'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      String msg = 'خطا در ثبت';
      if (e is DioException &&
          e.response?.data != null &&
          e.response?.data['error'] != null) {
        msg = '${e.response?.data['error']}';
      }
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = msg;
      });
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: _surfaceAlt,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // انبار فعلیِ کاربر که بایگانی شده — باید همچنان در لیست بماند تا dropdown نشکند
    final archivedWarehouse = widget.user?.warehouseId != null &&
            !widget.warehouses.any((w) => w.id == widget.user!.warehouseId)
        ? widget.user!.warehouseId
        : null;

    final warehouseItems = <DropdownMenuItem<String>>[
      if (archivedWarehouse != null)
        DropdownMenuItem(
          value: archivedWarehouse,
          child: Text(
            widget.user!.warehouseName ?? 'انبار فعلی (بایگانی شده)',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ...widget.warehouses.map(
        (w) => DropdownMenuItem(
          value: w.id,
          child: Text(w.name, style: const TextStyle(color: Colors.white)),
        ),
      ),
    ];

    return AlertDialog(
      backgroundColor: _surface,
      title: Text(_isEdit ? 'ویرایش کاربر' : 'کاربر جدید', style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _decoration('نام'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: _decoration('شماره موبایل'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: _decoration(
              _isEdit ? 'رمز عبور جدید (۶ رقم — اختیاری)' : 'رمز عبور (۶ رقم)',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            dropdownColor: _surfaceAlt,
            style: const TextStyle(color: Colors.white),
            decoration: _decoration('نقش'),
            items: const [
              DropdownMenuItem(value: 'MANAGER', child: Text('مدیر')),
              DropdownMenuItem(value: 'WAREHOUSE_KEEPER', child: Text('انباردار')),
              DropdownMenuItem(value: 'DRIVER', child: Text('راننده')),
            ],
            onChanged: (v) => setState(() {
              _role = v!;
              if (!_needsWarehouse) _warehouseId = null;
            }),
          ),
          if (_needsWarehouse) ...[
            const SizedBox(height: 12),
            if (warehouseItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.warning_rounded, color: _danger, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('هیچ انباری وجود ندارد! ابتدا یک انبار بسازید.', style: TextStyle(color: _danger, fontSize: 12))),
                ]),
              )
            else
              DropdownButtonFormField<String>(
                value: _warehouseId,
                isExpanded: true,
                dropdownColor: _surfaceAlt,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('انتخاب انبار (الزامی)'),
                items: warehouseItems,
                onChanged: (v) => setState(() => _warehouseId = v),
              ),
          ],
          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _danger.withValues(alpha: 0.3)),
              ),
              child: Text(
                _saveError!,
                style: const TextStyle(color: _danger, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف', style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: _green),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_isEdit ? 'ذخیره تغییرات' : 'ثبت', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected; final Color color; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.white.withOpacity(0.05)),
        ),
        child: Text(label, style: TextStyle(color: selected ? color : Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}