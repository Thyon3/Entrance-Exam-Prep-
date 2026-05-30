import 'dart:async';
import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_section_header.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
import 'package:finalyearproject/features/ai/presentation/widgets/student_chat_bot.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/chapter_list_page.dart';
import 'package:finalyearproject/features/student/application/student_dashboard_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(studentDashboardProvider);
    final grade = ref.watch(selectedGradeProvider);

    // Listen to grade changes to reload dashboard
    ref.listen(selectedGradeProvider, (_, __) {
      ref.read(studentDashboardProvider.notifier).load();
    });

    if (dashboard.isLoading && dashboard.subjects.isEmpty) {
      return const FuturexLoadingBody();
    }

    if (dashboard.error != null && dashboard.subjects.isEmpty) {
      return Center(
        child: FuturexErrorState(
          title: 'Oops! Something went wrong',
          message: dashboard.error!,
          onRetry: () => ref.read(studentDashboardProvider.notifier).load(),
        ),
      );
    }

    final pct = dashboard.gradeProgress is Map
        ? (dashboard.gradeProgress['completionPercentage'] as num?)?.toDouble()
        : null;
    final days = dashboard.streak is Map ? (dashboard.streak['currentStreak'] as num?)?.toInt() : null;
    final longest = dashboard.streak is Map ? (dashboard.streak['longestStreak'] as num?)?.toInt() : null;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => ref.read(studentDashboardProvider.notifier).load(),
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
                child: _buildCompactStats(pct, days, longest, grade),
              ),
              const SizedBox(height: 8),

              // ── My Subjects ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FuturexSectionHeader(
                  title: 'My subjects',
                  subtitle: dashboard.subjects.isEmpty
                      ? 'No subjects for Grade $grade yet'
                      : '${dashboard.subjects.length} subject${dashboard.subjects.length == 1 ? '' : 's'} · Grade $grade',
                ),
              ),
              if (dashboard.subjects.isEmpty && !dashboard.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FuturexEmptyState(
                    title: 'No subjects yet',
                    message: 'Try selecting another grade from the drawer menu, or pull to refresh.',
                    icon: Icons.school_outlined,
                    onAction: () => ref.read(studentDashboardProvider.notifier).load(),
                  ),
                )
              else
                for (final s in dashboard.subjects)
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
          child: const StudentChatBot(),
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

  Widget _buildCompactStats(double? pct, int? days, int? longest, String grade) {
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
                  streakData: ref.read(studentDashboardProvider).streak,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
