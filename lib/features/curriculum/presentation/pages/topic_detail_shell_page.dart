import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_concept_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_exam_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_exercise_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_objectives_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_qa_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_quiz_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_reports_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_video_page.dart';
import 'package:finalyearproject/features/content/presentation/widgets/topic_module_scaffold.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class TopicDetailShellPage extends StatefulWidget {
  const TopicDetailShellPage({
    super.key,
    required this.topicId,
    required this.topicName,
    this.isStudent = true,
  });

  final String topicId;
  final String topicName;
  final bool isStudent;

  @override
  State<TopicDetailShellPage> createState() => _TopicDetailShellPageState();
}

class _TopicDetailShellPageState extends State<TopicDetailShellPage> {
  dynamic _eligibility;
  bool _completing = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    if (widget.isStudent) _loadEligibility();
  }

  Future<void> _loadEligibility() async {
    try {
      final data =
          await EngagementRemoteDataSource().getTopicEligibility(widget.topicId);
      if (mounted) setState(() => _eligibility = data);
    } catch (_) {}
  }

  Future<void> _markComplete() async {
    setState(() {
      _completing = true;
      _message = null;
    });
    try {
      await EngagementRemoteDataSource().markTopicComplete(widget.topicId);
      await _loadEligibility();
      setState(() => _message = 'Topic marked complete.');
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      setState(() => _completing = false);
    }
  }

  void _openModule({
    required String title,
    required TopicModuleStyle style,
    required Widget child,
    String? subtitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicModuleScaffold(
          topicName: widget.topicName,
          moduleTitle: title,
          moduleSubtitle: subtitle,
          headerColor: style.color,
          child: child,
        ),
      ),
    );
  }

  List<({String title, String subtitle, TopicModuleStyle style, Widget child})>
      get _modules {
    final id = widget.topicId;
    final student = widget.isStudent;
    return [
      (
        title: 'Objectives',
        subtitle: 'What you will learn',
        style: TopicModuleStyle.objectives,
        child: TopicObjectivesPage(topicId: id, isStudent: student),
      ),
      (
        title: 'Notes',
        subtitle: 'Concepts & explanations',
        style: TopicModuleStyle.notes,
        child: TopicConceptPage(topicId: id, isStudent: student),
      ),
      (
        title: 'Videos',
        subtitle: 'Watch in the app',
        style: TopicModuleStyle.videos,
        child: TopicVideoPage(
          topicId: id,
          isStudent: student,
          topicName: widget.topicName,
        ),
      ),
      (
        title: 'Exercise',
        subtitle: 'Practice problems',
        style: TopicModuleStyle.exercise,
        child: TopicExercisePage(topicId: id, isStudent: student),
      ),
      (
        title: 'Quiz',
        subtitle: 'Quick check',
        style: TopicModuleStyle.quiz,
        child: TopicQuizPage(topicId: id, isStudent: student),
      ),
      (
        title: 'Exam',
        subtitle: 'Formal assessment',
        style: TopicModuleStyle.exam,
        child: TopicExamPage(topicId: id, isStudent: student),
      ),
      (
        title: 'Q&A',
        subtitle: 'Ask & discuss',
        style: TopicModuleStyle.qa,
        child: TopicQaPage(topicId: id, isStudent: student),
      ),
      if (student)
        (
          title: 'Reports',
          subtitle: 'Flag issues',
          style: TopicModuleStyle.reports,
          child: TopicReportsPage(topicId: id),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final modules = _modules;

    return Scaffold(
      backgroundColor: FuturexColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 168,
            pinned: true,
            stretch: true,
            backgroundColor: FuturexColors.gradientEnd,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              title: Text(
                widget.topicName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FuturexColors.gradientStart,
                      FuturexColors.gradientEnd,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: 20,
                      child: Icon(
                        Icons.school_rounded,
                        size: 140,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 52,
                      child: Text(
                        'Learning hub',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isStudent)
            SliverToBoxAdapter(child: _completionBar()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Choose a module',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final m = modules[index];
                  return TopicModuleCard(
                    title: m.title,
                    subtitle: m.subtitle,
                    style: m.style,
                    onTap: () => _openModule(
                      title: m.title,
                      style: m.style,
                      subtitle: m.subtitle,
                      child: m.child,
                    ),
                  );
                },
                childCount: modules.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested path',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...modules.take(5).map((m) {
                    return TopicModuleListTile(
                      title: m.title,
                      subtitle: m.subtitle,
                      style: m.style,
                      onTap: () => _openModule(
                        title: m.title,
                        style: m.style,
                        subtitle: m.subtitle,
                        child: m.child,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completionBar() {
    if (_eligibility == null) return const SizedBox.shrink();
    if (_eligibility is! Map) return const SizedBox.shrink();

    final eligible = _eligibility['eligible'] == true;
    final displayMsg = _message ?? _eligibility['message'] as String? ?? '';
    final isDone =
        _message != null && _message!.toLowerCase().contains('complete');

    Color accent;
    IconData icon;
    String headline;

    if (isDone) {
      accent = FuturexColors.success;
      icon = Icons.check_circle_rounded;
      headline = 'Topic completed';
    } else if (eligible) {
      accent = FuturexColors.primary;
      icon = Icons.emoji_events_rounded;
      headline = 'Ready to complete';
    } else {
      accent = Colors.orange;
      icon = Icons.lock_outline_rounded;
      headline = 'Keep going';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FuturexColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Text(
                headline,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: accent,
                ),
              ),
            ],
          ),
          if (displayMsg.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              displayMsg,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ],
          if (eligible && !isDone) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !_completing ? _markComplete : null,
                icon: _completing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(_completing ? 'Saving...' : 'Mark topic complete'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
