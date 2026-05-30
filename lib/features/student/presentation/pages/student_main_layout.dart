import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/core/widgets/futurex/student_shell_bottom_bar.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/welcome_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/bookmarks_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/notifications_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_search_page.dart';
import 'package:finalyearproject/features/profile/presentation/pages/profile_page.dart';
import 'package:finalyearproject/features/student/presentation/pages/student_dashboard_page.dart';
import 'package:finalyearproject/features/student/presentation/widgets/student_drawer.dart';
import 'package:finalyearproject/shared/providers/grade_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentMainLayout extends ConsumerStatefulWidget {
  const StudentMainLayout({super.key});

  @override
  ConsumerState<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends ConsumerState<StudentMainLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tabIndex = 0;

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  String get _appBarTitle {
    switch (_tabIndex) {
      case 0:
        final user = ref.watch(authProvider).user;
        return 'Hello, ${user?.firstName ?? 'Student'}';
      case 1:
        return 'Search';
      case 2:
        return 'Saved';
      case 3:
        return 'Profile';
      default:
        return 'Entrance Exam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final grade = ref.watch(selectedGradeProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: StudentDrawer(onLogout: _logout),
      appBar: _tabIndex == 3
          ? null
          : GradientAppBar(
              title: _appBarTitle,
              subtitle: _tabIndex == 0 ? 'Grade $grade · Your learning hub' : null,
              showNotificationIcon: _tabIndex == 0,
              onNotificationPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ),
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              implyLeading: false,
            ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          StudentDashboardPage(
            bottomInset: studentShellBottomInset(context),
          ),
          const TopicSearchPage(embedded: true),
          BookmarksPage(
            embedded: true,
            bottomInset: studentShellBottomInset(context),
          ),
          ProfilePage(
            embedded: true,
            bottomInset: studentShellBottomInset(context),
          ),
        ],
      ),
      bottomNavigationBar: StudentShellBottomBar(
        currentIndex: _tabIndex,
        onIndexChanged: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}
