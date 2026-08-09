import 'package:flutter/material.dart';
import 'inventory_list_view.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);

/// صفحهٔ کامل موجودی انبار خود کاربر — آینهٔ صفحهٔ «موجودی کل» پنل مدیر
class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('موجودی انبار', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const InventoryListView(),
    );
  }
}
