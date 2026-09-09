import 'package:flutter/material.dart';

import '../core/palette.dart';

/// کیت UI مشترک CRM — دکمه، ورودی، کارت KPI، حالت‌های بارگذاری/خالی/خطا.

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
    this.small = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: danger ? Palette.danger : Palette.primary,
        foregroundColor: danger ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 14 : 22,
          vertical: small ? 10 : 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(fontSize: small ? 12.5 : 14, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onSubmitted,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Palette.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onSubmitted: onSubmitted,
          style: const TextStyle(color: Palette.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Palette.textMuted, fontSize: 13),
            filled: true,
            fillColor: Palette.surfaceAlt,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Palette.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// قاب صفحه‌های تب — تیتر + زیرتیتر + دکمه تازه‌سازی
class CrmPage extends StatelessWidget {
  const CrmPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Palette.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Palette.textMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  tooltip: 'تازه‌سازی',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, color: Palette.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {  const SectionTitle(this.text, {super.key, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Palette.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
    this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Palette.primary;
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: c, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Palette.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: c, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(color: Palette.textMuted, fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: card,
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = 'در حال بارگذاری…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Palette.primary),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Palette.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.message = 'موردی یافت نشد', this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Palette.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Palette.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Palette.danger, size: 44),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Palette.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            AppButton(label: 'تلاش مجدد', onPressed: onRetry, small: true),
          ],
        ),
      ),
    );
  }
}

/// نوار افقی ساده (میله‌ای) برای تفکیک‌ها — بدون وابستگی خارجی
class BarRow extends StatelessWidget {
  const BarRow({
    super.key,
    required this.label,
    required this.value,
    required this.display,
    required this.fraction,
    this.color = Palette.primary,
  });

  final String label;
  final String value;
  final String display;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Palette.text, fontSize: 12),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Palette.surfaceAlt,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              '$display ($value)',
              textAlign: TextAlign.left,
              style: const TextStyle(color: Palette.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// دونات ساده با CustomPaint — بدون وابستگی خارجی
class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.segments, this.size = 170});

  final List<DonutSegment> segments;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(
              segments.map((e) => _Arc(e.value / (total == 0 ? 1 : total), e.color)).toList(),
            ),
            child: Center(
              child: Text(
                total.truncate().toString(),
                style: const TextStyle(
                  color: Palette.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in segments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Palette.textMuted, fontSize: 12),
                        ),
                      ),
                      Text(
                        s.value.truncate().toString(),
                        style: const TextStyle(color: Palette.text, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class DonutSegment {
  const DonutSegment(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _Arc {
  const _Arc(this.fraction, this.color);

  final double fraction;
  final Color color;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.arcs);

  final List<_Arc> arcs;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    var start = -3.141592653589793 / 2;
    final bg = Paint()
      ..color = const Color(0xFF22262D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    canvas.drawCircle(center, radius, bg);
    for (final arc in arcs) {
      if (arc.fraction <= 0) continue;
      final paint = Paint()
        ..color = arc.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt;
      final sweep = arc.fraction * 3.141592653589793 * 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.arcs != arcs;
}
