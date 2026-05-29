import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A bottom navigation bar with neobrutalist styling.
///
/// Features:
/// - White background with black top border (2-4px)
/// - Active item highlighted with pink accent
/// - Bold labels for active items
class NeoBottomNavBar extends StatelessWidget {
  const NeoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.borderWidth = AppTheme.borderWidth,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NeoBottomNavItem> items;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.black,
            width: borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: isActive
                            ? BoxDecoration(
                                color: AppTheme.pink.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        child: Icon(
                          item.icon,
                          color: isActive ? AppTheme.pink : AppTheme.darkGray,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? AppTheme.pink : AppTheme.darkGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Data class for a bottom navigation bar item.
class NeoBottomNavItem {
  const NeoBottomNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
