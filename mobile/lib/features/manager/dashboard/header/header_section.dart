import 'package:flutter/material.dart';
import 'package:ma_app/core/network/api_constants.dart';
import 'package:ma_app/features/manager/dashboard/widgets/notification_bell.dart';

const _green = Color(0xFF4ADE80);

class _UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  const _UserAvatar({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF22262D),
        border: Border.all(color: _green.withValues(alpha: 0.5), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? Image.network(
              ApiConstants.fullUrl(avatarUrl!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: _green),
            )
          : const Icon(Icons.person_rounded, color: _green),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? avatarUrl;

  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(children: [
        Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => Scaffold.of(ctx).openDrawer(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFF22262D), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.menu_rounded, color: Colors.white.withValues(alpha: 0.7), size: 22),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const NotificationBell(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12.5)),
          ]),
        ),
        const SizedBox(width: 12),
        _UserAvatar(avatarUrl: avatarUrl),
      ]),
    );
  }
}
