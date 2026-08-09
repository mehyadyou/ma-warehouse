import 'package:flutter/material.dart';
import '../../core/network/api_constants.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final String userName;
  final String userRole;
  final String? avatarUrl;
  final VoidCallback? onDashboardTap;
  final VoidCallback? onInventoryTap;
  final VoidCallback? onTransactionsTap;
  final VoidCallback? onHistoryTap;
  final VoidCallback? onArchiveTap;
  final VoidCallback? onSettingsTap;
  final Color greenColor;
  final Color surfaceColor;
  final Color bgColor;

  const AppDrawer({
    super.key,
    required this.onLogout,
    required this.userName,
    required this.userRole,
    this.avatarUrl,
    this.onDashboardTap,
    this.onInventoryTap,
    this.onTransactionsTap,
    this.onHistoryTap,
    this.onArchiveTap,
    this.onSettingsTap,
    this.greenColor = const Color(0xFF4ADE80),
    this.surfaceColor = const Color(0xFF1A1D22),
    this.bgColor = const Color(0xFF0F1114),
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: surfaceColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(bottom: BorderSide(color: greenColor)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22262D),
                    border: Border.all(color: greenColor, width: 2.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                          ApiConstants.fullUrl(avatarUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.person_rounded, color: Color(0xFF4ADE80), size: 40),
                        )
                      : const Icon(Icons.person_rounded, color: Color(0xFF4ADE80), size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userRole,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
_buildItem(context, Icons.dashboard, 'داشبورد', onDashboardTap),
          if (onInventoryTap != null)
            _buildItem(context, Icons.inventory, 'موجودی', onInventoryTap),
          _buildItem(context, Icons.history, 'تراکنش‌ها', onTransactionsTap),
          if (onHistoryTap != null)
            _buildItem(context, Icons.event_note_rounded, 'تاریخچه', onHistoryTap),
          if (onArchiveTap != null)
            _buildItem(context, Icons.archive_outlined, 'بایگانی', onArchiveTap),
          _buildItem(context, Icons.settings_rounded, 'تنظیمات', onSettingsTap),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('خروج', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: greenColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }
}
