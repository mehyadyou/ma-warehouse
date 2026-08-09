import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'quick_action_tile.dart';
import 'reports/reports_screen.dart';
import 'products/products_screen.dart';
import 'users/users_screen.dart';

const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFFB923C);

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QuickActionTile(
            action: QuickAction(
              icon: Icons.people_rounded,
              label: 'کاربران',
              color: _green,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen()));
              },
            ),
          ),
          QuickActionTile(
            action: QuickAction(
              icon: Icons.warehouse_rounded,
              label: 'انبارها',
              color: _orange,
              onTap: () => context.push('/manager/warehouses'),
            ),
          ),
          QuickActionTile(
            action: QuickAction(
              icon: Icons.inventory_rounded,
              label: 'محصولات',
              color: Colors.blue,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
              },
            ),
          ),
          QuickActionTile(
            action: QuickAction(
              icon: Icons.assessment_rounded,
              label: 'گزارش‌ها',
              color: Colors.purple,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}