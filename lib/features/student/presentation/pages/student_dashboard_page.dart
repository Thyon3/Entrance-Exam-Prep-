import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
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

    if (_loading) return const FuturexLoadingBody();

    final pct = _gradeProgress is Map
        ? (_gradeProgress['completionPercentage'] as num?)?.toDouble()
        : null;
    final days = _streak is Map ? (_streak['currentStreak'] as num?)?.toInt() : null;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _bannerCard(pct, days),
              const SizedBox(height: 8),
              const Text(
                'My Subjects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FuturexColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              if (_subjects.isEmpty)
                const FuturexEmptyState(
                  title: 'No subjects yet',
                  message: 'Subjects for your grade will appear here.',
                  icon: Icons.school_outlined,
                ),
              for (final s in _subjects)
                FuturexSubjectCard(
                  title: s.subjectName,
                  subtitle: s.stream != null ? 'Stream: ${s.stream}' : null,
                  progress: s.progressPercent,
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
              const SizedBox(height: 88),
            ],
          ),
        ),
        const Positioned(right: 16, bottom: 16, child: StudentChatBot()),
      ],
    );
  }

  Widget _bannerCard(double? pct, int? days) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your progress',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${pct?.toStringAsFixed(0) ?? '0'}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Grade completion',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.24)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Streak',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${days ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'days learning',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
