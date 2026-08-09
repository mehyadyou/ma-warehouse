import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _surface = Color(0xFF1A1D22);
const _green = Color(0xFF4ADE80);
const _border = Color(0xFF2A2D33);

class DriverHeader extends StatelessWidget {
  final String name;
  final String warehouseName;
  final bool isOnline;

  const DriverHeader({
    super.key,
    required this.name,
    required this.warehouseName,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(children: [
        // Online dot
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: isOnline ? _green : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: isOnline
                ? [BoxShadow(color: _green.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)]
                : [],
          ),
        ),
        const SizedBox(width: 12),
        // Name & warehouse
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(Icons.warehouse_rounded, size: 13, color: Colors.white.withOpacity(0.4)),
              const SizedBox(width: 4),
              Text(warehouseName,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ]),
          ]),
        ),
        // Truck icon
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _green.withOpacity(0.3)),
          ),
          child: const Icon(Icons.local_shipping_rounded, color: _green, size: 22),
        ),
      ]),
    );
  }
}