import 'package:flutter/material.dart';
import '../../features/manager/dashboard/search/search_screen.dart';

/// نوار جستجوی ظاهری — با لمس، صفحه جستجو باز می‌شود (مشترک مدیر و انباردار)
class SearchBarTrigger extends StatelessWidget {
  final String hintText;
  final EdgeInsetsGeometry padding;

  const SearchBarTrigger({
    super.key,
    this.hintText = 'جستجوی محموله...',
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: const Color(0xFF1A1D22), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.35), size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(hintText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14.5))),
          ]),
        ),
      ),
    );
  }
}