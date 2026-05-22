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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: 'Admin Console',
        showNotificationIcon: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        width: 280,
        child: ListView(
          padding: const EdgeInsets.only(top: 48),
          children: [
            _drawerTile(0, Icons.people, 'Manage users'),
            _drawerTile(1, Icons.school, 'Manage courses'),
            _drawerTile(2, Icons.forum, 'Discussion & issues'),
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
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
      selected: _section == index,
      onTap: () {
        setState(() => _section = index);
        Navigator.pop(context);
      },
    );
  }
}
