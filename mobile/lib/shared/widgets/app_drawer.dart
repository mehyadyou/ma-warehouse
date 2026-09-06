import 'package:flutter/material.dart';
import '../../core/network/api_constants.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final String userName;
  final String userRole;
  final String? avatarUrl;
  final VoidCallback? onHistoryTap;
  final VoidCallback? onArchiveTap;
  final VoidCallback? onInvoicesTap;
  final VoidCallback? onTransferTap;
  final VoidCallback? onDriversTap;
  final VoidCallback? onCarriersTap;
  final VoidCallback? onDeliveryInboxTap;
  final VoidCallback? onProductHistoryTap;
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
    this.onHistoryTap,
    this.onArchiveTap,
    this.onInvoicesTap,
    this.onTransferTap,
    this.onDriversTap,
    this.onCarriersTap,
    this.onDeliveryInboxTap,
    this.onProductHistoryTap,
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
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  surfaceColor,
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: greenColor.withOpacity(0.35),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(),
                const SizedBox(height: 16),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userRole,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          if (onHistoryTap != null)
            _buildItem(
              context,
              Icons.event_note_rounded,
              'تاریخچه',
              onHistoryTap,
            ),
          if (onArchiveTap != null)
            _buildItem(
              context,
              Icons.archive_outlined,
              'بایگانی',
              onArchiveTap,
            ),
          if (onInvoicesTap != null)
            _buildItem(
              context,
              Icons.receipt_long_rounded,
              'فاکتورها',
              onInvoicesTap,
            ),
          if (onTransferTap != null)
            _buildItem(
              context,
              Icons.swap_horizontal_circle_rounded,
              'جابه‌جایی محصول',
              onTransferTap,
            ),
          if (onDriversTap != null)
            _buildItem(
              context,
              Icons.local_shipping_rounded,
              'مدیریت رانندگان',
              onDriversTap,
            ),
          if (onCarriersTap != null)
            _buildItem(
              context,
              Icons.fire_truck_rounded,
              'باربری',
              onCarriersTap,
            ),
          if (onDeliveryInboxTap != null)
            _buildItem(
              context,
              Icons.inbox_rounded,
              'صندوق تحویل',
              onDeliveryInboxTap,
            ),
          if (onProductHistoryTap != null)
            _buildItem(
              context,
              Icons.manage_history_rounded,
              'سابقهٔ محصولات',
              onProductHistoryTap,
            ),
          if (onSettingsTap != null)
            _buildItem(
              context,
              Icons.settings_rounded,
              'تنظیمات',
              onSettingsTap,
            ),
          const Divider(
            color: Colors.white24,
            height: 24,
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
            ),
            title: const Text(
              'خروج',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              // تأیید قبل از خروج: نشست + پین و قفل برنامه پاک می‌شوند
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: surfaceColor,
                  title: const Text(
                    'خروج از حساب',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  content: const Text(
                    'نشست فعلی بسته می‌شود و پین و تنظیمات قفل برنامه پاک می‌شود. آیا مطمئن هستید؟',
                    style: TextStyle(color: Colors.white70, fontSize: 13.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'انصراف',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'خروج',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      width: 86,
      height: 86,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            greenColor,
            const Color(0xFF22C55E),
            const Color(0xFF14532D),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: greenColor.withOpacity(0.28),
            blurRadius: 24,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF111418),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipOval(
                child: hasAvatar
                    ? Image.network(
                        ApiConstants.fullUrl(avatarUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _buildDefaultAvatarIcon();
                        },
                      )
                    : _buildDefaultAvatarIcon(),
              ),
            ),
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 19,
                height: 19,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF111418),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: greenColor,
                    boxShadow: [
                      BoxShadow(
                        color: greenColor.withOpacity(0.75),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatarIcon() {
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: greenColor,
        size: 40,
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: greenColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }
}