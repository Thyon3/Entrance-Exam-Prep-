import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/welcome_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/notifications_page.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: StudentDrawer(onLogout: _logout),
      appBar: GradientAppBar(
        title: 'Hello, ${user?.firstName ?? 'Student'}',
        showNotificationIcon: true,
        onNotificationPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: const StudentDashboardPage(),
    );
  }
}
