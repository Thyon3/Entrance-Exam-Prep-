import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/admin/presentation/pages/admin_courses_page.dart';
import 'package:finalyearproject/features/admin/presentation/pages/admin_users_page.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/welcome_page.dart';
import 'package:finalyearproject/features/profile/presentation/pages/profile_page.dart';
import 'package:finalyearproject/features/teacher/presentation/pages/teacher_qa_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _section = 0;

  static const _sections = [
    (Icons.people_rounded, 'Manage users'),
    (Icons.school_rounded, 'Manage courses'),
    (Icons.forum_rounded, 'Discussion & issues'),
  ];

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: 'Admin Console',
        subtitle: _sections[_section].$2,
        showNotificationIcon: false,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        implyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        width: 300,
        backgroundColor: FuturexColors.scaffoldBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.paddingOf(context).top + 20,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [FuturexColors.gradientStart, FuturexColors.gradientEnd],
                ),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [
                  for (var i = 0; i < _sections.length; i++)
                    _drawerTile(i, _sections[i].$1, _sections[i].$2),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _section,
        children: const [
          AdminUsersPage(),
          AdminCoursesPage(),
          TeacherQaPage(),
        ],
      ),
    );
  }

  Widget _drawerTile(int index, IconData icon, String label) {
    final selected = _section == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: selected ? FuturexColors.primary.withValues(alpha: 0.1) : null,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (selected ? FuturexColors.primary : Colors.grey)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: selected ? FuturexColors.primary : FuturexColors.textSecondary,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? FuturexColors.primaryDark : FuturexColors.textPrimary,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle_rounded, color: FuturexColors.primary, size: 20)
            : null,
        onTap: () {
          setState(() => _section = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
