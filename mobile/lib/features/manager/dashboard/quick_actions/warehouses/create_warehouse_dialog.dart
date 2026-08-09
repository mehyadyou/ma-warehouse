import 'package:flutter/material.dart';

class CreateWarehouseDialog extends StatefulWidget {
  const CreateWarehouseDialog({super.key});

  @override
  State<CreateWarehouseDialog> createState() => _CreateWarehouseDialogState();
}

class _CreateWarehouseDialogState extends State<CreateWarehouseDialog> {
  final _warehouseNameCtrl = TextEditingController();
  final _keeperNameCtrl = TextEditingController();
  final _keeperPhoneCtrl = TextEditingController();
  final _keeperPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _warehouseNameCtrl.dispose();
    _keeperNameCtrl.dispose();
    _keeperPhoneCtrl.dispose();
    _keeperPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'warehouseName': _warehouseNameCtrl.text.trim(),
      'keeperName': _keeperNameCtrl.text.trim(),
      'keeperPhone': _keeperPhoneCtrl.text.trim(),
      'keeperPassword': _keeperPasswordCtrl.text.trim(),
    };

    // TODO: اتصال به API
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warehouse_rounded, color: Color(0xFF4ADE80), size: 20),
          ),
          const SizedBox(width: 10),
          const Text('ساخت انبار جدید', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // نام انبار
              TextFormField(
                controller: _warehouseNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'نام انبار',
                  hintText: 'مثال: انبار مرکزی',
                  prefixIcon: Icon(Icons.warehouse_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'نام انبار الزامی است' : null,
              ),
              const SizedBox(height: 16),

              // دیوایدر
              const Divider(),
              const SizedBox(height: 8),

              // عنوان بخش انباردار
              const Row(
                children: [
                  Icon(Icons.person_add_rounded, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('اطلاعات انباردار', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),

              // نام انباردار
              TextFormField(
                controller: _keeperNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'نام انباردار',
                  hintText: 'نام و نام خانوادگی',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'نام انباردار الزامی است' : null,
              ),
              const SizedBox(height: 12),

              // شماره موبایل انباردار
              TextFormField(
                controller: _keeperPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'شماره موبایل انباردار',
                  hintText: '۰۹۱۲۳۴۵۶۷۸۹',
                  prefixIcon: Icon(Icons.phone_android_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'شماره موبایل الزامی است';
                  if (v.trim().length != 11) return 'شماره موبایل باید ۱۱ رقم باشد';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // رمز عبور انباردار
              TextFormField(
                controller: _keeperPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'رمز عبور انباردار',
                  hintText: 'حداقل ۶ کاراکتر',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'رمز عبور الزامی است';
                  if (v.trim().length < 6) return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('ساخت'),
        ),
      ],
    );
  }
}

// تابع helper برای نمایش دیالوگ
Future<Map<String, String>?> showCreateWarehouseDialog(BuildContext context) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => const CreateWarehouseDialog(),
  );
}
