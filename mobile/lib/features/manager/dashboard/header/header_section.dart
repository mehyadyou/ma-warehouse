import 'package:flutter/material.dart';
import '../../../../shared/widgets/dashboard_header.dart';

/// هدر مشترک پنل مدیر — پوستهٔ نازک روی DashboardHeader
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
    return DashboardHeader(
      title: title,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
    );
  }
}