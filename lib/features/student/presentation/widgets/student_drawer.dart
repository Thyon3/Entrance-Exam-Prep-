import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/bookmarks_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/my_reports_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/notifications_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_search_page.dart';
import 'package:finalyearproject/features/profile/presentation/pages/profile_page.dart';
import 'package:finalyearproject/shared/providers/grade_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentDrawer extends ConsumerWidget {
  const StudentDrawer({super.key, required this.onLogout});
  final VoidCallback onLogout;

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(selectedGradeProvider);
    final user = ref.watch(authProvider).user;

    return Drawer(
      width: 280,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  user?.firstName.isNotEmpty == true
                      ? user!.firstName[0].toUpperCase()
                      : 'E',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 2, color: Colors.blue.shade900)],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Entrance Exam Prep',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (user != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user.fullName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Select Grade', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gradeItems.map((g) {
                  final selected = grade == g;
                  return GestureDetector(
                    onTap: () => ref.read(selectedGradeProvider.notifier).setGrade(g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Grade $g',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _item(
                    context,
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.search,
                    label: 'Search topics',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TopicSearchPage()),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsPage()),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.bookmark_outline,
                    label: 'Bookmarks',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookmarksPage()),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.flag_outlined,
                    label: 'My reports',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyReportsPage()),
                      );
                    },
                  ),
                  _item(
                    context,
                    icon: Icons.logout,
                    label: 'Sign out',
                    onTap: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
