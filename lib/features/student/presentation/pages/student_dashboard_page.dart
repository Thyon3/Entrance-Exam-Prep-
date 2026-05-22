import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_section_header.dart';
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
  const StudentDashboardPage({super.key, this.bottomInset = 0});

  final double bottomInset;

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

    final grade = ref.watch(selectedGradeProvider);
    final pct = _gradeProgress is Map
        ? (_gradeProgress['completionPercentage'] as num?)?.toDouble()
        : null;
    final days = _streak is Map ? (_streak['currentStreak'] as num?)?.toInt() : null;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          color: FuturexColors.primary,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, widget.bottomInset + 24),
            children: [
              _statsRow(pct, days, grade),
              FuturexSectionHeader(
                title: 'My subjects',
                subtitle: _subjects.isEmpty
                    ? 'No subjects for Grade $grade yet'
                    : '${_subjects.length} subject${_subjects.length == 1 ? '' : 's'} · Grade $grade',
              ),
              if (_subjects.isEmpty)
                FuturexEmptyState(
                  title: 'No subjects yet',
                  message:
                      'Try another grade using the selector below, or pull to refresh.',
                  icon: Icons.school_outlined,
                  onAction: _load,
                )
              else
                for (final s in _subjects)
                  FuturexSubjectCard(
                    title: s.subjectName,
                    subtitle: s.stream ?? 'Grade $grade',
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
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: widget.bottomInset + 16,
          child: const StudentChatBot(),
        ),
      ],
    );
  }

  Widget _statsRow(double? pct, int? days, String grade) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: _statCard(
            icon: Icons.trending_up_rounded,
            label: 'Grade $grade',
            value: '${pct?.toStringAsFixed(0) ?? '0'}%',
            hint: 'Completion',
            colors: [FuturexColors.gradientStart, FuturexColors.gradientEnd],
          )),
          const SizedBox(width: 12),
          Expanded(child: _statCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${days ?? 0}',
            hint: 'Days active',
            colors: [const Color(0xFFE65100), const Color(0xFFBF360C)],
          )),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String hint,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(
            hint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
