import 'package:flutter/material.dart';
import 'package:ma_app/features/warehouse_keeper/check_in/check_in_screen.dart';

class ProductManagementButton extends StatelessWidget {
  const ProductManagementButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CheckInScreen()),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D22),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.qr_code_scanner_rounded,
            color: Colors.white.withValues(alpha: 0.6), size: 24),
      ),
    );
  }
}
