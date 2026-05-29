import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/neo_bottom_nav_bar.dart';

/// The main app shell that wraps screens with a persistent bottom navigation bar.
///
/// Implements:
/// - 5-item bottom nav: Dashboard, Tasks, Budget, Guests, More
/// - "More" menu as a bottom sheet overlay with Phases, Rundown, Vendors, Settings
/// - Active item highlighting with pink accent
/// - "More" highlighted when viewing its sub-screens
/// - Tab state preservation via StatefulShellRoute's navigation shell
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// The nav bar index for the "More" button.
  static const int _moreNavIndex = 4;

  // Branch indices for "More" sub-screens
  static const int _phasesBranchIndex = 4;
  static const int _rundownBranchIndex = 5;
  static const int _vendorsBranchIndex = 6;
  static const int _settingsBranchIndex = 7;

  /// Returns the bottom nav index (0-4) based on the current branch.
  int get _currentNavIndex {
    final branchIndex = widget.navigationShell.currentIndex;
    if (branchIndex >= _phasesBranchIndex) {
      // Any "More" sub-screen highlights the "More" nav item
      return _moreNavIndex;
    }
    return branchIndex;
  }

  void _onNavTap(int index) {
    if (index == _moreNavIndex) {
      _showMoreMenu();
    } else {
      // Navigate to the corresponding branch
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }

  void _showMoreMenu() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _MoreMenuSheet(
        currentBranchIndex: widget.navigationShell.currentIndex,
      ),
    ).then((result) {
      // Navigate only if a valid route was returned (user tapped an option)
      if (result != null && mounted) {
        switch (result) {
          case 'phases':
            widget.navigationShell.goBranch(_phasesBranchIndex);
            break;
          case 'rundown':
            widget.navigationShell.goBranch(_rundownBranchIndex);
            break;
          case 'vendors':
            widget.navigationShell.goBranch(_vendorsBranchIndex);
            break;
          case 'settings':
            widget.navigationShell.goBranch(_settingsBranchIndex);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NeoBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        items: const [
          NeoBottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          NeoBottomNavItem(icon: Icons.check_circle, label: 'Tasks'),
          NeoBottomNavItem(icon: Icons.account_balance_wallet, label: 'Budget'),
          NeoBottomNavItem(icon: Icons.people, label: 'Guests'),
          NeoBottomNavItem(icon: Icons.more_horiz, label: 'More'),
        ],
      ),
    );
  }
}

/// The "More" menu bottom sheet content.
///
/// Shows navigation options for Phases, Rundown, Vendors, and Settings.
/// Returns the selected route key via Navigator.pop, or null if dismissed.
class _MoreMenuSheet extends StatelessWidget {
  const _MoreMenuSheet({
    required this.currentBranchIndex,
  });

  final int currentBranchIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(AppTheme.shadowOffset, AppTheme.shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.darkGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'More',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _MoreMenuItem(
            icon: Icons.timeline,
            label: 'Phases',
            isActive: currentBranchIndex == 4,
            onTap: () => Navigator.of(context).pop('phases'),
          ),
          _MoreMenuItem(
            icon: Icons.schedule,
            label: 'Rundown',
            isActive: currentBranchIndex == 5,
            onTap: () => Navigator.of(context).pop('rundown'),
          ),
          _MoreMenuItem(
            icon: Icons.store,
            label: 'Vendors',
            isActive: currentBranchIndex == 6,
            onTap: () => Navigator.of(context).pop('vendors'),
          ),
          _MoreMenuItem(
            icon: Icons.settings,
            label: 'Settings',
            isActive: currentBranchIndex == 7,
            onTap: () => Navigator.of(context).pop('settings'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// A single item in the "More" menu.
class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppTheme.pink.withValues(alpha: 0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? AppTheme.pink : AppTheme.darkGray,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppTheme.pink : AppTheme.black,
                ),
              ),
              const Spacer(),
              if (isActive)
                const Icon(
                  Icons.check,
                  color: AppTheme.pink,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
