import 'package:finalyearproject/core/constants/app_colors.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/bookmarks_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/my_reports_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/notifications_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_search_page.dart';
import 'package:finalyearproject/shared/providers/grade_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentDrawer extends ConsumerWidget {
  const StudentDrawer({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(selectedGradeProvider);
    final user = ref.watch(authProvider).user;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(user?.fullName ?? 'Student', style: Theme.of(context).textTheme.titleLarge),
            Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
            const Divider(height: 24),
            const Text('Grade', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: gradeItems.map((g) {
                final selected = grade == g;
                return ChoiceChip(
                  label: Text('Grade $g'),
                  selected: selected,
                  onSelected: (_) => ref.read(selectedGradeProvider.notifier).setGrade(g),
                );
              }).toList(),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search topics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TopicSearchPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Bookmarks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('My reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReportsPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign out'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
