import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_section_header.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/curriculum/application/curriculum_providers.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_detail_shell_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicListPage extends ConsumerStatefulWidget {
  const TopicListPage({
    super.key,
    required this.chapterId,
    required this.chapterName,
    required this.subjectId,
    this.isStudent = true,
  });

  final String chapterId;
  final String chapterName;
  final String subjectId;
  final bool isStudent;

  @override
  ConsumerState<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends ConsumerState<TopicListPage> {
  List<TopicModel> _topics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final topics =
          await ref.read(curriculumRemoteDataSourceProvider).getTopicsByChapter(widget.chapterId);
      setState(() {
        _topics = topics;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: widget.chapterName,
        subtitle: '${_topics.length} topics',
        showNotificationIcon: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: widget.isStudent
          ? null
          : FloatingActionButton.extended(
              backgroundColor: FuturexColors.primary,
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopicFormPage(chapterId: widget.chapterId),
                  ),
                );
                if (ok == true) _load();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Topic'),
            ),
      body: _loading
          ? const FuturexLoadingBody(message: 'Loading topics...')
          : _topics.isEmpty
              ? const FuturexEmptyState(
                  title: 'No topics yet',
                  message: 'Topics for this chapter will appear here.',
                  icon: Icons.topic_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: FuturexColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const FuturexSectionHeader(
                        title: 'Topics',
                        subtitle: 'Open a topic to start learning',
                      ),
                      for (var i = 0; i < _topics.length; i++)
                        FuturexTopicCard(
                          title: _topics[i].topicName,
                          index: i + 1,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TopicDetailShellPage(
                                topicId: _topics[i].id,
                                topicName: _topics[i].topicName,
                                isStudent: widget.isStudent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
