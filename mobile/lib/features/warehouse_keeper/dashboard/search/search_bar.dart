import 'package:flutter/material.dart';
import 'package:ma_app/features/manager/dashboard/search/search_screen.dart';

class WarehouseSearchBar extends StatelessWidget {
  const WarehouseSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: const Color(0xFF1A1D22),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.35), size: 22),
            const SizedBox(width: 10),
            Text('جستجوی محموله...', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14.5)),
          ],
        ),
      ),
    );
  }
}
