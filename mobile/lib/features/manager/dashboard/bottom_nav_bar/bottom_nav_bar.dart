import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'nav_item.dart';
import 'nav_items.dart';

const _islandTop = Color(0xFF1E2128);
const _islandBottom = Color(0xFF14161B);
const _pillColor = Color(0xFF262A33);
const _iconSelected = Color(0xFF4ADE80);
const _iconUnselected = Color(0xFF8A8F98);
const _labelSelected = Colors.white;
const _labelUnselected = Color(0xFF8A8F98);
const _fabColor = Color(0xFF4ADE80);
const _fabIcon = Color(0xFF0B0F0C);

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final VoidCallback? onAddPressed;
  final List<NavItem> items;
  final IconData fabIcon;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.onAddPressed,
    this.items = navItems,
    this.fabIcon = Icons.calendar_month_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: SizedBox(
          height: 78,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ─── جزیره ───
              Positioned(
                left: 0,
                right: 0,
                top: 14,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_islandTop, _islandBottom],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < 2; i++)
                        _NavItemSlot(
                          item: items[i],
                          isSelected: i == selectedIndex,
                          onTap: () => onTap(i),
                        ),
                      const SizedBox(width: 66),
                      for (int i = 2; i < items.length; i++)
                        _NavItemSlot(
                          item: items[i],
                          isSelected: i == selectedIndex,
                          onTap: () => onTap(i),
                        ),
                    ],
                  ),
                ),
              ),
              // ─── دکمهٔ مرکزی سبز ───
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAddPressed?.call();
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _fabColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _fabColor.withOpacity(0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        fabIcon,
                        color: _fabIcon,
                        size: 28,
                      ),                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemSlot extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemSlot({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? _pillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: isSelected ? _iconSelected : _iconUnselected,
                size: 20,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  color: isSelected ? _labelSelected : _labelUnselected,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
