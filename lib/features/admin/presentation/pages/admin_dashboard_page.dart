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
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Admin sections')),
            _tile(0, Icons.people, 'Manage users'),
            _tile(1, Icons.school, 'Manage courses'),
            _tile(2, Icons.forum, 'Discussion & issues'),
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

  Widget _tile(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: _section == index,
      onTap: () {
        setState(() => _section = index);
        Navigator.pop(context);
      },
    );
  }
}
