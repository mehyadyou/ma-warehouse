import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_provider.dart';
import '../../../core/notifications/notification_model.dart';

const _bg = Color(0xFF0F1114);
const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        title: const Text('اعلان\u200Cها', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _green)),
        error: (_, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.notifications_off_rounded, size: 64, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            Text('خطا در بارگذاری اعلان‌ها', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15)),
          ]),
        ),
        data: (notifications) => notifications.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.notifications_off_rounded, size: 64, color: Colors.white.withValues(alpha: 0.15)), const SizedBox(height: 16), Text('اعلانی وجود ندارد', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15))]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _NotificationTile(notifications[i]),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile(this.notification);

  String _timeAgo() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) return 'همین الان';
    if (diff.inHours < 1) return '${diff.inMinutes} دقیقه پیش';
    if (diff.inDays < 1) return '${diff.inHours} ساعت پیش';
    return '${diff.inDays} روز پیش';
  }

  IconData _icon() {
    switch (notification.type) {
      case 'error': return Icons.error_rounded;
      case 'success': return Icons.check_circle_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _iconColor() {
    switch (notification.type) {
      case 'error': return const Color(0xFFF87171);
      case 'success': return _green;
      default: return _green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: notification.isRead ? Colors.transparent : _green.withValues(alpha: 0.25), width: 1)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: _iconColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_icon(), color: _iconColor(), size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notification.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(notification.body, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          const SizedBox(height: 6),
          Text(_timeAgo(), style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
        ])),
        if (!notification.isRead) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
      ]),
    );
  }
}
