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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GradeSelectorBar(),
        SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: FuturexColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
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
                indicatorColor: FuturexColors.primary.withValues(alpha: 0.08),
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

/// Reserve space above the student bottom shell (grade bar + nav).
double studentShellBottomInset(BuildContext context) {
  final bottom = MediaQuery.paddingOf(context).bottom;
  return 172 + bottom;
}
