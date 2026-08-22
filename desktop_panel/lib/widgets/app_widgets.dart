import 'package:flutter/material.dart';

import '../core/palette.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double? height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final Color bg;
    final Color fg;
    final Color borderColor;
    final double fontSize;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = Palette.primary;
        fg = Colors.black;
        borderColor = Colors.transparent;
        fontSize = compact ? 12 : 14;
      case AppButtonVariant.secondary:
        bg = enabled ? Palette.surfaceHover : Palette.disabledBg;
        fg = enabled ? Palette.text : Palette.disabledText;
        borderColor = Palette.border;
        fontSize = compact ? 11.5 : 13;
      case AppButtonVariant.danger:
        bg = enabled ? Palette.dangerBg : Palette.disabledBg;
        fg = enabled ? Palette.danger : Palette.disabledText;
        borderColor = Palette.border;
        fontSize = compact ? 11.5 : 13;
    }
    return SizedBox(
      height: height ?? (compact ? 30 : null),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(10),
          hoverColor: enabled ? _hoverFor(variant) : null,
          child: Container(
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _hoverFor(AppButtonVariant variant) {
    switch (variant) {
      case AppButtonVariant.primary:
        return Palette.primaryHover;
      case AppButtonVariant.secondary:
        return Palette.border;
      case AppButtonVariant.danger:
        return Palette.dangerHover;
    }
  }
}

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.onSubmitted,
    this.textInputAction,
  });

  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.center,
      textInputAction: textInputAction ?? TextInputAction.next,
      onSubmitted: (_) => onSubmitted?.call(),
      style: const TextStyle(color: Palette.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Palette.textMuted),
        filled: true,
        fillColor: Palette.appBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.primary, width: 1.5),
        ),
      ),
    );
  }
}

class StateLabel extends StatelessWidget {
  const StateLabel(this.text, {super.key, this.padding = 40});

  final String text;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Palette.textMuted, fontSize: 15),
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 5),
      painter: _DashedLinePainter(),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Palette.divider
      ..strokeWidth = 0.8;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CountBadge extends StatelessWidget {
  const CountBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Palette.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Palette.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
