import 'package:flutter/material.dart';

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color iconBg;
  final String? createdAt;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.iconBg,
    this.createdAt,
  });
}