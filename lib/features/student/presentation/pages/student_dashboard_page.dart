import 'dart:async';
import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_section_header.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
import 'package:finalyearproject/features/ai/presentation/widgets/student_chat_bot.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/curriculum/application/curriculum_providers.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/chapter_list_page.dart';
import 'package:finalyearproject/features/engagement/application/engagement_providers.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:finalyearproject/features/student/presentation/pages/streak_detail_page.dart';
import 'package:finalyearproject/shared/providers/grade_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Banner carousel
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  static const _banners = [
    'lib/assets/images/banner_study_1.png',
    'lib/assets/images/banner_study_2.png',
    'lib/assets/images/banner_study_3.png',
  ];

  static const _bannerTitles = [
    'Study Smart, Score High',
    'Excellence Starts Today',
    'Your Future Begins Now',
  ];

  static const _bannerSubtitles = [
    'Consistent daily practice leads to exam success.',
    'Unlock your full potential with focused learning.',
    'Prepare today for the entrance exam of tomorrow.',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final grade = ref.read(selectedGradeProvider);
      final user = ref.read(authProvider).user;
      final curriculum = ref.read(curriculumRemoteDataSourceProvider);
      final engagement = ref.read(engagementRemoteDataSourceProvider);
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
        if (s.stream != null && user?.stream != null && s.stream != user!.stream) return false;
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
    final longest = _streak is Map ? (_streak['longestStreak'] as num?)?.toInt() : null;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          color: FuturexColors.primary,
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 24, 0, widget.bottomInset + 24),
            children: [
              // ── Banner Carousel ──────────────────────────────────────────
              _buildBannerCarousel(),
              const SizedBox(height: 16),

              // ── Compact Stat Cards ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCompactStats(pct, days, grade),
              ),
              const SizedBox(height: 8),

              // ── My Subjects ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FuturexSectionHeader(
                  title: 'My subjects',
                  subtitle: _subjects.isEmpty
                      ? 'No subjects for Grade $grade yet'
                      : '${_subjects.length} subject${_subjects.length == 1 ? '' : 's'} · Grade $grade',
                ),
              ),
              if (_subjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FuturexEmptyState(
                    title: 'No subjects yet',
                    message: 'Try selecting another grade from the drawer menu, or pull to refresh.',
                    icon: Icons.school_outlined,
                    onAction: _load,
                  ),
                )
              else
                for (final s in _subjects)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FuturexSubjectCard(
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
                  ),
            ],
          ),
        ),

        // ── Floating Chatbot FAB (above bottom nav) ──────────────────────
        Positioned(
          right: 16,
          bottom: 8,
          child: StudentChatBot(),
        ),
      ],
    );
  }

  Widget _buildBannerCarousel() {
    return Stack(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, i) {
              return _buildBannerSlide(i);
            },
          ),
        ),
        // Dots indicator
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _bannerIndex == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _bannerIndex == i ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSlide(int i) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FuturexColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.asset(
              _banners[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FuturexColors.gradientStart,
                      FuturexColors.gradientEnd,
                    ],
                  ),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 64),
              ),
            ),
            // Gradient overlay for text
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Text overlay
            Positioned(
              left: 18,
              bottom: 26,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _bannerTitles[i],
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bannerSubtitles[i],
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStats(double? pct, int? days, String grade) {
    return Row(
      children: [
        // Progress card (compact)
        Expanded(
          child: _compactStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Grade $grade Progress',
            value: '${pct?.toStringAsFixed(0) ?? '0'}%',
            colors: [FuturexColors.gradientStart, FuturexColors.gradientEnd],
            onTap: null,
          ),
        ),
        const SizedBox(width: 10),
        // Streak card (tappable → detail page)
        Expanded(
          child: _compactStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Day Streak',
            value: '${days ?? 0}',
            colors: [const Color(0xFFFF9500), const Color(0xFFFF3B00)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreakDetailPage(
                  currentStreak: days ?? 0,
                  longestStreak: (longest ?? days ?? 0),
                  streakData: _streak,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int? get longest => _streak is Map ? (_streak['longestStreak'] as num?)?.toInt() : null;

  Widget _compactStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> colors,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.7), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
