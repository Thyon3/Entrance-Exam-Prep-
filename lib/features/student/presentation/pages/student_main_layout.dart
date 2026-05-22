import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/welcome_page.dart';
import 'package:finalyearproject/features/profile/presentation/pages/profile_page.dart';
import 'package:finalyearproject/features/student/presentation/pages/student_dashboard_page.dart';
import 'package:finalyearproject/features/student/presentation/widgets/student_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentMainLayout extends ConsumerStatefulWidget {
  const StudentMainLayout({super.key});

  @override
  ConsumerState<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends ConsumerState<StudentMainLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      drawer: StudentDrawer(onLogout: _logout),
      appBar: AppBar(
        title: Text('Hello, ${user?.firstName ?? 'Student'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        ],
      ),
      body: const StudentDashboardPage(),
    );
  }
}
