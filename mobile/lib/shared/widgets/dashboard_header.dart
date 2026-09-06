import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../utils/numbers.dart';
import 'auth_network_image.dart';
import 'notification_bell.dart';

const _surfaceAlt = Color(0xFF22262D);
const _green = Color(0xFF4ADE80);

/// تاریخ امروز شمسی — منبع واحد تاریخ برای هدرهای همه پنل‌ها
String todayShamsiLabel() {
  final jalali = Jalali.fromDateTime(DateTime.now());
  return 'امروز ${faDigits('${jalali.year}/${jalali.month}/${jalali.day}')}';
}

/// هدر مشترک پنل‌ها (مدیر/انباردار/راننده):
/// [منو] [زنگ اعلان] متن (عنوان/زیرعنوان/تاریخ) [trailing اختیاری] [آواتار]
/// کروم (منو/زنگ/آواتار) مستقل از وضعیت داده است — لود/خطا فقط متن را تغییر می‌دهد.
class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showDate;
  final String? avatarUrl;
  final bool showBell;
  final bool showAvatar;
  final Widget? trailing;
  final VoidCallback? onMenuTap;

  /// برای «تلاش مجدد» در حالت خطا (مثل بارگذاری نام انبار)
  final VoidCallback? onTextTap;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showDate = false,
    this.avatarUrl,
    this.showBell = true,
    this.showAvatar = true,
    this.trailing,
    this.onMenuTap,
    this.onTextTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle?.trim() ?? '';
    final hasSubtitle = subtitleText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _menuButton(context),
          const SizedBox(width: 10),
          if (showAvatar) ...[_avatar(), const SizedBox(width: 12)],
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTextTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                  if (showDate) ...[
                    const SizedBox(height: 3),
                    Text(
                      todayShamsiLabel(),
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (trailing != null) ...[trailing!, const SizedBox(width: 10)],
          if (showBell) const NotificationBell(),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    return Builder(
      builder: (ctx) => Tooltip(
        message: 'منو',
        child: Material(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onMenuTap ?? () => Scaffold.of(ctx).openDrawer(),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.menu_rounded, color: Colors.white70, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _surfaceAlt,
        border: Border.all(color: _green.withValues(alpha: 0.5), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? AuthNetworkImage(
              path: avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_) =>
                  const Icon(Icons.person_rounded, color: _green),
            )
          : const Icon(Icons.person_rounded, color: _green),
    );
  }
}
