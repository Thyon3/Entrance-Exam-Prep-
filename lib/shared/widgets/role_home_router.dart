import 'package:finalyearproject/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:finalyearproject/features/auth/domain/auth_models.dart';
import 'package:finalyearproject/features/student/presentation/pages/student_main_layout.dart';
import 'package:finalyearproject/features/teacher/presentation/pages/teacher_main_layout.dart';
import 'package:flutter/material.dart';

class RoleHomeRouter extends StatelessWidget {
  const RoleHomeRouter({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    switch (user.role.toLowerCase()) {
      case 'admin':
        return const AdminDashboardPage();
      case 'teacher':
        return const TeacherMainLayout();
      default:
        return const StudentMainLayout();
    }
  }
}
