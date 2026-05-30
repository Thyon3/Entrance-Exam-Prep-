import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:flutter/material.dart';

/// Bottom area: grade selector + main navigation for the student shell.
class StudentShellBottomBar extends StatelessWidget {
  const StudentShellBottomBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFF0F172A).withValues(alpha: 0.06);
    final indicatorColor = isDark
        ? FuturexColors.primary.withValues(alpha: 0.22)
        : FuturexColors.primary.withValues(alpha: 0.08);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NavigationBar(
                height: 64,
                backgroundColor: Colors.transparent,
                elevation: 0,
                indicatorColor: indicatorColor,
                selectedIndex: currentIndex,
                onDestinationSelected: onIndexChanged,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_outline),
                    selectedIcon: Icon(Icons.bookmark_rounded),
                    label: 'Saved',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reserve space above the student bottom shell (nav only).
double studentShellBottomInset(BuildContext context) {
  final bottom = MediaQuery.paddingOf(context).bottom;
  return 88 + bottom;
}
