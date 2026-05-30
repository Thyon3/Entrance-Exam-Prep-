import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_section_header.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/welcome_page.dart';
import 'package:finalyearproject/features/curriculum/application/curriculum_providers.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/chapter_list_page.dart';
import 'package:finalyearproject/features/profile/presentation/pages/profile_page.dart';
import 'package:finalyearproject/features/teacher/presentation/pages/teacher_qa_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherMainLayout extends ConsumerStatefulWidget {
  const TeacherMainLayout({super.key});

  @override
  ConsumerState<TeacherMainLayout> createState() => _TeacherMainLayoutState();
}

class _TeacherMainLayoutState extends ConsumerState<TeacherMainLayout> {
  int _index = 0;
  List<SubjectModel> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _loading = true);
    try {
      final all = await ref.read(curriculumRemoteDataSourceProvider).getSubjects();
      setState(() {
        _subjects = all;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: _index == 0 ? 'Course Management' : 'Q&A & Issues',
        subtitle: _index == 0 && !_loading ? '${_subjects.length} subjects' : null,
        showNotificationIcon: false,
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: FuturexColors.primary.withValues(alpha: 0.12),
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: 'Q&A',
          ),
        ],
      ),
      body: _index == 0 ? _subjectsTab() : const TeacherQaPage(),
    );
  }

  Widget _subjectsTab() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: FuturexColors.primary),
      );
    }

    if (_subjects.isEmpty) {
      return Center(
        child: Text(
          'No subjects available',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubjects,
      color: FuturexColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FuturexSectionHeader(
            title: 'Subjects',
            subtitle: 'Select a subject to manage chapters',
          ),
          for (final s in _subjects)
            FuturexSubjectCard(
              title: s.subjectName,
              subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterListPage(
                    subjectId: s.id,
                    subjectName: s.subjectName,
                    isStudent: false,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
