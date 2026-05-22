import 'package:finalyearproject/core/constants/app_colors.dart';
import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/ai/presentation/widgets/student_chat_bot.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/chapter_list_page.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:finalyearproject/shared/providers/grade_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  List<SubjectModel> _subjects = [];
  dynamic _gradeProgress;
  dynamic _streak;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final grade = ref.read(selectedGradeProvider);
      final user = ref.read(authProvider).user;
      final curriculum = CurriculumRemoteDataSource();
      final engagement = EngagementRemoteDataSource();
      final all = await curriculum.getSubjects();
      final progressList = await engagement.getSubjectProgress();
      final progressMap = <String, dynamic>{};
      for (final p in progressList) {
        if (p is Map) {
          final sid = (p['subjectId']?['_id'] ?? p['subjectId'])?.toString();
          if (sid != null) progressMap[sid] = p;
        }
      }
      final filtered = all.where((s) {
        if (!gradeMatchesFilter(s.gradeLevel, grade)) return false;
        if (s.stream != null && user?.stream != null && s.stream != user!.stream) {
          return false;
        }
        return true;
      }).map((s) {
        final p = progressMap[s.id];
        final pct = p is Map ? (p['completionPercentage'] as num?)?.toDouble() : null;
        return SubjectModel(
          id: s.id,
          subjectName: s.subjectName,
          gradeLevel: s.gradeLevel,
          stream: s.stream,
          progressPercent: pct,
        );
      }).toList();
      final gradeProg = await engagement.getGradeProgress(grade);
      final streak = await engagement.getLearningStreak(gradeLevel: grade);
      setState(() {
        _subjects = filtered;
        _gradeProgress = gradeProg;
        _streak = streak;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedGradeProvider, (_, __) => _load());
    if (_loading) return const LoadingView();
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _statsRow(),
              const SizedBox(height: 20),
              Text('Subjects', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (_subjects.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No subjects for this grade yet.'),
                  ),
                )
              else
                ..._subjects.map((s) => _subjectCard(context, s)),
              const SizedBox(height: 80),
            ],
          ),
        ),
        const Positioned(right: 16, bottom: 16, child: StudentChatBot()),
      ],
    );
  }

  Widget _statsRow() {
    final pct = _gradeProgress is Map
        ? (_gradeProgress['completionPercentage'] as num?)?.toDouble()
        : null;
    final days = _streak is Map ? (_streak['currentStreak'] as num?)?.toInt() : null;
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grade progress', style: TextStyle(color: AppColors.textSecondary)),
                  Text('${pct?.toStringAsFixed(0) ?? '0'}%', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Learning streak', style: TextStyle(color: AppColors.textSecondary)),
                  Text('${days ?? 0} days', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _subjectCard(BuildContext context, SubjectModel s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(s.subjectName),
        subtitle: LinearProgressIndicator(
          value: (s.progressPercent ?? 0) / 100,
          backgroundColor: AppColors.outline,
          color: AppColors.accent,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterListPage(
              subjectId: s.id,
              subjectName: s.subjectName,
              isStudent: true,
            ),
          ),
        ),
      ),
    );
  }
}
