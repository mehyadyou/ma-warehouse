import 'package:flutter/material.dart';
import 'search_screen.dart';

const _surface = Color(0xFF1A1D22);

class AppSearchBar extends StatelessWidget {
  final String hintText;

  const AppSearchBar({
    super.key,
    this.hintText = 'جستجوی محموله...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.search_rounded,
                  color: Colors.white.withOpacity(0.35), size: 22),
              const SizedBox(width: 10),
              Text(hintText,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14.5)),
            ],
          ),
        ),
      ),
    );
  }
}
