import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/welcome_page.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
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
    try {
      final all = await CurriculumRemoteDataSource().getSubjects();
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
        showNotificationIcon: false,
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: Colors.red.shade100,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Q&A'),
        ],
      ),
      body: _index == 0 ? _subjectsTab() : const TeacherQaPage(),
    );
  }

  Widget _subjectsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadSubjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _subjects.length,
        itemBuilder: (context, i) {
          final s = _subjects[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.school, color: Colors.blue.shade800),
              ),
              title: Text(
                s.subjectName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              subtitle: Text('Grade ${s.gradeLevel ?? ''}'),
              trailing: const Icon(Icons.chevron_right),
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
          );
        },
      ),
    );
  }
}
