import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/grade_selector_bar.dart';
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
    return Material(
      color: FuturexColors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GradeSelectorBar(),
            NavigationBar(
              height: 64,
              backgroundColor: FuturexColors.surface,
              indicatorColor: FuturexColors.primary.withValues(alpha: 0.12),
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
          ],
        ),
      ),
    );
  }
}

/// Reserve space above the student bottom shell (grade bar + nav).
double studentShellBottomInset(BuildContext context) {
  final bottom = MediaQuery.paddingOf(context).bottom;
  return 152 + bottom;
}
