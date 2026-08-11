import 'package:flutter/material.dart';

const _bg = Color(0xFF0F1114);
const _green = Color(0xFF4ADE80);
const _surfaceAlt = Color(0xFF22262D);

/// صفحه اسپلش — نشان برنامه + حداقل مدت نمایش؛ مسیردهی بعدی را
/// GoRouter بر اساس وضعیت نشست (قفل/لاگین/داشبورد) انجام می‌دهد.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _green, width: 1.5),
                ),
                child: const Icon(
                  Icons.warehouse_rounded,
                  color: _green,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ما',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'مدیریت هوشمند انبار',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
