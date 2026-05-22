import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_detail_shell_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_form_page.dart';
import 'package:flutter/material.dart';

class TopicListPage extends StatefulWidget {
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
  State<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends State<TopicListPage> {
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
          await CurriculumRemoteDataSource().getTopicsByChapter(widget.chapterId);
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
        showNotificationIcon: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: widget.isStudent
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue.shade700,
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopicFormPage(chapterId: widget.chapterId),
                  ),
                );
                if (ok == true) _load();
              },
              child: const Icon(Icons.add),
            ),
      body: _loading
          ? const FuturexLoadingBody(message: 'Loading topics...')
          : _topics.isEmpty
              ? const FuturexEmptyState(
                  title: 'No topics yet',
                  message: 'Topics for this chapter will appear here.',
                  icon: Icons.topic_outlined,
                )
              : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _topics.length,
              itemBuilder: (context, i) {
                final t = _topics[i];
                return FuturexSimpleListCard(
                  title: t.topicName,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicDetailShellPage(
                        topicId: t.id,
                        topicName: t.topicName,
                        isStudent: widget.isStudent,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
