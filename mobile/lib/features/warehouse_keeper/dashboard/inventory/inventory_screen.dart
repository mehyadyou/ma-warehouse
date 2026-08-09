import 'package:flutter/material.dart';
import 'inventory_list_view.dart';

/// تب «موجودی» داشبورد انباردار — همشکل صفحهٔ موجودی پنل مدیر،
/// اما فقط با دادهٔ انبارِ متصل به کاربر (تضمین سمت بک‌اند)
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InventoryListView();
  }
}
