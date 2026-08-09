import 'package:flutter/material.dart';

const _green = Color(0xFF4ADE80);
const _surface = Color(0xFF1A1D22);

class SearchResultTile extends StatelessWidget {
  final String id;
  final String title;
  final String status;
  final String warehouse;

  const SearchResultTile({
    super.key,
    required this.id,
    required this.title,
    required this.status,
    required this.warehouse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_shipping_rounded, color: _green, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('شماره: $id | انبار: $warehouse', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text(status, style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
