import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_detail_shell_page.dart';
import 'package:flutter/material.dart';

class TopicSearchPage extends StatefulWidget {
  const TopicSearchPage({super.key});

  @override
  State<TopicSearchPage> createState() => _TopicSearchPageState();
}

class _TopicSearchPageState extends State<TopicSearchPage> {
  final _query = TextEditingController();
  List<TopicModel> _results = [];
  bool _searching = false;

  Future<void> _search() async {
    if (_query.text.trim().length < 2) return;
    setState(() => _searching = true);
    try {
      final list = await CurriculumRemoteDataSource().searchTopics(_query.text.trim());
      setState(() {
        _results = list;
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const GradientAppBar(title: 'Search topics', showNotificationIcon: false),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.blue),
                Expanded(
                  child: TextField(
                    controller: _query,
                    decoration: const InputDecoration(
                      hintText: 'Search topics...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.arrow_forward)),
              ],
            ),
          ),
          if (_searching) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final t = _results[i];
                return FuturexSimpleListCard(
                  title: t.topicName,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicDetailShellPage(
                        topicId: t.id,
                        topicName: t.topicName,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
