import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_concept_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_exam_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_exercise_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_objectives_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_qa_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_quiz_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_reports_page.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_video_page.dart';
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

class _TopicDetailShellPageState extends State<TopicDetailShellPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  dynamic _eligibility;
  bool _completing = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    const learningCount = 6;
    final count = learningCount + 1 + (widget.isStudent ? 1 : 0);
    _tabs = TabController(length: count, vsync: this);
    if (widget.isStudent) _loadEligibility();
  }

  Future<void> _loadEligibility() async {
    try {
      final data = await EngagementRemoteDataSource()
          .getTopicEligibility(widget.topicId);
      setState(() => _eligibility = data);
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

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<Widget> get _tabPages => [
        TopicObjectivesPage(topicId: widget.topicId, isStudent: widget.isStudent),
        TopicConceptPage(topicId: widget.topicId, isStudent: widget.isStudent),
        TopicVideoPage(topicId: widget.topicId, isStudent: widget.isStudent),
        TopicExercisePage(topicId: widget.topicId, isStudent: widget.isStudent),
        TopicQuizPage(topicId: widget.topicId, isStudent: widget.isStudent),
        TopicExamPage(topicId: widget.topicId, isStudent: widget.isStudent),
        TopicQaPage(topicId: widget.topicId, isStudent: widget.isStudent),
        if (widget.isStudent) TopicReportsPage(topicId: widget.topicId),
      ];

  List<Tab> get _tabLabels => [
        const Tab(text: 'Objectives'),
        const Tab(text: 'Notes'),
        const Tab(text: 'Videos'),
        const Tab(text: 'Exercise'),
        const Tab(text: 'Quiz'),
        const Tab(text: 'Exam'),
        const Tab(text: 'Q&A'),
        if (widget.isStudent) const Tab(text: 'Reports'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: widget.topicName,
        showNotificationIcon: false,
      ),
      body: Column(
        children: [
          if (widget.isStudent) _completionBar(),
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: FuturexColors.primary,
              unselectedLabelColor: FuturexColors.textSecondary,
              indicatorColor: FuturexColors.primary,
              tabs: _tabLabels,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: _tabPages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _completionBar() {
    final canComplete =
        _eligibility is Map && (_eligibility['canMarkComplete'] == true);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _message!,
                style: TextStyle(
                  color: _message!.contains('complete')
                      ? FuturexColors.success
                      : FuturexColors.error,
                  fontSize: 13,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: canComplete && !_completing ? _markComplete : null,
            child: _completing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Mark topic complete'),
          ),
        ],
      ),
    );
  }
}
