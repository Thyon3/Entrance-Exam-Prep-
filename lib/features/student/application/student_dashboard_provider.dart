import 'dart:async';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/curriculum/application/curriculum_providers.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/engagement/application/engagement_providers.dart';
import 'package:finalyearproject/shared/providers/grade_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentDashboardState {
  const StudentDashboardState({
    this.subjects = const [],
    this.gradeProgress,
    this.streak,
    this.isLoading = true,
    this.error,
  });

  final List<SubjectModel> subjects;
  final dynamic gradeProgress;
  final dynamic streak;
  final bool isLoading;
  final String? error;

  StudentDashboardState copyWith({
    List<SubjectModel>? subjects,
    dynamic gradeProgress,
    dynamic streak,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StudentDashboardState(
      subjects: subjects ?? this.subjects,
      gradeProgress: gradeProgress ?? this.gradeProgress,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StudentDashboardNotifier extends StateNotifier<StudentDashboardState> {
  StudentDashboardNotifier(this.ref) : super(const StudentDashboardState()) {
    load();
  }

  final Ref ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final grade = ref.read(selectedGradeProvider);
      final user = ref.read(authProvider).user;
      final curriculum = ref.read(curriculumRemoteDataSourceProvider);
      final engagement = ref.read(engagementRemoteDataSourceProvider);

      final allSubjects = await curriculum.getSubjects();
      final progressList = await engagement.getSubjectProgress();
      
      final progressMap = <String, dynamic>{};
      for (final p in progressList) {
        if (p is Map) {
          final sid = (p['subjectId']?['_id'] ?? p['subjectId'])?.toString();
          if (sid != null) progressMap[sid] = p;
        }
      }

      final filtered = allSubjects.where((s) {
        if (!gradeMatchesFilter(s.gradeLevel, grade)) return false;
        final userStream = user?.stream;
        if (s.stream != null && userStream != null && s.stream != userStream) return false;
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

      state = state.copyWith(
        subjects: filtered,
        gradeProgress: gradeProg,
        streak: streak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool gradeMatchesFilter(String? itemGrade, String selectedGrade) {
    if (itemGrade == null) return false;
    return itemGrade.toString().toLowerCase().contains(selectedGrade.toLowerCase());
  }
}

final studentDashboardProvider =
    StateNotifierProvider<StudentDashboardNotifier, StudentDashboardState>((ref) {
  return StudentDashboardNotifier(ref);
});
